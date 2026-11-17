---
type: Practice
title: nixpkgs Dedup Pre-flight
description: Before ANY nixpkgs contribution — init, version bump, or fix — search the TARGET repo (NixOS/nixpkgs) for existing work, check whether a newer upstream release already ships the fix, and check bot-maintained update PRs (r-ryantm/nix-update). Nixpkgs is bot-heavy; a hand-written duplicate is the most likely failure mode.
tags: [nix, nixpkgs, dedup, duplicate-pr, r-ryantm, nix-update, pre-flight, upstream]
date:
  created: "2026-11-17"
  knowledge-basis: "2026-11-17"
  last-used: "2026-11-17"
sources:
  - id: nixos-nixpkgs-576090
    resource: https://github.com/NixOS/nixpkgs/pull/576090
    title: "NixOS/nixpkgs#576090 — packer 1.15.4 -> 1.16.1, closed as duplicate"
  - id: nixos-nixpkgs-545258
    resource: https://github.com/NixOS/nixpkgs/pull/545258
    title: "NixOS/nixpkgs#545258 — r-ryantm bot PR covering the same packer bump"
  - id: nixify-search-nixpkgs-prs-sh
    resource: ../../skills/software-dev/nixify/scripts/search-nixpkgs-prs.sh
    title: "nixify search-nixpkgs-prs.sh — mechanical target-repo dedup search"
  - id: nixify-fix-pr-reference
    resource: ../../skills/software-dev/nixify/references/nixpkgs-fix-pr.md
    title: "nixify nixpkgs-fix-pr.md — fix/update contribution procedure"
---

# nixpkgs Dedup Pre-flight

## Failure Mode

Searching the **project's own repo** for existing issues/PRs before
contributing does not protect against duplicates in the **target repo**.
When the target is `NixOS/nixpkgs` — one of the most bot-active repos on
GitHub — the gap is expensive:

- **2026-10-19**: an agent opened NixOS/nixpkgs#576090 ("packer: 1.15.4 ->
  1.16.1") to fix a SIGSEGV on aarch64-darwin.
- r-ryantm's nix-update bot PR **#545258** had covered the identical bump
  since **2026-07-24** — open nearly three months.
- #576090 was closed as a duplicate on **2026-11-07**.

A second, independent miss compounded it: packer v1.16.1 already vendored
the fixed `go-m1cpu`, so the correct contribution was a plain version
bump — which is exactly what the bot PR was. No upstream-release check
meant a patch-shaped contribution was attempted for a bump-shaped problem.

## Practice

**Before ANY nixpkgs contribution — init, version bump, or fix — run a
target-repo dedup pre-flight.**

1. **Classify the contribution**: `init` (new package), `version_bump`,
   `fix` (same-version patch/override), or `meta`. The class determines
   what counts as a duplicate.
2. **Search the target repo mechanically**:
   `search-nixpkgs-prs.sh <package> --version <target>` queries
   `NixOS/nixpkgs` for PRs and issues, classifies `<pkg>:`-scoped titles by
   state, flags bot authors and `nix-update` labels, and emits a
   `recommendation` (`coordinate`, `skip_already_landed`,
   `investigate_merged`, `proceed`, …). Present matches to the user —
   the script reports, it does not decide.
3. **Check whether a newer upstream release already ships the fix.** If
   it does, the contribution is a version bump, not a patch — and bump PRs
   are the bot's home turf.
4. **Check bot coverage explicitly.** `r-ryantm`/nix-update PRs sit open
   for weeks or months; an open bot PR for the same version means comment
   or coordinate, never a competing PR. A merged one means the work is
   already in nixpkgs-unstable.
5. **Decide**: coordinate on the existing PR, stop entirely, or proceed —
   in that order of preference.

## Why Bot-Heavy Repos Change the Math

In a repo with human-driven contributions, an open duplicate PR is an
etiquette problem. In nixpkgs it is close to a certainty of wasted work:
the update bots cover the long tail of version bumps continuously, so
"is there already a PR for this?" has a high prior of yes for anything
version-shaped. The dedup search is therefore MANDATORY and mechanical
(a script), not a prose reminder — prose-only checks get skipped under
time pressure, which is exactly how #576090 happened.

## Related Concepts

- [nixpkgs Contribution](nixpkgs-contribution.md) — the init-side
  packaging workflow this pre-flight precedes
- [Search the Target Repo](https://github.com/levonk/skills-releases/blob/main/knowledge/upstream-contribution-practices/search-target-repo.md)
  — the generalized upstream-contribution version of this practice
- [Package Verification](package-verification.md) — verify the package
  name/version in nixpkgs before contributing
