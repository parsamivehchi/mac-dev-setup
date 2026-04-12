# Mac Dev Setup

**One-command bootstrap + full migration kit for development on macOS (Apple Silicon)**

![Shell](https://img.shields.io/badge/shell-bash-green?logo=gnubash&logoColor=white)
![Phases](https://img.shields.io/badge/phases-18-blue)
![Packages](https://img.shields.io/badge/packages-120-cyan)
![Apple Silicon](https://img.shields.io/badge/Apple_Silicon-recommended-black?logo=apple)

Goes beyond dotfiles — 18-phase automated setup, config backup/restore with encrypted secrets, pre-migration audit, post-setup verification, and comprehensive knowledge base documentation.

---

## Quick Start

```bash
# Clone and run
git clone https://github.com/YOUR_USERNAME/mac-dev-setup.git ~/mac-dev-setup
cd ~/mac-dev-setup
./setup.sh
```

Preview without making changes:

```bash
./setup.sh --dry-run
```

Or use the one-liner bootstrap (installs Xcode CLI tools + Homebrew first):

```bash
curl -fsSL https://raw.githubusercontent.com/YOUR_USERNAME/mac-dev-setup/main/bootstrap.sh | bash
```

> **Note**: Replace `YOUR_USERNAME` with your GitHub username after forking.

---

## What's Included

### 120 Packages (Brewfile)
- **50 Homebrew Formulae**: git, gh, bat, eza, fzf, ripgrep, fd, jq, node, python, go, ollama, and more
- **40 Casks**: Ghostty, Cursor, VS Code, Docker, Raycast, Rectangle, Claude, ChatGPT, Arc, and more
- **30 App Store Apps**: Xcode, Bitwarden, Perplexity, Amphetamine, and more

### Configuration Files
- **zshrc**: Custom prompt, git aliases, Claude Code aliases (remote + local Ollama), Ghostty per-pane colors, Python venv management
- **Ghostty**: Catppuccin theme, JetBrains Mono Nerd Font, Quake-style dropdown terminal (Ctrl+`)
- **macOS Defaults**: Dock, Finder, keyboard, screenshots preferences
- **Git + SSH**: Identity setup, ed25519 key generation
- **Ollama**: LaunchAgent for auto-start, 5 pre-configured models

### Knowledge Base (docs/)
- `dependencies.md` — Every package with description, usage, and why it's included
- `apps-inventory.md` — Every app organized by category with setup notes
- `configs-map.md` — Every config file, its location, and backup strategy
- `rebuild-guide.md` — Step-by-step fresh Mac rebuild guide with troubleshooting

### Scripts
| Script | Purpose |
|--------|---------|
| `setup.sh` | 18-phase idempotent bootstrap (`--dry-run`, `--skip-restore`) |
| `bootstrap.sh` | curl one-liner: Xcode CLI + Homebrew + clone + setup |
| `audit.sh` | Pre-migration readiness scan (12 sections) |
| `backup.sh` | Export configs, data, and AES-256 encrypted secrets |
| `restore.sh` | Restore from backup with SHA-256 manifest verification |
| `tests/verify.sh` | Automated post-setup checks (30+ CLI tools, 10+ apps) |
| `scripts/icloud-sync.sh` | Mirror configs + docs to iCloud Drive |

---

## Setup Phases

| # | Phase | Type |
|---|-------|------|
| 1 | Xcode CLI Tools | core |
| 2 | Homebrew | core |
| 3 | Brew Bundle (120 packages) | core |
| 4 | Mac App Store verification | core |
| 5 | Claude Code | dev |
| 6 | uv (Python) | dev |
| 7 | Bun (JS) | dev |
| 8 | Ollama Models | llm |
| 9 | Git + SSH | config |
| 10 | macOS Defaults | config |
| 11 | Symlink Configs | config |
| 12 | Claude Code config restore | restore |
| 13 | Editor settings restore | restore |
| 14 | Raycast prefs restore | restore |
| 15 | Project data restore | restore |
| 16 | Manual app checklist | verify |
| 17 | Verification (30+ tools) | verify |
| 18 | iCloud config sync | sync |

---

## Migration Workflow

### On your OLD Mac:

```bash
cd ~/mac-dev-setup
./audit.sh                    # 1. Scan current state
./backup.sh                   # 2. Export configs + encrypted secrets
git add -A && git commit      # 3. Commit updated configs
git push                      # 4. Push to GitHub
# Transfer backups/ to new Mac via AirDrop (never push to git)
```

### On your NEW Mac:

```bash
git clone <repo> ~/mac-dev-setup
# Copy backups/ folder from old Mac
./setup.sh                    # 5. Bootstrap (18 phases)
./restore.sh backups/<ts>     # 6. Restore configs
./tests/verify.sh             # 7. Verify
```

---

## Customization

After cloning, personalize for your setup:

1. **Brewfile** — Add/remove packages to match your needs
2. **config/zshrc** — Customize aliases, PATH, prompt
3. **config/ghostty/config** — Terminal appearance and keybindings
4. **scripts/pull_models.sh** — Choose which Ollama models to download
5. **scripts/macos_defaults.sh** — Adjust macOS preferences
6. **bootstrap.sh** — Update `REPO_URL` with your GitHub username
7. **Secrets** — Store API tokens in macOS Keychain:
   ```bash
   security add-generic-password -a "$USER" -s "TOKEN_NAME" -w "value" -U
   ```

---

## Structure

```
mac-dev-setup/
  bootstrap.sh                 curl one-liner entry point
  setup.sh                     18-phase bootstrap
  audit.sh                     Pre-migration audit
  backup.sh                    Config/data/secrets export
  restore.sh                   Restore from backup
  Brewfile                     120 packages (formulae + casks + mas)
  config/
    zshrc                      Shell configuration
    ghostty/config             Terminal emulator
    starship.toml              Prompt theme (optional)
    ollama.env                 Ollama environment
    claude/                    Claude Code settings snapshot
    vscode/                    VS Code extension list + settings
    cursor/                    Cursor extension list + settings
  scripts/
    icloud-sync.sh             Mirror configs to iCloud
    git_config.sh              Git identity + SSH
    macos_defaults.sh          macOS preferences
    pull_models.sh             Download Ollama models
    restore_claude.sh          Restore Claude Code config
    restore_editors.sh         Restore VS Code + Cursor
    restore_raycast.sh         Restore Raycast prefs
  docs/
    dependencies.md            Complete package reference
    apps-inventory.md          App inventory by category
    configs-map.md             Configuration file map
    rebuild-guide.md           Fresh Mac rebuild guide
  tests/
    verify.sh                  Automated post-setup checks
    checklist.md               Manual verification items
  LaunchAgents/
    com.user.ollama.plist      Ollama background service
  backups/                     (gitignored) timestamped backups
```

## Requirements

- macOS 13+ (Apple Silicon recommended)
- Internet connection
- Admin privileges (Homebrew, macOS defaults)
- App Store sign-in (for mas apps)

## License

MIT
