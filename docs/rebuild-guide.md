# Fresh Mac Rebuild Guide

> Step-by-step guide to rebuild a fully configured development environment
> from a factory-reset Apple Silicon Mac. Estimated time: ~45 min active, ~2 hrs with downloads.

## Prerequisites

Before starting, make sure you have the following ready:

- **Apple Silicon Mac** (M4/M3/M2/M1 — any Apple Silicon chip)
- **Apple ID credentials** — needed for iCloud, App Store, and system services
- **GitHub account** — for cloning the setup repo and private project repos
- **API tokens to re-enter** — Vercel, Anthropic, Stripe, Supabase, etc.
- **Wi-Fi password** — the Mac needs internet for every download step
- **Power adapter** — the full install pulls 20+ GB; battery alone is risky
- **Optional: backup archive** from `backup.sh` — enables config restoration (editor settings, Claude Code memory, Raycast preferences, SSH keys, `.env` files)
- **Optional: Bitwarden/1Password vault access** — for retrieving passwords and tokens

---

## Phase 1: First Boot (5 minutes)

After powering on the factory-reset Mac:

1. **Language & Region** — Select your language and region. The setup assistant walks through these.

2. **Wi-Fi** — Connect to your network. Every subsequent step requires internet.

3. **Migration Assistant** — Skip this. The setup repo handles everything better than Apple's Migration Assistant, which tends to carry over stale configs and bloat.

4. **Apple ID sign-in** — Sign in with your Apple ID. This enables iCloud, App Store, and Find My Mac.

5. **iCloud setup** — When prompted, enable iCloud Drive, Keychain, and Find My Mac. iCloud Drive is important because the setup script mirrors configs there for disaster recovery.

6. **Create your local account** — Set a strong password. This becomes your Keychain password, which protects all API tokens stored later.

7. **App Store verification** — Open the **App Store** app and confirm you are signed in. The `mas` CLI tool (installed in Phase 2) requires an active App Store session to install apps. If you skip this, 30 App Store apps will fail to install.

8. **Connect to power** — Xcode Command Line Tools alone is 1+ GB. The full Brewfile pulls ~10 GB of formulae, casks, and App Store apps. Stay plugged in.

9. **System Settings check** — Open System Settings and confirm:
   - iCloud Drive is syncing (Settings > Apple ID > iCloud > iCloud Drive)
   - FileVault is enabled (Settings > Privacy & Security > FileVault)

---

## Phase 2: Bootstrap (15 minutes)

Open **Terminal.app** (it's in `/Applications/Utilities/`). You will use this for the initial bootstrap only — the setup installs Ghostty as the permanent terminal.

### Option A: Public Repo (one-liner)

If the setup repo is public, run this single command:

```bash
curl -fsSL https://raw.githubusercontent.com/$USER/mac-dev-setup/main/bootstrap.sh | bash
```

**What the bootstrap script does, step by step:**

1. Checks for Xcode CLI tools — installs them if missing (a system dialog may appear)
2. Checks for Homebrew — installs it from the official installer script
3. Evaluates `brew shellenv` to add `/opt/homebrew/bin` to `$PATH` for the current session
4. Checks for Git — installs via Homebrew if missing
5. Clones the setup repo to `~/Desktop/DEV/mac-setup/`
6. Makes `setup.sh` executable and runs it, forwarding any arguments you passed

### Option B: Private Repo (manual bootstrap)

If the repo is private, the `curl` one-liner will fail because GitHub requires authentication. Do these steps manually:

```bash
# Step 1: Install Xcode Command Line Tools
# A dialog box appears — click "Install" and wait 1-5 minutes
xcode-select --install

# Step 2: Install Homebrew (Apple Silicon path: /opt/homebrew)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Step 3: Add Homebrew to PATH for the current session
# (setup.sh makes this permanent later via .zshrc)
eval "$(/opt/homebrew/bin/brew shellenv)"

# Step 4: Install GitHub CLI and Git
brew install gh git

# Step 5: Authenticate with GitHub
# Follow the interactive prompts — choose HTTPS + browser auth
gh auth login

# Step 6: Clone the setup repo
gh repo clone $USER/mac-dev-setup ~/Desktop/DEV/mac-setup

# Step 7: Run the setup
cd ~/Desktop/DEV/mac-setup
./setup.sh
```

### setup.sh Flags

| Flag | Effect |
|------|--------|
| `--dry-run` | Show what would happen without making changes — useful for previewing |
| `--skip-restore` | Skip phases 12-15 (config restoration from backup) |
| `-h` / `--help` | Print usage information |

---

## What setup.sh Does (18 Phases Explained)

The setup script is fully idempotent. Every phase checks state before acting, so it is safe to re-run if interrupted. Each phase prints colored status: green = success, yellow = already done (skipped), red = failed, purple = dry-run.

| Phase | Name | What It Does | Estimated Time |
|-------|------|-------------|----------------|
| 1 | Xcode CLI Tools | Installs Apple's compiler toolchain (clang, make, git). Required by Homebrew and most build tools. Shows a system dialog on first install. | 1-5 min |
| 2 | Homebrew | Installs the Homebrew package manager at `/opt/homebrew/` (Apple Silicon path). Updates it if already installed. | 2-3 min |
| 3 | Brew Bundle | Runs `brew bundle` against the Brewfile. Installs 50 formulae (CLI tools), 40 casks (GUI apps), and 30 App Store apps via `mas`. This is the longest phase. | 10-20 min |
| 4 | App Store Verification | Checks that `mas` can reach the App Store and reports how many MAS apps were installed. Warns if not signed in. | <10 sec |
| 5 | Claude Code | Installs the Claude Code CLI globally via `npm install -g @anthropic-ai/claude-code`. Requires Node.js (installed in Phase 3). | 30 sec |
| 6 | uv | Installs `uv`, the fast Python package manager from Astral, via its official install script. | 10 sec |
| 7 | Bun | Installs the Bun JavaScript runtime via its official install script. Bun is used for fast JS/TS tooling. | 10 sec |
| 8 | Ollama Models | Runs `scripts/pull_models.sh` to pull 5 LLM models: `qwen3-coder:latest`, `qwen2.5-coder:14b`, `deepseek-r1:14b`, `llama3.2:3b`, and `nomic-embed-text`. Starts Ollama server if not running. Skips models already downloaded. | 5-30 min (depends on bandwidth; models total ~20 GB) |
| 9 | Git + SSH | Runs `scripts/git_config.sh`. Prompts for name/email (if not already set), sets Git defaults (`defaultBranch=main`, `pull.rebase=true`, `push.autoSetupRemote=true`, editor=`code --wait`), generates an ed25519 SSH key if none exists, and prints the public key. | 1 min |
| 10 | macOS Defaults | Runs `scripts/macos_defaults.sh`. Applies developer-friendly system preferences. See table below. Restarts Dock and Finder to apply changes. | <10 sec |
| 11 | Symlink Configs | Links dotfiles from the repo into their expected locations. Backs up existing files as `*.bak`. Also installs the Ollama LaunchAgent plist. Linked files: `.zshrc`, `ghostty/config`, `starship.toml` (optional). | <10 sec |
| 12 | Claude Code Restore | Restores Claude Code settings, plugins metadata, and project memories from the most recent backup in `backups/`. Skipped if `--skip-restore` or no backup found. | <10 sec |
| 13 | Editor Settings Restore | Restores VS Code and Cursor settings, keybindings, and extension lists from backup. Extensions are reinstalled from the saved list. Skipped if `--skip-restore` or no backup found. | 1-3 min |
| 14 | Raycast Restore | Restores Raycast preferences plist from backup. Note: full Raycast config import still requires manual UI action. Skipped if `--skip-restore` or no backup found. | <10 sec |
| 15 | Project Data Restore | Restores non-git project artifacts (project data archives) and clones git repos from the saved inventory. Skipped if `--skip-restore` or no backup found. | 1-5 min |
| 16 | Manual App Checklist | Scans `/Applications/` for apps that are NOT managed by Homebrew or the App Store. Lists which ones need manual download (Adobe, Logitech, etc.). Informational only — does not install anything. | <10 sec |
| 17 | Verification | Checks that 30+ CLI tools are in `$PATH` (`git`, `gh`, `node`, `python3`, `uv`, `bun`, `ollama`, `claude`, `bat`, `eza`, `fzf`, `rg`, `fd`, `jq`, `yq`, `tmux`, `stow`, `starship`, `zoxide`, `lazygit`, `ncdu`, `htop`, `btop`, `mas`, `deno`, `ffmpeg`, `pandoc`). Reports pass/fail counts. | <10 sec |
| 18 | iCloud Sync | Mirrors config files and docs to iCloud Drive at `~/Library/Mobile Documents/com~apple~CloudDocs/@ BACKUPS & CONFIGURATIONS/mac-setup-mirror/`. This creates a read-only copy in iCloud for disaster recovery. | <10 sec |

### macOS Defaults Applied in Phase 10

| Category | Setting | Value |
|----------|---------|-------|
| Dock | Auto-hide | Enabled |
| Dock | Icon size | 36 pixels |
| Dock | Auto-hide delay | 0 seconds (instant) |
| Dock | Animation speed | 0.3 seconds (fast) |
| Dock | Show recent apps | Disabled |
| Dock | Minimize effect | Scale (not Genie) |
| Finder | Show file extensions | All extensions visible |
| Finder | Path bar | Visible at bottom |
| Finder | Status bar | Visible |
| Finder | Default view | List view |
| Finder | Folders first | Enabled |
| Finder | Extension change warning | Disabled |
| Finder | ~/Library | Visible (unhidden) |
| Keyboard | Key repeat rate | 2 (very fast) |
| Keyboard | Initial repeat delay | 15 (short) |
| Keyboard | Auto-correct | Disabled |
| Keyboard | Auto-capitalize | Disabled |
| Keyboard | Smart dashes | Disabled |
| Keyboard | Smart quotes | Disabled |
| Screenshots | Save location | `~/Screenshots/` |
| Screenshots | Format | PNG |
| Screenshots | Shadow | Disabled |
| Trackpad | Natural scroll | Disabled (traditional) |
| Trackpad | Tap to click | Enabled |
| Mission Control | Auto-rearrange Spaces | Disabled (fixed order) |

---

## Phase 3: Post-Setup Manual Configuration (20 minutes)

These steps require human interaction and cannot be automated by the setup script.

### 3.1 SSH Key Setup

Phase 9 generates an ed25519 SSH key automatically. You now need to register it with GitHub:

```bash
# Copy the public key to clipboard
pbcopy < ~/.ssh/id_ed25519.pub

# Or view it
cat ~/.ssh/id_ed25519.pub
```

1. Go to [github.com/settings/keys](https://github.com/settings/keys)
2. Click **New SSH key**
3. Title: something like "MacBook Pro M2 Max" (identify the machine)
4. Paste the key
5. Click **Add SSH key**

Test the connection:

```bash
ssh -T git@github.com
# Expected: "Hi $USER! You've successfully authenticated..."
```

If you have backup SSH keys (from `backup.sh`), the restore process in Phase 6 of `restore.sh` will decrypt and place them at `~/.ssh/` with correct permissions (600 for private keys, 644 for public keys). In that case, skip the GitHub registration step above — your old key is already registered.

### 3.2 API Token Storage (macOS Keychain)

This system stores API tokens in the macOS Keychain, not in dotfiles or `.env` files. The Keychain is encrypted at rest using your Mac login password and is unlocked automatically when you log in.

**How it works:**

- Tokens are stored as "generic passwords" in the **login** keychain
- They appear in the **Keychain Access** app (or the Passwords app in newer macOS versions)
- The `.zshrc` reads tokens from Keychain on shell startup using `security find-generic-password`
- Tokens are available as environment variables in every terminal session

**Adding a token:**

```bash
# Add or update a token (-U flag updates if it already exists)
security add-generic-password -a "$USER" -s "VERCEL_TOKEN" -w "your-token-here" -U
security add-generic-password -a "$USER" -s "ANTHROPIC_API_KEY" -w "sk-ant-..." -U
security add-generic-password -a "$USER" -s "SUPABASE_ACCESS_TOKEN" -w "sbp_..." -U
```

**Reading a token (to verify):**

```bash
security find-generic-password -a "$USER" -s "VERCEL_TOKEN" -w
```

**Tokens you may need to store:**

| Token Name | Where to Get It |
|------------|----------------|
| `VERCEL_TOKEN` | [vercel.com/account/tokens](https://vercel.com/account/tokens) |
| `ANTHROPIC_API_KEY` | [console.anthropic.com/settings/keys](https://console.anthropic.com/settings/keys) |
| `SUPABASE_ACCESS_TOKEN` | [supabase.com/dashboard/account/tokens](https://supabase.com/dashboard/account/tokens) |
| `STRIPE_SECRET_KEY` | [dashboard.stripe.com/apikeys](https://dashboard.stripe.com/apikeys) |

**Important notes about Keychain:**

- Keychain does NOT sync to Bitwarden or 1Password — these are completely separate systems
- For cross-device backup, manually store a copy of tokens in your password manager
- Keychain is tied to the local Mac user account — migrating to a new Mac requires re-entering tokens
- The `backup.sh` script does NOT back up Keychain tokens (by design — they require interactive passphrase)

### 3.3 App Configuration Imports

If you have config exports from a previous Mac (created by `backup.sh` or exported manually to iCloud), import them now:

**Raycast:**
1. Open Raycast (press `Cmd+Space` or launch from `/Applications/`)
2. Go to Settings (gear icon) > Advanced
3. Click **Import** and select the export file from iCloud Drive
4. Location: `~/Library/Mobile Documents/com~apple~CloudDocs/@ BACKUPS & CONFIGURATIONS/`
5. Or use the Raycast plist restored by `restore.sh` (but manual import is more reliable)

**Rectangle (window management):**
1. Open Rectangle from `/Applications/`
2. Go to Preferences
3. Click **Import** and select the JSON file from iCloud Drive
4. This restores all window snapping hotkeys

**Stats (system monitor):**
1. Open Stats from the menu bar (or `/Applications/`)
2. Go to Preferences
3. Import the plist from your backup
4. This restores which sensors are visible in the menu bar

### 3.4 App Sign-ins

These apps are installed by the Brewfile but require manual sign-in:

| App | Notes |
|-----|-------|
| 1Password | Sign in with account credentials; unlock vault |
| NordVPN | Sign in; may need 2FA |
| Google Drive | Sign in with Google account; choose which folders to sync |
| Notion | Sign in; workspaces sync automatically |
| Claude | Sign in with Anthropic account |
| ChatGPT | Sign in with OpenAI account |
| Bitwarden | Sign in; vault syncs automatically |
| Mimestream | Sign in with Google account for email |
| Arc | Sign in with Arc account to sync tabs, spaces, and settings |
| Brave Browser | Optionally sign in for sync |
| Obsidian | Open vault from local directory |
| Docker | Sign in to Docker Hub (optional) |
| Xcode | Sign in with Apple ID (Settings > Accounts) |

### 3.5 Ollama Model Verification

Phase 8 pulls 5 models automatically. Verify they are all present:

```bash
# List all downloaded models
ollama list
```

Expected models:

| Model | Size | Purpose |
|-------|------|---------|
| `qwen3-coder:latest` | ~5 GB | Daily driver for Claude Code local mode |
| `qwen2.5-coder:14b` | ~9 GB | Dense code specialist |
| `deepseek-r1:14b` | ~9 GB | Reasoning model |
| `llama3.2:3b` | ~2 GB | Lightweight tasks |
| `nomic-embed-text` | ~274 MB | Text embeddings |

If any are missing, pull them manually:

```bash
ollama pull qwen3-coder
ollama pull qwen2.5-coder:14b
```

Verify a model works:

```bash
ollama run qwen3-coder "Say hello in one sentence"
```

Check Ollama environment variables are set (these are in `.zshrc`):

```bash
echo $OLLAMA_CONTEXT_LENGTH    # Should be 16384
echo $OLLAMA_MAX_LOADED_MODELS # Should be 1
echo $OLLAMA_KV_CACHE_TYPE     # Should be q8_0
```

### 3.6 Claude Code Setup

Claude Code is installed globally in Phase 5. Configure it:

```bash
# First run — creates ~/.claude/ directory structure
claude

# Verify installation
claude --version
```

On first run, Claude Code will:
1. Create `~/.claude/` directory
2. Prompt for Anthropic API key (if `ANTHROPIC_API_KEY` is not already in Keychain/env)
3. Download plugins (if `installed_plugins.json` was restored from backup)

If restoring from backup, verify:
- `~/.claude/settings.json` exists and has your settings
- `~/.claude/CLAUDE.md` exists (global instructions)
- Plugin count matches expectations: check `~/.claude/plugins/installed_plugins.json`

**Local mode aliases** (for using Ollama models instead of the Anthropic API):

```bash
# See all available aliases
cc-help

# Quick test with local model
cc-local   # Uses qwen3-coder via Ollama, --bare mode
```

### 3.7 Terminal Configuration

Open Ghostty (installed via Brewfile):

1. The config is symlinked in Phase 11: `~/.config/ghostty/config` points to the repo
2. Verify the font loads: JetBrains Mono Nerd Font (installed via Brewfile)
3. Enable **Quake mode** (dropdown terminal on `Ctrl+``):
   - System Settings > Privacy & Security > Accessibility
   - Add Ghostty to the list and enable it
   - This is required for the global hotkey to work

### 3.8 Shell Verification

Open a new terminal window (or `source ~/.zshrc`) and verify:

```bash
# Aliases work
ll          # Should use eza for colored file listing
cc-help     # Should print Claude Code alias reference

# Zoxide works
z Desktop   # Should jump to ~/Desktop

# Tools are in PATH
which bat rg fd fzf jq   # All should resolve to /opt/homebrew/bin/
```

---

## Phase 4: Verification (10 minutes)

### Automated Verification

Run the verification suite:

```bash
cd ~/Desktop/DEV/mac-setup
./tests/verify.sh
```

**What it checks (60+ items):**

- **CLI tools** (24 required): `git`, `gh`, `brew`, `node`, `npm`, `python3`, `uv`, `bun`, `bat`, `eza`, `fzf`, `rg`, `fd`, `jq`, `yq`, `tmux`, `stow`, `starship`, `zoxide`, `ollama`, `claude`, `btop`, `htop`, plus 10 optional tools
- **GUI applications** (10 required): Ghostty, Cursor, VS Code, Arc, Raycast, and others
- **Optional apps** (9 checked): Docker, 1Password, ChatGPT, Claude, Brave, IINA, VLC, Stats, Rectangle
- **Config symlinks** (3): `.zshrc`, `starship.toml`, `ghostty/config` — verifies they are symlinks, not copies
- **Claude Code**: `~/.claude/` exists, `settings.json` present, plugins metadata present
- **SSH**: `~/.ssh/` exists, key files present
- **Ollama**: service responds to `ollama list`
- **Editor extensions**: VS Code and Cursor have 10+ extensions each

The script prints a summary: `X passed, Y failed, Z warnings`.

### Manual Checklist

Walk through `tests/checklist.md` for items that cannot be verified automatically:

```bash
cat ~/Desktop/DEV/mac-setup/tests/checklist.md
```

**Terminal & Shell:**
- [ ] Open Ghostty — verify font (JetBrains Mono), dark theme, padding
- [ ] Starship prompt shows git branch, node version, python version
- [ ] `z` (zoxide) jumps to recent directories
- [ ] `ll` (eza alias) shows colored file listing
- [ ] `cat` (bat alias) shows syntax highlighting

**Ollama & LLM:**
- [ ] `ollama list` shows 5 models
- [ ] `ollama run qwen3-coder "hello"` responds
- [ ] Ollama LaunchAgent is loaded: `launchctl list | grep ollama`

**Editors:**
- [ ] VS Code opens, extensions loaded (80+ expected)
- [ ] Cursor opens, extensions loaded (80+ expected)
- [ ] Settings and keybindings match expectations

**Claude Code:**
- [ ] `claude` launches successfully
- [ ] Plugins download on first run
- [ ] Settings applied (`~/.claude/settings.json`)

**Git & SSH:**
- [ ] `git config user.name` returns correct name
- [ ] `ssh -T git@github.com` authenticates
- [ ] `gh auth status` shows authenticated

**macOS Preferences:**
- [ ] Dock auto-hides, small icon size, no recent apps
- [ ] Finder shows file extensions, path bar visible
- [ ] Keyboard repeat is fast
- [ ] Tap to click works on trackpad

---

## Phase 5: Ongoing Maintenance

### Keeping Everything Updated

The `update-dev` script is the comprehensive updater for all package managers:

```bash
update-dev
```

This updates Homebrew, npm globals, pipx, Ollama models, and more in a single command.

For manual updates:

```bash
# Homebrew only
brew update && brew upgrade && brew cleanup

# Ollama models
ollama pull qwen3-coder
ollama pull qwen2.5-coder:14b

# Claude Code
npm update -g @anthropic-ai/claude-code

# uv
uv self update

# Bun
bun upgrade
```

### Re-syncing Configs to iCloud

After changing configs (`.zshrc`, Ghostty, Brewfile), sync the mirror to iCloud:

```bash
cd ~/Desktop/DEV/mac-setup
./scripts/icloud-sync.sh
```

This copies config files and docs to `~/Library/Mobile Documents/com~apple~CloudDocs/@ BACKUPS & CONFIGURATIONS/mac-setup-mirror/`. The mirror is read-only — always edit the source files in the git repo.

### Creating New Backups

Before migrating to a new Mac or as a periodic checkpoint:

```bash
cd ~/Desktop/DEV/mac-setup
./backup.sh
```

**Important:** `backup.sh` is interactive — it prompts for an encryption passphrase (for `.env` files and SSH keys). It must be run directly in a terminal, not from a script or CI.

The backup creates a timestamped directory under `backups/` containing:
1. Claude Code settings, plugins, and project memories
2. VS Code and Cursor settings, keybindings, and extension lists
3. Raycast preferences plist
4. Project data archives (project artifacts)
5. Git repo inventory (names, remotes, branches)
6. Encrypted secrets (`.env` files and SSH keys)
7. System snapshot (Brewfile dump, App Store list, application inventory)
8. SHA-256 manifest for integrity verification

Available flags:

| Flag | Effect |
|------|--------|
| `--skip-secrets` | Skip `.env` file and SSH key backup (no encryption prompt) |
| `--skip-projects` | Skip project archive and git repo inventory |

**Security:** The `backups/` directory is in `.gitignore` and must NEVER be pushed to git. Transfer to a new Mac via AirDrop, USB drive, or encrypted cloud storage.

### Adding New Tools

When you install a new tool that should survive a rebuild:

1. **Install it:** `brew install <tool>` or `brew install --cask <app>`
2. **Add to Brewfile:** Add the line with a comment describing it
3. **Update docs:** Add to `docs/dependencies.md` if it is a key tool
4. **Sync to iCloud:** `./scripts/icloud-sync.sh`
5. **Commit:** Push changes to the git repo

### Pre-Migration Audit

Before rebuilding or migrating, run the audit to find gaps:

```bash
cd ~/Desktop/DEV/mac-setup
./audit.sh
```

The audit compares your installed state against the Brewfile and reports:
- Formulae/casks installed but NOT in Brewfile (gap — add them)
- Apps not managed by Homebrew or App Store (manual install list)
- Claude Code plugin count and settings status
- Editor extension counts
- Git repos with uncommitted or unpushed changes
- `.env` files that need backing up

---

## What's NOT Automated

| Item | Why | How to Handle |
|------|-----|---------------|
| Adobe Creative Cloud | Proprietary installer, requires sign-in | Download from [adobe.com](https://www.adobe.com) |
| Adobe Photoshop / Illustrator / Lightroom | Installed via Creative Cloud | Install through Creative Cloud app |
| Logitech Options+ | Proprietary driver package | Download from [logitech.com](https://www.logitech.com/software/logi-options-plus.html) |
| GoPro Webcam | Proprietary | Download from GoPro website |
| Hik-Connect | Proprietary | Download from App Store or website |
| Macs Fan Control | Not in Homebrew | Download from developer website |
| CompressX | Not in Homebrew | Download from developer website |
| App sign-ins | Require credentials + 2FA | Sign in manually to each app |
| Keychain API tokens | Security — cannot be scripted safely | Add via `security add-generic-password` CLI |
| Raycast full config | Binary plist, needs app-level export/import | Export from old Mac, import via Raycast UI |
| Rectangle config | JSON export from app UI | Export from old Mac, import via Rectangle preferences |
| Stats config | Plist export from app UI | Export from old Mac, import via Stats preferences |
| SSH key registration | Requires GitHub web UI | Paste public key at github.com/settings/keys |
| Communication apps (Slack, Discord, Teams) | Excluded by design — install only if needed | `brew install --cask slack` |

---

## Troubleshooting

### Common Issues

#### Brew bundle fails on some casks

Casks may fail if the app was already installed manually (e.g., dragged from a DMG). Homebrew refuses to overwrite.

```bash
# Force reinstall a specific cask
brew install --cask <name> --force

# Or uninstall the manual copy first
sudo rm -rf "/Applications/<App Name>.app"
brew install --cask <name>
```

#### `mas install` fails

The `mas` CLI requires an active App Store session. Common causes:

- **Not signed in:** Open App Store.app and sign in manually
- **Purchase history required:** Some apps need to have been "purchased" (even free ones) on your Apple ID first. Open the App Store, search for the app, and click Get/Install manually once.
- **macOS version mismatch:** Some apps require a newer macOS version

```bash
# Check if signed in
mas account

# Retry a specific app (find the ID in the Brewfile)
mas install 937984704   # Amphetamine
```

#### Xcode CLI tools dialog does not appear

The install dialog sometimes hangs or does not appear. Fix:

```bash
# Remove any partial install and retry
sudo rm -rf /Library/Developer/CommandLineTools
xcode-select --install
```

If the dialog still does not appear, download Xcode CLI Tools manually from [developer.apple.com/download/more/](https://developer.apple.com/download/more/).

#### Ollama out of memory

The M2 Max with 32 GB unified memory can run one 26B-parameter model OR two 14B models simultaneously. If Ollama crashes or responses are garbled:

```bash
# Check what is loaded
ollama ps

# Stop all models
ollama stop qwen3-coder

# Reduce max loaded models (already set in .zshrc)
export OLLAMA_MAX_LOADED_MODELS=1

# Reduce context length if still OOM
export OLLAMA_CONTEXT_LENGTH=8192
```

Memory budget for M2 Max 32 GB:
- macOS + apps: ~8-10 GB
- One 26B model (gemma4:26b): ~18 GB with q8 KV cache
- One 14B model (qwen2.5-coder:14b): ~10 GB
- Embedding model (nomic-embed-text): ~300 MB

#### Claude Code local mode is slow

Local models via Ollama are significantly slower than the Anthropic API. Expected performance on M2 Max:

- `qwen3-coder`: ~1-2s time-to-first-token, ~30-40 tok/s
- `gemma4:26b`: ~20-30s time-to-first-token, ~15-20 tok/s

Tips:
- Use `--bare` flag (the `cc-local` alias includes this). It skips CLAUDE.md, hooks, plugins, and MCP, cutting baseline prefill from ~30k to ~2-3k tokens.
- Do not use `cc-local-full` variants on 32 GB unless you need project context — they are 10x slower.
- For anything requiring large file reads or high accuracy, use `cc` (Anthropic API) instead.

#### Ghostty Quake terminal not working

The `Ctrl+`` global hotkey (dropdown/quake terminal) requires accessibility permissions:

1. System Settings > Privacy & Security > Accessibility
2. Click the `+` button, navigate to `/Applications/Ghostty.app`
3. Enable the toggle
4. Restart Ghostty

If the hotkey still does not work, check System Settings > Keyboard > Keyboard Shortcuts > App Shortcuts for conflicts.

#### Homebrew PATH not working after install

On Apple Silicon, Homebrew installs to `/opt/homebrew/`. The default Terminal.app does not source `.zshrc` on first run after install. Fix:

```bash
# Add Homebrew to PATH for the current session
eval "$(/opt/homebrew/bin/brew shellenv)"

# Verify
which brew   # Should show /opt/homebrew/bin/brew
```

Once `setup.sh` symlinks `.zshrc` in Phase 11, this is handled automatically for all future sessions.

#### Git config prompts during setup

Phase 9 interactively asks for your name and email if Git is not yet configured. On a fresh Mac, this always runs. Enter your full name and the email associated with your GitHub account.

```bash
# Verify after setup
git config --global user.name
git config --global user.email
```

#### iCloud sync script fails

The iCloud sync script expects a specific folder structure in iCloud Drive:

```
~/Library/Mobile Documents/com~apple~CloudDocs/@ BACKUPS & CONFIGURATIONS/
```

If this folder does not exist, iCloud Drive may not be fully synced yet. Wait a few minutes after enabling iCloud, then:

```bash
mkdir -p "$HOME/Library/Mobile Documents/com~apple~CloudDocs/@ BACKUPS & CONFIGURATIONS"
./scripts/icloud-sync.sh
```

#### Editor extensions not restoring

VS Code and Cursor extensions are restored from a saved list (`extensions.txt`). If the restore script does not run (no backup) or extensions fail to install:

```bash
# Manually install all extensions from the list
cat ~/Desktop/DEV/mac-setup/config/vscode/extensions.txt | xargs -L 1 code --install-extension
cat ~/Desktop/DEV/mac-setup/config/cursor/extensions.txt | xargs -L 1 cursor --install-extension
```

---

## Quick Reference Commands

| Task | Command |
|------|---------|
| Full system update | `update-dev` |
| Re-run setup (safe, idempotent) | `cd ~/Desktop/DEV/mac-setup && ./setup.sh` |
| Preview setup without changes | `./setup.sh --dry-run` |
| Check what is installed | `brew list`, `brew list --cask`, `mas list` |
| iCloud config sync | `./scripts/icloud-sync.sh` |
| Create backup | `./backup.sh` |
| Create backup (no secrets) | `./backup.sh --skip-secrets` |
| Restore from backup | `./restore.sh backups/<timestamp>` |
| Verify setup | `./tests/verify.sh` |
| Pre-migration audit | `./audit.sh` |
| Manual verification checklist | `cat tests/checklist.md` |
| Claude Code (remote, Anthropic API) | `cc` or `claude` |
| Claude Code (local, Ollama) | `cc-local` |
| Claude Code (skip permissions) | `cc-skip` |
| All Claude Code aliases | `cc-help` |
| Store API token in Keychain | `security add-generic-password -a "$USER" -s "NAME" -w "value" -U` |
| Read API token from Keychain | `security find-generic-password -a "$USER" -s "NAME" -w` |
| Loaded Ollama models | `ollama ps` |
| All Ollama models | `ollama list` |
| Pull a new model | `ollama pull <model>` |
| System monitor (terminal) | `btop` or `htop` |
| System monitor (CPU/GPU/ANE) | `sudo mactop` |
| Disk usage analyzer | `ncdu` |
| Git TUI | `lazygit` |

---

## File Structure Reference

```
~/Desktop/DEV/mac-setup/
├── setup.sh                    # Main 18-phase bootstrap script
├── bootstrap.sh                # One-liner entry point (curl-friendly)
├── backup.sh                   # Pre-migration backup creator
├── restore.sh                  # Post-migration backup restorer
├── audit.sh                    # Pre-migration readiness audit
├── Brewfile                    # 50 formulae + 40 casks + 30 MAS apps
├── config/
│   ├── zshrc                   # Shell config (symlinked to ~/.zshrc)
│   ├── ghostty/config          # Terminal config (symlinked)
│   ├── starship.toml           # Prompt config (symlinked)
│   ├── claude/                 # Claude Code settings snapshot
│   ├── vscode/                 # VS Code settings + extension list
│   └── cursor/                 # Cursor settings + extension list
├── scripts/
│   ├── git_config.sh           # Git identity + SSH key setup
│   ├── macos_defaults.sh       # System preferences automation
│   ├── pull_models.sh          # Ollama model downloader
│   ├── icloud-sync.sh          # Config mirror to iCloud Drive
│   ├── restore_claude.sh       # Claude Code restore helper
│   ├── restore_editors.sh      # Editor restore helper
│   └── restore_raycast.sh      # Raycast restore helper
├── LaunchAgents/
│   └── com.user.ollama.plist   # Auto-start Ollama on login
├── tests/
│   ├── verify.sh               # Automated post-setup checks
│   └── checklist.md            # Manual verification checklist
├── docs/
│   ├── rebuild-guide.md        # This file
│   ├── dependencies.md         # Full dependency inventory
│   ├── apps-inventory.md       # Application catalog
│   ├── configs-map.md          # Config file locations
│   └── index.html              # GitHub Pages site
└── backups/                    # Created by backup.sh (gitignored)
    └── <timestamp>/
        ├── claude/             # Settings, plugins, memories
        ├── editors/            # VS Code + Cursor
        ├── raycast/            # Preferences plist
        ├── project-data/       # Archives + git repo list
        ├── secrets/            # Encrypted .env + SSH keys
        ├── system/             # Brewfile dump, app list
        └── manifest.json       # SHA-256 integrity manifest
```
