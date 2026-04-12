# Configuration Reference

> Every configuration file in this development environment — where it lives,
> what it controls, how to back it up, and how to restore it.
> Designed to be read by both humans and LLMs for setup assistance and troubleshooting.

---

## How Configs Flow

```
mac-setup/config/zshrc  ──symlink──>  ~/.zshrc (live)
mac-setup/config/ghostty/config  ──symlink──>  ~/.config/ghostty/config (live)
mac-setup/config/starship.toml  ──symlink──>  ~/.config/starship.toml (live, optional)

backup.sh  ──captures──>  backups/<timestamp>/  (Claude Code, editors, Raycast)
icloud-sync.sh  ──mirrors──>  iCloud/mac-setup-mirror/  (configs + docs, no secrets)
```

Editing a symlinked live file also edits the repo copy — one source of truth.

---

## Locations Overview

| Config | Live Location | Backed Up To | What It Controls |
|--------|--------------|--------------|-----------------|
| zshrc | `~/.zshrc` | repo + iCloud | Shell, aliases, PATH, Ollama, Claude Code |
| Ghostty | `~/.config/ghostty/config` | repo + iCloud | Terminal appearance, keys, Quake dropdown |
| SSH | `~/.ssh/config` | manual | Remote server access, GitHub key |
| Git | `~/.gitconfig` | `git_config.sh` recreates | Identity, defaults, editor |
| GitHub CLI | `~/.config/gh/config.yml` | manual | Protocol, CLI aliases |
| Claude Code | `~/.claude/settings.json` | `backup.sh` | Plugins, hooks, permissions |
| VS Code | `~/Library/Application Support/Code/User/settings.json` | `backup.sh` | Editor settings, extensions |
| Cursor | `~/Library/Application Support/Cursor/User/settings.json` | `backup.sh` | Editor settings, AI config |
| Raycast | `~/Library/Preferences/com.raycast.macos.plist` | `backup.sh` + iCloud export | Extensions, snippets, hotkeys |
| Rectangle | exported JSON | iCloud | Window management shortcuts |
| Stats.app | exported plist | iCloud | Menu bar monitors |
| Ollama Agent | `~/Library/LaunchAgents/com.user.ollama.plist` | repo | Auto-start Ollama on boot |
| Starship | `~/.config/starship.toml` | repo | Prompt theme (optional) |

---

## Shell Configuration (~/.zshrc)

The shell config is 307 lines and controls the entire command-line experience.

### PATH Order (first match wins)

```
1. /opt/homebrew/bin          # Homebrew formulae
2. /opt/homebrew/sbin         # Homebrew system tools
3. /opt/homebrew/opt/python@3.13/bin  # Python 3.13
4. $HOME/bin                  # Custom scripts (update-dev, etc.)
5. $HOME/.bun/bin             # Bun JS runtime
6. $HOME/.antigravity/antigravity/bin  # Antigravity app
7. /usr/local/bin             # System tools
8. /usr/bin, /bin, /usr/sbin, /sbin    # macOS defaults
```

`typeset -U PATH` deduplicates at the end.

### Complete Alias Reference

#### Navigation
| Alias | Command | Purpose |
|-------|---------|---------|
| `ll` | `ls -la` | Long listing with hidden files |
| `la` | `ls -A` | All files except . and .. |
| `l` | `ls -CF` | Compact listing |
| `..` | `cd ..` | Up one directory |
| `...` | `cd ../..` | Up two directories |
| `c` | `clear` | Clear terminal |

#### Git
| Alias | Command | Purpose |
|-------|---------|---------|
| `gs` | `git status` | Working tree status |
| `ga` | `git add` | Stage changes |
| `gc` | `git commit` | Create commit |
| `gp` | `git push` | Push to remote |
| `gl` | `git pull` | Pull from remote |

#### Claude Code (Remote — Anthropic API)
| Alias | Command | Purpose |
|-------|---------|---------|
| `cc` | `claude` | Normal mode |
| `cc-skip` | `claude --dangerously-skip-permissions` | Skip all permission prompts |
| `claude-full` | `claude --append-system-prompt-file ~/.claude/orientation.md` | With orientation prompt |
| `claude-orient` | `claude --append-system-prompt "Read CLAUDE.md..."` | Ecosystem integrity check |

#### Claude Code (Local — Ollama)

Bare mode (`--bare`): skips CLAUDE.md, hooks, plugins, MCP. Cuts prefill from ~30K to ~2-3K tokens. Essential for 32GB RAM.

| Alias | Model | Mode | Use Case |
|-------|-------|------|----------|
| `cc-local` | qwen3-coder | bare | **Daily driver** — fast TTFT, strong tool use |
| `cc-local-heavy` | gemma4:26b | bare | Highest quality, slow TTFT (24s) |
| `cc-local-tiny` | gemma4:e4b | bare | Smallest tool-capable, multimodal |
| `cc-local-coder` | qwen2.5-coder:14b | bare | Dense code specialist |
| `cc-local-full` | qwen3-coder | full | Only when project context needed |
| `cc-local-heavy-full` | gemma4:26b | full | Quality + context (very slow) |
| `cc-help` | — | — | Print all aliases with descriptions |

#### Custom Scripts
| Alias | Target | Purpose |
|-------|--------|---------|
| `update-dev` | `$HOME/bin/update-dev` | Update all package managers |
| *(add yours)* | | |

### Functions

| Function | Purpose | Usage |
|----------|---------|-------|
| `claude()` | Wraps `claude` CLI to set terminal title to `$PWD` | Automatic |
| `update_all()` | Updates Homebrew + pipx | `update_all` |
| `mkcd <dir>` | Create directory and cd into it | `mkcd my-project` |
| `mkvenv <name>` | Create Python venv in `~/.virtualenvs/` | `mkvenv my-env` |
| `workon [name]` | Activate venv, or list all if no arg | `workon my-env` |

### Prompt

Git-aware prompt with color coding:
```
green(user@host) blue(~/path) yellow((branch)) $
```

Uses `vcs_info` for git branch display. No third-party prompt tool required (Starship is available but not active).

### Ghostty Per-Pane Color Hook

Each terminal pane gets a unique background color based on its TTY number. Only fires inside Ghostty.

| Index | Color | Hex |
|-------|-------|-----|
| 0 | Cobalt | `#0d2040` |
| 1 | Emerald | `#0d3820` |
| 2 | Magenta | `#380d28` |
| 3 | Gold | `#38280d` |
| 4 | Purple | `#280d40` |
| 5 | Teal | `#0d3838` |
| 6 | Rust | `#381a0d` |
| 7 | Grass | `#1a380d` |

### Ollama Environment Variables

| Variable | Value | Purpose |
|----------|-------|---------|
| `OLLAMA_CONTEXT_LENGTH` | `16384` | 16K context — safe for M2 Max 32GB with 26B models |
| `OLLAMA_MAX_LOADED_MODELS` | `1` | Only one model in RAM at a time |
| `OLLAMA_KV_CACHE_TYPE` | `q8_0` | 8-bit KV cache — cuts memory ~50% |
| `OLLAMA_FLASH_ATTENTION` | `1` | Metal flash-attention kernel — further memory savings |
| `OLLAMA_KEEP_ALIVE` | `30m` | Keep model warm between invocations |

### History

- 10,000 entries, saved to `~/.zsh_history`
- Shared across sessions (`SHARE_HISTORY`)
- Duplicates ignored (`HIST_IGNORE_DUPS`)

---

## Secrets Strategy

**Rule: Never store tokens in config files.** All API tokens go in macOS Keychain.

### Adding a Token

```bash
security add-generic-password -a "$USER" -s "TOKEN_NAME" -w "token-value" -U
```

The `-U` flag updates if the entry already exists.

### Reading a Token

```bash
export MY_TOKEN=$(security find-generic-password -a "$USER" -s "TOKEN_NAME" -w 2>/dev/null)
```

### Current Tokens

| Token | Keychain Service Name | Used By |
|-------|-----------------------|---------|
| Vercel | `VERCEL_TOKEN` | Vercel CLI, deployments |

### Machine-Specific Overrides

`~/.zshrc.local` is sourced if it exists. Use for:
- Additional API tokens
- Machine-specific PATH entries
- Overrides that shouldn't be committed

This file is NOT tracked in git and NOT synced to iCloud.

### Keychain + Passwords App + Bitwarden

- Keychain items appear in the **Passwords app** (macOS 15+) under your login keychain
- They are encrypted at rest and unlocked with your Mac login password
- Keychain does **NOT** sync to Bitwarden — these are separate stores
- For cross-device backup: manually add tokens to Bitwarden too
- The `security` CLI is the standard tool for shell integration

---

## Terminal Configuration (Ghostty)

File: `~/.config/ghostty/config` (symlinked from repo)

### Appearance
| Setting | Value | Notes |
|---------|-------|-------|
| Font | JetBrains Mono Nerd Font | Requires `font-jetbrains-mono-nerd-font` cask |
| Size | 14pt | With `font-thicken` enabled |
| Theme | Catppuccin Latte/Mocha | Auto-switches with macOS light/dark mode |
| Background | 80% opacity | With 20px blur |
| Titlebar | Transparent | macOS-native |

### Quick Terminal (Quake Mode)
| Setting | Value |
|---------|-------|
| Hotkey | `Ctrl+\`` (global, works from any app) |
| Position | Top (drops down) |
| Screen | Follows mouse |
| Auto-hide | Yes |
| Animation | 0.15s |

### Keybindings
| Shortcut | Action |
|----------|--------|
| `Cmd+T` | New tab |
| `Cmd+Shift+Left/Right` | Switch tabs |
| `Cmd+W` | Close tab/pane |
| `Cmd+D` | Split right |
| `Cmd+Shift+D` | Split down |
| `Cmd+Alt+Arrows` | Navigate splits |
| `Cmd+Shift+E` | Equalize splits |
| `Cmd+Shift+F` | Zoom split (toggle) |
| `Cmd+Plus/Minus/Zero` | Font size |
| `Cmd+Shift+,` | Reload config |

### Split Pane Styling
- Unfocused panes dim to 75% opacity
- Tinted with `#1e1e2e` (Catppuccin Mocha base)
- Divider color: `#cba6f7` (Catppuccin Mauve)
- Scrollback: 25MB

---

## Git Configuration

Created by `scripts/git_config.sh`:

| Setting | Value |
|---------|-------|
| `defaultBranch` | `main` |
| `pull.rebase` | `true` |
| `core.editor` | `code` (VS Code) |
| `push.autoSetupRemote` | `true` |
| SSH key type | `ed25519` |

The script also starts `ssh-agent` and adds the key.

---

## Claude Code Configuration

File: `~/.claude/settings.json`

| Setting | Value |
|---------|-------|
| Permission mode | `dontAsk` (no confirmation prompts) |
| Effort level | `high` |
| Auto-updates | `latest` channel |
| Voice | Enabled |

### Plugins (enabled)
claude-mem, superpowers, frontend-design, context7, code-review, feature-dev, code-simplifier, vercel

### Hooks
| Hook | Trigger | Script |
|------|---------|--------|
| `PreToolUse` Bash | Before shell commands | `safety-guard.sh` |
| `PreToolUse` Skill | Before skill invocation | `track-skill.sh` |
| `PostToolUse` Write/Edit | After file changes | `auto-format.sh` |
| `PostToolUse` Bash | After shell commands | `post-deploy-verify.sh` |
| `SessionStart` | On new session | `session-start.sh` |

---

## Editor Configuration

### VS Code
| Item | Location |
|------|----------|
| Settings | `~/Library/Application Support/Code/User/settings.json` |
| Keybindings | `~/Library/Application Support/Code/User/keybindings.json` |
| Snippets | `~/Library/Application Support/Code/User/snippets/` |
| Extensions | ~86 installed, list captured by `backup.sh` |

### Cursor
| Item | Location |
|------|----------|
| Settings | `~/Library/Application Support/Cursor/User/settings.json` |
| Keybindings | `~/Library/Application Support/Cursor/User/keybindings.json` |
| Snippets | `~/Library/Application Support/Cursor/User/snippets/` |
| Extensions | ~86 installed, list captured by `backup.sh` |

Backup: `backup.sh` saves extension lists and settings. Restore: `scripts/restore_editors.sh` reinstalls extensions from the list.

---

## App Config Exports (Manual)

These apps store config in binary/proprietary formats that can't be committed to git. Export manually and store in iCloud.

### Raycast
1. Open Raycast → Settings → Advanced → Export
2. Save `.rayconfig` file to iCloud `@ BACKUPS & CONFIGURATIONS/`
3. To restore: Raycast → Settings → Advanced → Import

### Rectangle
1. Open Rectangle → Preferences → Export
2. Save JSON to iCloud `@ BACKUPS & CONFIGURATIONS/`
3. To restore: Rectangle → Preferences → Import

### Stats.app
1. Open Stats → Preferences → Export
2. Save plist to iCloud `@ BACKUPS & CONFIGURATIONS/`
3. To restore: import plist from backup

---

## Ollama Configuration

### LaunchAgent (auto-start on boot)
File: `~/Library/LaunchAgents/com.user.ollama.plist`
- Installed by `setup.sh` Phase 11
- Runs `ollama serve` at login
- Binds to `127.0.0.1:11434` (localhost only)
- Keeps alive on crash
- Logs to `/tmp/ollama.log`

### Model Storage
- Physical location: `~/_Local_LLMs/ollama/`
- Symlink: `~/.ollama/models` → physical location
- Total size: ~65GB for 5 models

---

## macOS System Preferences

Applied by `scripts/macos_defaults.sh`:

### Dock
| Setting | Value |
|---------|-------|
| Auto-hide | Enabled |
| Icon size | 36px |
| Show recents | Disabled |
| Minimize effect | Scale |

### Finder
| Setting | Value |
|---------|-------|
| Show extensions | Yes |
| Path bar | Visible |
| Status bar | Visible |
| Default view | List |
| Folders on top | Yes |

### Keyboard
| Setting | Value |
|---------|-------|
| Key repeat rate | 2 (fast) |
| Initial delay | 15ms (short) |
| Auto-correct | Disabled |
| Auto-capitalize | Disabled |
| Smart quotes | Disabled |
| Smart dashes | Disabled |

### Screenshots
| Setting | Value |
|---------|-------|
| Save location | `~/Screenshots` |
| Drop shadow | Disabled |

---

## Backup & Restore Strategy

| Method | What It Covers | Frequency |
|--------|---------------|-----------|
| Git repo (`mac-setup/config/`) | zshrc, Ghostty, Starship, Brewfile | Every commit |
| `backup.sh` | Claude Code, editors, Raycast, project data, encrypted secrets | Before migration |
| `icloud-sync.sh` | Configs + docs mirror (no secrets) | Manual / after changes |
| iCloud manual exports | Raycast, Rectangle, Stats configs | Periodic |
| macOS Keychain | API tokens | Persistent on device |
| `git_config.sh` | Git identity + SSH key | Recreated on setup |

### What Must Be Done Manually
- App sign-ins (1Password, NordVPN, Google Drive, etc.)
- Keychain token entry
- Raycast/Rectangle/Stats config import from iCloud
- Adobe app installation
- SSH key addition to GitHub
