#!/usr/bin/env bash
set -euo pipefail

# ============================================================================
# Restore Claude Code Configuration
# Restores settings, plugin metadata, and memory files to ~/.claude/
# ============================================================================

BACKUP_DIR="${1:?Usage: restore_claude.sh <backup_dir>}"
CLAUDE_DIR="$HOME/.claude"

ok() { echo -e "  \033[1;32m✓\033[0m $1"; }
warn() { echo -e "  \033[1;33m!\033[0m $1"; }
skip() { echo -e "  \033[1;33m→\033[0m $1 (already exists, skipping)"; }

CLAUDE_BACKUP="$BACKUP_DIR/claude"
if [[ ! -d "$CLAUDE_BACKUP" ]]; then
    echo "No Claude backup found at $CLAUDE_BACKUP"
    exit 0
fi

mkdir -p "$CLAUDE_DIR"

# Settings files
for f in settings.json settings.local.json; do
    if [[ -f "$CLAUDE_BACKUP/$f" ]]; then
        if [[ -f "$CLAUDE_DIR/$f" ]]; then
            skip "$f"
        else
            cp "$CLAUDE_BACKUP/$f" "$CLAUDE_DIR/$f"
            ok "Restored $f"
        fi
    fi
done

# Plugin metadata
if [[ -f "$CLAUDE_BACKUP/plugins/installed_plugins.json" ]]; then
    mkdir -p "$CLAUDE_DIR/plugins"
    if [[ -f "$CLAUDE_DIR/plugins/installed_plugins.json" ]]; then
        skip "installed_plugins.json"
    else
        cp "$CLAUDE_BACKUP/plugins/installed_plugins.json" "$CLAUDE_DIR/plugins/"
        ok "Restored installed_plugins.json"
    fi
fi

# Memory files
MEMORY_COUNT=0
while IFS= read -r memdir; do
    [[ -z "$memdir" ]] && continue
    REL_PATH="${memdir#$CLAUDE_BACKUP/}"
    TARGET="$CLAUDE_DIR/$REL_PATH"
    mkdir -p "$TARGET"
    cp -a "$memdir"/* "$TARGET/" 2>/dev/null || true
    ((MEMORY_COUNT++)) || true
done < <(find "$CLAUDE_BACKUP/projects" -name "memory" -type d 2>/dev/null)

if [[ "$MEMORY_COUNT" -gt 0 ]]; then
    ok "Restored ${MEMORY_COUNT} memory directories"
fi

# Per-project settings
while IFS= read -r settings_file; do
    [[ -z "$settings_file" ]] && continue
    REL_PATH="${settings_file#$CLAUDE_BACKUP/}"
    TARGET="$CLAUDE_DIR/$REL_PATH"
    mkdir -p "$(dirname "$TARGET")"
    if [[ -f "$TARGET" ]]; then
        skip "$(echo "$REL_PATH" | tail -c 60)"
    else
        cp "$settings_file" "$TARGET"
        ok "Restored $(echo "$REL_PATH" | tail -c 60)"
    fi
done < <(find "$CLAUDE_BACKUP/projects" -name "settings.local.json" 2>/dev/null)

# Per-project CLAUDE.md
while IFS= read -r claude_md; do
    [[ -z "$claude_md" ]] && continue
    REL_PATH="${claude_md#$CLAUDE_BACKUP/}"
    TARGET="$CLAUDE_DIR/$REL_PATH"
    mkdir -p "$(dirname "$TARGET")"
    if [[ -f "$TARGET" ]]; then
        skip "$(echo "$REL_PATH" | tail -c 60)"
    else
        cp "$claude_md" "$TARGET"
        ok "Restored $(echo "$REL_PATH" | tail -c 60)"
    fi
done < <(find "$CLAUDE_BACKUP/projects" -name "CLAUDE.md" 2>/dev/null)

echo ""
echo "  Run 'claude' to trigger automatic plugin downloads."
