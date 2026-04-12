#!/usr/bin/env bash
set -euo pipefail

# ============================================================================
# iCloud Sync — Mirror configs & docs to iCloud Drive
#
# Syncs lightweight config files and knowledge base docs to:
#   ~/Library/Mobile Documents/com~apple~CloudDocs/@ BACKUPS & CONFIGURATIONS/mac-setup-mirror/
#
# What gets synced: zshrc, Ghostty config, Brewfile, knowledge base docs
# What does NOT get synced: secrets, tokens, SSH keys, full scripts, backups
#
# Usage: ./scripts/icloud-sync.sh
# ============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
ICLOUD_BASE="$HOME/Library/Mobile Documents/com~apple~CloudDocs/@ BACKUPS & CONFIGURATIONS"
MIRROR_DIR="$ICLOUD_BASE/mac-setup-mirror"
TIMESTAMP=$(date +%Y-%m-%d_%H%M)

# --- Helpers ----------------------------------------------------------------

ok() { echo -e "  \033[1;32m✓\033[0m $1"; }
skip() { echo -e "  \033[1;33m→\033[0m $1 (skipped)"; }
info() { echo -e "  \033[0;36mℹ\033[0m $1"; }

# --- Pre-flight -------------------------------------------------------------

echo ""
echo -e "\033[1;34m════════════════════════════════════════\033[0m"
echo -e "\033[1;34m  iCloud Config Sync\033[0m"
echo -e "\033[1;34m════════════════════════════════════════\033[0m"
echo ""

if [[ ! -d "$ICLOUD_BASE" ]]; then
    echo "  iCloud backup folder not found: $ICLOUD_BASE"
    echo "  Make sure iCloud Drive is enabled."
    exit 1
fi

mkdir -p "$MIRROR_DIR"
mkdir -p "$MIRROR_DIR/docs"

# --- Sync Configs -----------------------------------------------------------

echo "Syncing config files..."

# zshrc (from the repo copy, which has secrets redacted)
if [[ -f "$PROJECT_DIR/config/zshrc" ]]; then
    cp "$PROJECT_DIR/config/zshrc" "$MIRROR_DIR/zshrc"
    ok "zshrc"
else
    skip "config/zshrc not found"
fi

# Ghostty config
if [[ -f "$PROJECT_DIR/config/ghostty/config" ]]; then
    mkdir -p "$MIRROR_DIR/ghostty"
    cp "$PROJECT_DIR/config/ghostty/config" "$MIRROR_DIR/ghostty/config"
    ok "ghostty/config"
else
    skip "config/ghostty/config not found"
fi

# Brewfile
if [[ -f "$PROJECT_DIR/Brewfile" ]]; then
    cp "$PROJECT_DIR/Brewfile" "$MIRROR_DIR/Brewfile"
    ok "Brewfile"
else
    skip "Brewfile not found"
fi

# Starship config (if it exists)
if [[ -f "$PROJECT_DIR/config/starship.toml" ]]; then
    cp "$PROJECT_DIR/config/starship.toml" "$MIRROR_DIR/starship.toml"
    ok "starship.toml"
fi

# Ollama env
if [[ -f "$PROJECT_DIR/config/ollama.env" ]]; then
    cp "$PROJECT_DIR/config/ollama.env" "$MIRROR_DIR/ollama.env"
    ok "ollama.env"
fi

# --- Sync Docs --------------------------------------------------------------

echo ""
echo "Syncing knowledge base docs..."

for doc in dependencies.md configs-map.md apps-inventory.md rebuild-guide.md; do
    if [[ -f "$PROJECT_DIR/docs/$doc" ]]; then
        cp "$PROJECT_DIR/docs/$doc" "$MIRROR_DIR/docs/$doc"
        ok "$doc"
    else
        skip "docs/$doc not found"
    fi
done

# --- Write sync metadata ----------------------------------------------------

cat > "$MIRROR_DIR/SYNC_INFO.txt" <<EOF
Last synced: $TIMESTAMP
Source: $PROJECT_DIR
GitHub: https://github.com/YOUR_USERNAME/mac-dev-setup

This is a read-only mirror. Edit the source files in the git repo,
then run scripts/icloud-sync.sh to update this mirror.

Reminder: App-specific configs need manual export:
  - Raycast: Raycast > Settings > Advanced > Export
  - Rectangle: Rectangle > Preferences > Export
  - Stats: Stats > Preferences > Export
EOF
ok "SYNC_INFO.txt"

# --- Summary ----------------------------------------------------------------

FILE_COUNT=$(find "$MIRROR_DIR" -type f | wc -l | tr -d ' ')
TOTAL_SIZE=$(du -sh "$MIRROR_DIR" 2>/dev/null | cut -f1)

echo ""
echo -e "\033[1;32m  Sync complete!\033[0m"
echo "  $FILE_COUNT files synced to iCloud ($TOTAL_SIZE)"
echo "  Location: $MIRROR_DIR"
echo ""
