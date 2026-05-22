#!/usr/bin/env bash
# install-gitignore-xattr.sh - install a default .gitignore AND apply the iCloud
# Drive exclusion xattr to the .git directory.
#
# The xattr step prevents iCloud Drive from creating " 2" duplicate files inside
# .git/refs/ when git updates a ref at the same moment iCloud is syncing.
# See parsamivehchi/dotclaude gotchas.md entry for 2026-05-21.
#
# Usage:
#   ./install-gitignore-xattr.sh                     # current directory
#   ./install-gitignore-xattr.sh <path>              # specific path
#
# Pre-condition: <path>/.git must exist (run `git init` first if needed).

set -euo pipefail

TARGET_DIR="${1:-.}"

if [[ ! -d "$TARGET_DIR" ]]; then
  echo "ERROR: $TARGET_DIR is not a directory." >&2
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Step 1: install the default .gitignore (idempotent)
bash "$SCRIPT_DIR/install-gitignore.sh" "$TARGET_DIR"

# Step 2: apply iCloud xattr if .git exists
GIT_DIR="$TARGET_DIR/.git"
if [[ ! -d "$GIT_DIR" ]]; then
  echo "Note: $GIT_DIR does not exist yet. Run \`git init\` first, then re-run this script."
  exit 0
fi

if xattr -l "$GIT_DIR" 2>/dev/null | grep -q "com.apple.fileprovider.ignore"; then
  echo "Already excluded from iCloud: $GIT_DIR"
else
  xattr -w com.apple.fileprovider.ignore#P 1 "$GIT_DIR"
  echo "Applied iCloud-exclude xattr: $GIT_DIR"
fi

# Sweep any existing " 2" duplicate refs (one-time cleanup if .git existed already)
DUPS=$(find "$GIT_DIR" -name "* 2" 2>/dev/null | wc -l | tr -d ' ')
if [[ "$DUPS" -gt 0 ]]; then
  echo "Found $DUPS stale duplicate ref files; deleting"
  find "$GIT_DIR" -name "* 2" -delete 2>/dev/null
fi
