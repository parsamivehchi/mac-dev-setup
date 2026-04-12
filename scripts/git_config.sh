#!/usr/bin/env bash
set -euo pipefail

# Configure Git identity and generate SSH key if missing.

echo ""

# --- Git identity -----------------------------------------------------------

current_name="$(git config --global user.name 2>/dev/null || echo "")"
current_email="$(git config --global user.email 2>/dev/null || echo "")"

if [[ -n "$current_name" && -n "$current_email" ]]; then
    echo "  Git already configured as: ${current_name} <${current_email}>"
    read -rp "  Keep current config? [Y/n] " keep
    if [[ "${keep,,}" == "n" ]]; then
        current_name=""
        current_email=""
    fi
fi

if [[ -z "$current_name" ]]; then
    read -rp "  Your full name: " input_name
    git config --global user.name "$input_name"
    echo -e "  \033[1;32m✓\033[0m user.name set to: ${input_name}"
fi

if [[ -z "$current_email" ]]; then
    read -rp "  Your email (for Git commits): " input_email
    git config --global user.email "$input_email"
    echo -e "  \033[1;32m✓\033[0m user.email set to: ${input_email}"
fi

# --- Git defaults ------------------------------------------------------------

git config --global init.defaultBranch main
git config --global pull.rebase true
git config --global core.editor "code --wait"
git config --global push.autoSetupRemote true

echo -e "  \033[1;32m✓\033[0m Git defaults set (defaultBranch=main, pull.rebase=true)"

# --- SSH key -----------------------------------------------------------------

SSH_KEY="${HOME}/.ssh/id_ed25519"

if [[ -f "$SSH_KEY" ]]; then
    echo -e "  \033[1;33m→\033[0m SSH key already exists at ${SSH_KEY} (skipping)"
else
    echo "  Generating ed25519 SSH key..."
    mkdir -p "${HOME}/.ssh"
    chmod 700 "${HOME}/.ssh"

    email="$(git config --global user.email)"
    ssh-keygen -t ed25519 -C "$email" -f "$SSH_KEY" -N ""

    # Start ssh-agent and add key
    eval "$(ssh-agent -s)" &>/dev/null
    ssh-add "$SSH_KEY" 2>/dev/null

    echo -e "  \033[1;32m✓\033[0m SSH key generated"
fi

# --- Print public key --------------------------------------------------------

echo ""
echo "  Your SSH public key:"
echo "  ─────────────────────────────────────────────"
cat "${SSH_KEY}.pub"
echo "  ─────────────────────────────────────────────"
echo ""
echo "  Add it to GitHub: https://github.com/settings/ssh/new"
echo "  Then test with:   ssh -T git@github.com"
echo ""
