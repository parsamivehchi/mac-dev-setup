#!/usr/bin/env bash
set -euo pipefail

# ============================================================================
# Post-Setup Verification
# Automated checks to confirm setup completed successfully.
# ============================================================================

PASS=0
FAIL=0
WARN=0

check() {
    local desc="$1"
    shift
    if "$@" &>/dev/null; then
        echo -e "  \033[1;32m✓\033[0m $desc"
        ((PASS++)) || true
    else
        echo -e "  \033[1;31m✗\033[0m $desc"
        ((FAIL++)) || true
    fi
}

check_warn() {
    local desc="$1"
    shift
    if "$@" &>/dev/null; then
        echo -e "  \033[1;32m✓\033[0m $desc"
        ((PASS++)) || true
    else
        echo -e "  \033[1;33m!\033[0m $desc (optional)"
        ((WARN++)) || true
    fi
}

header() {
    echo ""
    echo -e "\033[1;36m━━━ $1\033[0m"
}

echo -e "\033[1;34m╔════════════════════════════════════════╗\033[0m"
echo -e "\033[1;34m║    Post-Setup Verification             ║\033[0m"
echo -e "\033[1;34m╚════════════════════════════════════════╝\033[0m"

# --- CLI Tools in PATH ------------------------------------------------------
header "CLI Tools"

TOOLS=(
    git gh brew node npm python3 uv bun bat eza fzf rg fd jq yq
    tmux stow starship zoxide ollama claude btop htop
)

for tool in "${TOOLS[@]}"; do
    check "$tool" command -v "$tool"
done

# Additional tools
EXTRA_TOOLS=(mas deno ffmpeg lazygit ncdu pandoc yt-dlp gpg pipx)
for tool in "${EXTRA_TOOLS[@]}"; do
    check_warn "$tool" command -v "$tool"
done

# --- GUI Applications -------------------------------------------------------
header "Applications"

APPS=(
    "Ghostty" "Cursor" "Visual Studio Code" "Arc" "Raycast"
    "Slack" "Discord" "Notion" "Obsidian" "Spotify"
)

for app in "${APPS[@]}"; do
    check "$app" test -d "/Applications/${app}.app"
done

OPTIONAL_APPS=(
    "Docker" "1Password" "ChatGPT" "Claude" "Brave Browser"
    "IINA" "VLC" "Stats" "Rectangle"
)

for app in "${OPTIONAL_APPS[@]}"; do
    check_warn "$app" test -d "/Applications/${app}.app"
done

# --- Config Symlinks ---------------------------------------------------------
header "Configuration Symlinks"

check ".zshrc is symlink" test -L "$HOME/.zshrc"
check "starship.toml is symlink" test -L "$HOME/.config/starship.toml"
check "ghostty config is symlink" test -L "$HOME/.config/ghostty/config"

# --- Claude Code -------------------------------------------------------------
header "Claude Code"

check "~/.claude exists" test -d "$HOME/.claude"
check "settings.json exists" test -f "$HOME/.claude/settings.json"
check_warn "plugins metadata exists" test -f "$HOME/.claude/plugins/installed_plugins.json"

# --- SSH Key -----------------------------------------------------------------
header "SSH"

check "~/.ssh exists" test -d "$HOME/.ssh"
check_warn "SSH key exists" test -f "$HOME/.ssh/id_ed25519" -o -f "$HOME/.ssh/id_rsa"

# --- Ollama ------------------------------------------------------------------
header "Ollama"

check_warn "Ollama service responding" ollama list

# --- Editors -----------------------------------------------------------------
header "Editor Extensions"

if command -v code &>/dev/null; then
    VSCODE_EXT=$(code --list-extensions 2>/dev/null | wc -l | tr -d ' ')
    if [[ "$VSCODE_EXT" -gt 10 ]]; then
        echo -e "  \033[1;32m✓\033[0m VS Code: ${VSCODE_EXT} extensions"
        ((PASS++)) || true
    else
        echo -e "  \033[1;33m!\033[0m VS Code: only ${VSCODE_EXT} extensions (expected 80+)"
        ((WARN++)) || true
    fi
fi

if command -v cursor &>/dev/null; then
    CURSOR_EXT=$(cursor --list-extensions 2>/dev/null | wc -l | tr -d ' ')
    if [[ "$CURSOR_EXT" -gt 10 ]]; then
        echo -e "  \033[1;32m✓\033[0m Cursor: ${CURSOR_EXT} extensions"
        ((PASS++)) || true
    else
        echo -e "  \033[1;33m!\033[0m Cursor: only ${CURSOR_EXT} extensions (expected 80+)"
        ((WARN++)) || true
    fi
fi

# --- Summary -----------------------------------------------------------------
echo ""
echo -e "\033[1;34m════════════════════════════════════════\033[0m"
TOTAL=$((PASS + FAIL + WARN))
echo -e "  \033[1;32m${PASS} passed\033[0m  \033[1;31m${FAIL} failed\033[0m  \033[1;33m${WARN} warnings\033[0m  (${TOTAL} total)"
echo -e "\033[1;34m════════════════════════════════════════\033[0m"

if [[ "$FAIL" -gt 0 ]]; then
    echo ""
    echo "  Some required checks failed. Review the output above."
    exit 1
else
    echo ""
    echo "  All required checks passed!"
    exit 0
fi
