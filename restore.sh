#!/usr/bin/env bash
set -euo pipefail

# ============================================================================
# Mac Migration Restore
# Restores configs, data, and secrets from a backup.
# Run on your NEW Mac AFTER setup.sh completes.
#
# Usage: ./restore.sh <backup_dir>
#        ./restore.sh backups/20260227_153000
# ============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# --- Helpers ----------------------------------------------------------------

header() {
    echo ""
    echo -e "\033[1;36m━━━ $1\033[0m"
}

ok() { echo -e "  \033[1;32m✓\033[0m $1"; }
warn() { echo -e "  \033[1;33m!\033[0m $1"; }
fail() { echo -e "  \033[1;31m✗\033[0m $1"; }
info() { echo -e "  \033[0;37m·\033[0m $1"; }

# ============================================================================
# Validate backup
# ============================================================================

if [[ $# -lt 1 ]]; then
    echo "Usage: ./restore.sh <backup_dir>"
    echo ""
    echo "Available backups:"
    if [[ -d "${SCRIPT_DIR}/backups" ]]; then
        ls -1d "${SCRIPT_DIR}"/backups/*/ 2>/dev/null | while read -r d; do
            echo "  $(basename "$d")"
        done
    else
        echo "  (none found)"
    fi
    exit 1
fi

BACKUP_DIR="$1"
# Handle relative paths
if [[ ! "$BACKUP_DIR" = /* ]]; then
    BACKUP_DIR="${SCRIPT_DIR}/${BACKUP_DIR}"
fi

if [[ ! -d "$BACKUP_DIR" ]]; then
    fail "Backup directory not found: $BACKUP_DIR"
    exit 1
fi

echo -e "\033[1;34m╔════════════════════════════════════════╗\033[0m"
echo -e "\033[1;34m║    Mac Migration Restore               ║\033[0m"
echo -e "\033[1;34m╚════════════════════════════════════════╝\033[0m"
echo ""
info "Restoring from: ${BACKUP_DIR}"

# ============================================================================
# 1. Verify Manifest
# ============================================================================
header "1. Verifying Backup Integrity"

MANIFEST="$BACKUP_DIR/manifest.json"
if [[ -f "$MANIFEST" ]]; then
    VERIFY_RESULT=$(python3 -c "
import json, hashlib, os, sys

manifest = json.load(open('$MANIFEST'))
backup_dir = '$BACKUP_DIR'
errors = 0
checked = 0

for rel_path, meta in manifest.get('files', {}).items():
    fpath = os.path.join(backup_dir, rel_path)
    if not os.path.exists(fpath):
        print(f'  MISSING: {rel_path}')
        errors += 1
        continue
    sha = hashlib.sha256(open(fpath, 'rb').read()).hexdigest()
    if sha != meta['sha256']:
        print(f'  CORRUPT: {rel_path}')
        errors += 1
    checked += 1

if errors > 0:
    print(f'  {errors} errors found in {checked + errors} files')
    sys.exit(1)
else:
    print(f'  All {checked} files verified OK')
" 2>&1) || {
        fail "Backup integrity check failed:"
        echo "$VERIFY_RESULT"
        read -rp "  Continue anyway? [y/N] " CONFIRM
        [[ ! "$CONFIRM" =~ ^[Yy] ]] && exit 1
    }
    ok "$VERIFY_RESULT"
else
    warn "No manifest.json found — skipping integrity check"
fi

# ============================================================================
# 2. Claude Code
# ============================================================================
header "2. Restoring Claude Code"

if [[ -d "$BACKUP_DIR/claude" ]]; then
    bash "${SCRIPT_DIR}/scripts/restore_claude.sh" "$BACKUP_DIR"
    ok "Claude Code restore complete"
else
    info "No Claude backup found, skipping"
fi

# ============================================================================
# 3. Editors (VS Code + Cursor)
# ============================================================================
header "3. Restoring Editors"

if [[ -d "$BACKUP_DIR/editors" ]]; then
    bash "${SCRIPT_DIR}/scripts/restore_editors.sh" "$BACKUP_DIR"
    ok "Editor restore complete"
else
    info "No editor backup found, skipping"
fi

# ============================================================================
# 4. Raycast
# ============================================================================
header "4. Restoring Raycast"

if [[ -d "$BACKUP_DIR/raycast" ]]; then
    bash "${SCRIPT_DIR}/scripts/restore_raycast.sh" "$BACKUP_DIR"
    ok "Raycast restore complete"
else
    info "No Raycast backup found, skipping"
fi

# ============================================================================
# 5. Project Data
# ============================================================================
header "5. Restoring Project Data"

PROJECT_BACKUP="$BACKUP_DIR/project-data"
if [[ -d "$PROJECT_BACKUP" ]]; then
    # >>> CUSTOMIZE: Add project-specific data restore here <<<
    # Example:
    # if [[ -f "$PROJECT_BACKUP/my-project-data.tar.gz" ]]; then
    #     tar xzf "$PROJECT_BACKUP/my-project-data.tar.gz" -C "$HOME/projects/my-project"
    #     ok "my-project data restored"
    # fi

    # Clone git repos
    if [[ -f "$PROJECT_BACKUP/git_repos.txt" ]]; then
        echo ""
        info "Git repositories to clone:"
        while IFS='|' read -r name remote branch; do
            [[ "$name" == "#"* ]] && continue
            [[ -z "$name" ]] && continue
            TARGET="$HOME/Desktop/DEV/$name"
            if [[ -d "$TARGET" ]]; then
                skip "$name (already exists)"
            else
                read -rp "  Clone $name from $remote? [Y/n] " CONFIRM
                if [[ ! "$CONFIRM" =~ ^[Nn] ]]; then
                    git clone "$remote" "$TARGET" 2>/dev/null && \
                        ok "Cloned $name" || warn "Failed to clone $name"
                fi
            fi
        done < "$PROJECT_BACKUP/git_repos.txt"
    fi
else
    info "No project data backup found, skipping"
fi

# ============================================================================
# 6. Secrets
# ============================================================================
header "6. Restoring Secrets"

SECRETS_BACKUP="$BACKUP_DIR/secrets"
if [[ -d "$SECRETS_BACKUP" ]]; then
    # .env files
    if [[ -f "$SECRETS_BACKUP/env_files.tar.gz.enc" ]]; then
        echo ""
        echo "  Decrypting .env files..."
        TMPFILE=$(mktemp)
        if openssl enc -aes-256-cbc -d -salt -pbkdf2 \
            -in "$SECRETS_BACKUP/env_files.tar.gz.enc" \
            -out "$TMPFILE" 2>/dev/null; then
            tar xzf "$TMPFILE" -C / 2>/dev/null
            rm -f "$TMPFILE"
            ok "Restored .env files"
        else
            rm -f "$TMPFILE"
            fail "Decryption failed (wrong passphrase?)"
        fi
    fi

    # SSH keys
    if [[ -f "$SECRETS_BACKUP/ssh_keys.tar.gz.enc" ]]; then
        echo ""
        if [[ -d "$HOME/.ssh" ]] && [[ -n "$(ls -A "$HOME/.ssh" 2>/dev/null)" ]]; then
            warn "~/.ssh already has content"
            read -rp "  Restore SSH keys anyway? [y/N] " CONFIRM
        else
            CONFIRM="y"
        fi

        if [[ "$CONFIRM" =~ ^[Yy] ]]; then
            echo "  Decrypting SSH keys..."
            TMPFILE=$(mktemp)
            if openssl enc -aes-256-cbc -d -salt -pbkdf2 \
                -in "$SECRETS_BACKUP/ssh_keys.tar.gz.enc" \
                -out "$TMPFILE" 2>/dev/null; then
                tar xzf "$TMPFILE" -C "$HOME" 2>/dev/null
                chmod 700 "$HOME/.ssh"
                chmod 600 "$HOME/.ssh"/id_* 2>/dev/null || true
                chmod 644 "$HOME/.ssh"/*.pub 2>/dev/null || true
                rm -f "$TMPFILE"
                ok "Restored SSH keys with correct permissions"
            else
                rm -f "$TMPFILE"
                fail "Decryption failed (wrong passphrase?)"
            fi
        fi
    fi
else
    info "No secrets backup found, skipping"
fi

# ============================================================================
# Summary
# ============================================================================
echo ""
echo -e "\033[1;34m════════════════════════════════════════\033[0m"
echo -e "\033[1;32m  Restore Complete!\033[0m"
echo -e "\033[1;34m════════════════════════════════════════\033[0m"
echo ""
echo "  Next steps:"
echo "    1. Run ./tests/verify.sh for automated checks"
echo "    2. Walk through tests/checklist.md for manual verification"
echo "    3. Open Claude Code — plugins will auto-download"
echo "    4. Open VS Code/Cursor — verify extensions loaded"
echo "    5. Open Raycast — re-import settings if needed"
echo ""
