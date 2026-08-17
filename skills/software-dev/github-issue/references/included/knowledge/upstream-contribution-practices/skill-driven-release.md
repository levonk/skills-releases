---
type: Practice
title: Skill-Driven Release — SemVer, Keep a Changelog, and a Single Command
description: Encode the release process as a repeatable, automated procedure that combines Semantic Versioning, Keep a Changelog format, and a single-command trigger with pre-flight checks, deterministic version bumps, and post-release verification.
tags: [release, semver, keep-a-changelog, automation, release-skill, changesets, release-please, versioning]
date:
  created: "2026-08-10"
  knowledge-basis: "2026-08-10"
  last-used: "2026-08-10"
sources:
  - id: keep-a-changelog
    resource: "https://keepachangelog.com/en/1.1.0/"
    title: "Keep a Changelog"
  - id: semver-spec
    resource: "https://semver.org/spec/v2.0.0.html"
    title: "Semantic Versioning 2.0.0"
---

# Skill-Driven Release — SemVer, Keep a Changelog, and a Single Command

## Rule

Encode the release process as a repeatable, automated procedure — not an
ad-hoc sequence of manual steps. The procedure combines three pillars:

1. **Semantic Versioning** — version bumps follow the SemVer contract:
   patch for backwards-compatible fixes, minor for backwards-compatible
   features, major for breaking changes. The version lives in one
   canonical location (e.g. `package.json`, `Cargo.toml`, `pyproject.toml`).
2. **Keep a Changelog** — the changelog follows the Keep a Changelog format
   with `Added`, `Changed`, `Fixed`, `Removed`, `Deprecated`, and `Security`
   sections under each version heading. Entries are generated from commit
   history, not hand-written from memory.
3. **Single-command trigger** — one command (a skill, a script, or a CLI
   subcommand) runs the full release: pre-flight validation, version bump,
   changelog generation, PR creation, and post-release verification.

The release procedure must include **pre-flight checks** that abort before
any user-visible change if the repository is not in a releasable state:
clean working tree, release branch contains the base branch (no drift),
and a compiled-binary smoke test (if applicable) that catches module-init
crashes only visible in compiled output.

## Why

Ad-hoc releases fail in predictable ways:

- **Stale changelog** — entries are written after the fact from memory,
  missing fixes that were never documented. Users discover breaking
  changes from bug reports, not from the changelog.
- **Wrong version bump** — a breaking change ships as a patch, or a trivial
  fix ships as a minor. Consumers relying on SemVer are surprised.
- **Drift between branches** — commits land on the release branch directly
  (a hotfix, a docs typo) and are never merged back. The release PR then
  proposes *reverting* them, and the next release inherits the drift.
- **Broken binaries discovered too late** — a module-init crash or bundler
  bug only surfaces in compiled output, not in `bun run` or `cargo run`.
  CI catches it — but only after the tag is pushed and a GitHub Release is
  live. By then the damage (empty release, broken `install.sh`, broken
  `releases/latest`) is already public.
- **Post-release artifacts stale** — package manager formulas (Homebrew,
  AUR) need SHA256 checksums from the published release. Updating the
  version without updating the checksums creates a formula that looks valid
  but fails on install.

A single-command release with pre-flight checks keeps the blast radius at
"no release was cut" when something is wrong, rather than "a broken release
is live."

## How It Works

### Pre-flight validation

Before any version bump or changelog edit, the release procedure checks:

1. **Clean working tree** — `git status --porcelain` must be empty.
2. **Branch contains base** — the working branch must contain all commits
   from the release branch. If commits exist on the release branch that the
   working branch does not have, abort and instruct the user to resync.
3. **Compiled-binary smoke test** (if applicable) — compile the binary for
   the native target only and run a safe, non-interactive command (`--help`,
   not `version`) to verify the module-init graph does not crash in a
   compiled context. This catches `readFileSync` of a path that only exists
   in `node_modules`, CommonJS module errors, and bundler quirks that
   `bun run` / `cargo run` do not reproduce.

### Version bump and changelog generation

The procedure determines the bump level from the trigger (`/release` →
patch, `/release minor` → minor, `/release major` → major), increments the
single canonical version field, and generates changelog entries from the
commit history between the release branch and the working branch.

Entries are grouped into Keep a Changelog sections. Each entry is a
one-sentence summary prefixed with the issue or PR number for traceability.
Breaking changes are called out explicitly under a `Breaking` heading.

### Release PR

The procedure creates a PR from the working branch to the release branch
with the version bump and changelog entries. The PR is reviewed and merged.
After merge, the tag is pushed and the release workflow builds and publishes
artifacts.

### Post-release verification

After the release workflow publishes artifacts, the procedure verifies:

- **Checksums** — fetch `checksums.txt` from the published release and
  parse per-platform SHA256 values.
- **Package manager formulas** — update the version AND the checksums
  atomically in a single commit. Never update one without the other.
- **End-to-end install** — verify the install path works (e.g.
  `brew install && <binary> --help`).

## Concrete Instances

### `/release` skill (Claude Code skill)

A Claude Code skill that encodes the full release procedure as a
prompt-driven workflow. The skill validates state, runs a pre-flight
compiled-binary smoke test, bumps the version, generates changelog entries
from commits, creates a PR to the release branch, and after the tag is
pushed, updates the Homebrew formula with real SHA256 values from the
published `checksums.txt`. The version and checksums are updated
atomically — never one without the other.

### Changesets (npm ecosystem)

A tool that manages versioning and changelog generation for monorepos.
Each change gets a "changeset" — a markdown file describing the bump level
and changelog entry. The `changeset version` command consumes all pending
changesets, bumps versions, and updates `CHANGELOG.md` files. A separate
PR publishes the packages. Changesets decouple "describe the change" from
"apply the version bump," letting multiple changes accumulate before a
release.

### release-please (Google)

A GitHub Action that generates release PRs from conventional commit
messages. It analyzes commit history since the last release, determines the
bump level from commit types (`feat:` → minor, `fix:` → patch,
`BREAKING CHANGE:` → major), and opens a release PR with the version bump
and changelog entries. Merging the PR tags the release and publishes
artifacts. release-please automates the "single-command trigger" as a
"merge-the-PR trigger" — the release happens on merge, not on a manual
command.

## Related

* [Follow Project Conventions](follow-project-conventions.md) — read the
  project's release conventions before contributing; some projects use
  changesets, others use release-please, others use a custom skill.
* [Separate Style Commit](separate-style-commit.md) — the release PR should
  contain only the version bump and changelog, not unrelated changes.
* [Linear History](linear-history.md) — the release PR should be a clean
  single commit, not a merge commit with noise.
