# Dependencies Reference

> Complete inventory of every package, application, and tool in this development environment.
> Designed to be read by both humans and LLMs for setup assistance and troubleshooting.
>
> **Target hardware**: Apple Silicon Mac (M2 Max, 32GB unified memory, macOS)
> **Shell**: zsh (`$HOME/.zshrc`)
> **All projects live in**: `$HOME/Desktop/DEV/`

## Quick Install

All packages install via one command:

```bash
brew bundle --file=Brewfile
```

This installs Homebrew formulae, casks, and Mac App Store apps in a single pass. The Brewfile also declares three custom taps:

| Tap | Provides |
|-----|----------|
| `minicodemonkey/chief` | `chief` CLI |
| `stripe/stripe-cli` | `stripe` CLI |
| `supabase/tap` | `supabase` CLI |

After `brew bundle`, the setup script (`setup.sh`) runs additional phases for Claude Code (npm), uv (curl), Bun (curl), Ollama models, Git/SSH config, macOS defaults, dotfile symlinks, and config restoration. Run `./setup.sh --dry-run` to preview without making changes.

---

## Homebrew Formulae (50 packages)

### Core Development Languages & Runtimes

**git** --- Distributed version control system.
- The foundation of all project management in this environment. Every project in `$HOME/Desktop/DEV/` is a git repo.
- Config is set by `scripts/git_config.sh` during setup (user name, email, default branch `main`, pull rebase, push autoSetupRemote).
- Key commands: `gs` (status), `ga` (add), `gc` (commit), `gp` (push), `gl` (pull) --- all aliased in `.zshrc`.
- SSH keys are generated during setup and stored at `$HOME/.ssh/`.

**gh** --- GitHub CLI for managing pull requests, issues, repos, and releases from the terminal.
- Used extensively by Claude Code for PR creation, issue management, and repository operations.
- Authenticate with: `gh auth login`
- Key commands: `gh pr create`, `gh pr view`, `gh repo clone`, `gh issue list`, `gh api`.
- Claude Code invokes `gh` directly for all GitHub-related tasks.

**node** --- Node.js JavaScript runtime (LTS via Homebrew).
- Required for: npm package management, Claude Code (`npm install -g @anthropic-ai/claude-code`), Next.js development, React/Vite builds.
- Provides `node` and `npm` commands. No version manager (nvm/n) is used --- Homebrew manages the single system version.
- npm global packages include Claude Code and any CLI tools installed via `npm install -g`.

**deno** --- Secure TypeScript/JavaScript runtime by Ryan Dahl.
- Used for scripts that benefit from built-in TypeScript support and top-level await.
- Runs TypeScript files directly without a build step: `deno run script.ts`.
- Has its own permissions model (`--allow-read`, `--allow-net`, etc.) for sandboxed execution.
- Not the primary JS runtime (Node.js is), but available for Deno-native projects.

**go** --- Go programming language (latest stable via Homebrew).
- Used for CLI tool development and any Go-based projects.
- Go modules handle dependency management (`go mod init`, `go mod tidy`).
- Binaries install to `$GOPATH/bin` (defaults to `$HOME/go/bin`).

**python@3.13** --- Python 3.13, the primary Python runtime.
- Set as default via PATH and aliases in `.zshrc`: `alias python=python3.13`, `alias pip=pip3.13`.
- PATH entry: `/opt/homebrew/opt/python@3.13/bin` is prepended to `$PATH`.
- Virtual environments created with: `python3.13 -m venv .venv` or via `uv venv`.
- Important: in non-interactive shells (Claude Code Bash tool), use `.venv/bin/python` directly --- `source activate` does not persist between commands.

**python@3.11** --- Python 3.11, kept for compatibility.
- Some older packages or projects may require 3.11. Available as `python3.11`.
- Not the default; only used when explicitly invoked.

### Package Managers & Build Tools

**mas** --- Mac App Store command-line interface.
- Installs App Store apps programmatically from the Brewfile. Requires the user to be signed into the App Store before running `brew bundle`.
- Key commands: `mas install <id>`, `mas list`, `mas search <name>`, `mas upgrade`.
- The Brewfile contains 29 App Store entries with their numeric IDs.

**pipx** --- Install and run Python CLI tools in isolated virtual environments.
- Each tool gets its own venv, preventing dependency conflicts.
- Key commands: `pipx install <package>`, `pipx upgrade-all`, `pipx list`.
- Example: `pipx install black` installs the Black formatter without polluting the global Python environment.

**uv** --- Ultra-fast Python package installer and resolver (by Astral, the Ruff team).
- 10-100x faster than pip. Written in Rust.
- Replaces pip for most operations: `uv pip install`, `uv pip compile`, `uv venv`.
- Also manages Python versions: `uv python install 3.13`.
- Installed via curl during setup (Phase 6), not via Homebrew, to get the latest version --- though it is also listed in the Brewfile as a fallback.

**xcodegen** --- Generate Xcode `.xcodeproj` files from a YAML spec (`project.yml`).
- Critical for iOS projects that use GRDB or other SPM dependencies.
- Eliminates Xcode project file merge conflicts in git.
- Workflow: edit `project.yml` -> run `xcodegen generate` -> open in Xcode.
- The generated `.xcodeproj` is gitignored; only `project.yml` is committed.

### CLI Productivity Suite

This section covers the modern Unix tool replacements that form the daily-driver CLI experience. Each replaces a legacy tool with better defaults, syntax highlighting, or performance.

**bat** --- Replaces `cat`.
- Adds syntax highlighting, line numbers, and git diff markers to file output.
- Supports paging (pipes to `less` automatically for long files).
- Integrates with `fzf` for previewing files in fuzzy search.
- Usage: `bat README.md`, `bat -l json data.json`, `bat --diff file1 file2`.
- Why over alternatives: bat is the most mature cat replacement with the broadest language support. `ccat` and `highlight` lack git integration.

**eza** --- Replaces `ls`.
- Modern ls with colors, icons (with Nerd Font), git status per file, tree view, and header rows.
- Usage: `eza -la` (long + hidden), `eza --tree --level=2`, `eza --git --long`.
- Why over alternatives: eza is the actively maintained fork of the original `exa` (now archived). `lsd` is similar but eza has better git integration.
- No aliases defined (the default `ll`, `la`, `l` aliases in `.zshrc` still use plain `ls` --- eza is used when you explicitly want its features).

**fd** --- Replaces `find`.
- Intuitive syntax, respects `.gitignore`, colorized output, and 5-10x faster than GNU find.
- Usage: `fd "\.py$"` (find Python files), `fd -t d node_modules` (find directories), `fd -e json` (find by extension).
- Works well with `fzf`: `fd --type f | fzf`.
- Why over alternatives: fd is the clear winner --- simpler syntax than `find`, faster, and sane defaults.

**fzf** --- Command-line fuzzy finder.
- Interactive filter for any list: files, command history, git branches, processes.
- Key bindings: `Ctrl-R` (fuzzy history search), `Ctrl-T` (fuzzy file finder), `Alt-C` (fuzzy cd).
- Integrates with bat for previews: `fzf --preview 'bat --color=always {}'`.
- Usage: pipe anything into it: `git branch | fzf`, `ps aux | fzf`.
- Why over alternatives: fzf is the industry standard. `skim` (sk) is a Rust clone but has less ecosystem support.

**ripgrep** --- Replaces `grep`. Binary name: `rg`.
- Extremely fast recursive search. Respects `.gitignore`, searches compressed files, supports PCRE2.
- Usage: `rg "TODO"`, `rg -t py "import"`, `rg -l "function"` (files only), `rg -C 3 "error"` (context).
- Claude Code uses ripgrep internally for its Grep tool.
- Why over alternatives: fastest grep available. `ag` (The Silver Searcher) is slower and less maintained. `ack` is even slower.

**jq** --- Command-line JSON processor.
- Parse, filter, and transform JSON. Essential for working with APIs and config files.
- Usage: `curl api | jq '.data[0].name'`, `jq '.scripts' package.json`, `jq -r '.key'` (raw output).
- Supports complex queries: `jq '[.[] | select(.status == "active")]'`.

**yq** --- Command-line YAML/XML/TOML processor (like jq but for YAML).
- Usage: `yq '.services.web.ports' docker-compose.yml`, `yq -i '.version = "2.0"' config.yml`.
- Supports in-place editing with `-i`.
- Also handles XML and TOML.

**htop** --- Interactive process viewer, replaces `top`.
- Color-coded CPU/memory bars, tree view of processes, easy kill commands.
- Usage: `htop` (interactive), `htop -u $USER` (your processes only).
- Sortable columns, searchable, filterable.

**btop** --- Resource monitor with rich graphs for CPU, memory, disk, and network.
- More visual than htop, with historical graphs and per-core CPU display.
- Shows disk I/O, network throughput, and temperature sensors.
- Usage: `btop` (interactive).
- Why both htop and btop: htop for quick process management, btop for system overview dashboards.

**mactop** --- macOS-native system monitor designed specifically for Apple Silicon.
- Shows CPU cluster usage (efficiency vs. performance cores), GPU utilization, and ANE (Neural Engine) activity.
- Critical for monitoring Ollama inference: watch GPU spike during model loading and inference.
- Usage: `sudo mactop` (requires sudo for hardware counters).

**tmux** --- Terminal multiplexer.
- Split a single terminal into multiple panes and windows. Sessions persist across disconnections.
- Key commands: `tmux new -s work`, `tmux attach -t work`, `Ctrl-b %` (vertical split), `Ctrl-b "` (horizontal split).
- Useful for long-running processes (builds, servers) that need to survive terminal closure.

**stow** --- GNU Stow, a symlink manager for dotfiles.
- Manages dotfile symlinks by mirroring directory structure. Used during setup to link config files from the repo to `$HOME`.
- Usage: `stow -d dotfiles -t $HOME zsh` (symlinks `dotfiles/zsh/.zshrc` to `$HOME/.zshrc`).
- The setup script uses a custom `link_config` function rather than raw stow, but stow is available for manual dotfile management.

**starship** --- Cross-shell prompt with minimal configuration.
- Config file: `$HOME/.config/starship.toml`.
- Shows git branch, language versions, command duration, and error codes.
- Note: the `.zshrc` uses a custom PROMPT by default (green user@host, blue path, yellow git branch). Starship is installed and configured but not activated unless you add `eval "$(starship init zsh)"` to `.zshrc`.

**zoxide** --- Smarter `cd` that learns your most-used directories.
- Tracks directory visit frequency. Type partial paths and it jumps to the best match.
- Usage: `z dev` (jumps to `$HOME/Desktop/DEV` if you visit it often), `zi` (interactive with fzf).
- Init: add `eval "$(zoxide init zsh)"` to `.zshrc` to enable.

**lazygit** --- Terminal UI for git commands.
- Full git workflow in a TUI: staging, committing, branching, rebasing, stashing, resolving conflicts.
- Usage: `lazygit` (opens in current repo).
- Why over alternatives: lazygit is the most polished git TUI. `tig` is read-only; `gitui` is newer but less feature-complete.

**ncdu** --- NCurses disk usage analyzer.
- Interactive, sortable view of what is consuming disk space. Navigate directories and delete files.
- Usage: `ncdu /` (scan from root), `ncdu $HOME` (scan home directory).
- Essential for finding large `.ollama/models`, `node_modules`, `.venv` directories consuming disk.

### LLM & AI Tools

**ollama** --- Run large language models locally on Apple Silicon.
- Models are stored at a custom path (symlinked from `$HOME/.ollama/models`).
- Runs as a LaunchAgent (`$HOME/Library/LaunchAgents/com.user.ollama.plist`) so it starts automatically at login.
- API endpoint: `http://localhost:11434` (OpenAI-compatible).
- See the [Ollama Models](#ollama-models) section for configured models and memory settings.
- See the [Claude Code Integration](#claude-code-integration) section for how Claude Code connects to Ollama.
- Key commands: `ollama list` (show installed models), `ollama ps` (show loaded model), `ollama run <model>` (chat), `ollama pull <model>` (download), `ollama serve` (start server manually).

### Media & Image Processing

**ffmpeg** --- Swiss-army knife for audio/video conversion, transcoding, and streaming.
- Convert between any media format, extract audio, resize video, create thumbnails, stream RTMP.
- Usage: `ffmpeg -i input.mov output.mp4`, `ffmpeg -i video.mp4 -vn audio.mp3`, `ffmpeg -i input.mp4 -vf scale=1280:720 output.mp4`.
- Used by: yt-dlp (post-processing), gifski (frame extraction), and various automation scripts.

**gifsicle** --- GIF optimizer and editor.
- Reduce GIF file sizes, crop, resize, adjust frame delays, extract frames.
- Usage: `gifsicle -O3 --lossy=80 input.gif -o output.gif` (aggressive optimization).
- Pairs with gifski for a create-then-optimize workflow.

**gifski** --- High-quality GIF encoder from video frames.
- Produces the highest-quality GIFs possible (uses pngquant's quantization algorithm for each frame).
- Usage: `gifski --fps 15 --width 640 frames/*.png -o output.gif`.
- Workflow: extract frames with ffmpeg, encode with gifski, optimize with gifsicle.

**pngquant** --- Lossy PNG compressor.
- Reduces PNG file size by 60-80% with minimal visual quality loss using median-cut quantization.
- Usage: `pngquant --quality=65-80 --speed 1 --strip input.png`.
- Used by ImageOptim (the GUI app) under the hood.

**resvg** --- SVG rendering and conversion to PNG.
- Handles complex SVGs that other renderers choke on (gradients, filters, text).
- Usage: `resvg input.svg output.png --width 1024`.
- Useful for generating raster assets from vector source files.

**tesseract** --- OCR engine for extracting text from images.
- Supports 100+ languages. Can output plain text, hOCR, or searchable PDF.
- Usage: `tesseract image.png output` (creates output.txt), `tesseract image.png - -l eng` (stdout).
- Useful for extracting text from screenshots, scanned documents, or PDF images.

### Security & Encryption

**gnupg** --- GNU Privacy Guard (GPG) for encryption and digital signatures.
- Used for encrypting backup files. The backup script (`backup.sh`) uses OpenSSL for its own encryption, but GPG is available for git commit signing, email encryption, and general-purpose file encryption.
- Key commands: `gpg --gen-key`, `gpg --encrypt -r recipient file`, `gpg --decrypt file.gpg`.
- Git commit signing: `git config --global commit.gpgsign true`.

### Data & Documents

**pandoc** --- Universal document converter.
- Converts between Markdown, LaTeX, HTML, DOCX, PDF, EPUB, reStructuredText, and 40+ other formats.
- Usage: `pandoc README.md -o README.pdf`, `pandoc input.docx -t markdown -o output.md`.
- Requires MacTeX (installed as a cask) for PDF output via LaTeX.
- Essential for generating documentation in multiple formats from a single Markdown source.

**jupyterlab** --- Interactive notebook environment for Python data science.
- Web-based IDE with code cells, rich output (charts, tables, images), and Markdown documentation.
- Usage: `jupyter lab` (starts server at `http://localhost:8888`).
- Used for data analysis, visualization prototyping, and exploratory programming.
- Installed via Homebrew formula, which includes Python kernel by default.

### Downloaders & Archival

**yt-dlp** --- Download videos from YouTube and 1000+ other sites.
- Fork of youtube-dl with active development and more features.
- Usage: `yt-dlp "https://youtube.com/watch?v=..."`, `yt-dlp -x --audio-format mp3 URL` (extract audio).
- Supports format selection: `yt-dlp -f "bestvideo[height<=1080]+bestaudio"`.
- Requires ffmpeg for post-processing (merging video+audio, format conversion).

**gallery-dl** --- Download image galleries from various websites.
- Supports Instagram, Twitter/X, Reddit, Flickr, DeviantArt, and hundreds of other sites.
- Usage: `gallery-dl "https://site.com/gallery"`.
- Config file at `$HOME/.config/gallery-dl/config.json` for authentication and download paths.

### Cloud & Backend CLIs

**stripe** --- Stripe CLI for payment integration development.
- Forward webhooks to local dev server, trigger test events, manage API resources.
- Usage: `stripe listen --forward-to localhost:3000/api/webhooks`, `stripe trigger payment_intent.succeeded`.
- Authenticate: `stripe login`.
- Critical for developing Stripe payment flows without deploying to production.

**supabase** --- Supabase CLI for local development, database migrations, and deployments.
- Run Supabase locally with Docker: `supabase start` (starts Postgres, Auth, Storage, Realtime, etc.).
- Manage migrations: `supabase migration new`, `supabase db push`, `supabase db diff`.
- Link to remote: `supabase link --project-ref <ref>`.
- Used by multiple projects that use Supabase as their backend.

**duck** --- Cyberduck CLI for cloud storage transfers (WebDAV, S3, SFTP, FTP, Azure, Google Cloud Storage).
- Command-line version of the Cyberduck GUI.
- Usage: `duck --upload sftp://host/path local-file`, `duck --download s3://bucket/key local-path`.
- Used in conjunction with Mountain Duck (the cask) for mounting cloud storage.

**chief** --- Chief CLI tool from the `minicodemonkey/chief` tap.
- Task runner and workflow automation tool.

### Miscellaneous

**agent-browser** --- Headless browser automation for AI agents.
- Provides a browser that AI tools can control programmatically for web scraping, testing, and interaction.
- Used by Claude Code's agent-browser skill for E2E testing, screenshots, and debugging.

**cliclick** --- macOS CLI tool for simulating mouse clicks and keyboard events.
- Automate GUI interactions from shell scripts: click buttons, type text, move mouse.
- Usage: `cliclick c:100,200` (click at coordinates), `cliclick t:"hello"` (type text).

**mlx** --- Apple MLX framework for machine learning on Apple Silicon.
- NumPy-like API optimized for unified memory architecture.
- Enables running ML models (including LLMs) natively on Apple Silicon GPU.
- Used as a dependency by some local AI tools; Ollama uses its own Metal backend.

**mole** --- SSH tunnel manager.
- Simplifies creating SSH tunnels with a friendly CLI.
- Usage: `mole start local --source :8080 --destination db-host:5432 --server bastion`.
- Useful for connecting to remote databases through jump hosts.

**portaudio** --- Cross-platform audio I/O library.
- C library for recording and playing audio. Required as a build dependency by some Python audio packages (e.g., PyAudio).
- Not used directly --- it is a dependency for audio processing tools.

**speedtest-cli** --- Internet speed test from the terminal.
- Usage: `speedtest-cli` (runs Ookla speed test and prints download/upload/ping).
- Also available as a Mac App Store app (Speedtest by Ookla) for GUI usage.

**tcl-tk** --- Tcl/Tk scripting language and GUI toolkit.
- Required by Python's `tkinter` module for GUI applications.
- Homebrew Python links against this for `import tkinter` support.
- Not used directly; it is a build/runtime dependency.

---

## Homebrew Casks (40 GUI Applications)

### Terminal & Editors (12)

**ghostty** (`ghostty`) --- PRIMARY terminal emulator.
- GPU-accelerated, written in Zig, extremely fast rendering.
- Config: `$HOME/.config/ghostty/config` (symlinked from the mac-setup repo during setup).
- Features: native macOS splits/tabs, font ligatures, custom color schemes, per-pane background colors.
- The `.zshrc` includes a `_ghostty_pane_color()` function that assigns unique neon background colors to each pane based on TTY number (cobalt, emerald, magenta, gold, purple, teal, rust, grass).
- Tab titles auto-update to show the current working directory via the `chpwd()` hook.
- Font: JetBrains Mono Nerd Font (installed as a separate cask).

**cursor** (`cursor`) --- AI-first code editor (VS Code fork).
- Primary code editor for AI-assisted development. Supports Claude, GPT, and local models.
- Settings synced via backup/restore scripts. Config stored at `$HOME/Library/Application Support/Cursor/User/`.
- Extensions are compatible with VS Code extensions.

**visual-studio-code** (`visual-studio-code`) --- Microsoft's code editor.
- Secondary editor. `$EDITOR` and `$VISUAL` are set to `code` in `.zshrc`.
- Used when Cursor is not suitable or for projects that need specific VS Code extensions.
- Config stored at `$HOME/Library/Application Support/Code/User/`.

**supacode** (`supacode`) --- Supabase-focused code editor.
- Specialized editor with built-in Supabase tooling for database schema editing and migration management.

**windsurf** (`windsurf`) --- AI-powered code editor by Codeium.
- Alternative AI IDE. Useful for comparison testing of AI coding assistants.

**tabby** (`tabby`) --- Alternative terminal emulator.
- Cross-platform terminal with built-in SSH client and serial port support.
- Not the primary terminal (Ghostty is), but available as a fallback.

**docker** (`docker`) --- Docker Desktop for macOS.
- Container runtime for local development. Required by `supabase start` (runs Postgres, Auth, etc. in containers).
- Uses Apple Silicon native images (ARM64).
- Resource limits should be configured in Docker Desktop preferences (recommended: 4 CPU, 8GB RAM for M2 Max).

**localcan** (`localcan`) --- Local development environment manager.
- Provides local HTTPS URLs, custom domains, and port management for local development servers.

**codexbar** (`codexbar`) --- Menu bar code utility.

**gcollazo-mongodb** (`gcollazo-mongodb`) --- Lightweight MongoDB GUI.
- Simple GUI for browsing and querying MongoDB databases.
- No configuration needed --- connect to `mongodb://localhost:27017` by default.

**mactex** (`mactex`) --- Full TeX/LaTeX distribution for macOS.
- Required by pandoc for PDF generation via LaTeX.
- Large install (~5GB). Provides `pdflatex`, `xelatex`, `lualatex`, and the full CTAN package repository.
- After install, TeX binaries are at `/Library/TeX/texbin/`.

**font-jetbrains-mono-nerd-font** (`font-jetbrains-mono-nerd-font`) --- JetBrains Mono with Nerd Font icon patches.
- Monospace font with ligatures and 3000+ icons (file type icons, git symbols, etc.).
- Used by Ghostty, eza (for file type icons), starship prompt, and all code editors.
- Must be selected in each application's font settings after install.

### AI Desktop Apps (2)

**claude** (`claude`) --- Anthropic's Claude desktop app.
- Native macOS app for conversing with Claude. Separate from Claude Code (the CLI).
- Supports file uploads, image analysis, and long conversations.

**chatgpt** (`chatgpt`) --- OpenAI's ChatGPT desktop app.
- Native macOS app for ChatGPT. Supports GPT-4o, DALL-E, and file uploads.

### Browsers (4)

**arc** (`arc`) --- PRIMARY web browser.
- Chromium-based with workspaces (spaces), built-in ad blocking, split views, and a command palette.
- Organizes tabs into pinned, unpinned, and archived. Reduces tab clutter significantly.
- Supports Chrome extensions.
- Default browser for all development work.

**brave-browser** (`brave-browser`) --- Privacy-focused Chromium browser.
- Built-in ad/tracker blocking, Tor integration, and crypto wallet.
- Used as a secondary browser and for privacy-sensitive browsing.

**google-chrome** (`google-chrome`) --- Google Chrome.
- Used for Chrome DevTools, Lighthouse audits, and testing in the most popular browser engine.
- Chrome-specific DevTools features (Performance tab, Memory profiler) are sometimes needed.

**helium-browser** (`helium-browser`) --- Floating translucent browser window.
- Creates an always-on-top, semi-transparent browser window that floats over other apps.
- Useful for watching tutorials or referencing documentation while coding.
- Hard to find and not well-known --- important to track in this inventory as a manual reinstall is difficult.

### Productivity & System Utilities (16)

**raycast** (`raycast`) --- Spotlight replacement with extensions and snippets.
- Launcher, clipboard history, window management, snippets, calculator, and 1000+ extensions.
- Replaces macOS Spotlight entirely. Triggered with `Cmd+Space` (after remapping Spotlight).
- Config backed up and restored by `scripts/restore_raycast.sh`.
- Extensions include GitHub, Jira, 1Password, Tailwind CSS colors, and custom scripts.

**rectangle** (`rectangle`) --- Window management with keyboard shortcuts.
- Snap windows to halves, thirds, quarters, and custom grid positions.
- Key shortcuts: `Ctrl+Option+Arrow` (halves), `Ctrl+Option+D/F` (thirds).
- Config is backed up during `backup.sh`.

**stats** (`stats`) --- Menu bar system monitor.
- Shows CPU usage, memory pressure, disk I/O, network throughput, battery status, and temperature in the menu bar.
- Lightweight and always visible. Click for detailed graphs.
- Complements btop (terminal) and mactop (Apple Silicon specific) for different monitoring contexts.

**jordanbaird-ice** (`jordanbaird-ice`) --- Menu bar item manager.
- Hides/shows menu bar icons to reduce clutter. Group icons into "always show", "hidden", and "always hidden".
- Essential on MacBook screens where menu bar space is limited.

**1password** (`1password`) --- Password manager.
- Stores passwords, SSH keys, API tokens, software licenses, and secure notes.
- Browser extension integrates with Arc, Chrome, and Brave.
- SSH agent integration allows using 1Password-stored SSH keys without manual key management.

**coconutbattery** (`coconutbattery`) --- Battery health monitor.
- Shows battery cycle count, design capacity vs. current capacity, temperature, and charge history.
- Also monitors connected iOS devices via USB.

**imageoptim** (`imageoptim`) --- Lossless image compression GUI.
- Drag-and-drop PNG, JPEG, GIF, and SVG optimization. Uses pngquant, gifsicle, and other tools under the hood.
- Strips metadata (EXIF, ICC profiles) and applies lossless compression.

**monitorcontrol** (`monitorcontrol`) --- Control external display brightness and volume.
- Uses DDC/CI to control external monitors via keyboard shortcuts or menu bar.
- Essential for external displays that lack macOS-native brightness controls.

**mountain-duck** (`mountain-duck`) --- Mount cloud storage as local drives.
- Supports S3, SFTP, WebDAV, Google Drive, Dropbox, Azure, and more.
- Mounts appear as native Finder volumes.
- Note: mounted paths may contain special characters (`|`) that break shell commands. Use Read/Write/Edit tools instead of Bash when working with Mountain Duck mounts.

**google-drive** (`google-drive`) --- Google Drive desktop sync client.
- Syncs Google Drive to a local folder for offline access.
- Appears as a drive in Finder sidebar.

**inkscape** (`inkscape`) --- Open-source vector graphics editor.
- SVG-native editor for creating and editing vector graphics.
- Alternative to Adobe Illustrator for SVG work.

**qlvideo** (`qlvideo`) --- QuickLook plugin for video thumbnails and previews.
- Adds video thumbnail generation and playback to Finder's QuickLook (press Space on a video file).
- Supports most video formats that ffmpeg can decode.

**antigravity** (`antigravity`) --- Window manager utility.
- Additional window management capabilities. PATH addition in `.zshrc`: `$HOME/.antigravity/antigravity/bin`.

**neohtop** (`neohtop`) --- Modern htop alternative with a native GUI.
- GUI process viewer with a modern interface. Alternative to terminal-based htop/btop.

**mimestream** (`mimestream`) --- Native macOS email client for Gmail.
- Built with native macOS APIs (not Electron). Fast, lightweight, supports Gmail features (labels, send-as, snooze).
- Primary email client for Gmail accounts.

**geekbench** (`geekbench`) --- CPU and GPU benchmark tool.
- Measures single-core, multi-core, and GPU compute performance.
- Useful for verifying hardware performance and comparing across machines.
- M2 Max typical scores: ~2700 single-core, ~14000 multi-core.

### Knowledge & Notes (4)

**notion** (`notion`) --- All-in-one workspace for notes, docs, databases, and project management.
- Used for documentation, planning, and knowledge management.
- Syncs across devices. Supports databases, Kanban boards, calendars, and wiki-style linking.

**notion-calendar** (`notion-calendar`) --- Calendar app integrated with Notion.
- Links calendar events to Notion pages. Shows schedule alongside tasks and notes.

**obsidian** (`obsidian`) --- Markdown-based knowledge base with bidirectional linking.
- Local-first: all notes are plain Markdown files stored on disk.
- Supports plugins, graph view, and powerful search.
- Vaults stored in `$HOME/` or synced via iCloud.

**zotero** (`zotero`) --- Reference manager and PDF organizer for research.
- Manages academic papers, generates citations, and organizes PDF annotations.
- Browser extension captures references from web pages.

### Media (2)

**iina** (`iina`) --- PRIMARY video player for macOS.
- Native macOS UI, supports all common video formats via mpv/ffmpeg backend.
- Lightweight, fast, and integrates with macOS (Touch Bar, Picture-in-Picture, dark mode).
- Preferred over VLC for everyday use due to native macOS feel.

**vlc** (`vlc`) --- Universal media player.
- Plays virtually any media format. Fallback for files IINA cannot handle.
- Also useful for streaming (RTSP, HTTP, etc.) and media conversion.

---

## Mac App Store Apps (29 apps)

Installed via `mas` CLI. Requires App Store sign-in before running setup.

### Productivity (5)

| App | MAS ID | Purpose |
|-----|--------|---------|
| Amphetamine | 937984704 | Prevents Mac from sleeping. Configurable triggers (while app running, on schedule, while downloading). Replaces the deprecated `caffeinate`-based solutions with a GUI. |
| CopyClip | 595191960 | Clipboard history manager. Lives in menu bar, stores clipboard history for quick paste of previous copies. |
| The Unarchiver | 425424353 | Opens any archive format (ZIP, RAR, 7z, tar.gz, bz2, ISO, etc.). Integrates as the default archive handler in Finder. |
| Image2Icon | 992115977 | Creates custom `.icns` icons from images. Drag an image to create macOS app icons, folder icons, or favicons. |
| Boop | 1518425043 | Developer scratchpad for text transformations. Paste text, apply transforms (Base64 encode/decode, JSON format, URL encode, hash, etc.) with a single keystroke. |

### Apple iWork (3)

| App | MAS ID | Purpose |
|-----|--------|---------|
| Keynote | 409183694 | Apple's presentation app. Used for client presentations and slide decks. |
| Pages | 409201541 | Apple's word processor. Used for documents that need more formatting than Markdown provides. |
| Numbers | 409203825 | Apple's spreadsheet app. Used for quick calculations and data tables. |

### Notes & Learning (1)

| App | MAS ID | Purpose |
|-----|--------|---------|
| Notability | 360593530 | Note-taking with Apple Pencil support on iPad. Syncs across devices via iCloud. |

### Development (4)

| App | MAS ID | Purpose |
|-----|--------|---------|
| Xcode | 497799835 | Apple's IDE for iOS/macOS development. Required for building Swift/SwiftUI projects, running iOS simulator, and accessing Apple frameworks. Large install (~35GB with simulators). |
| Developer | 640199958 | Apple Developer app for WWDC sessions, documentation, and developer news. |
| TestFlight | 899247664 | Beta app testing platform. Install and test beta builds of iOS/macOS apps. |
| Transporter | 1450874784 | Upload builds to App Store Connect. Used for submitting iOS app builds for review. |

### Design & Media (5)

| App | MAS ID | Purpose |
|-----|--------|---------|
| ColorSlurp | 1287239339 | System-wide color picker. Sample any pixel on screen, get hex/RGB/HSL values, organize color palettes. |
| Photomator | 1444636541 | AI-powered photo editor. Non-destructive editing with ML-based adjustments (Super Resolution, denoise, color match). |
| Exporter | 1099120373 | Export photos from Apple Photos to folders with original filenames and metadata. |
| Infuse | 1136220934 | Premium video player with broad codec support. Streams from NAS, Plex, and cloud storage. |
| Capo | 696977615 | Automatic chord detection for music. Analyzes audio files and displays detected chords in a timeline. |

### Security & Network (3)

| App | MAS ID | Purpose |
|-----|--------|---------|
| NordVPN | 905953485 | VPN client for privacy and geo-unblocking. Used for secure connections on public networks. |
| Bitwarden | 1352778147 | Open-source password manager. Cross-platform alternative to 1Password (both are installed for different use cases). |
| AdBlock Pro | 1018301773 | Safari ad and tracker blocker. Lightweight content blocker for Safari browsing. |

### Diagnostics & Tools (3)

| App | MAS ID | Purpose |
|-----|--------|---------|
| Blackmagic Disk Speed Test | 425264550 | Measures sequential read/write speed of drives. Essential for verifying SSD performance and external drive throughput. |
| Speedtest | 1153157709 | Ookla internet speed test with a native GUI. Measures download, upload, and latency. |
| HP | 1474276998 | HP printer drivers and utilities. Required for HP printers to function on macOS. |

### AI (2)

| App | MAS ID | Purpose |
|-----|--------|---------|
| Perplexity | 6714467650 | AI-powered search engine and answer tool. Provides sourced, cited answers to questions. Native Mac app with quick access. |
| Locally AI | 6741426692 | Run local AI models with a native macOS UI. Alternative interface to Ollama for testing local models with a GUI. |

### Tracking & Travel (3)

| App | MAS ID | Purpose |
|-----|--------|---------|
| Flighty | 1358823008 | Real-time flight tracker. Shows live flight status, delays, gate changes, and historical on-time data. |
| Parcel Classic | 639968404 | Package delivery tracking. Tracks shipments from all major carriers with push notifications. |
| Ground News | 1324203419 | News aggregator with political bias analysis. Shows how the same story is covered by left, center, and right media. |

### 3D & Engineering (1)

| App | MAS ID | Purpose |
|-----|--------|---------|
| Shapr3D | 1091675654 | Professional 3D CAD modeling on Apple Silicon. Parasolid kernel, direct modeling, import/export STEP and IGES. Runs natively on M2 Max with excellent performance. |

---

## Not Managed by Package Managers

These apps must be installed manually after the main setup completes.

| App | Why Manual | Install Method |
|-----|-----------|----------------|
| CompressX | Not available in Homebrew or App Store | Download from website |
| Adobe Creative Cloud | Requires Adobe's proprietary installer; login and license activation are interactive | Download from adobe.com; installs Photoshop, Illustrator, Lightroom, etc. |
| Logitech Options+ | Hardware driver with kernel extensions | Download from logitech.com |
| GoPro Webcam | Proprietary driver for GoPro as webcam | Download from gopro.com |
| Macs Fan Control | System-level fan control utility | Download from crystalidea.com |

---

## Explicitly Excluded

These apps are deliberately **not** installed by setup. They are either not needed, replaced by better alternatives, or intentionally installed only on-demand.

| App | Reason for Exclusion |
|-----|---------------------|
| Microsoft Office (Word, Excel, PowerPoint, OneNote, Outlook, To Do, OneDrive) | Not needed; Apple iWork suite covers document needs |
| iMovie | Apple bloatware; not used for video editing |
| GarageBand | Apple bloatware; not used for audio production |
| Spotify | Not needed for development workflow |
| Slack | Communication app; install manually if needed for a specific team |
| Discord | Communication app; install manually if needed |
| Microsoft Teams | Communication app; install manually if needed |
| WhatsApp | Communication app; install manually if needed |
| Telegram | Communication app; install manually if needed |
| Messenger | Communication app; install manually if needed |
| Mini Motorways | Game; install manually if wanted |
| Solves | Game; install manually if wanted |

---

## Version Managers & Runtimes

This environment uses a deliberately simple approach to version management: Homebrew provides the primary version of each language, and lightweight version managers handle edge cases.

| Language | Primary Version | Manager | Notes |
|----------|----------------|---------|-------|
| **Python** | 3.13 (Homebrew) | `uv` for virtualenvs and package installs | `python@3.11` also installed for compatibility. `uv venv` creates venvs. Use `.venv/bin/python` in scripts (activation does not persist in non-interactive shells). Global venvs stored at `$HOME/.virtualenvs/`. |
| **Node.js** | LTS (Homebrew) | None (single version) | No nvm or n. Homebrew manages the single Node.js version. Sufficient for Next.js, React, and Vite projects. |
| **Bun** | Latest (curl installer) | Self-updating (`bun upgrade`) | Installed to `$HOME/.bun/`. Added to PATH in `.zshrc`. Used for fast script execution, plugin worker services, and some project builds. |
| **Deno** | Latest (Homebrew) | Self-updating (`deno upgrade`) | Used for TypeScript scripts. Manages its own cache at `$HOME/.cache/deno/`. |
| **Go** | Latest (Homebrew) | None | Go modules handle per-project dependencies. Binaries install to `$HOME/go/bin/`. |
| **Rust** | Via rustup (if needed) | `rustup` | Not installed by default in the Brewfile. Install with `curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs \| sh` when needed. Some Homebrew formulae (ripgrep, fd, bat, etc.) are Rust-based but ship as prebuilt binaries. |
| **mise** | Available | `mise` | Universal version manager that can replace nvm, pyenv, rbenv, etc. Available but not the primary version management strategy in this setup. |

### PATH Order

The `$PATH` is constructed in `.zshrc` in this priority order (first match wins):

1. `$HOME/bin` --- custom scripts and the `update-dev` updater
2. `$HOME/.bun/bin` --- Bun runtime and bun-installed binaries
3. `$HOME/.antigravity/antigravity/bin` --- Antigravity window manager
4. `/opt/homebrew/opt/python@3.13/bin` --- Python 3.13 as default python3
5. `/opt/homebrew/bin` and `/opt/homebrew/sbin` --- all Homebrew packages
6. System paths (`/usr/bin`, `/bin`, etc.)

Duplicates are removed by `typeset -U PATH` at the end of `.zshrc`.

---

## Ollama Models

Five models are pre-configured for local LLM inference on the M2 Max (32GB unified memory).

| Model | Size on Disk | Quantization | Use Case | TTFT on M2 Max | Tool Use Support |
|-------|-------------|--------------|----------|----------------|------------------|
| `qwen3-coder:latest` | 18 GB | Default (Q4) | **Daily driver** for Claude Code local mode. MoE architecture. Strong tool use and code generation. | ~1.1s | Yes |
| `gemma4:26b` | 17 GB | Default (Q4) | Highest quality (8.36/10 in benchmarks). Used when accuracy matters more than speed. | ~24.5s | Yes |
| `gemma4:e4b` | 9.6 GB | Default (Q4) | Smallest tool-capable model. Multimodal (can process images). Fast inference. | Fast | Yes |
| `qwen2.5-coder:14b` | 9.0 GB | Default (Q4) | Dense code specialist. Fallback for pure coding tasks. Strong at code completion and generation. | Moderate | Yes |
| `phi4:14b` | 9.1 GB | Default (Q4) | General reasoning. **Does NOT support tool use** --- cannot be used with Claude Code. Use via `ollama run phi4:14b "prompt"` for direct chat only. | Moderate | **No** |

### Memory Configuration

All settings are exported as environment variables in `.zshrc`:

```bash
export OLLAMA_CONTEXT_LENGTH=16384    # 16K context window
export OLLAMA_MAX_LOADED_MODELS=1     # Only 1 model in RAM at a time
export OLLAMA_KV_CACHE_TYPE=q8_0      # Quantized KV cache (saves ~50% KV memory)
export OLLAMA_FLASH_ATTENTION=1       # Metal flash-attention kernel
export OLLAMA_KEEP_ALIVE=30m          # Keep model warm for 30 minutes between calls
```

**Why these settings:**

- **16K context**: The M2 Max has 32GB unified memory. The largest model (qwen3-coder at 18GB) leaves ~14GB for the OS, KV cache, and other apps. 16K context with Q8_0 KV cache keeps memory usage safe. Going higher (32K, 64K) risks memory pressure and swap thrashing.
- **1 model loaded**: Loading two 18GB models simultaneously would exceed available memory. Only one model is resident at a time; switching models takes 10-30 seconds as the old model unloads and the new one loads.
- **Q8_0 KV cache**: Reduces KV cache memory by ~50% compared to FP16 with negligible quality loss. Critical for fitting large models in 32GB.
- **Flash attention**: Metal-optimized attention kernel that further reduces KV memory footprint and improves throughput on Apple Silicon GPUs.
- **30-minute keep-alive**: Keeps the model warm in RAM between invocations. After 30 minutes of inactivity, the model unloads to free memory. Balance between responsiveness and memory usage.

### Model Storage

Models are stored at a custom path (not the default `$HOME/.ollama/models`). The default path is symlinked to the custom location. This allows storing models on a different volume or partition if needed.

### LaunchAgent

Ollama runs as a macOS LaunchAgent (`$HOME/Library/LaunchAgents/com.user.ollama.plist`), which means it starts automatically at login and runs in the background. The `ollama serve` command does not need to be run manually.

---

## Claude Code Integration

Claude Code is the primary development tool in this environment. It connects to both remote (Anthropic API) and local (Ollama) backends.

### Installation

Installed globally via npm during setup Phase 5:

```bash
npm install -g @anthropic-ai/claude-code
```

### Remote Mode (Default)

By default, Claude Code connects to Anthropic's API using an API key stored in the system. This provides access to the full Claude model family (Opus, Sonnet, Haiku) with full context windows, tool use, and all features.

### Local Mode (Ollama)

Claude Code can connect to the local Ollama server for offline, free, low-latency work. Local mode is activated via shell aliases that set environment variables per-invocation.

### All `cc*` Aliases

These are defined in `.zshrc` and form the primary interface for launching Claude Code:

**Remote (Anthropic API):**

| Alias | Command | Description |
|-------|---------|-------------|
| `cc` | `claude` | Standard Claude Code session. Full CLAUDE.md, hooks, plugins, MCP, LSP. |
| `cc-skip` | `claude --dangerously-skip-permissions` | YOLO mode --- skips all permission prompts. Use for trusted, repetitive tasks. |

**Local --- Bare Mode** (no CLAUDE.md, hooks, plugins, LSP, MCP, or auto-memory):

| Alias | Ollama Model | Description |
|-------|-------------|-------------|
| `cc-local` | `qwen3-coder` | **Daily driver.** MoE model, 1.1s TTFT, strong tool use. |
| `cc-local-heavy` | `gemma4:26b` | Highest quality but slow (24.5s TTFT). Use for complex tasks. |
| `cc-local-tiny` | `gemma4:e4b` | Smallest tool-capable model. Multimodal. |
| `cc-local-coder` | `qwen2.5-coder:14b` | Dense code specialist fallback. |

**Local --- Full Mode** (loads CLAUDE.md, hooks, plugins --- SLOW on 32GB, 30-60s per turn):

| Alias | Ollama Model | Description |
|-------|-------------|-------------|
| `cc-local-full` | `qwen3-coder` | Use only when project context is essential and latency is acceptable. |
| `cc-local-heavy-full` | `gemma4:26b` | Maximum quality + full context. Very slow. |

**Utilities:**

| Alias/Command | Description |
|---------------|-------------|
| `cc-help` | Prints a formatted help menu of all `cc*` aliases with descriptions. |
| `claude-full` | Appends `$HOME/.claude/orientation.md` as a system prompt for full ecosystem awareness. |
| `claude-orient` | Asks Claude to read and verify the entire hook/skill/agent/plugin ecosystem. |
| `ollama ps` | Check which model is currently loaded in GPU memory. |
| `sudo mactop` | Watch GPU spike during Ollama inference (Apple Silicon GPU/ANE monitor). |

### Bare Mode vs Full Mode Tradeoffs

| Aspect | Bare Mode (`--bare`) | Full Mode (default) |
|--------|---------------------|---------------------|
| **Token prefill** | ~2-3K tokens/turn | ~30K+ tokens/turn |
| **Latency on 32GB** | 1-5 seconds | 30-60 seconds |
| **CLAUDE.md loaded** | No | Yes |
| **Hooks execute** | No | Yes |
| **Plugins/MCP available** | No | Yes |
| **LSP integration** | No | Yes |
| **Auto-memory** | No | Yes |
| **When to use** | Quick edits, file ops, simple questions | Complex project work requiring full context |

The core issue is that 32GB is tight for large models (18GB qwen3-coder) plus a 30K+ token context. Bare mode slashes the per-turn token budget, keeping inference fast and avoiding memory pressure. Full mode is viable but expect 30-60 second response times as the model processes the full context prefix.

### Warning: Local Model Limitations

Local models hallucinate on large tool outputs (e.g., "count 6000 files in this directory"). Any task where the correct answer depends on reading a large list should use remote Claude (`cc`) instead of local (`cc-local`).

---

## macOS System Preferences

The setup script applies developer-friendly macOS defaults via `scripts/macos_defaults.sh`:

| Category | Setting | Value |
|----------|---------|-------|
| **Dock** | Auto-hide | Enabled |
| **Dock** | Icon size | 36px |
| **Dock** | Auto-hide delay | 0 (instant) |
| **Dock** | Animation speed | 0.3s (fast) |
| **Dock** | Show recent apps | Disabled |
| **Dock** | Minimize effect | Scale (not Genie) |
| **Finder** | Show extensions | All files |
| **Finder** | Path bar | Visible |
| **Finder** | Status bar | Visible |
| **Finder** | Default view | List view |
| **Finder** | Folders first | Enabled |
| **Finder** | Extension change warning | Disabled |
| **Finder** | ~/Library visible | Yes |
| **Keyboard** | Key repeat rate | 2 (very fast) |
| **Keyboard** | Initial repeat delay | 15 (short) |
| **Keyboard** | Auto-correct | Disabled |
| **Keyboard** | Auto-capitalize | Disabled |
| **Keyboard** | Smart dashes | Disabled |
| **Keyboard** | Smart quotes | Disabled |
| **Screenshots** | Location | `$HOME/Screenshots` |
| **Screenshots** | Format | PNG |
| **Screenshots** | Shadow | Disabled |
| **Trackpad** | Natural scroll | Disabled (traditional) |
| **Trackpad** | Tap to click | Enabled |
| **Mission Control** | Auto-rearrange spaces | Disabled (fixed order) |

---

## API Tokens & Secrets

API tokens are stored in the **macOS Keychain**, not in environment files. The `.zshrc` retrieves them at shell startup:

```bash
export VERCEL_TOKEN=$(security find-generic-password -a "$USER" -s "VERCEL_TOKEN" -w 2>/dev/null)
```

To add a token to the Keychain:

```bash
security add-generic-password -a "$USER" -s "TOKEN_NAME" -w "token-value" -U
```

Machine-specific overrides (secrets not tracked in git) go in `$HOME/.zshrc.local`, which is sourced if it exists.

---

## Update Workflow

The `update-dev` script (`$HOME/bin/update-dev`) is a zero-sudo, zero-prompt updater that refreshes all package managers in one command:

```bash
update-dev
```

It updates: Homebrew (formulae + casks), npm globals, pipx packages, Bun, uv, Ollama models, Docker images, and pulls latest for tracked git repos. Aliased as `update-dev` in `.zshrc`.

There is also a simpler `update_all()` function defined in `.zshrc` that covers just Homebrew and pipx:

```bash
update_all   # brew update + upgrade + cleanup, then pipx upgrade-all
```
