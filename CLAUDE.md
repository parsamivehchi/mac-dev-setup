# Mac Dev Setup - bootstrap and disaster-recovery kit for Apple Silicon

## What it is
Bash kit that rebuilds a Mac dev environment (setup, audit, backup, restore) plus a small public product page under `site/`. Public repo (parsamivehchi/mac-dev-setup). No app server, no portless name.

## Current state (as of 2026-10-22)
- Last commit 2026-07-24; kit is complete, no open work (not a tombstone candidate: nothing supersedes it). No ship.json, AGENTS.md, CHANGELOG.md or `.claude/STATE.md` in the repo.
- Public page: `site/mac-setup` (static `index.html` + `styles.css`), mounted at mivehchi.app/mac-setup. `site/vercel.json` 307s the vercel.app host to that mount and exempts requests carrying `x-cf-mount-host` (commits 2026-07-10, 2026-07-12, 2026-07-24).

## Run, gate, deploy
- `./setup.sh --dry-run` first; then `./setup.sh [--skip-restore]` (18 phases; `--skip-restore` skips phases 12-15).
- `./audit.sh` (pre-migration scan), `./backup.sh [--skip-secrets] [--skip-projects]`, `./restore.sh <backup_dir>`, `bootstrap.sh` (curl one-liner entry).
- Gate: `tests/verify.sh` (post-setup checks), checklist in `tests/checklist.md`.
- Deploy: only `site/` goes to Vercel; no deploy config beyond `site/vercel.json` is in the repo (unverified 2026-10-22: project name and deploy command).

## Architecture map
- Entry scripts at root: `setup.sh`, `audit.sh`, `backup.sh`, `restore.sh`, `bootstrap.sh`; `Brewfile` drives Phase 3.
- `scripts/` helpers: `restore_{claude,editors,raycast}.sh`, `git_config.sh`, `macos_defaults.sh`, `pull_models.sh`, `icloud-sync.sh`, `install-gitignore.sh`, `install-gitignore-xattr.sh`.
- `config/`: committed snapshots (`claude`, `vscode`, `cursor`, `ghostty`, `zshrc`, `starship.toml`, `ollama.env`).
- `LaunchAgents/com.user.ollama.plist` at repo root (Ollama launch agent).
- Backups go to timestamped dirs under `backups/` (gitignored); secrets encrypted with `openssl enc -aes-256-cbc -salt -pbkdf2`; manifest uses SHA-256 via Python `hashlib`.
- API tokens live in macOS Keychain (setup.sh prints the instruction), not config files.
- Docs: `docs/{apps-inventory,configs-map,dependencies,rebuild-guide}.md`, `LESSONS.md`.

## Invariants
- NEVER commit `backups/` (contains secrets). `.gitignore` covers `backups/`, `audit_report_*.txt`, `*.enc`, `.DS_Store`, `.zshrc.local`.
- No API keys, passwords or personal identifiers in committed files (public repo and public site). Secrets go in Keychain or `~/.zshrc.local`.
- Every phase is idempotent: check state before acting.

## Project conventions
- All scripts: `set -euo pipefail`, colored helpers (`ok`, `warn`, `fail`, `skip`), `SCRIPT_DIR` for portable paths.
- Bash only, no Python except JSON/manifest generation. All paths use `$HOME`, no hardcoded usernames.
- Colors: green=success, yellow=skip/warn, red=fail, cyan=headers, purple=dry-run.
- Brewfile comments use `# description` after the package name.

## Gotchas
- `backup.sh` prompts for an openssl passphrase; it will not work in the Claude Code Bash tool. Run it directly in a terminal, or use `--skip-secrets`.
- `brew leaves` shows only direct installs, so the audit comparison can report false "not installed" for dependency packages.
- `pipefail` plus pipes kills scripts; see `LESSONS.md`.
- Run `gh auth status` before pushing.

## Where history lives
`git log`, `LESSONS.md`, `docs/`.
