#!/usr/bin/env bash
set -euo pipefail

# ============================================================================
# Mac Migration Audit
# Pre-migration readiness check — compares installed state vs Brewfile.
# Run on your CURRENT Mac before migration.
# ============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
REPORT_FILE="${SCRIPT_DIR}/audit_report_${TIMESTAMP}.txt"

# Counters
TOTAL_CHECKS=0
COVERED=0
UNCOVERED=0

# --- Helpers ----------------------------------------------------------------

header() {
    local msg="$1"
    echo ""
    echo -e "\033[1;36m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo -e "\033[1;36m  ${msg}\033[0m"
    echo -e "\033[1;36m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
}

ok() { echo -e "  \033[1;32m✓\033[0m $1"; }
warn() { echo -e "  \033[1;33m!\033[0m $1"; }
miss() { echo -e "  \033[1;31m✗\033[0m $1"; }
info() { echo -e "  \033[0;37m·\033[0m $1"; }

# Tee everything to report file
exec > >(tee "$REPORT_FILE") 2>&1

echo -e "\033[1;34m╔════════════════════════════════════════╗\033[0m"
echo -e "\033[1;34m║    Mac Migration Audit Report          ║\033[0m"
echo -e "\033[1;34m║    $(date '+%Y-%m-%d %H:%M:%S')              ║\033[0m"
echo -e "\033[1;34m╚════════════════════════════════════════╝\033[0m"

# ============================================================================
# 1. System Info
# ============================================================================
header "1. System Information"

info "Hostname:  $(scutil --get ComputerName 2>/dev/null || hostname)"
info "Model:     $(sysctl -n hw.model 2>/dev/null || echo 'unknown')"
info "Chip:      $(sysctl -n machdep.cpu.brand_string 2>/dev/null || echo 'unknown')"
info "Memory:    $(( $(sysctl -n hw.memsize 2>/dev/null || echo 0) / 1073741824 )) GB"
info "macOS:     $(sw_vers -productVersion 2>/dev/null || echo 'unknown') ($(sw_vers -buildVersion 2>/dev/null || echo '?'))"
info "Disk:      $(df -h / | awk 'NR==2 {print $4 " free of " $2}')"

# ============================================================================
# 2. Brew Formulae
# ============================================================================
header "2. Homebrew Formulae"

if command -v brew &>/dev/null; then
    INSTALLED_FORMULAE=$(brew leaves | sort)
    BREWFILE_FORMULAE=$(grep '^brew ' "${SCRIPT_DIR}/Brewfile" 2>/dev/null | sed 's/brew "\([^"]*\)".*/\1/' | sort)

    IN_BREWFILE_NOT_INSTALLED=$(comm -23 <(echo "$BREWFILE_FORMULAE") <(echo "$INSTALLED_FORMULAE"))
    INSTALLED_NOT_IN_BREWFILE=$(comm -13 <(echo "$BREWFILE_FORMULAE") <(echo "$INSTALLED_FORMULAE"))
    IN_BOTH=$(comm -12 <(echo "$BREWFILE_FORMULAE") <(echo "$INSTALLED_FORMULAE"))

    FORMULAE_INSTALLED_COUNT=$(echo "$INSTALLED_FORMULAE" | grep -c . || true)
    FORMULAE_BREWFILE_COUNT=$(echo "$BREWFILE_FORMULAE" | grep -c . || true)
    FORMULAE_COVERED=$(echo "$IN_BOTH" | grep -c . || true)

    info "Installed (leaves): ${FORMULAE_INSTALLED_COUNT}"
    info "In Brewfile:        ${FORMULAE_BREWFILE_COUNT}"
    info "Covered:            ${FORMULAE_COVERED}"

    if [[ -n "$INSTALLED_NOT_IN_BREWFILE" ]]; then
        echo ""
        warn "Installed but NOT in Brewfile:"
        while IFS= read -r f; do
            miss "  $f"
            ((UNCOVERED++)) || true
            ((TOTAL_CHECKS++)) || true
        done <<< "$INSTALLED_NOT_IN_BREWFILE"
    fi

    if [[ -n "$IN_BREWFILE_NOT_INSTALLED" ]]; then
        echo ""
        warn "In Brewfile but NOT installed:"
        while IFS= read -r f; do
            warn "  $f (will be installed on new Mac)"
        done <<< "$IN_BREWFILE_NOT_INSTALLED"
    fi
else
    miss "Homebrew not installed"
fi

# ============================================================================
# 3. Brew Casks
# ============================================================================
header "3. Homebrew Casks"

if command -v brew &>/dev/null; then
    INSTALLED_CASKS=$(brew list --cask 2>/dev/null | sort)
    BREWFILE_CASKS=$(grep '^cask ' "${SCRIPT_DIR}/Brewfile" 2>/dev/null | sed 's/cask "\([^"]*\)".*/\1/' | sort)

    CASKS_INSTALLED_NOT_IN_BREWFILE=$(comm -13 <(echo "$BREWFILE_CASKS") <(echo "$INSTALLED_CASKS"))
    CASKS_IN_BOTH=$(comm -12 <(echo "$BREWFILE_CASKS") <(echo "$INSTALLED_CASKS"))

    CASKS_INSTALLED_COUNT=$(echo "$INSTALLED_CASKS" | grep -c . || true)
    CASKS_BREWFILE_COUNT=$(echo "$BREWFILE_CASKS" | grep -c . || true)
    CASKS_COVERED=$(echo "$CASKS_IN_BOTH" | grep -c . || true)

    info "Installed casks: ${CASKS_INSTALLED_COUNT}"
    info "In Brewfile:     ${CASKS_BREWFILE_COUNT}"
    info "Covered:         ${CASKS_COVERED}"

    if [[ -n "$CASKS_INSTALLED_NOT_IN_BREWFILE" ]]; then
        echo ""
        warn "Installed casks NOT in Brewfile:"
        while IFS= read -r c; do
            miss "  $c"
            ((UNCOVERED++)) || true
            ((TOTAL_CHECKS++)) || true
        done <<< "$CASKS_INSTALLED_NOT_IN_BREWFILE"
    fi
fi

# ============================================================================
# 4. Mac App Store Apps
# ============================================================================
header "4. Mac App Store Apps"

if command -v mas &>/dev/null; then
    MAS_INSTALLED=$(mas list 2>/dev/null | sort)
    MAS_COUNT=$(echo "$MAS_INSTALLED" | grep -c . || true)
    BREWFILE_MAS=$(grep '^mas ' "${SCRIPT_DIR}/Brewfile" 2>/dev/null || true)
    BREWFILE_MAS_COUNT=$(echo "$BREWFILE_MAS" | grep -c . || true)

    info "App Store apps installed: ${MAS_COUNT}"
    info "In Brewfile:              ${BREWFILE_MAS_COUNT}"

    if [[ "$BREWFILE_MAS_COUNT" -eq 0 ]] && [[ "$MAS_COUNT" -gt 0 ]]; then
        warn "No mas entries in Brewfile! Add these:"
        echo ""
        while IFS= read -r line; do
            APP_ID=$(echo "$line" | awk '{print $1}')
            APP_NAME=$(echo "$line" | sed 's/^[0-9]* *//' | sed 's/ *(.*//')
            miss "  mas \"${APP_NAME}\", id: ${APP_ID}"
            ((UNCOVERED++)) || true
            ((TOTAL_CHECKS++)) || true
        done <<< "$MAS_INSTALLED"
    fi
else
    miss "mas CLI not installed (brew install mas)"
fi

# ============================================================================
# 5. DMG/Manual Apps
# ============================================================================
header "5. Apps Not Managed by Homebrew or App Store"

# Get lists of managed apps
MAS_APPS=""
if command -v mas &>/dev/null; then
    MAS_APPS=$(mas list 2>/dev/null | sed 's/^[0-9]* *//' | sed 's/ *(.*//' | sort -u)
fi

# Get cask names from Brewfile (these are managed even if not yet installed)
BREWFILE_CASK_NAMES=$(grep '^cask ' "${SCRIPT_DIR}/Brewfile" 2>/dev/null | sed 's/cask "\([^"]*\)".*/\1/' | sort)
# Get mas app names from Brewfile
BREWFILE_MAS_NAMES=$(grep '^mas ' "${SCRIPT_DIR}/Brewfile" 2>/dev/null | sed 's/mas "\([^"]*\)".*/\1/' | sort)

ALL_APPS=$(ls /Applications/ 2>/dev/null | sed 's/\.app$//' | sort)
SYSTEM_APPS="Safari|Utilities|SF Symbols|Developer"

MANUAL_COUNT=0
while IFS= read -r app; do
    [[ -z "$app" ]] && continue
    echo "$app" | grep -qE "^(${SYSTEM_APPS})$" && continue

    # Check if managed by mas
    echo "$MAS_APPS" | grep -qi "^${app}$" 2>/dev/null && continue
    echo "$BREWFILE_MAS_NAMES" | grep -qi "^${app}$" 2>/dev/null && continue

    # Check if managed by brew cask (fuzzy: lowercase, dashes)
    APP_SLUG=$(echo "$app" | tr '[:upper:]' '[:lower:]' | tr ' ' '-')
    echo "$BREWFILE_CASK_NAMES" | grep -qi "^${APP_SLUG}$" 2>/dev/null && continue
    # Also check installed casks
    echo "$INSTALLED_CASKS" | grep -qi "^${APP_SLUG}$" 2>/dev/null && continue

    info "$app  (not in Brewfile)"
    ((MANUAL_COUNT++)) || true
done <<< "$ALL_APPS"

info "Total unmanaged apps: ${MANUAL_COUNT}"

# ============================================================================
# 6. Claude Code
# ============================================================================
header "6. Claude Code"

CLAUDE_DIR="$HOME/.claude"
if [[ -d "$CLAUDE_DIR" ]]; then
    ok "Claude Code directory exists"

    # Plugins
    if [[ -f "$CLAUDE_DIR/plugins/installed_plugins.json" ]]; then
        PLUGIN_COUNT=$(python3 -c "import json; d=json.load(open('$CLAUDE_DIR/plugins/installed_plugins.json')); print(len(d.get('plugins',[])))" 2>/dev/null || echo "?")
        info "Plugins installed: ${PLUGIN_COUNT}"
    fi

    # Settings
    for f in settings.json settings.local.json; do
        if [[ -f "$CLAUDE_DIR/$f" ]]; then
            ok "  $f exists"
        else
            warn "  $f not found"
        fi
    done

    # Memory dirs
    MEMORY_DIRS=$(find "$CLAUDE_DIR/projects" -name "memory" -type d 2>/dev/null | wc -l | tr -d ' ')
    info "Memory directories: ${MEMORY_DIRS}"

    # Total size (excluding large caches)
    CLAUDE_SIZE=$(du -sh "$CLAUDE_DIR" 2>/dev/null | awk '{print $1}')
    info "Total ~/.claude size: ${CLAUDE_SIZE}"
else
    miss "Claude Code not configured (~/.claude not found)"
fi

# ============================================================================
# 7. Editors
# ============================================================================
header "7. Editors (VS Code + Cursor)"

for editor_name in "VS Code" "Cursor"; do
    if [[ "$editor_name" == "VS Code" ]]; then
        cmd="code"
        settings_dir="$HOME/Library/Application Support/Code/User"
    else
        cmd="cursor"
        settings_dir="$HOME/Library/Application Support/Cursor/User"
    fi

    echo ""
    info "${editor_name}:"
    if command -v "$cmd" &>/dev/null; then
        EXT_COUNT=$("$cmd" --list-extensions 2>/dev/null | wc -l | tr -d ' ')
        ok "  CLI available, ${EXT_COUNT} extensions installed"
    else
        warn "  CLI ($cmd) not in PATH"
    fi

    if [[ -f "$settings_dir/settings.json" ]]; then
        ok "  settings.json exists"
    else
        warn "  settings.json not found"
    fi

    if [[ -f "$settings_dir/keybindings.json" ]]; then
        ok "  keybindings.json exists"
    else
        warn "  keybindings.json not found"
    fi
done

# ============================================================================
# 8. Raycast
# ============================================================================
header "8. Raycast"

RAYCAST_PLIST="$HOME/Library/Preferences/com.raycast.macos.plist"
RAYCAST_SUPPORT="$HOME/Library/Application Support/com.raycast.macos"

if [[ -f "$RAYCAST_PLIST" ]]; then
    ok "Raycast preferences plist exists"
else
    warn "Raycast plist not found"
fi

if [[ -d "$RAYCAST_SUPPORT" ]]; then
    ok "Raycast support directory exists"
    RAYCAST_SIZE=$(du -sh "$RAYCAST_SUPPORT" 2>/dev/null | awk '{print $1}')
    info "Raycast data size: ${RAYCAST_SIZE}"
else
    warn "Raycast support directory not found"
fi

# ============================================================================
# 9. Project Data (non-git artifacts)
# ============================================================================
header "9. Project Data"

DEV_DIR="$HOME/Desktop/DEV"
if [[ -d "$DEV_DIR" ]]; then
    info "Scanning ${DEV_DIR} for non-git data..."
    echo ""

    for project_dir in "$DEV_DIR"/*/; do
        [[ ! -d "$project_dir" ]] && continue
        PROJECT_NAME=$(basename "$project_dir")

        # Find directories that typically contain generated/non-git data
        DATA_SIZE=""
        for subdir in data reports exports dist build .venv node_modules; do
            if [[ -d "$project_dir/$subdir" ]]; then
                SIZE=$(du -sh "$project_dir/$subdir" 2>/dev/null | awk '{print $1}')
                DATA_SIZE="${DATA_SIZE}${subdir}(${SIZE}) "
            fi
        done

        if [[ -n "$DATA_SIZE" ]]; then
            info "${PROJECT_NAME}: ${DATA_SIZE}"
        fi
    done
fi

# ============================================================================
# 10. Secrets
# ============================================================================
header "10. Secrets & Keys"

# .env files
info "Searching for .env files in ~/Desktop/DEV..."
ENV_FILES=$(find "$HOME/Desktop/DEV" -name ".env" -not -path "*/node_modules/*" -not -path "*/.venv/*" 2>/dev/null || true)
if [[ -n "$ENV_FILES" ]]; then
    while IFS= read -r f; do
        warn "  $f"
    done <<< "$ENV_FILES"
else
    info "  No .env files found"
fi

# SSH keys
echo ""
info "SSH keys:"
if [[ -d "$HOME/.ssh" ]]; then
    for key in "$HOME/.ssh"/id_*; do
        [[ -f "$key" ]] || continue
        [[ "$key" == *.pub ]] && continue
        ok "  $(basename "$key") ($(stat -f '%Sp' "$key" 2>/dev/null || echo '?'))"
    done
else
    warn "  No ~/.ssh directory"
fi

# ============================================================================
# 11. Git Repos
# ============================================================================
header "11. Git Repositories"

if [[ -d "$DEV_DIR" ]]; then
    for project_dir in "$DEV_DIR"/*/; do
        [[ ! -d "$project_dir/.git" ]] && continue
        PROJECT_NAME=$(basename "$project_dir")

        REMOTE=$(git -C "$project_dir" remote get-url origin 2>/dev/null || echo "no remote")
        DIRTY=""
        if [[ -n "$(git -C "$project_dir" status --porcelain 2>/dev/null || true)" ]]; then
            DIRTY=" \033[1;33m[uncommitted changes]\033[0m"
        fi

        UNPUSHED_MSG=""
        UNPUSHED=$(git -C "$project_dir" log --oneline '@{u}..HEAD' 2>/dev/null || true)
        if [[ -n "$UNPUSHED" ]]; then
            UNPUSHED_COUNT=$(echo "$UNPUSHED" | wc -l | tr -d ' ')
            UNPUSHED_MSG=" \033[1;31m[${UNPUSHED_COUNT} unpushed commits]\033[0m"
        fi

        echo -e "  ${PROJECT_NAME}: ${REMOTE}${DIRTY}${UNPUSHED_MSG}"
    done
fi

# ============================================================================
# 12. Summary
# ============================================================================
header "SUMMARY"

echo ""
echo -e "  \033[1;37mBrewfile Coverage:\033[0m"
info "  Formulae: ${FORMULAE_COVERED:-0}/${FORMULAE_INSTALLED_COUNT:-0} covered"
info "  Casks:    ${CASKS_COVERED:-0}/${CASKS_INSTALLED_COUNT:-0} covered"
info "  App Store: ${BREWFILE_MAS_COUNT:-0}/${MAS_COUNT:-0} covered"
info "  Manual apps: ~${MANUAL_COUNT:-0} unmanaged"
echo ""
echo -e "  \033[1;37mConfig Backup Needed:\033[0m"
info "  Claude Code: plugins, settings, memory"
info "  Editors: VS Code + Cursor extensions, settings"
info "  Raycast: preferences, extensions"
echo ""
echo -e "  Report saved to: \033[1;37m${REPORT_FILE}\033[0m"
echo ""
