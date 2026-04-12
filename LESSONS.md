# Lessons Learned

## Bash Scripting

### `set -euo pipefail` with pipes
`git log '@{u}..HEAD' 2>/dev/null | wc -l` will kill the entire script if the git command fails, even with `2>/dev/null`, because `pipefail` propagates the leftmost non-zero exit. Fix: capture output with `|| true` first, then process.

```bash
# BAD — kills script if no upstream
UNPUSHED=$(git log --oneline '@{u}..HEAD' 2>/dev/null | wc -l)

# GOOD — safe with pipefail
UNPUSHED=$(git log --oneline '@{u}..HEAD' 2>/dev/null || true)
[[ -n "$UNPUSHED" ]] && COUNT=$(echo "$UNPUSHED" | wc -l)
```

### Sed with inline comments
Brewfile lines like `brew "ffmpeg"  # Media processing` break naive sed. Use `[^"]*` instead of `.*` to stop at the closing quote.

```bash
# BAD — captures everything including comment
sed 's/brew "\(.*\)"/\1/'

# GOOD — stops at closing quote
sed 's/brew "\([^"]*\)".*/\1/'
```

### Interactive prompts in automated tools
`openssl enc` and `read -rp` require real TTY input. Claude Code's Bash tool can't handle these. Solution: use `--skip-secrets` flag for automated runs, run the full script directly in terminal.

## Homebrew

### `brew leaves` vs `brew list`
`brew leaves` shows only packages you explicitly installed, not their dependencies. If you install `ffmpeg` manually but `bat` comes as a dependency of something else, `brew leaves` will show `ffmpeg` but not `bat`. This means comparing `brew leaves` against Brewfile will show false "not installed" for packages that are actually present as dependencies.

### Cask app name matching
Homebrew cask names don't always match `/Applications/` names. `visual-studio-code` installs as "Visual Studio Code.app", `1password` installs as "1Password.app". Fuzzy matching (lowercase + dashes) works for most but not all cases.

### `brew search --cask` is slow and imprecise
Running `brew search --cask` per app in a loop is slow (~1s each) and returns fuzzy matches that are often wrong (e.g., "Microsoft Word" matches "microsoft-edge"). Better to compare against known Brewfile entries directly.

## Git

### Repos without remotes
Not all git repos have an `origin` remote. `git remote get-url origin` exits non-zero in this case. Always use `|| echo "no remote"` or `|| true`.

### Auto-configured committer
Without `git config --global user.name`, git auto-detects from the system hostname, producing commits like `Your Name <username@hostname.localdomain>`. Works but looks unprofessional.

## Security

### Personal info in config files
`installed_plugins.json` contained hardcoded home directory paths in `installPath` fields. Always grep for username/email/paths before making a repo public.

### What NOT to commit
- `backups/` — contains encrypted secrets, project data
- `audit_report_*.txt` — contains system info, paths, secret locations
- `.env` files — API keys
- `*.enc` — encrypted files (useless without passphrase, but still sensitive)

## GitHub

### Repo renaming
`gh repo rename <new-name>` works cleanly but you must update the local remote URL afterward:
```bash
gh repo rename new-name --repo owner/old-name --yes
git remote set-url origin https://github.com/owner/new-name.git
```

### GitHub Pages from docs/
```bash
gh api repos/OWNER/REPO/pages -X POST \
  -f "build_type=legacy" \
  -f "source[branch]=main" \
  -f "source[path]=/docs"
```

## macOS

### `screencapture` permissions
`screencapture` requires Screen Recording permission. CLI tools like Claude Code don't have this by default, so `screencapture -x` fails with "could not create image from display".

### App Store sign-in detection
`mas account` returns "not signed in" or the email. On newer macOS versions, detection can be unreliable — the App Store may be signed in but `mas account` still reports otherwise.
