# Changelog Entry

If the project maintains a CHANGELOG.md, add an entry under `## Unreleased` -> `### Added`:

```markdown
### Added
- Added optional Nix flake support for building, running, installing, and developing <project-name> with Nix. (#<issue-number>)
```

**Format guidelines:**
- Use present tense ("Added" not "Adds")
- Reference the issue number if available
- Keep it concise and factual
- Follow the existing changelog style in the project
- **When `platform_scope` is `darwin_only` or `linux_only`** (Step 4a), mention
  the platform scope in the entry, e.g.:
  `Added optional Nix flake support for <project-name> on macOS (Apple Silicon & Intel). (#<issue-number>)`
  This sets user expectations correctly — Linux users seeing the changelog
  won't expect a `nix run` path that doesn't exist for their platform.

**Content scope — describe user-visible capability ONLY:**
- **No output names** (`#default`, `#source`, `#prebuilt`, `#nixpkgs`). These
  are implementation details that mean nothing to a user reading a changelog.
- **No implementation details** (build approach, toolchain, crane, fetchurl,
  autoPatchelf, nixpkgs-darwin-legacy pin). The user does not care how the
  flake builds the binary — only that they can now `nix run` it.
- **No CI/workflow behavior** (scheduled updates, hash automation, daily
  lag-check, zizmor, actionlint). These are internal mechanics, not
  user-visible features.
- Just what the user can now do.

**Example (good):**
```
- Added optional Nix flake support for building, running, installing, and
  developing <project-name> with Nix. (#<issue-number>)
```

**Example (bad — do NOT do this):**
```
- Added Nix flake support with prebuilt binary outputs for Linux and macOS.
  The flake exposes #default (prebuilt standalone binary), #source (from-source
  build of the Rust CLI), #prebuilt, and #nixpkgs. A scheduled workflow
  auto-bumps the version and per-platform sha256 hashes on each release.
```
The bad example leaks output names, build implementation details, and CI
workflow behavior — all of which CodeRabbit flagged as inappropriate for a
changeset on pnpm PR #14255. The changeset is a release note for users, not
a technical spec for maintainers.

## When the maintainer handles the changelog

Some maintainers explicitly maintain the changelog themselves on each release
and request that PRs do not modify `CHANGELOG.md`. This is common in projects
where the changelog is generated from release notes, hand-curated, or
maintained via a separate release process.

**If the maintainer has stated (in PR review feedback, contribution guidelines,
or an issue comment) that they handle the changelog:**

1. **Do not add a changelog entry.** Skip this step entirely.
2. **Do not modify `CHANGELOG.md`** in the PR diff. If you already added an
   entry, revert it: `git checkout <base-ref> -- CHANGELOG.md`.
3. **Prevent accidental future local edits** by setting the skip-worktree flag:
   ```bash
   git update-index --skip-worktree CHANGELOG.md
   ```
   This hides local modifications to the tracked file from `git status`, so
   accidental edits to the changelog never appear in `git diff` or get staged.
   Note: `.git/info/exclude` only affects untracked files — it is insufficient
   for tracked files like `CHANGELOG.md`.
4. **Clear the flag before syncing** if upstream changelog updates need to be
   pulled (e.g. before a rebase):
   ```bash
   git update-index --no-skip-worktree CHANGELOG.md
   ```

This exception takes precedence over the generic "add a changelog entry"
guidance above — the maintainer's explicit request is authoritative. See
nono PR #1823 for an example: the maintainer requested removing the changelog
entry because "the changelog is maintained by us on each release."
