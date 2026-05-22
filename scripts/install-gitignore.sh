#!/usr/bin/env bash
# install-gitignore.sh - install a sensible default .gitignore in the target directory.
#
# Idempotent: refuses to overwrite an existing .gitignore. Use --force to override
# (rare; prefer to merge by hand).
#
# Usage:
#   ./install-gitignore.sh                 # install into current directory
#   ./install-gitignore.sh <path>          # install into <path>
#   ./install-gitignore.sh --force [<path>] # overwrite an existing .gitignore

set -euo pipefail

FORCE=0
TARGET_DIR="."

while [[ $# -gt 0 ]]; do
  case "$1" in
    --force) FORCE=1; shift ;;
    --help|-h) sed -n '2,12p' "$0"; exit 0 ;;
    *) TARGET_DIR="$1"; shift ;;
  esac
done

if [[ ! -d "$TARGET_DIR" ]]; then
  echo "ERROR: $TARGET_DIR is not a directory." >&2
  exit 1
fi

TARGET="$TARGET_DIR/.gitignore"

if [[ -f "$TARGET" && "$FORCE" -ne 1 ]]; then
  echo "Already exists: $TARGET (use --force to overwrite)" >&2
  exit 0
fi

cat > "$TARGET" <<'EOF'
# Local env vars (never commit secrets)
.env
.env.*
!.env.example
!.env.local.example

# Node
node_modules/
dist/
build/
.next/
out/
coverage/
.vercel/

# TypeScript
*.tsbuildinfo

# Swift Package Manager / Xcode
.build/
.swiftpm/
DerivedData/
*.xcuserstate
xcuserdata/

# macOS noise
.DS_Store
**/.DS_Store

# Logs / IDE
*.log
.idea/
.vscode/
*.swp
EOF

echo "Installed: $TARGET"
