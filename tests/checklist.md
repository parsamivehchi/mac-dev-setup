# Manual Verification Checklist

Run through these after `setup.sh`, `restore.sh`, and `verify.sh` complete.

## Terminal & Shell

- [ ] Open Ghostty — verify font (JetBrains Mono), dark theme, padding
- [ ] Starship prompt shows — git branch, node version, python version
- [ ] `z` (zoxide) jumps to recent directories
- [ ] `ll` (eza alias) shows colored file listing
- [ ] `cat` (bat alias) shows syntax highlighting

## Ollama & LLM

- [ ] `ollama list` shows 5 models (qwen3-coder, qwen2.5-coder:14b, deepseek-r1:14b, glm-4.7-flash, etc.)
- [ ] `ollama run qwen3-coder "hello"` responds successfully
- [ ] Ollama LaunchAgent is loaded: `launchctl list | grep ollama`

## Editors

- [ ] VS Code opens, extensions loaded (87 expected)
- [ ] VS Code settings.json applied (check theme, font, key bindings)
- [ ] Cursor opens, extensions loaded (87 expected)
- [ ] Cursor settings and keybindings match old Mac

## Claude Code

- [ ] `claude` launches successfully
- [ ] Plugins download on first run (11 expected)
- [ ] Memory files present in `~/.claude/projects/`
- [ ] Settings applied (check `~/.claude/settings.json`)

## Raycast

- [ ] Raycast launches on `Cmd+Space` (or configured hotkey)
- [ ] Extensions visible (38 expected)
- [ ] AI features configured
- [ ] Window management hotkeys work

## Git & SSH

- [ ] `git config user.name` returns correct name
- [ ] `git config user.email` returns correct email
- [ ] `ssh -T git@github.com` authenticates successfully
- [ ] `gh auth status` shows authenticated

## macOS Preferences

- [ ] Dock: auto-hide enabled, small icon size
- [ ] Finder: show file extensions, path bar visible
- [ ] Keyboard: fast key repeat, short initial repeat delay
- [ ] Trackpad: tap to click enabled

## Project Data

- [ ] Project data restored from backup (if applicable)
- [ ] Git repos cloned with correct remotes

## Secrets

- [ ] `.env` files decrypted and in correct locations
- [ ] `~/.ssh/id_*` have correct permissions (600 for private, 644 for public)
- [ ] SSH key added to GitHub

## Apps (Manual Install Required)

These apps need manual installation (not available via Homebrew or App Store):

- [ ] Adobe Creative Cloud (Photoshop, Illustrator, Lightroom)
- [ ] Logitech Options+ (logioptionsplus)
- [ ] GoPro Webcam
- [ ] Hik-Connect
- [ ] Macs Fan Control
- [ ] Mx Power Gadget
