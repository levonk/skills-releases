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

<!-- Variant: Source Build Flake (flake_type=source_build, devbox included) -->
<!-- CRITICAL: All content MUST reference the UPSTREAM repository ($UPSTREAM_OWNER/$UPSTREAM_REPO), NOT the fork. -->

<!-- Template body follows. Copy everything below this comment as the PR body. -->

---
title: feat: add Nix flake and Devbox support
---

## What

Adds a `flake.nix` so the project can be installed and run directly from GitHub:

```bash
nix run github:$UPSTREAM_OWNER/$UPSTREAM_REPO
nix profile install github:$UPSTREAM_OWNER/$UPSTREAM_REPO
nix run github:$UPSTREAM_OWNER/$UPSTREAM_REPO/v1.2.3   # pin a specific release
```

Adds a `devbox.json` for reproducible development environments (if not present):

```bash
devbox shell
devbox run build
```

## Why

The project currently requires users to clone the repository and build from source. For users who already have Nix installed, a flake provides:

- **Pure / Hermetic builds** — every input (compiler, libraries, system dependencies) is pinned in `flake.lock`. If it builds today, it builds in ten years.
- **Reproducible** — the exact same derivation always produces the exact same output bit-for-bit. No "works on my machine."
- **Idempotent installs** — running `nix profile install` twice is a no-op. The system reaches the declared state and stays there.
- **Rollback-able** — `nix profile rollback` restores the previous profile generation instantly. Broken update? One command back.
- **Declarative** — the entire build is a single expression (`flake.nix`). No imperative `apt install`, `brew install`, `make` dance.
- **One-command install / run** — `nix run github:$UPSTREAM_OWNER/$UPSTREAM_REPO` with no clone or manual build steps.
- **Binary cache eligibility** — Nix can pull pre-built artifacts from cache.nixos.org or flakehub when the project is packaged.
- **Cross-platform** — same invocation on macOS (Apple Silicon & Intel) and Linux. The flake handles platform-specific dependencies.
- **Atomic upgrades / downgrades** — profiles are switched atomically. No half-upgraded state.
- **Clean uninstall** — `nix profile remove` leaves no residue. No orphaned global packages.

## Changes

- `flake.nix`: Nix flake with `packages.default`, `apps.default`, `overlays.default`, and `checks`
- `devbox.json`: Devbox configuration for reproducible development environments (if not present)
- `.gitignore`: Added Nix build result symlinks
- `.github/workflows/nix.yml`: GitHub Actions CI for Nix validation
- `README.md`: Added Nix installation subsection
- `README.ko.md`: Mirrored Nix installation subsection (if applicable)
- `CHANGELOG.md`: Added changelog entry (if applicable)
- Optional: `nix/modules/` directory with modular structure
- Optional: `nix/modules/hm-module.nix` for home-manager integration
- Optional: `default.nix` and `shell.nix` for legacy Nix support
- Optional: `nix/modules/treefmt.nix` for automated formatting
- Optional: `.github/workflows/cachix.yml` for binary caching

## Testing

Verified locally:

```bash
nix run . -- --help
devbox run build
devbox run test
```

Builds and runs successfully on `<platform>`.

## Notes

- The flake uses `nixpkgs-unstable` and `flake-utils` for broad platform support.
- Darwin builds include `libiconv`; modern `rustPlatform` handles Security framework linking without the deprecated `apple_sdk` compatibility stub.
- No breaking changes to existing build paths.

## Scope

The PR scope is well-contained — additive only, no existing functionality affected.

## Related

Resolves #<issue-number>
