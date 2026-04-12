# Mac Dev Setup

## Project
Mac development environment bootstrap and disaster recovery kit for Apple Silicon.

## Key Scripts
| Script | Purpose | Flags |
|--------|---------|-------|
| `setup.sh` | 18-phase bootstrap | `--dry-run`, `--skip-restore` |
| `audit.sh` | Pre-migration readiness scan | — |
| `backup.sh` | Export configs/data/secrets | `--skip-secrets`, `--skip-projects` |
| `restore.sh` | Restore from backup | `<backup_dir>` argument |
| `tests/verify.sh` | Post-setup automated checks | — |
| `bootstrap.sh` | curl one-liner entry point | — |

## Architecture
- All scripts use `set -euo pipefail` with colored output helpers (`ok`, `warn`, `fail`, `skip`)
- Backup creates timestamped dirs under `backups/` (gitignored)
- Secrets encrypted with `openssl enc -aes-256-cbc -salt -pbkdf2`
- Manifest uses SHA-256 checksums via Python's `hashlib`
- Restore helper scripts in `scripts/restore_{claude,editors,raycast}.sh`
- Config snapshots committed to `config/{claude,vscode,cursor}/`
- API tokens stored in macOS Keychain, not config files

## Conventions
- Bash scripts — no Python except for JSON/manifest generation
- Idempotent — every phase checks state before acting
- `SCRIPT_DIR` pattern for portable path resolution
- Color codes: green=success, yellow=skip/warn, red=fail, cyan=headers, purple=dry-run
- Brewfile comments use `# description` after the package name
- All paths use `$HOME` — no hardcoded usernames

## Security Rules
- NEVER commit `backups/` directory (contains secrets)
- No API keys, passwords, or personal identifiers in committed files
- `.gitignore` covers: `backups/`, `audit_report_*.txt`, `*.enc`, `.DS_Store`, `.zshrc.local`
- Secrets go in macOS Keychain or `~/.zshrc.local` (both gitignored)

## Working With This Repo
- `gh auth status` — verify GitHub CLI auth before push
- Interactive prompts in `backup.sh` (openssl passphrase) won't work in Claude Code Bash tool — must run directly in terminal
- `brew leaves` only shows direct installs, not deps — audit comparison may show false "not installed" for dependency packages
