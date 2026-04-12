#!/usr/bin/env bash
set -euo pipefail

# ============================================================================
# Mac Migration Backup
# Exports configs, data, and secrets for migration to a new Mac.
# Run on your CURRENT Mac before migration.
#
# Usage: ./backup.sh [--skip-secrets] [--skip-projects]
# ============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
BACKUP_DIR="${SCRIPT_DIR}/backups/${TIMESTAMP}"
CONFIG_DIR="${SCRIPT_DIR}/config"

SKIP_SECRETS=false
SKIP_PROJECTS=false

for arg in "$@"; do
    case "$arg" in
        --skip-secrets)  SKIP_SECRETS=true ;;
        --skip-projects) SKIP_PROJECTS=true ;;
        -h|--help)
            echo "Usage: ./backup.sh [--skip-secrets] [--skip-projects]"
            exit 0
            ;;
    esac
done

# --- Helpers ----------------------------------------------------------------

header() {
    echo ""
    echo -e "\033[1;36m━━━ $1\033[0m"
}

ok() { echo -e "  \033[1;32m✓\033[0m $1"; }
warn() { echo -e "  \033[1;33m!\033[0m $1"; }
fail() { echo -e "  \033[1;31m✗\033[0m $1"; }
info() { echo -e "  \033[0;37m·\033[0m $1"; }

safe_copy() {
    local src="$1"
    local dst="$2"
    if [[ -e "$src" ]]; then
        mkdir -p "$(dirname "$dst")"
        cp -a "$src" "$dst"
        ok "$(basename "$src")"
    else
        warn "Not found: $src"
    fi
}

echo -e "\033[1;34m╔════════════════════════════════════════╗\033[0m"
echo -e "\033[1;34m║    Mac Migration Backup                ║\033[0m"
echo -e "\033[1;34m║    ${TIMESTAMP}                     ║\033[0m"
echo -e "\033[1;34m╚════════════════════════════════════════╝\033[0m"
echo ""
info "Backup directory: ${BACKUP_DIR}"

mkdir -p "$BACKUP_DIR"

# ============================================================================
# 1. Claude Code
# ============================================================================
header "1. Claude Code"

CLAUDE_DIR="$HOME/.claude"
CLAUDE_BACKUP="${BACKUP_DIR}/claude"
CLAUDE_CONFIG="${CONFIG_DIR}/claude"

if [[ -d "$CLAUDE_DIR" ]]; then
    mkdir -p "$CLAUDE_BACKUP" "$CLAUDE_CONFIG"

    # Settings files
    safe_copy "$CLAUDE_DIR/settings.json" "$CLAUDE_BACKUP/settings.json"
    safe_copy "$CLAUDE_DIR/settings.local.json" "$CLAUDE_BACKUP/settings.local.json"

    # Also copy to config/ for git commit
    safe_copy "$CLAUDE_DIR/settings.json" "$CLAUDE_CONFIG/settings.json"

    # Plugins metadata
    safe_copy "$CLAUDE_DIR/plugins/installed_plugins.json" "$CLAUDE_BACKUP/plugins/installed_plugins.json"
    safe_copy "$CLAUDE_DIR/plugins/installed_plugins.json" "$CLAUDE_CONFIG/installed_plugins.json"

    # Memory files (all project memories)
    if [[ -d "$CLAUDE_DIR/projects" ]]; then
        MEMORY_COUNT=0
        while IFS= read -r memdir; do
            [[ -z "$memdir" ]] && continue
            REL_PATH="${memdir#$CLAUDE_DIR/}"
            mkdir -p "$CLAUDE_BACKUP/$REL_PATH"
            cp -a "$memdir"/* "$CLAUDE_BACKUP/$REL_PATH/" 2>/dev/null || true
            ((MEMORY_COUNT++)) || true
        done < <(find "$CLAUDE_DIR/projects" -name "memory" -type d 2>/dev/null)
        info "Backed up ${MEMORY_COUNT} memory directories"
    fi

    # Per-project settings
    while IFS= read -r settings_file; do
        [[ -z "$settings_file" ]] && continue
        REL_PATH="${settings_file#$CLAUDE_DIR/}"
        mkdir -p "$(dirname "$CLAUDE_BACKUP/$REL_PATH")"
        cp -a "$settings_file" "$CLAUDE_BACKUP/$REL_PATH"
    done < <(find "$CLAUDE_DIR/projects" -name "settings.local.json" 2>/dev/null)

    # Per-project CLAUDE.md files
    while IFS= read -r claude_md; do
        [[ -z "$claude_md" ]] && continue
        REL_PATH="${claude_md#$CLAUDE_DIR/}"
        mkdir -p "$(dirname "$CLAUDE_BACKUP/$REL_PATH")"
        cp -a "$claude_md" "$CLAUDE_BACKUP/$REL_PATH"
    done < <(find "$CLAUDE_DIR/projects" -name "CLAUDE.md" 2>/dev/null)

    CLAUDE_SIZE=$(du -sh "$CLAUDE_BACKUP" 2>/dev/null | awk '{print $1}')
    ok "Claude Code backup complete (${CLAUDE_SIZE})"
else
    warn "Claude Code not configured, skipping"
fi

# ============================================================================
# 2. VS Code
# ============================================================================
header "2. VS Code"

VSCODE_BACKUP="${BACKUP_DIR}/editors/vscode"
VSCODE_CONFIG="${CONFIG_DIR}/vscode"
VSCODE_SETTINGS="$HOME/Library/Application Support/Code/User"

mkdir -p "$VSCODE_BACKUP" "$VSCODE_CONFIG"

if command -v code &>/dev/null; then
    code --list-extensions 2>/dev/null > "$VSCODE_BACKUP/extensions.txt"
    cp "$VSCODE_BACKUP/extensions.txt" "$VSCODE_CONFIG/extensions.txt"
    EXT_COUNT=$(wc -l < "$VSCODE_BACKUP/extensions.txt" | tr -d ' ')
    ok "Extension list saved (${EXT_COUNT} extensions)"
else
    warn "VS Code CLI not in PATH"
fi

safe_copy "$VSCODE_SETTINGS/settings.json" "$VSCODE_BACKUP/settings.json"
safe_copy "$VSCODE_SETTINGS/keybindings.json" "$VSCODE_BACKUP/keybindings.json"

# Also copy settings to config/ for git
[[ -f "$VSCODE_SETTINGS/settings.json" ]] && cp "$VSCODE_SETTINGS/settings.json" "$VSCODE_CONFIG/settings.json" 2>/dev/null || true
[[ -f "$VSCODE_SETTINGS/keybindings.json" ]] && cp "$VSCODE_SETTINGS/keybindings.json" "$VSCODE_CONFIG/keybindings.json" 2>/dev/null || true

if [[ -d "$VSCODE_SETTINGS/snippets" ]]; then
    cp -a "$VSCODE_SETTINGS/snippets" "$VSCODE_BACKUP/snippets"
    ok "Snippets directory copied"
fi

# ============================================================================
# 3. Cursor
# ============================================================================
header "3. Cursor"

CURSOR_BACKUP="${BACKUP_DIR}/editors/cursor"
CURSOR_CONFIG="${CONFIG_DIR}/cursor"
CURSOR_SETTINGS="$HOME/Library/Application Support/Cursor/User"

mkdir -p "$CURSOR_BACKUP" "$CURSOR_CONFIG"

if command -v cursor &>/dev/null; then
    cursor --list-extensions 2>/dev/null > "$CURSOR_BACKUP/extensions.txt"
    cp "$CURSOR_BACKUP/extensions.txt" "$CURSOR_CONFIG/extensions.txt"
    EXT_COUNT=$(wc -l < "$CURSOR_BACKUP/extensions.txt" | tr -d ' ')
    ok "Extension list saved (${EXT_COUNT} extensions)"
else
    warn "Cursor CLI not in PATH"
fi

safe_copy "$CURSOR_SETTINGS/settings.json" "$CURSOR_BACKUP/settings.json"
safe_copy "$CURSOR_SETTINGS/keybindings.json" "$CURSOR_BACKUP/keybindings.json"

[[ -f "$CURSOR_SETTINGS/settings.json" ]] && cp "$CURSOR_SETTINGS/settings.json" "$CURSOR_CONFIG/settings.json" 2>/dev/null || true
[[ -f "$CURSOR_SETTINGS/keybindings.json" ]] && cp "$CURSOR_SETTINGS/keybindings.json" "$CURSOR_CONFIG/keybindings.json" 2>/dev/null || true

if [[ -d "$CURSOR_SETTINGS/snippets" ]]; then
    cp -a "$CURSOR_SETTINGS/snippets" "$CURSOR_BACKUP/snippets"
    ok "Snippets directory copied"
fi

# ============================================================================
# 4. Raycast
# ============================================================================
header "4. Raycast"

RAYCAST_BACKUP="${BACKUP_DIR}/raycast"
mkdir -p "$RAYCAST_BACKUP"

RAYCAST_PLIST="$HOME/Library/Preferences/com.raycast.macos.plist"
RAYCAST_SUPPORT="$HOME/Library/Application Support/com.raycast.macos"

safe_copy "$RAYCAST_PLIST" "$RAYCAST_BACKUP/com.raycast.macos.plist"

if [[ -d "$RAYCAST_SUPPORT" ]]; then
    # Copy config but skip large caches
    if [[ -f "$RAYCAST_SUPPORT/config.json" ]]; then
        safe_copy "$RAYCAST_SUPPORT/config.json" "$RAYCAST_BACKUP/config.json"
    fi
fi

echo ""
warn "Tip: Also export Raycast settings manually via Raycast > Settings > Advanced > Export"

# ============================================================================
# 5. Project Data
# ============================================================================
header "5. Project Data"

if [[ "$SKIP_PROJECTS" == true ]]; then
    warn "Skipped (--skip-projects)"
else
    PROJECT_BACKUP="${BACKUP_DIR}/project-data"
    mkdir -p "$PROJECT_BACKUP"

    # >>> CUSTOMIZE: Add project-specific data archives here <<<
    # Example:
    # if [[ -d "$HOME/projects/my-project/data" ]]; then
    #     tar czf "$PROJECT_BACKUP/my-project-data.tar.gz" -C "$HOME/projects/my-project" data/
    #     ok "my-project data archived"
    # fi

    # Git repo inventory
    info "Creating git repo inventory..."
    REPO_LIST="$PROJECT_BACKUP/git_repos.txt"
    echo "# Git repositories in ~/Desktop/DEV — $(date)" > "$REPO_LIST"
    for project_dir in "$HOME/Desktop/DEV"/*/; do
        [[ ! -d "$project_dir/.git" ]] && continue
        REMOTE=$(git -C "$project_dir" remote get-url origin 2>/dev/null || echo "no-remote")
        BRANCH=$(git -C "$project_dir" branch --show-current 2>/dev/null || echo "?")
        echo "$(basename "$project_dir")|${REMOTE}|${BRANCH}" >> "$REPO_LIST"
    done
    ok "Git repo inventory saved"
fi

# ============================================================================
# 6. Secrets
# ============================================================================
header "6. Secrets"

if [[ "$SKIP_SECRETS" == true ]]; then
    warn "Skipped (--skip-secrets)"
else
    SECRETS_BACKUP="${BACKUP_DIR}/secrets"
    mkdir -p "$SECRETS_BACKUP"

    echo ""
    echo -e "  \033[1;33m⚠  Secrets will be encrypted with AES-256.\033[0m"
    echo -e "  \033[1;33m   You'll be prompted for a passphrase.\033[0m"
    echo ""

    # Collect .env files
    ENV_TARBALL=$(mktemp)
    ENV_FILES=$(find "$HOME/Desktop/DEV" -name ".env" -not -path "*/node_modules/*" -not -path "*/.venv/*" 2>/dev/null || true)
    if [[ -n "$ENV_FILES" ]]; then
        tar czf "$ENV_TARBALL" $ENV_FILES 2>/dev/null || true
        openssl enc -aes-256-cbc -salt -pbkdf2 -in "$ENV_TARBALL" -out "$SECRETS_BACKUP/env_files.tar.gz.enc"
        rm -f "$ENV_TARBALL"
        ok "Encrypted .env files"
    else
        rm -f "$ENV_TARBALL"
        info "No .env files found"
    fi

    # SSH keys
    if [[ -d "$HOME/.ssh" ]]; then
        echo ""
        warn "SSH keys contain sensitive private key material."
        read -rp "  Back up SSH keys? [y/N] " CONFIRM
        if [[ "$CONFIRM" =~ ^[Yy] ]]; then
            SSH_TARBALL=$(mktemp)
            tar czf "$SSH_TARBALL" -C "$HOME" .ssh/ 2>/dev/null
            openssl enc -aes-256-cbc -salt -pbkdf2 -in "$SSH_TARBALL" -out "$SECRETS_BACKUP/ssh_keys.tar.gz.enc"
            rm -f "$SSH_TARBALL"
            ok "Encrypted SSH keys"
        else
            warn "SSH keys skipped"
        fi
    fi
fi

# ============================================================================
# 7. System Snapshot
# ============================================================================
header "7. System Snapshot"

SYSTEM_BACKUP="${BACKUP_DIR}/system"
mkdir -p "$SYSTEM_BACKUP"

# Current Brewfile dump
brew bundle dump --file="$SYSTEM_BACKUP/Brewfile.current" --force 2>/dev/null && \
    ok "Brew bundle dump saved" || warn "Brew bundle dump failed"

# mas list
mas list 2>/dev/null > "$SYSTEM_BACKUP/mas_list.txt" && \
    ok "App Store app list saved" || warn "mas list failed"

# Application inventory
ls /Applications/ > "$SYSTEM_BACKUP/applications.txt" 2>/dev/null && \
    ok "Application inventory saved"

# Dock plist
safe_copy "$HOME/Library/Preferences/com.apple.dock.plist" "$SYSTEM_BACKUP/com.apple.dock.plist"

# Finder plist
safe_copy "$HOME/Library/Preferences/com.apple.finder.plist" "$SYSTEM_BACKUP/com.apple.finder.plist"

# Git config
safe_copy "$HOME/.gitconfig" "$SYSTEM_BACKUP/.gitconfig"

# ============================================================================
# 8. Manifest
# ============================================================================
header "8. Creating Manifest"

MANIFEST="${BACKUP_DIR}/manifest.json"

# Build manifest with checksums
python3 -c "
import json, hashlib, os, datetime

backup_dir = '$BACKUP_DIR'
manifest = {
    'timestamp': '$TIMESTAMP',
    'created': datetime.datetime.now().isoformat(),
    'hostname': '$(scutil --get ComputerName 2>/dev/null || hostname)',
    'macos_version': '$(sw_vers -productVersion 2>/dev/null)',
    'files': {}
}

for root, dirs, files in os.walk(backup_dir):
    for f in files:
        if f == 'manifest.json':
            continue
        fpath = os.path.join(root, f)
        rel = os.path.relpath(fpath, backup_dir)
        size = os.path.getsize(fpath)
        sha = hashlib.sha256(open(fpath, 'rb').read()).hexdigest()
        manifest['files'][rel] = {'size': size, 'sha256': sha}

json.dump(manifest, open('$MANIFEST', 'w'), indent=2)
print(f'  Manifest: {len(manifest[\"files\"])} files tracked')
"

ok "manifest.json created"

# ============================================================================
# Summary
# ============================================================================
echo ""
TOTAL_SIZE=$(du -sh "$BACKUP_DIR" 2>/dev/null | awk '{print $1}')
echo -e "\033[1;34m════════════════════════════════════════\033[0m"
echo -e "\033[1;32m  Backup Complete!\033[0m"
echo -e "\033[1;34m════════════════════════════════════════\033[0m"
echo ""
echo "  Location: ${BACKUP_DIR}"
echo "  Size:     ${TOTAL_SIZE}"
echo ""
echo "  Next steps:"
echo "    1. Review the backup contents"
echo "    2. Commit mac-setup repo (config/ changes are safe to commit)"
echo "    3. Push repo to GitHub"
echo "    4. Transfer backups/ folder to new Mac (AirDrop, USB drive)"
echo "       ⚠  backups/ contains secrets — NEVER push to git"
echo ""
