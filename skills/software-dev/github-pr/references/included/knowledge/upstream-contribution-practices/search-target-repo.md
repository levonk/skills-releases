---
type: Practice
title: Search the Target Repo Before Contributing
description: Searching your own repo for related issues/PRs is not enough — before opening a contribution to a repo you don't own, search the TARGET repo for existing work covering the same change, including bot-authored and bot-labeled PRs. Bot-heavy repos like NixOS/nixpkgs have a high prior that the work is already covered.
tags: [search, duplicate, upstream, target-repo, bots, nixpkgs, pre-flight, github]
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
---

# Search the Target Repo Before Contributing

## Rule

[Search Before Opening](search-before-opening.md) covers searching the
**project's own repo** for related issues/PRs. That is necessary but not
sufficient. Before opening a contribution to a repo you don't own, also
search the **target repo** for existing work covering the same change —
including bot-authored and automation-labeled PRs, which own-repo searches
never surface because they don't exist in your fork.

## Why

- **The target repo has state your repo doesn't.** Your fork's issue/PR
  list is empty or stale; the upstream repo is where the real discussion
  and prior attempts live.
- **Bot-heavy repos have a high prior of coverage.** Update bots
  (nix-update/r-ryantm in NixOS/nixpkgs, dependabot, renovate elsewhere)
  open PRs for the long tail of mechanical changes continuously. "Is
  there already a PR for this?" is very often yes for anything
  version-shaped.
- **Duplicates waste maintainer time and get closed.** A duplicate PR is
  pure triage overhead; in nixpkgs it also competes with a bot PR that has
  already accumulated review approvals.

## Worked Example

On 2026-10-19 an agent opened NixOS/nixpkgs#576090 ("packer: 1.15.4 ->
1.16.1") to fix a SIGSEGV on aarch64-darwin. The identical bump was
already covered by r-ryantm's bot PR **#545258**, open since 2026-07-24.
#576090 was closed as a duplicate on 2026-11-07. A second miss compounded
it: packer v1.16.1 already vendored the fixed `go-m1cpu`, so the correct
contribution was a plain version bump — exactly what the bot PR was.

## How to Search

Search both PRs and issues, all states, in the **target** repo:

```bash
# PRs matching the package/change term (title + body)
gh search prs --repo <target-owner>/<target-repo> "<term>" --limit 50 \
  --json number,title,state,author,labels,url

# PRs scoped by title convention (e.g. nixpkgs "<pkg>: ...")
gh pr list --repo <target-owner>/<target-repo> \
  --search "<term> in:title" --state all --limit 30 \
  --json number,title,state,author,labels,url

# Issues
gh issue list --repo <target-owner>/<target-repo> \
  --search "<term> in:title" --state all --limit 30 \
  --json number,title,state,url
```

For mechanical changes, prefer a script over prose judgment — prose-only
checks get skipped under time pressure. The nixify skill ships
`scripts/search-nixpkgs-prs.sh` for the nixpkgs case; it classifies
`<pkg>:`-scoped titles by state, flags bot authors and `nix-update`
labels, and emits a recommendation.

## What to Do If You Find Existing Work

| State of existing work | Action |
|------------------------|--------|
| Open PR covering the same change | Comment on it or coordinate with the author. Do NOT open a duplicate. |
| Open PR by an update bot covering the same version | Same — comment with evidence (build/test results, platform notes) or coordinate. Never open a competing PR. |
| Merged PR already carrying your change | The work has landed. Do not open anything. |
| Merged PRs exist but none match your change | Read them — the fix may already be in via a different route. Re-classify your contribution. |
| Closed-unmerged PRs | Read the close reason before proceeding — maintainers sometimes close bot bumps for broken builds; your contribution may need to address that reason. |
| Only closed-rejected issues | Read the rejection reason. If circumstances changed, reference it; if not, don't re-litigate. |

## Beyond nixpkgs

The pattern generalizes to any upstream contribution where automation
may already cover the change:

- **Version bumps and dependency updates** — dependabot/renovate/nix-update
  PRs are near-certain to exist or be imminent.
- **Mechanical fixes** — lint, formatting, typo, and metadata fixes are
  bot territory in many repos.
- **Check whether upstream already ships your fix** — a newer release may
  contain the change you were about to patch, turning your "fix" into a
  "bump" (or nothing at all).

## Related

* [Search Before Opening](search-before-opening.md) — the own-repo half of
  the dedup check; this page is the target-repo half
* [Contribution Eligibility](contribution-eligibility.md) — pre-flight
  checks before starting upstream work
* [Human Review Gate](human-review-gate.md) — present search results to
  the user before deciding to proceed
* [nixpkgs Dedup Pre-flight](../nix-build-practices/nixpkgs-dedup-preflight.md)
  — the nixpkgs-specific instance of this practice
