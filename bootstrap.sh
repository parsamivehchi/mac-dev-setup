#!/usr/bin/env bash
set -euo pipefail

# ============================================================================
# Bootstrap — One-liner entry point for fresh Mac setup
#
# Usage (public repo):
#   curl -fsSL https://raw.githubusercontent.com/YOUR_USERNAME/mac-dev-setup/main/bootstrap.sh | bash
#
# Usage (private repo):
#   1. Install Xcode CLI tools: xcode-select --install
#   2. Install Homebrew: /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
#   3. eval "$(/opt/homebrew/bin/brew shellenv)"
#   4. brew install gh git
#   5. gh auth login
#   6. gh repo clone YOUR_USERNAME/mac-dev-setup ~/mac-dev-setup
#   7. cd ~/mac-dev-setup && ./setup.sh
# ============================================================================

# >>> CUSTOMIZE: Replace with your GitHub repo URL <<<
REPO_URL="https://github.com/YOUR_USERNAME/mac-dev-setup.git"
INSTALL_DIR="$HOME/mac-dev-setup"

echo ""
echo "================================================"
echo "  Mac Development Environment Bootstrap"
echo "================================================"
echo ""

# --- Step 1: Xcode CLI Tools ------------------------------------------------
echo "[1/4] Checking Xcode CLI tools..."
if xcode-select -p &>/dev/null; then
    echo "  Already installed."
else
    echo "  Installing Xcode CLI tools (a dialog may appear)..."
    xcode-select --install 2>/dev/null || true
    echo "  Waiting for installation to complete..."
    until xcode-select -p &>/dev/null; do
        sleep 5
    done
    echo "  Installed."
fi

# --- Step 2: Homebrew --------------------------------------------------------
echo "[2/4] Checking Homebrew..."
if command -v brew &>/dev/null; then
    echo "  Already installed."
else
    echo "  Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    if [[ -f /opt/homebrew/bin/brew ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
    echo "  Installed."
fi

# --- Step 3: Git (via Homebrew) ----------------------------------------------
echo "[3/4] Checking Git..."
if command -v git &>/dev/null; then
    echo "  Already installed."
else
    echo "  Installing Git via Homebrew..."
    brew install git
    echo "  Installed."
fi

# --- Step 4: Clone & Run ----------------------------------------------------
echo "[4/4] Cloning setup repo..."
if [[ -d "$INSTALL_DIR/.git" ]]; then
    echo "  Repo already exists at $INSTALL_DIR"
    echo "  Pulling latest changes..."
    git -C "$INSTALL_DIR" pull --ff-only 2>/dev/null || echo "  (pull skipped — may need auth)"
else
    mkdir -p "$(dirname "$INSTALL_DIR")"
    if git clone "$REPO_URL" "$INSTALL_DIR" 2>/dev/null; then
        echo "  Cloned to $INSTALL_DIR"
    else
        echo ""
        echo "  Clone failed — repo may be private."
        echo "  Run these commands manually:"
        echo ""
        echo "    brew install gh"
        echo "    gh auth login"
        echo "    gh repo clone YOUR_USERNAME/mac-dev-setup $INSTALL_DIR"
        echo "    cd $INSTALL_DIR && ./setup.sh"
        echo ""
        exit 1
    fi
fi

echo ""
echo "Starting setup..."
echo ""
cd "$INSTALL_DIR"
chmod +x setup.sh
exec ./setup.sh "$@"
