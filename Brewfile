# ============================================================================
# Brewfile — Full system inventory for Mac development environment
# Run: brew bundle --file=Brewfile
# Check: brew bundle check --file=Brewfile
# Last audited: 2026-04-12
# ============================================================================

# --- Taps -------------------------------------------------------------------
tap "minicodemonkey/chief"
tap "stripe/stripe-cli"
tap "supabase/tap"

# --- Core Development Tools -------------------------------------------------
brew "git"                  # Version control
brew "gh"                   # GitHub CLI
brew "node"                 # Node.js runtime
brew "deno"                 # JS/TS runtime
brew "go"                   # Go programming language
brew "python@3.13"          # Python 3.13 (primary)
brew "python@3.11"          # Python 3.11 (compatibility)

# --- Package Managers & Build Tools -----------------------------------------
brew "mas"                  # Mac App Store CLI
brew "pipx"                 # Isolated Python tool installer
brew "uv"                   # Fast Python package manager
brew "xcodegen"             # Xcode project generator

# --- CLI Productivity -------------------------------------------------------
brew "bat"                  # cat with syntax highlighting
brew "eza"                  # Modern ls replacement
brew "fd"                   # Fast find alternative
brew "fzf"                  # Fuzzy finder
brew "ripgrep"              # Fast grep (rg)
brew "jq"                   # JSON processor
brew "yq"                   # YAML processor
brew "htop"                 # Process viewer
brew "btop"                 # Resource monitor
brew "mactop"               # macOS CPU/GPU/ANE monitor
brew "tmux"                 # Terminal multiplexer
brew "stow"                 # Dotfile symlink manager
brew "starship"             # Cross-shell prompt
brew "zoxide"               # Smart cd replacement
brew "lazygit"              # Terminal Git UI
brew "ncdu"                 # Disk usage analyzer

# --- LLM & AI Tools --------------------------------------------------------
brew "ollama"               # Local LLM runner

# --- Media & Image Processing ----------------------------------------------
brew "ffmpeg"               # Media processing
brew "gifsicle"             # GIF optimizer
brew "gifski"               # High-quality GIF encoder
brew "pngquant"             # PNG compressor
brew "resvg"                # SVG renderer
brew "tesseract"            # OCR engine

# --- Security & Encryption -------------------------------------------------
brew "gnupg"                # GPG encryption

# --- Data & Documents -------------------------------------------------------
brew "pandoc"               # Document converter
brew "jupyterlab"           # Data science notebooks

# --- Downloaders & Archival -------------------------------------------------
brew "yt-dlp"               # Video downloader
brew "gallery-dl"           # Media archival

# --- Cloud & Backend CLIs --------------------------------------------------
brew "stripe/stripe-cli/stripe"     # Stripe CLI
brew "supabase/tap/supabase"        # Supabase CLI
brew "duck"                         # Cyberduck CLI (WebDAV/S3)
brew "minicodemonkey/chief/chief"   # Chief CLI

# --- Miscellaneous ----------------------------------------------------------
brew "agent-browser"        # Headless browser automation
brew "cliclick"             # macOS mouse/keyboard automation
brew "mlx"                  # Apple MLX framework
brew "mole"                 # SSH tunneling
brew "portaudio"            # Audio I/O library
brew "speedtest-cli"        # Network speed test
brew "tcl-tk"               # Tcl/Tk toolkit

# ============================================================================
# Casks (GUI Applications)
# ============================================================================

# --- Dev Tools & Editors ----------------------------------------------------
cask "ghostty"              # Terminal emulator
cask "cursor"               # AI code editor
cask "visual-studio-code"   # Code editor
cask "docker"               # Container platform
cask "supacode"             # Supabase code editor
cask "windsurf"             # AI IDE
cask "tabby"                # Terminal emulator (alt)
cask "localcan"             # Local development
cask "codexbar"             # Menu bar customization
cask "gcollazo-mongodb"     # MongoDB GUI
cask "mactex"               # LaTeX distribution
cask "font-jetbrains-mono-nerd-font"  # Terminal font

# --- AI & LLM Apps ---------------------------------------------------------
cask "claude"               # Claude desktop app
cask "chatgpt"              # ChatGPT desktop app

# --- Browsers ---------------------------------------------------------------
cask "arc"                  # Arc browser
cask "brave-browser"        # Brave browser
cask "google-chrome"        # Chrome browser
cask "helium-browser"       # Floating browser window

# --- Productivity & Utilities -----------------------------------------------
cask "raycast"              # Launcher & productivity
cask "rectangle"            # Window management
cask "stats"                # System monitor (menu bar)
cask "jordanbaird-ice"      # Menu bar manager
cask "1password"            # Password manager
cask "coconutbattery"       # Battery health monitor
cask "imageoptim"           # Image compression
cask "monitorcontrol"       # External display brightness
cask "mountain-duck"        # Cloud storage mounting
cask "google-drive"         # Google Drive sync
cask "inkscape"             # Vector graphics editor
cask "qlvideo"              # QuickLook video preview
cask "antigravity"          # Antigravity app
cask "neohtop"              # Modern htop GUI
cask "mimestream"           # Native macOS email
cask "geekbench"            # System benchmarking

# --- Knowledge & Notes ------------------------------------------------------
cask "notion"               # Notes & wiki
cask "notion-calendar"      # Calendar
cask "obsidian"             # Markdown knowledge base
cask "zotero"               # Research reference manager

# --- Media ------------------------------------------------------------------
cask "iina"                 # Modern media player
cask "vlc"                  # Universal media player

# ============================================================================
# Mac App Store Apps (via mas)
# ============================================================================
# Requires: App Store sign-in on target Mac
# Install with: mas install <id>

# --- Productivity ---
mas "Amphetamine", id: 937984704           # Prevent sleep
mas "CopyClip", id: 595191960             # Clipboard manager
mas "The Unarchiver", id: 425424353        # Archive extraction
mas "Image2Icon", id: 992115977           # Icon creator
mas "Boop", id: 1518425043               # Text scratchpad

# --- Apple iWork ---
mas "Keynote", id: 409183694
mas "Pages", id: 409201541
mas "Numbers", id: 409203825

# --- Notes & Learning ---
mas "Notability", id: 360593530            # Note-taking

# --- Development ---
mas "Xcode", id: 497799835               # Apple IDE
mas "Developer", id: 640199958           # WWDC & docs
mas "TestFlight", id: 899247664          # Beta testing
mas "Transporter", id: 1450874784        # App Store uploads

# --- Design & Media ---
mas "ColorSlurp", id: 1287239339          # Color picker
mas "Photomator", id: 1444636541          # Photo editor
mas "Exporter", id: 1099120373           # Photo export
mas "Infuse", id: 1136220934             # Media player
mas "Capo", id: 696977615               # Music analysis

# --- Security & Network ---
mas "NordVPN", id: 905953485
mas "Bitwarden", id: 1352778147
mas "AdBlock Pro", id: 1018301773

# --- Diagnostics & Tools ---
mas "Blackmagic Disk Speed Test", id: 425264550
mas "Speedtest", id: 1153157709
mas "HP", id: 1474276998                  # Printer drivers

# --- AI ---
mas "Perplexity", id: 6714467650
mas "Locally AI", id: 6741426692          # Local AI runner

# --- Tracking & Travel ---
mas "Flighty", id: 1358823008            # Flight tracker
mas "Parcel Classic", id: 639968404       # Package tracker
mas "Ground News", id: 1324203419         # News aggregator

# --- 3D & Engineering ---
mas "Shapr3D", id: 1091675654            # 3D CAD modeling
