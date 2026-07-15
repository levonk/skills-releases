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

<!-- Variant: Prebuilt Tarball (flake_type=prebuilt_tarball, no devbox) -->
<!-- CRITICAL: All content MUST reference the UPSTREAM repository ($UPSTREAM_OWNER/$UPSTREAM_REPO), NOT the fork. -->

<!-- Template body follows. Copy everything below this comment as the issue body. -->

---
title: feat: add Nix flake support for one-command installation
---

## Summary

This issue tracks adding Nix flake support to the upstream project so users can install and run it without cloning or compiling manually.

## What Nix provides

- **One-command install / run** — `nix run github:$UPSTREAM_OWNER/$UPSTREAM_REPO` with no clone or manual build steps.
- **Pure / Hermetic builds** — every input (the prebuilt binary, glibc/libiconv) is pinned in `flake.lock`. If it builds today, it builds in ten years.
- **Reproducible** — the exact same derivation always produces the exact same output bit-for-bit. No "works on my machine."
- **Idempotent installs** — running `nix profile install` twice is a no-op.
- **Rollback-able** — `nix profile rollback` restores the previous profile generation instantly.
- **Cross-platform** — same invocation on macOS (Apple Silicon & Intel) and Linux. The flake handles platform-specific linking.
- **Atomic upgrades / downgrades** — profiles are switched atomically. No half-upgraded state.
- **Clean uninstall** — `nix profile remove` leaves no residue.

## Current gap

The project currently only documents source builds (`cargo install --path .`, `npm install -g`, etc.). There is no one-command install path for users who already have Nix.

## Proposed change

- Add `flake.nix` with `packages.default` and `apps.default` (prebuilt release tarball), plus `packages.<system>.source` and `apps.<system>.source` (from-source build) so users can choose between the fast prebuilt path and the reproducible-from-source path.
- Add a scheduled GitHub Action that auto-bumps `version` and refreshes per-platform `sha256` hashes when a new release is cut.
- Update README install section to include Nix (flakes) instructions
- Mirror changes to translated READMEs (e.g., `README.ko.md`)
- Update `docs/getting-started/installation.md` with `### Nix (Flakes)` subsection (if present)
- Update `docs/index.mdx` landing page install splash with Nix option (if present)
- Update `docs/contributing/releasing.md` with Nix flake version/hash update step (if present)

## Branch

`feat-nix-package-manager-install` on the fork.

## Implementation

I have prepared the implementation in my fork at:
https://github.com/$CURRENT_USER/$UPSTREAM_REPO/tree/feat-nix-package-manager-install

The changes include:
- `flake.nix`: Nix flake wrapping the prebuilt release tarball as `packages.<system>.default` and `apps.<system>.default`, plus a from-source build as `packages.<system>.source` and `apps.<system>.source`
- `flake.lock`: pinned `nixpkgs-unstable` input
- `.github/workflows/nix-release.yml`: scheduled lag-check automation that auto-bumps `version` + per-platform `sha256` hashes
- `.github/workflows/nix.yml`: GitHub Actions CI for Nix validation
- `README.md`: added "With Nix (flakes)" install subsection
- `README.ko.md`: mirrored the Nix install section (if applicable)
- `docs/getting-started/installation.md`: added `### Nix (Flakes)` subsection (if present)
- `docs/index.mdx`: added Nix code block to install splash (if present)
- `docs/contributing/releasing.md`: added Nix flake update step (if present)

Tested locally with `nix run . -- --help`.
