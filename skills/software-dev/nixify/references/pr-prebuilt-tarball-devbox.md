## CRITICAL — How to post these bodies to GitHub (read before any `gh` call)

The template below contains markdown backticks (`` ` `` and triple-fence ``` ``` ```), shell-style `$VARS` (`$UPSTREAM_OWNER`, `$UPSTREAM_REPO`, `$CURRENT_USER`), and real newlines. If you pass it to `gh` the wrong way, GitHub stores garbage. Two failure modes have shipped broken PRs/issues in the wild:

1. **Literal `\n` in the body** — happens when you reconstruct the body as a single-line string with `\n` escape sequences (e.g. an LLM-emitted string literal) and pass it to `gh --body "..."`. The `\n` is stored verbatim as two characters, not a newline. The whole post becomes one unreadable line.
2. **Stripped code spans + empty variables** — happens when you feed the body through an unquoted shell heredoc (`cat <<EOF` instead of `cat <<'EOF'`) or `echo "..."`. Backticks get command-substituted (`` `flake.nix` `` runs as a command → empty), and `$UPSTREAM_OWNER` is expanded by the shell to empty.

**Always do this, no exceptions:**

1. Substitute the four placeholders by **text replacement** (not shell expansion): `$UPSTREAM_OWNER`, `$UPSTREAM_REPO`, `$CURRENT_USER`, and `<issue-number>` / `<platform>` / `<project-name>`. Use `sed -i`/`perl -pi -e` or edit the file in your editor tool — never let bash expand `$UPSTREAM_OWNER`.
2. Write the final body to a **file** (e.g. `/tmp/pr-body.md`).
3. Post with `--body-file`, never `--body`:
   ```bash
   gh pr create --repo "$UPSTREAM_OWNER/$UPSTREAM_REPO" --title "..." --body-file /tmp/pr-body.md
   gh issue create --repo "$UPSTREAM_OWNER/$UPSTREAM_REPO" --title "..." --body-file /tmp/issue-body.md
   ```
4. Before posting, sanity-check the file: `grep -c '\\n' /tmp/pr-body.md` must return `0` (no literal backslash-n), and `grep -n '`'` must show the backtick code spans intact.

**Never** use `gh ... --body "$BODY"` with an inline string. **Never** use an unquoted heredoc to build the body. The `--body-file` path is the only one that survives multi-line markdown with backticks and `$` intact.


---

<!-- Variant: Prebuilt Tarball Flake — with devbox (flake_type=prebuilt_tarball, include_devbox=true) -->
<!-- Use this variant ONLY when the user explicitly asked for devbox in a prebuilt tarball PR. This is not the default. -->
<!-- CRITICAL: All content MUST reference the UPSTREAM repository ($UPSTREAM_OWNER/$UPSTREAM_REPO), NOT the fork. -->

<!-- Template body follows. Copy everything below this comment as the PR body. -->

---
title: feat: add Nix flake and Devbox support
---

## What

Adds a `flake.nix` so the project can be installed and run directly from GitHub at the latest release:

```bash
nix run github:$UPSTREAM_OWNER/$UPSTREAM_REPO
nix profile add github:$UPSTREAM_OWNER/$UPSTREAM_REPO
```

The flake tracks the default branch and is auto-bumped to the latest release by a daily workflow, so `github:$UPSTREAM_OWNER/$UPSTREAM_REPO` always serves the current release.

Adds a `devbox.json` for reproducible development environments (if not present):

```bash
devbox shell
devbox run build
```

## Why

For users who already have Nix installed, a flake provides:

- **One-command install / run** — `nix run github:$UPSTREAM_OWNER/$UPSTREAM_REPO` with no clone or manual build steps.
- **Pure / Hermetic builds** — every input (the prebuilt binary, glibc/libiconv) is pinned in `flake.lock`. If it builds today, it builds in ten years.
- **Reproducible** — the exact same derivation always produces the exact same output bit-for-bit. No "works on my machine."
- **Idempotent installs** — running `nix profile add` twice is a no-op.
- **Rollback-able** — `nix profile rollback` restores the previous profile generation instantly.
- **Cross-platform** — same invocation on macOS (Apple Silicon & Intel) and Linux. The flake handles platform-specific linking.
- **Atomic upgrades / downgrades** — profiles are switched atomically. No half-upgraded state.
- **Clean uninstall** — `nix profile remove` leaves no residue.

## Changes

- `flake.nix`: Nix flake wrapping the prebuilt release tarball as `packages.<system>.default` and `apps.<system>.default`.
- `flake.lock`: pinned `nixpkgs-unstable` input.
- `.github/workflows/nix-release.yml`: scheduled lag-check automation that auto-bumps `version` + per-platform `sha256` hashes and opens a PR when `flake.nix` falls behind the latest release.
- `devbox.json`: Devbox configuration for reproducible development environments (if not present)
- `.gitignore`: Added Nix build result symlinks
- `README.md`: Added Nix installation subsection
- `README.ko.md`: Mirrored Nix installation subsection (if applicable)
- `CHANGELOG.md`: Added changelog entry (if applicable)

## Testing

Verified locally:

```bash
nix flake check --no-build
nix build .
nix run . -- --help
```

Builds and runs successfully on `<platform>`.

## Notes

- The flake exposes the **prebuilt release tarball** as `#prebuilt` (also `#default`, fast, no compilation) and a **from-source build** as `#source` (reproducible, auditable). Both are exercised by CI.
- Tag-pinning (`github:.../vX.Y.Z`) is not supported for the prebuilt output — release tags are cut before the bump workflow updates `flake.nix`. Use `github:.../` (tracks default branch) or pin to a commit SHA. The `#source` output works at any tag since it builds from source.
- No breaking changes to existing build paths.

## Scope

The PR scope is well-contained — additive only, no existing functionality affected.

## Related

Resolves #<issue-number>
