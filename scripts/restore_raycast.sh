#!/usr/bin/env bash
set -euo pipefail

# ============================================================================
# Restore Raycast Preferences
# ============================================================================

BACKUP_DIR="${1:?Usage: restore_raycast.sh <backup_dir>}"

ok() { echo -e "  \033[1;32m✓\033[0m $1"; }
warn() { echo -e "  \033[1;33m!\033[0m $1"; }
skip() { echo -e "  \033[1;33m→\033[0m $1 (already exists, skipping)"; }

RAYCAST_BACKUP="$BACKUP_DIR/raycast"
if [[ ! -d "$RAYCAST_BACKUP" ]]; then
    echo "No Raycast backup found at $RAYCAST_BACKUP"
    exit 0
fi

RAYCAST_PREFS="$HOME/Library/Preferences"
RAYCAST_SUPPORT="$HOME/Library/Application Support/com.raycast.macos"

# Plist
if [[ -f "$RAYCAST_BACKUP/com.raycast.macos.plist" ]]; then
    if [[ -f "$RAYCAST_PREFS/com.raycast.macos.plist" ]]; then
        skip "Raycast plist (Raycast already configured)"
    else
        cp "$RAYCAST_BACKUP/com.raycast.macos.plist" "$RAYCAST_PREFS/"
        ok "Restored Raycast plist"
    fi
fi

# Config
if [[ -f "$RAYCAST_BACKUP/config.json" ]]; then
    mkdir -p "$RAYCAST_SUPPORT"
    if [[ -f "$RAYCAST_SUPPORT/config.json" ]]; then
        skip "Raycast config.json"
    else
        cp "$RAYCAST_BACKUP/config.json" "$RAYCAST_SUPPORT/"
        ok "Restored Raycast config.json"
    fi
fi

echo ""
warn "For full Raycast restoration, also use:"
warn "  Raycast > Settings > Advanced > Import"
warn "  (from the export file you created manually)"
