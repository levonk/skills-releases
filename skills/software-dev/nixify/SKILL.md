---
name: nixify
description: Add Nix flake support to a project so it can be installed via nix run github:... or nix profile install github:.... Use when the user wants to make a project installable via Nix flakes from a remote GitHub repository, add devbox.json for reproducible development environments, or package a project for Nix profile installation. Covers forking, cloning, architecture analysis, flake template selection, documentation updates, CI setup, and PR creation.
version: 2.7.0
date:
  created: "2026-06-01"
  updated: "2026-07-06"
  last-used: "2026-07-06"
tags:
  - "nix"
  - "nixos"
  - "flake"
  - "devbox"
  - "packaging"
  - "github"
  - "software-dev"
triggers:
  - user
see-also:
  - template: "base-ai-guidance"
    relationship: "base-framework"
    description: "Shared framework for creating all AI guidance types"
---

---

{{{ include "includes/base-ai-guidance.md" . }}}

# Nixify: Add Nix Flake Support to a Project

Make a project installable with a single command:

```bash
nix run github:<owner>/<repo>
nix profile install github:<owner>/<repo>
```

**CRITICAL RULE FOR FORKS**: When working on a fork for an upstream repository, ALL code files (flake.nix, README.md, documentation) and commit/issue/PR templates MUST reference the UPSTREAM repository, NOT the fork. The fork is only for testing and development. This skill uses `$UPSTREAM_OWNER` and `$UPSTREAM_REPO` variables to enforce this.

## Prerequisites

- Nix installed with flakes enabled
- Git configured with GitHub access
- Fork permissions on the target repository (if third-party)

## Steps

1. **Check for existing flake**: Run `scripts/check-existing-flake.sh <owner> <repo>`. If flake exists, abort — inspect the existing flake to see if it needs updates instead of replacement.

2. **Detect user and repo access**: Run `scripts/detect-access.sh <owner> <repo>`. Determine fork vs direct clone. Store `UPSTREAM_OWNER`, `UPSTREAM_REPO`, `CURRENT_USER`, and `HAS_DIRECT_ACCESS` for later steps.

3. **Search for existing issues and PRs**: Run `scripts/search-existing-work.sh <owner> <repo>`. If existing work found, present links to user and ask whether to proceed. Check contribution guidelines for project-specific conventions.

4. **Check for prebuilt release tarballs**: Run `scripts/check-releases.sh <owner> <repo>`. If tarballs exist, use the fetchurl approach (see `references/flake-templates.md` — Prebuilt Tarball Flake). This is the preferred path. **MANDATORY, not preferred, when the binary resolves runtime assets beside itself** (vendored `runtime/`, `node_modules`, N-API `.node` addons, etc.) — a from-source flake is broken for that class of project even if it builds cleanly. See `references/architecture-analysis.md` — Check for Prebuilt Release Tarballs.

5. **Analyze distribution complexity**: If no prebuilt tarballs (AND the project does not ship runtime assets beside the binary — see Step 4's MANDATORY rule), analyze the project for complex multi-component distribution (runtime assets, native addons, workspace exclusions). See `references/architecture-analysis.md` for decision guidance, success/failure patterns, and build script Nix-awareness tips.

6. **Fork and clone**: Run `scripts/fork-and-clone.sh <owner> <repo> <has_direct_access> <current_user>`. Use `--dry-run` to preview. Always rebase from upstream after cloning.

7. **Detect release trigger mechanism**: Run `scripts/check-release-trigger.sh` from within the cloned repo. This inspects `.github/workflows/` for how releases are created (`secrets.GITHUB_TOKEN` vs PAT/App token) and outputs a JSON recommendation (`trigger: scheduled_lag_check` or `release_published`). **Store the `trigger` value — it determines which workflow template to use at Step 16.** This prevents the GITHUB_TOKEN trap where a `release: published` workflow silently never fires because GitHub does not start new runs from `GITHUB_TOKEN`-authored events.

8. **Validate existing tests**: Run the project's test suite to establish a baseline. Document any pre-existing failures — do not fix source code in a Nix-only PR.

9. **Set up branch and git author**: Run `scripts/setup-branch.sh`. Creates `feat-nix-package-manager-install` branch and verifies git author is configured with public identity (not private info).

10. **Check nixpkgs for upstream packages**: Run `scripts/check-nixpkgs.sh <project-name> [dep1 dep2 ...]`. Decide: use upstream nixpkgs package (preferred), build from source with nixpkgs dependencies, or build everything from source. See `references/flake-templates.md` — Using Upstream nixpkgs Packages.

11. [fork] **Inspect existing nixpkgs derivation**: Run `scripts/inspect-nixpkgs-derivation.sh <project-name>`. If the project (or a close analog) is already packaged in nixpkgs, this fetches the full derivation source and resolved dependency lists (`buildInputs`, `nativeBuildInputs`, `propagatedBuildInputs`, `runtimeDependencies`). **Read the derivation source carefully** and catalog every dependency, patch, `postInstall`/`preInstall` hook, wrapper script (`makeWrapper` args), and special build flag. Cross-check this catalog against your planned flake.nix at Step 12 — anything in the nixpkgs derivation that your flake omits is a candidate for a "builds but doesn't work" failure. If the project itself isn't in nixpkgs but a similar project is (e.g. packaging a new browser — inspect `brave`'s derivation), run the script with the analog's name and extract the patterns that apply. See `references/architecture-analysis.md` — Inspecting Existing nixpkgs Derivations for the full checklist of what to look for. This step is the diligence check that prevents missing runtime dependencies, required patches, and postInstall setup.

12. **Generate flake.nix**: Choose the appropriate template from `references/flake-templates.md` based on Step 4 results and the derivation analysis from Step 11:
    - Prebuilt tarballs -> Prebuilt Tarball Flake (preferred) — **store `flake_type=prebuilt_tarball`**
    - Binary releases -> Binary Release Flake Template — **store `flake_type=prebuilt_tarball`**
    - No releases -> Source Build Flake Template (Rust/Node/Go/Python variants) — **store `flake_type=source_build`**
    - Project in nixpkgs -> nixpkgs wrapper — **store `flake_type=nixpkgs_wrapper`**

    **Store the `flake_type` value — it determines documentation content at Step 15, advanced features at Step 16, and PR body at Step 22.** Source Build and Prebuilt Tarball flakes have fundamentally different properties: Source Build flakes exist at every git tag (tag-pinning works), while Prebuilt Tarball flakes are bumped *after* the release tag is cut (tag-pinning does NOT work). Mixing these up produces broken install instructions.

    **MANDATORY — expose `.#<project-name>`: Every template in `references/flake-templates.md` exposes the package under the project's own name (`packages.<system>.<project-name>` and `apps.<system>.<project-name>`) alongside `default`. Users naturally try `nix run .#<project-name>` / `nix build .#<project-name>` before reaching for `#default` or `#latest`; a flake that only exposes `default` is reported as "broken" by users who try the named output and get `error: flake output 'packages.<system>.<project-name>' not found`. Do not strip the named output when filling in a template. See `references/flake-templates.md` — Exposing Flake Output Variants.

13. **Check for existing devbox.json**: Run `scripts/check-devbox.sh <owner> <repo>`. If no devbox exists, create one using the appropriate template from `references/devbox-templates.md` (Rust, Node.js, Go, Python, Darwin variants).

14. **Update .gitignore**: Run `scripts/update-gitignore.sh`. Adds `/result` and `/result-*` symlinks to prevent committing Nix build artifacts.

15. **Update installation documentation**: Update README and docs with Nix and Devbox install instructions. **Use the `flake_type` value from Step 12** to select the correct template — `references/documentation-updates.md` has separate sections for Source Build and Prebuilt Tarball flakes. Do NOT mix: Prebuilt Tarball READMEs must not include tag-pinning (`github:.../vX.Y.Z`) or `#source` output examples. See `references/documentation-updates.md` for insertion examples, docs-site installation pages, releasing documentation, and translated README handling.

16. **Add advanced features**: See `references/advanced-features.md`. The first item is required for release-based repos; the rest are optional:
    - **Release-triggered hash automation** — REQUIRED for the Prebuilt Tarball Flake path: a GitHub Action that auto-bumps `version` and refreshes per-platform `sha256` hashes in `flake.nix`, then opens a PR. This is the deliverable that makes a repo-owned flake acceptable to maintainers who don't know Nix; without it every release needs manual hash updates and the flake rots one release after merge. **Use the `trigger` value from Step 7** to select the correct template: `scheduled_lag_check` -> Template A (daily lag-check, recommended for `GITHUB_TOKEN`-created releases); `release_published` -> Template B (`release: published`, only for PAT/App-token releases). See `references/advanced-features.md` — Release-Triggered Hash Automation. **After adding the workflow, verify it via manual `workflow_dispatch`** (see the Verification subsection) — the automation is not exercised by the PR's own CI.
    - Home-manager module for declarative configuration
    - Modular Nix structure for complex projects
    - Flake-compat shims for legacy Nix support
    - treefmt configuration for automated formatting
    - GitHub Actions CI for Nix validation
    - Cachix integration for binary caching (push your builds)
    - Upstream cache consumption via `nixConfig` (pull others' pre-built deps)
    - Input `follows` for nixpkgs deduplication across inputs
    - `forAllSystems` / `perSystem` pattern (eliminate `flake-utils` dependency)

17. **Stage and test**: Run `scripts/validate-flake.sh <binary-name> <project-name>`. Stages flake.nix, runs `nix flake check --no-build`, `nix build`, `nix run . -- --help`, and `nix run .#<project-name> -- --help` (the runnable check that the `.#<project-name>` output from Step 12 actually exists and runs). Iterate until all pass.

18. **Commit, rebase, and push**: Squash iterative commits into a single clean commit. Use the commit message template from `references/issue-pr-templates.md`. Pull latest upstream and rebase before pushing. Never merge upstream into the feature branch — always rebase.

19. **Create orientation issue (fork only)**: Generate issue content from `references/issue-pr-templates.md` — Orientation Issue Template. Present to user for review. Record issue number for PR body. **Follow the "CRITICAL — How to post these bodies to GitHub" guard at the top of that file**: substitute `$UPSTREAM_OWNER`/`$UPSTREAM_REPO`/`$CURRENT_USER` by text replacement, write the body to a file, and post with `gh issue create --body-file` — never `--body` with an inline string, never an unquoted heredoc (backticks get command-substituted and `\n` ends up literal).

20. **Update changelog (if applicable)**: If CHANGELOG.md exists, add entry under `## Unreleased` -> `### Added`. See `references/issue-pr-templates.md` — Changelog Entry.

21. **Validate PR cleanliness**: Verify no merge commits, no unrelated changes, clean linear history from upstream/main to HEAD.

22. **Generate PR description**: Use the PR template from `references/issue-pr-templates.md` — Pull Request Template. **Use the `flake_type` value from Step 12** to select the correct install examples — Prebuilt Tarball PRs must not advertise tag-pinning or `#source` output. Present to user for review. Do NOT open PR automatically. **When you do open it, follow the "CRITICAL — How to post these bodies to GitHub" guard at the top of that file**: substitute the `$UPSTREAM_*`/`$CURRENT_USER`/`<issue-number>` placeholders by text replacement, write the body to a file, and post with `gh pr create --body-file` — never `--body` with an inline string, never an unquoted heredoc (backticks get command-substituted to empty and `\n` ends up literal in the stored body).

23. **Validate posted issue and PR bodies**: After the issue (Step 19) and PR (Step 22) are created, run `scripts/validate-pr-issue.sh <owner>/<repo> (pr|issue) <number>` for each. This is the runnable check that the Step-19/22 posting guard held — it catches the two corruption modes that have shipped broken nixify posts in the wild (literal `\n` instead of newlines, and stripped backtick code spans / unsubstituted `$UPSTREAM_*` placeholders). If it exits non-zero, the body is corrupted: re-fetch the template, fix the posting method, and `gh pr/issue edit --body-file` until the validator passes. Do not declare the skill run complete with a failing validator.

## Troubleshooting

| Symptom | Cause | Fix |
| --- | --- | --- |
| `nix run .` fails with "not tracked by Git" | `flake.nix` is untracked | `git add flake.nix` |
| `devbox run build` fails with "command not found" | Devbox not installed or not in PATH | `curl -fsSL https://get.jetify.dev/devbox \| bash` or `brew install jetify-com/devbox/devbox` |
| `devbox.json` schema validation fails | Invalid JSON or missing required fields | Verify JSON syntax and check against devbox schema |
| Darwin build fails with `apple_sdk_11_0 removed` | Deprecated `apple_sdk` reference | Remove `pkgs.darwin.apple_sdk.frameworks.Security`, keep only `pkgs.libiconv` |
| `release: published` workflow never fires | Releases created with `secrets.GITHUB_TOKEN` — GitHub does not start new runs from `GITHUB_TOKEN` events | Run `scripts/check-release-trigger.sh`; use the scheduled lag-check template (Template A) instead |
| PR/issue body is one unreadable line of `## What\n\n...` | Body was passed as a string literal with `\n` escapes via `gh --body "..."` | Rebuild from template, write to a file, repost with `gh ... edit --body-file`; see `references/issue-pr-templates.md` — CRITICAL section |
| PR/issue body has blank spots where `` `code` `` and `$UPSTREAM_*` should be | Body went through an unquoted heredoc or `echo "..."` — backticks command-substituted to empty, `$VARS` expanded by shell | Same fix; always use `--body-file` with a pre-substituted file |
| `validate-pr-issue.sh` exits non-zero after posting | One of the two corruption modes above | Re-fetch template, substitute placeholders by text replacement, repost with `--body-file`, re-run validator until it passes |

---

## Context Declaration

### File Paths
- Main skill: `config/ai/skills/software-dev/nixify/SKILL.md`
- Scripts: `config/ai/skills/software-dev/nixify/scripts/`
- References: `config/ai/skills/software-dev/nixify/references/`
- Includes: `config/ai/skills/includes/`

### External Resources
- Nix package search: https://search.nixos.org/packages
- Devbox documentation: https://www.jetify.com/devbox
- Cachix: https://cachix.org

### Project Information
- Project: levonk/dotfiles
- Repository: https://github.com/levonk/dotfiles
- Owner: levonk
