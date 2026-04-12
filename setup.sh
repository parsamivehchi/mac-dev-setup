#!/usr/bin/env bash
set -euo pipefail

# ============================================================================
# Mac Setup for LLM Development
# One-command bootstrap — idempotent, safe to re-run.
#
# Usage: ./setup.sh [--dry-run] [--skip-restore]
# ============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TOTAL_PHASES=18
DRY_RUN=false
SKIP_RESTORE=false

for arg in "$@"; do
    case "$arg" in
        --dry-run)      DRY_RUN=true ;;
        --skip-restore) SKIP_RESTORE=true ;;
        -h|--help)
            echo "Usage: ./setup.sh [--dry-run] [--skip-restore]"
            echo "  --dry-run       Show what would be done without making changes"
            echo "  --skip-restore  Skip phases 12-15 (config/data restoration)"
            exit 0
            ;;
    esac
done

# --- Helpers ----------------------------------------------------------------

phase() {
    local num="$1"
    local msg="$2"
    echo -e "\n\033[1;34m[Phase ${num}/${TOTAL_PHASES}]\033[0m ${msg}"
}

success() {
    echo -e "  \033[1;32m✓\033[0m $1"
}

skip() {
    echo -e "  \033[1;33m→\033[0m $1 (already done, skipping)"
}

fail() {
    echo -e "  \033[1;31m✗\033[0m $1"
}

dry() {
    echo -e "  \033[1;35m[dry-run]\033[0m $1"
}

# Wrapper: run command or print in dry-run mode
run() {
    if [[ "$DRY_RUN" == true ]]; then
        dry "Would run: $*"
    else
        "$@"
    fi
}

if [[ "$DRY_RUN" == true ]]; then
    echo -e "\033[1;35m══ DRY RUN MODE — no changes will be made ══\033[0m"
    echo ""
fi

# ============================================================================
# Phase 1: Xcode Command Line Tools
# ============================================================================
phase 1 "Installing Xcode CLI tools..."

if xcode-select -p &>/dev/null; then
    skip "Xcode CLI tools installed"
else
    if [[ "$DRY_RUN" == true ]]; then
        dry "Would install Xcode CLI tools"
    else
        echo "  Installing Xcode CLI tools (this may open a dialog)..."
        xcode-select --install 2>/dev/null || true
        echo "  Waiting for Xcode CLI tools installation to complete..."
        until xcode-select -p &>/dev/null; do
            sleep 5
        done
        success "Xcode CLI tools installed"
    fi
fi

# ============================================================================
# Phase 2: Homebrew
# ============================================================================
phase 2 "Installing Homebrew..."

if command -v brew &>/dev/null; then
    skip "Homebrew installed"
    if [[ "$DRY_RUN" != true ]]; then
        echo "  Updating Homebrew..."
        brew update --quiet
        success "Homebrew updated"
    fi
else
    if [[ "$DRY_RUN" == true ]]; then
        dry "Would install Homebrew"
    else
        echo "  Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        if [[ -f /opt/homebrew/bin/brew ]]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        fi
        success "Homebrew installed"
    fi
fi

# ============================================================================
# Phase 3: Brew Bundle
# ============================================================================
phase 3 "Installing Homebrew packages (Brewfile)..."

if [[ -f "${SCRIPT_DIR}/Brewfile" ]]; then
    if [[ "$DRY_RUN" == true ]]; then
        FORMULAE_COUNT=$(grep -c '^brew ' "${SCRIPT_DIR}/Brewfile" || true)
        CASK_COUNT=$(grep -c '^cask ' "${SCRIPT_DIR}/Brewfile" || true)
        MAS_COUNT=$(grep -c '^mas ' "${SCRIPT_DIR}/Brewfile" || true)
        dry "Would install ${FORMULAE_COUNT} formulae, ${CASK_COUNT} casks, ${MAS_COUNT} App Store apps"
    else
        brew bundle --file="${SCRIPT_DIR}/Brewfile" --no-lock --quiet || {
            fail "Some Brewfile items failed (non-fatal, continuing)"
        }
        success "Brewfile packages installed"
    fi
else
    fail "Brewfile not found at ${SCRIPT_DIR}/Brewfile"
fi

# ============================================================================
# Phase 4: Mac App Store Verification
# ============================================================================
phase 4 "Verifying Mac App Store apps..."

if command -v mas &>/dev/null; then
    MAS_ACCOUNT=$(mas account 2>/dev/null || echo "not signed in")
    if [[ "$MAS_ACCOUNT" == "not signed in" ]] && [[ "$MAS_ACCOUNT" != *"@"* ]]; then
        fail "Not signed into App Store — sign in via App Store.app, then re-run"
        echo "  Some App Store apps from Brewfile may not have installed."
    else
        success "App Store signed in: ${MAS_ACCOUNT}"
        MAS_INSTALLED=$(mas list 2>/dev/null | wc -l | tr -d ' ')
        success "${MAS_INSTALLED} App Store apps installed"
    fi
else
    fail "mas CLI not installed (should have been installed in Phase 3)"
fi

# ============================================================================
# Phase 5: Claude Code
# ============================================================================
phase 5 "Installing Claude Code..."

if command -v claude &>/dev/null; then
    skip "Claude Code already installed"
else
    if [[ "$DRY_RUN" == true ]]; then
        dry "Would install Claude Code via npm"
    elif command -v npm &>/dev/null; then
        npm install -g @anthropic-ai/claude-code
        success "Claude Code installed"
    else
        fail "npm not found — install Node.js first"
    fi
fi

# ============================================================================
# Phase 6: uv (Python package manager)
# ============================================================================
phase 6 "Installing uv..."

if command -v uv &>/dev/null; then
    skip "uv already installed"
else
    if [[ "$DRY_RUN" == true ]]; then
        dry "Would install uv"
    else
        curl -LsSf https://astral.sh/uv/install.sh | sh
        success "uv installed"
    fi
fi

# ============================================================================
# Phase 7: Bun (JS runtime)
# ============================================================================
phase 7 "Installing Bun..."

if command -v bun &>/dev/null; then
    skip "Bun already installed"
else
    if [[ "$DRY_RUN" == true ]]; then
        dry "Would install Bun"
    else
        curl -fsSL https://bun.sh/install | bash
        success "Bun installed"
    fi
fi

# ============================================================================
# Phase 8: Ollama Models
# ============================================================================
phase 8 "Pulling Ollama models..."

if [[ -x "${SCRIPT_DIR}/scripts/pull_models.sh" ]]; then
    if [[ "$DRY_RUN" == true ]]; then
        dry "Would pull Ollama models"
    else
        bash "${SCRIPT_DIR}/scripts/pull_models.sh"
        success "Ollama models pulled"
    fi
else
    fail "scripts/pull_models.sh not found or not executable"
fi

# ============================================================================
# Phase 9: Git + SSH
# ============================================================================
phase 9 "Configuring Git and SSH..."

if [[ -x "${SCRIPT_DIR}/scripts/git_config.sh" ]]; then
    if [[ "$DRY_RUN" == true ]]; then
        dry "Would configure Git and SSH"
    else
        bash "${SCRIPT_DIR}/scripts/git_config.sh"
        success "Git and SSH configured"
    fi
else
    fail "scripts/git_config.sh not found or not executable"
fi

# ============================================================================
# Phase 10: macOS Defaults
# ============================================================================
phase 10 "Applying macOS defaults..."

if [[ -x "${SCRIPT_DIR}/scripts/macos_defaults.sh" ]]; then
    if [[ "$DRY_RUN" == true ]]; then
        dry "Would apply macOS defaults"
    else
        bash "${SCRIPT_DIR}/scripts/macos_defaults.sh"
        success "macOS defaults applied"
    fi
else
    fail "scripts/macos_defaults.sh not found or not executable"
fi

# ============================================================================
# Phase 11: Symlink Configs (dotfiles)
# ============================================================================
phase 11 "Symlinking configuration files..."

link_config() {
    local src="$1"
    local dst="$2"
    local dst_dir
    dst_dir="$(dirname "$dst")"

    if [[ ! -f "$src" ]]; then
        fail "Source not found: ${src}"
        return
    fi

    if [[ "$DRY_RUN" == true ]]; then
        if [[ -L "$dst" ]]; then
            local current_target
            current_target="$(readlink "$dst")"
            if [[ "$current_target" == "$src" ]]; then
                skip "$(basename "$dst") already linked"
            else
                dry "Would relink $(basename "$dst")"
            fi
        elif [[ -f "$dst" ]]; then
            dry "Would backup and link $(basename "$dst")"
        else
            dry "Would link $(basename "$dst")"
        fi
        return
    fi

    mkdir -p "$dst_dir"

    if [[ -L "$dst" ]]; then
        local current_target
        current_target="$(readlink "$dst")"
        if [[ "$current_target" == "$src" ]]; then
            skip "$(basename "$dst") already linked"
            return
        fi
        rm -f "$dst"
    elif [[ -f "$dst" ]]; then
        echo "  Backing up existing $(basename "$dst") to ${dst}.bak"
        mv "$dst" "${dst}.bak"
    fi

    ln -sf "$src" "$dst"
    success "Linked $(basename "$dst")"
}

link_config "${SCRIPT_DIR}/config/zshrc" "${HOME}/.zshrc"
link_config "${SCRIPT_DIR}/config/ghostty/config" "${HOME}/.config/ghostty/config"

# Starship config (optional — zshrc uses custom prompt by default, but starship is available)
if [[ -f "${SCRIPT_DIR}/config/starship.toml" ]]; then
    link_config "${SCRIPT_DIR}/config/starship.toml" "${HOME}/.config/starship.toml"
fi

# Install Ollama LaunchAgent
LAUNCHAGENT_SRC="${SCRIPT_DIR}/LaunchAgents/com.user.ollama.plist"
LAUNCHAGENT_DST="${HOME}/Library/LaunchAgents/com.user.ollama.plist"

if [[ -f "$LAUNCHAGENT_SRC" ]]; then
    if [[ -L "$LAUNCHAGENT_DST" || -f "$LAUNCHAGENT_DST" ]]; then
        skip "Ollama LaunchAgent already installed"
    elif [[ "$DRY_RUN" == true ]]; then
        dry "Would install Ollama LaunchAgent"
    else
        mkdir -p "${HOME}/Library/LaunchAgents"
        cp "$LAUNCHAGENT_SRC" "$LAUNCHAGENT_DST"
        launchctl load "$LAUNCHAGENT_DST" 2>/dev/null || true
        success "Ollama LaunchAgent installed and loaded"
    fi
fi

# ============================================================================
# Phase 12: Claude Code Config Restore
# ============================================================================
phase 12 "Restoring Claude Code configuration..."

if [[ "$SKIP_RESTORE" == true ]]; then
    skip "Skipped (--skip-restore)"
elif [[ -x "${SCRIPT_DIR}/scripts/restore_claude.sh" ]]; then
    # Find the most recent backup
    LATEST_BACKUP=$(ls -1d "${SCRIPT_DIR}"/backups/*/ 2>/dev/null | sort | tail -1 || true)
    if [[ -n "$LATEST_BACKUP" ]] && [[ -d "$LATEST_BACKUP/claude" ]]; then
        if [[ "$DRY_RUN" == true ]]; then
            dry "Would restore Claude config from $(basename "$LATEST_BACKUP")"
        else
            bash "${SCRIPT_DIR}/scripts/restore_claude.sh" "$LATEST_BACKUP"
            success "Claude Code config restored"
        fi
    else
        skip "No Claude backup found in backups/"
    fi
else
    skip "scripts/restore_claude.sh not found"
fi

# ============================================================================
# Phase 13: Editor Settings Restore
# ============================================================================
phase 13 "Restoring editor settings..."

if [[ "$SKIP_RESTORE" == true ]]; then
    skip "Skipped (--skip-restore)"
elif [[ -x "${SCRIPT_DIR}/scripts/restore_editors.sh" ]]; then
    LATEST_BACKUP=$(ls -1d "${SCRIPT_DIR}"/backups/*/ 2>/dev/null | sort | tail -1 || true)
    if [[ -n "$LATEST_BACKUP" ]] && [[ -d "$LATEST_BACKUP/editors" ]]; then
        if [[ "$DRY_RUN" == true ]]; then
            dry "Would restore editor settings from $(basename "$LATEST_BACKUP")"
        else
            bash "${SCRIPT_DIR}/scripts/restore_editors.sh" "$LATEST_BACKUP"
            success "Editor settings restored"
        fi
    else
        skip "No editor backup found in backups/"
    fi
else
    skip "scripts/restore_editors.sh not found"
fi

# ============================================================================
# Phase 14: Raycast Preferences Restore
# ============================================================================
phase 14 "Restoring Raycast preferences..."

if [[ "$SKIP_RESTORE" == true ]]; then
    skip "Skipped (--skip-restore)"
elif [[ -x "${SCRIPT_DIR}/scripts/restore_raycast.sh" ]]; then
    LATEST_BACKUP=$(ls -1d "${SCRIPT_DIR}"/backups/*/ 2>/dev/null | sort | tail -1 || true)
    if [[ -n "$LATEST_BACKUP" ]] && [[ -d "$LATEST_BACKUP/raycast" ]]; then
        if [[ "$DRY_RUN" == true ]]; then
            dry "Would restore Raycast preferences from $(basename "$LATEST_BACKUP")"
        else
            bash "${SCRIPT_DIR}/scripts/restore_raycast.sh" "$LATEST_BACKUP"
            success "Raycast preferences restored"
        fi
    else
        skip "No Raycast backup found in backups/"
    fi
else
    skip "scripts/restore_raycast.sh not found"
fi

# ============================================================================
# Phase 15: Project Data Restore
# ============================================================================
phase 15 "Restoring project data..."

if [[ "$SKIP_RESTORE" == true ]]; then
    skip "Skipped (--skip-restore)"
else
    LATEST_BACKUP=$(ls -1d "${SCRIPT_DIR}"/backups/*/ 2>/dev/null | sort | tail -1 || true)
    if [[ -n "$LATEST_BACKUP" ]] && [[ -d "$LATEST_BACKUP/project-data" ]]; then
        if [[ "$DRY_RUN" == true ]]; then
            dry "Would restore project data from $(basename "$LATEST_BACKUP")"
        else
            PROJECT_BACKUP="$LATEST_BACKUP/project-data"

            # Git repos
            if [[ -f "$PROJECT_BACKUP/git_repos.txt" ]]; then
                while IFS='|' read -r name remote branch; do
                    [[ "$name" == "#"* ]] && continue
                    [[ -z "$name" ]] && continue
                    TARGET="$HOME/Desktop/DEV/$name"
                    if [[ -d "$TARGET" ]]; then
                        skip "$name"
                    else
                        git clone "$remote" "$TARGET" 2>/dev/null && \
                            success "Cloned $name" || fail "Failed to clone $name"
                    fi
                done < "$PROJECT_BACKUP/git_repos.txt"
            fi
        fi
    else
        skip "No project data backup found in backups/"
    fi
fi

# ============================================================================
# Phase 16: Manual App Checklist
# ============================================================================
phase 16 "Checking for non-Homebrew apps..."

# >>> CUSTOMIZE: Add apps that aren't managed by Homebrew or the App Store <<<
MANUAL_APPS=(
    # "Adobe Creative Cloud"
    # "Logitech Options+"
    # Add your manually-installed apps here
)

MISSING_MANUAL=0
for app in "${MANUAL_APPS[@]}"; do
    if [[ ! -d "/Applications/${app}.app" ]]; then
        echo -e "  \033[0;37m·\033[0m ${app} — manual install needed"
        ((MISSING_MANUAL++)) || true
    fi
done

if [[ "$MISSING_MANUAL" -eq 0 ]]; then
    success "All manual apps present"
else
    echo "  ${MISSING_MANUAL} apps require manual installation"
fi

# ============================================================================
# Phase 17: Verification
# ============================================================================
phase 17 "Verifying installations..."

TOOLS=(
    "git" "gh" "brew" "node" "npm" "python3" "uv" "bun"
    "bat" "eza" "fzf" "rg" "fd" "jq" "yq"
    "tmux" "stow" "starship" "zoxide"
    "ollama" "claude" "btop" "htop"
    "mas" "deno" "ffmpeg" "lazygit" "ncdu" "pandoc"
)

pass_count=0
fail_count=0

for tool in "${TOOLS[@]}"; do
    if command -v "$tool" &>/dev/null; then
        success "${tool}"
        ((pass_count++))
    else
        fail "${tool} not found in PATH"
        ((fail_count++))
    fi
done

# ============================================================================
# Phase 18: iCloud Sync (optional)
# ============================================================================
phase 18 "Syncing configs to iCloud..."

ICLOUD_SYNC="${SCRIPT_DIR}/scripts/icloud-sync.sh"
if [[ -x "$ICLOUD_SYNC" ]]; then
    if [[ "$DRY_RUN" == true ]]; then
        dry "Would sync configs and docs to iCloud"
    else
        bash "$ICLOUD_SYNC" && success "iCloud sync complete" || {
            fail "iCloud sync failed (non-fatal, continuing)"
        }
    fi
else
    skip "scripts/icloud-sync.sh not found"
fi

# ============================================================================
# Summary
# ============================================================================
echo ""
echo -e "\033[1;34m════════════════════════════════════════\033[0m"
if [[ "$DRY_RUN" == true ]]; then
    echo -e "\033[1;35m  Dry Run Complete! (no changes made)\033[0m"
else
    echo -e "\033[1;32m  Mac Setup Complete!\033[0m"
fi
echo -e "\033[1;34m════════════════════════════════════════\033[0m"
echo ""
echo "  Tools verified: ${pass_count} passed, ${fail_count} failed"
echo ""
echo "  Next steps:"
echo "    1. Restart your terminal (or run: source ~/.zshrc)"
echo "    2. Add your SSH key to GitHub: https://github.com/settings/keys"
echo "    3. Store API tokens in Keychain:"
echo "       security add-generic-password -a \"\$USER\" -s \"VERCEL_TOKEN\" -w \"your-token\" -U"
echo "    4. Start Ollama: ollama serve (or it runs via LaunchAgent)"
if [[ "$SKIP_RESTORE" == true ]]; then
    echo "    5. Run ./restore.sh <backup_dir> to restore configs and data"
fi
echo "    6. Run ./tests/verify.sh for comprehensive verification"
echo "    7. Walk through tests/checklist.md for manual checks"
echo "    8. Import Raycast/Rectangle/Stats configs from iCloud backup"
echo ""
