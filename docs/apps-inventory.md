# Application Inventory

> Every application in this development environment, organized by purpose.
> Each entry includes: install method, what it does, why it's here, and setup notes.
> Designed to be read by both humans and LLMs for setup assistance and troubleshooting.

---

## Install Methods

| Method | Command | What It Installs |
|--------|---------|-----------------|
| `brew install <formula>` | Homebrew formula | CLI tools, libraries, runtimes |
| `brew install --cask <name>` | Homebrew cask | GUI applications |
| `mas install <id>` | Mac App Store CLI | App Store apps (requires sign-in) |
| Manual | Download from website | Apps not in any package manager |

All packages are declared in the `Brewfile` and installed during `setup.sh` Phase 3.

---

## 1. Terminal & Code Editors

### Ghostty — PRIMARY Terminal
- **Install**: `cask ghostty`
- **What**: GPU-accelerated terminal emulator built by one of the Zig creators
- **Why**: Fast rendering, native macOS feel, Catppuccin theme, split panes, Quake-style dropdown terminal
- **Config**: `~/.config/ghostty/config` (symlinked from repo)
- **Key feature**: `Ctrl+\`` global hotkey drops a terminal from the top of the screen
- **Requires**: JetBrains Mono Nerd Font (`cask font-jetbrains-mono-nerd-font`)

### Cursor — PRIMARY Code Editor
- **Install**: `cask cursor`
- **What**: VS Code fork with built-in AI assistance (GPT-4, Claude)
- **Why**: AI tab completion, inline chat, codebase-aware suggestions
- **Config**: `~/Library/Application Support/Cursor/User/settings.json`
- **Extensions**: ~86 installed, tracked by `backup.sh`

### Visual Studio Code
- **Install**: `cask visual-studio-code`
- **What**: Microsoft's extensible code editor
- **Why**: Broad extension ecosystem, used as `$EDITOR` for git commits and quick edits
- **Extensions**: ~86 installed, tracked by `backup.sh`

### Supacode
- **Install**: `cask supacode`
- **What**: Code editor optimized for Supabase development
- **Why**: Direct Supabase integration for database and auth work

### Windsurf
- **Install**: `cask windsurf`
- **What**: AI-powered IDE by Codeium
- **Why**: Alternative AI coding environment for comparison

### Tabby
- **Install**: `cask tabby`
- **What**: Cross-platform terminal with built-in SSH and serial support
- **Why**: Secondary terminal for SSH sessions

### Docker Desktop
- **Install**: `cask docker`
- **What**: Container runtime with GUI management
- **Why**: Running databases, services, and containerized dev environments locally

### LocalCan
- **Install**: `cask localcan`
- **What**: Local development environment manager
- **Why**: Quick local server setup for testing

### CodexBar
- **Install**: `cask codexbar`
- **What**: Menu bar code utility
- **Setup**: Runs in menu bar after first launch

### MongoDB GUI
- **Install**: `cask gcollazo-mongodb`
- **What**: Lightweight MongoDB GUI client
- **Why**: Visual inspection of MongoDB databases

### MacTeX
- **Install**: `cask mactex`
- **What**: Full TeX/LaTeX distribution (~4GB)
- **Why**: Document typesetting, academic papers, technical reports

### JetBrains Mono Nerd Font
- **Install**: `cask font-jetbrains-mono-nerd-font`
- **What**: JetBrains Mono with Nerd Font icons (powerline, devicons, etc.)
- **Why**: Required by Ghostty config for icon rendering in terminal

---

## 2. AI & LLM Tools

### Claude (Desktop)
- **Install**: `cask claude`
- **What**: Anthropic's Claude AI assistant desktop app
- **Why**: Quick access to Claude outside the browser

### ChatGPT (Desktop)
- **Install**: `cask chatgpt`
- **What**: OpenAI's ChatGPT desktop app
- **Why**: System-wide AI access via keyboard shortcut

### Perplexity
- **Install**: `mas 6714467650`
- **What**: AI-powered search engine and answer tool
- **Why**: Research and quick fact-checking with citations

### Locally AI
- **Install**: `mas 6741426692`
- **What**: Native macOS GUI for running local AI models
- **Why**: Visual interface for local model experimentation

### Ollama
- **Install**: `brew ollama` (CLI) + auto-start via LaunchAgent
- **What**: Local LLM runner — download and run models on Apple Silicon
- **Why**: Run Claude Code locally with `cc-local` aliases, avoiding API costs
- **Models**: qwen3-coder (daily driver), gemma4:26b (quality), gemma4:e4b (tiny), qwen2.5-coder:14b, phi4:14b
- **Storage**: ~65GB at `~/_Local_LLMs/ollama/`

### MLX
- **Install**: `brew mlx`
- **What**: Apple's machine learning framework for Apple Silicon
- **Why**: On-device ML inference optimized for Metal GPU

### Agent Browser
- **Install**: `brew agent-browser`
- **What**: Headless browser automation CLI
- **Why**: E2E testing, screenshot capture, visual debugging for web apps

### Claude Code (CLI)
- **Install**: `npm install -g @anthropic-ai/claude-code`
- **What**: Anthropic's AI coding assistant for the terminal
- **Why**: Primary development tool — code generation, debugging, file operations
- **Aliases**: `cc` (normal), `cc-skip` (no permissions), `cc-local` (Ollama), `cc-help` (reference)

---

## 3. Browsers

### Arc — PRIMARY
- **Install**: `cask arc`
- **What**: Chromium browser with workspaces, split views, and built-in tools
- **Why**: Primary browser for development and daily use

### Brave
- **Install**: `cask brave-browser`
- **What**: Privacy-focused Chromium browser with built-in ad blocking
- **Why**: Testing and privacy-sensitive browsing

### Google Chrome
- **Install**: `cask google-chrome`
- **What**: Google's web browser
- **Why**: DevTools, compatibility testing, some extensions only work in Chrome

### Helium
- **Install**: `cask helium-browser`
- **What**: Floating translucent browser window that stays on top of other apps
- **Why**: Reference material, video tutorials, or documentation visible while coding
- **Note**: This is an uncommon app — **important to track** so it doesn't get lost during rebuilds

---

## 4. Productivity & Launchers

### Raycast — Spotlight Replacement
- **Install**: `cask raycast`
- **What**: Launcher, clipboard manager, snippet engine, window management, and 76+ extensions
- **Why**: Replaces Spotlight entirely. Extensions for GitHub, Jira, calculations, color picker, etc.
- **Config**: Binary plist — must be exported manually from Settings > Advanced > Export
- **Backup**: Export `.rayconfig` to iCloud

### Rectangle
- **Install**: `cask rectangle`
- **What**: Window management with keyboard shortcuts
- **Why**: Snap windows to halves, quarters, thirds with hotkeys
- **Config**: JSON export — Rectangle > Preferences > Export
- **Backup**: Export JSON to iCloud

### Amphetamine
- **Install**: `mas 937984704`
- **What**: Prevents Mac from sleeping
- **Why**: Keep machine awake during long builds, presentations, or Ollama inference

### CopyClip
- **Install**: `mas 595191960`
- **What**: Clipboard history in the menu bar
- **Why**: Access previously copied items

### Boop
- **Install**: `mas 1518425043`
- **What**: Developer scratchpad for text transformations
- **Why**: Quick JSON formatting, base64 encoding, URL encoding, etc.

### The Unarchiver
- **Install**: `mas 425424353`
- **What**: Opens any archive format (ZIP, RAR, 7z, tar, etc.)
- **Why**: macOS Archive Utility doesn't handle all formats

### Image2Icon
- **Install**: `mas 992115977`
- **What**: Create custom app icons from any image
- **Why**: Custom icons for development projects

---

## 5. System Monitoring

### Stats
- **Install**: `cask stats`
- **What**: Menu bar system monitor (CPU, RAM, disk, network, battery, GPU)
- **Why**: Always-visible system health. Lightweight alternative to iStat Menus.
- **Config**: Export plist to iCloud for backup

### Ice
- **Install**: `cask jordanbaird-ice`
- **What**: Menu bar item manager — hide/show menu bar icons
- **Why**: Menu bar gets cluttered with many apps. Ice lets you collapse rarely-used icons.

### MonitorControl
- **Install**: `cask monitorcontrol`
- **What**: Control external display brightness and volume via DDC
- **Why**: Adjust external monitors without using their physical buttons

### NeoHtop
- **Install**: `cask neohtop`
- **What**: Modern process viewer with a graphical UI
- **Why**: Visual alternative to htop for process inspection

### coconutBattery
- **Install**: `cask coconutbattery`
- **What**: Battery health monitor for Mac and connected iOS devices
- **Why**: Track battery cycle count, health percentage, and degradation

### Geekbench
- **Install**: `cask geekbench`
- **What**: CPU and GPU benchmark tool
- **Why**: Measure and compare system performance

### Blackmagic Disk Speed Test
- **Install**: `mas 425264550`
- **What**: Measure read/write speed of drives
- **Why**: Verify SSD performance, test external drives

### Speedtest (Ookla)
- **Install**: `mas 1153157709`
- **What**: Internet speed test with native UI
- **Why**: Quick network diagnostics (also available as `speedtest-cli` in terminal)

---

## 6. Cloud & Storage

### Google Drive
- **Install**: `cask google-drive`
- **What**: Desktop sync client for Google Drive
- **Why**: Sync files and access Drive as a mounted volume

### Mountain Duck
- **Install**: `cask mountain-duck`
- **What**: Mount cloud storage (S3, WebDAV, SFTP, FTP) as local drives in Finder
- **Why**: Access remote servers (cPanel, S3 buckets) as if they were local folders
- **Note**: WebDAV mount paths contain `|` characters — use Read/Write tools, not Bash commands

---

## 7. Knowledge & Notes

### Notion
- **Install**: `cask notion`
- **What**: All-in-one workspace for notes, docs, databases, and project management
- **Why**: Team collaboration, personal wiki, project tracking

### Notion Calendar
- **Install**: `cask notion-calendar`
- **What**: Calendar app integrated with Notion databases
- **Why**: Unified scheduling with Notion tasks

### Obsidian
- **Install**: `cask obsidian`
- **What**: Markdown-based knowledge base with bidirectional linking
- **Why**: Personal notes, research, long-term knowledge management

### Notability
- **Install**: `mas 360593530`
- **What**: Note-taking with handwriting and annotation support
- **Why**: Meeting notes, sketches, PDF annotation

### Zotero
- **Install**: `cask zotero`
- **What**: Research reference manager and PDF organizer
- **Why**: Academic papers, citations, research library

---

## 8. Media Players

### IINA — PRIMARY
- **Install**: `cask iina`
- **What**: Modern, native macOS media player
- **Why**: Better macOS integration than VLC, supports all common formats, picture-in-picture

### VLC
- **Install**: `cask vlc`
- **What**: Universal media player — plays virtually any format
- **Why**: Fallback for edge-case formats IINA can't handle

### Infuse
- **Install**: `mas 1136220934`
- **What**: Premium video player with broad codec support and streaming
- **Why**: Beautiful UI, streams from NAS/Plex/network shares

### Capo
- **Install**: `mas 696977615`
- **What**: Automatic chord and key detection for music
- **Why**: Music analysis and learning

---

## 9. Design & Media Tools

### ImageOptim
- **Install**: `cask imageoptim`
- **What**: Lossless image compression GUI
- **Why**: Optimize images for web before deployment

### Inkscape
- **Install**: `cask inkscape`
- **What**: Open-source vector graphics editor (SVG)
- **Why**: Logo design, SVG editing, alternative to Illustrator for simple tasks

### ColorSlurp
- **Install**: `mas 1287239339`
- **What**: System-wide color picker with format conversion
- **Why**: Pick any color from screen, copy as HEX/RGB/HSL

### Photomator
- **Install**: `mas 1444636541`
- **What**: AI-powered photo editor (formerly Pixelmator Photo)
- **Why**: Quick photo editing without launching full Adobe suite

### Exporter
- **Install**: `mas 1099120373`
- **What**: Export photos from Apple Photos to folders with naming rules
- **Why**: Batch photo export with custom organization

### CompressX
- **Install**: **Manual** (not in Homebrew)
- **What**: Image and video compression tool
- **Why**: Reduce file sizes for web assets

---

## 10. Security & Privacy

### 1Password
- **Install**: `cask 1password`
- **What**: Password manager with browser extensions
- **Why**: Secure credential storage, SSH key agent, developer tokens

### Bitwarden
- **Install**: `mas 1352778147`
- **What**: Open-source password manager
- **Why**: Free alternative/backup password store, cross-platform sync

### NordVPN
- **Install**: `mas 905953485`
- **What**: VPN client for privacy and geo-unblocking
- **Why**: Secure browsing on public networks, access region-locked content

### AdBlock Pro
- **Install**: `mas 1018301773`
- **What**: Safari ad and tracker blocker
- **Why**: Block ads in Safari without performance overhead

---

## 11. Development Utilities

### Xcode
- **Install**: `mas 497799835`
- **What**: Apple's IDE for iOS, macOS, watchOS, tvOS development
- **Why**: Required for iOS/macOS app development, provides simulators and instruments

### TestFlight
- **Install**: `mas 899247664`
- **What**: Beta app testing platform
- **Why**: Test pre-release builds of iOS/macOS apps

### Transporter
- **Install**: `mas 1450874784`
- **What**: Upload builds to App Store Connect
- **Why**: Submit app binaries for review

### Developer (Apple)
- **Install**: `mas 640199958`
- **What**: WWDC sessions, documentation, and developer resources
- **Why**: Stay current with Apple platform changes

### XcodeGen
- **Install**: `brew xcodegen`
- **What**: Generate Xcode projects from YAML specs
- **Why**: Declarative Xcode project configuration, avoids `.xcodeproj` merge conflicts

### Shapr3D
- **Install**: `mas 1091675654`
- **What**: Professional 3D CAD modeling optimized for Apple Silicon
- **Why**: Engineering design, 3D modeling, rapid prototyping

---

## 12. Apple iWork

| App | MAS ID | Purpose |
|-----|--------|---------|
| Keynote | 409183694 | Presentations |
| Pages | 409201541 | Documents |
| Numbers | 409203825 | Spreadsheets |

---

## 13. Tracking & Information

### Flighty
- **Install**: `mas 1358823008`
- **What**: Flight tracker with live status, delays, and gate changes
- **Why**: Travel companion for frequent flyers

### Parcel Classic
- **Install**: `mas 639968404`
- **What**: Package delivery tracking across all carriers
- **Why**: Track shipments from Amazon, FedEx, UPS, etc.

### Ground News
- **Install**: `mas 1324203419`
- **What**: News aggregator with media bias analysis
- **Why**: See how stories are covered across the political spectrum

---

## 14. Miscellaneous

### Antigravity
- **Install**: `cask antigravity`
- **What**: Antigravity utility app
- **Setup**: Adds `~/.antigravity/antigravity/bin` to PATH

### Mimestream
- **Install**: `cask mimestream`
- **What**: Native macOS email client built specifically for Gmail
- **Why**: Fast, lightweight, uses Gmail API directly

### HP Printer
- **Install**: `mas 1474276998`
- **What**: HP printer drivers and scanning utilities
- **Why**: Required for HP printer support

### QLVideo
- **Install**: `cask qlvideo`
- **What**: QuickLook plugin for video file thumbnails and previews
- **Why**: Preview video files in Finder without opening a player

---

## 15. Explicitly Excluded

These apps are deliberately NOT included in the automated setup.

| App | Reason | Alternative |
|-----|--------|-------------|
| Microsoft Word | Not needed for development | Pages, Google Docs |
| Microsoft Excel | Not needed for development | Numbers, Google Sheets |
| Microsoft PowerPoint | Not needed for development | Keynote |
| Microsoft OneNote | Not needed | Notability, Obsidian |
| Microsoft Outlook | Not needed | Mimestream |
| Microsoft To Do | Not needed | Notion |
| Microsoft OneDrive | Not needed | Google Drive |
| Spotify | Not needed | Apple Music, YouTube |
| iMovie | Apple bloatware | DaVinci Resolve (if needed) |
| GarageBand | Apple bloatware | Logic Pro (if needed) |
| Mini Motorways | Game | Install manually: `mas install 1456188526` |
| Solves | Game | Install manually: `mas install 1394359548` |
| Slack | Communication — install if needed | `brew install --cask slack` |
| Discord | Communication — install if needed | `brew install --cask discord` |
| Microsoft Teams | Communication — install if needed | `brew install --cask microsoft-teams` |
| WhatsApp | Communication — install if needed | `mas install 310633997` |
| Telegram Lite | Communication — install if needed | `mas install 946399090` |
| Messenger | Communication — install if needed | `mas install 1480068668` |
| Adobe Suite | Proprietary installer | Download from adobe.com |

---

## Counts

| Category | Count |
|----------|-------|
| Homebrew Formulae | 50 |
| Homebrew Casks | 40 |
| Mac App Store | 30 |
| Manual Install | 1 (CompressX) |
| Excluded | 19 |
| **Total managed** | **120** |
