#!/usr/bin/env bash
set -euo pipefail

# ============================================================================
# Restore VS Code + Cursor Extensions and Settings
# ============================================================================

BACKUP_DIR="${1:?Usage: restore_editors.sh <backup_dir>}"

ok() { echo -e "  \033[1;32m✓\033[0m $1"; }
warn() { echo -e "  \033[1;33m!\033[0m $1"; }
skip() { echo -e "  \033[1;33m→\033[0m $1 (already exists, skipping)"; }

restore_editor() {
    local name="$1"
    local cmd="$2"
    local settings_dir="$3"
    local backup_subdir="$4"

    local editor_backup="$BACKUP_DIR/editors/$backup_subdir"
    if [[ ! -d "$editor_backup" ]]; then
        warn "No $name backup found"
        return
    fi

    echo ""
    echo -e "  \033[1;37m${name}:\033[0m"

    # Install extensions
    if [[ -f "$editor_backup/extensions.txt" ]] && command -v "$cmd" &>/dev/null; then
        TOTAL=$(wc -l < "$editor_backup/extensions.txt" | tr -d ' ')
        INSTALLED=0
        FAILED=0

        while IFS= read -r ext; do
            [[ -z "$ext" ]] && continue
            if "$cmd" --install-extension "$ext" --force 2>/dev/null; then
                ((INSTALLED++)) || true
            else
                ((FAILED++)) || true
            fi
        done < "$editor_backup/extensions.txt"

        ok "Extensions: ${INSTALLED}/${TOTAL} installed ($FAILED failed)"
    elif ! command -v "$cmd" &>/dev/null; then
        warn "$cmd CLI not in PATH — install $name first, then re-run"
    fi

    # Copy settings
    mkdir -p "$settings_dir"

    for f in settings.json keybindings.json; do
        if [[ -f "$editor_backup/$f" ]]; then
            if [[ -f "$settings_dir/$f" ]]; then
                skip "$f"
            else
                cp "$editor_backup/$f" "$settings_dir/$f"
                ok "Restored $f"
            fi
        fi
    done

    # Copy snippets
    if [[ -d "$editor_backup/snippets" ]]; then
        if [[ -d "$settings_dir/snippets" ]]; then
            skip "snippets/"
        else
            cp -a "$editor_backup/snippets" "$settings_dir/snippets"
            ok "Restored snippets"
        fi
    fi
}

restore_editor "VS Code" "code" \
    "$HOME/Library/Application Support/Code/User" "vscode"

restore_editor "Cursor" "cursor" \
    "$HOME/Library/Application Support/Cursor/User" "cursor"
