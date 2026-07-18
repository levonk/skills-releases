---
type: Synthesis
title: Upstream Contribution Practices Overview
description: Synthesis of fork-PR best practices extracted from real upstream contribution work.
tags: [upstream-contribution, fork, pull-request, github, overview, synthesis]
timestamp: 2026-07-14T11:30:00Z
---

# Upstream Contribution Practices Overview

This bundle documents practices for contributing to upstream open-source
projects via the fork → branch → PR workflow. Each concept was extracted
from a real failure mode — a PR that was rejected, corrupted, or delayed
because the practice wasn't followed.

## The Contribution Lifecycle

```
pre-flight → fork → clone → rebase → branch → baseline tests → work → sync → rebase → commit feature → format → lint → commit style → scan → build → test → push → review → post → validate
```

Each phase has practices that prevent specific failure modes:

| Phase | Practice | Prevents |
|-------|----------|----------|
| Pre-flight | [Contribution Eligibility](contribution-eligibility.md) | Wasted work on projects that reject external PRs or have risky CLAs |
| Pre-flight | [Search Before Opening](search-before-opening.md) | Duplicate issues/PRs, re-litigating settled rejections |
| Pre-flight | [Follow Project Conventions](follow-project-conventions.md) | Review feedback asking to match changelog/template/doc style |
| Branch creation | [Feature Branch Only](feature-branch-only.md) | Cannot create PR, polluted default branch, broken sync |
| Branch creation | [Sync Before Push](sync-before-push.md) | Stale base, conflicts at PR time |
| Branch creation | [Git Author Privacy](git-author-privacy.md) | Private hostname/username leaked in commit metadata |
| Pre-work | [Test Baseline](test-baseline.md) | Can't distinguish your breakage from pre-existing failures |
| Development | [Minimal Scope](minimal-scope.md) | PR rejected for being too broad, mixing unrelated changes |
| Development | [Upstream Identity](upstream-identity.md) | PR references fork instead of upstream |
| Development | [No User Identity Leak](no-user-identity-leak.md) | Local paths, usernames, or fork-specific config leaked in file content |
| Pre-commit | [Format Artifacts](format-artifacts.md) | Review feedback asking to run project formatter |
| Pre-commit | [Lint Artifacts](lint-artifacts.md) | Upstream lint CI failing on a PR that builds but has style/pattern issues |
| Pre-commit | [Verify Command Currency](verify-command-currency.md) | Shipping deprecated tool syntax that breaks for users on current versions |
| Commit | [Separate Style Commit](separate-style-commit.md) | Format and lint changes hidden inside feature diff, causing review friction |
| Commit | [Massive-Change Guard](massive-change-guard.md) | Formatter or linter auto-fix reformatting entire modified files, expanding PR scope |
| Pre-push | [Rebase, Never Merge](rebase-never-merge.md) | Merge commits polluting upstream history |
| Pre-push | [Linear History](linear-history.md) | Iterative commits cluttering the PR |
| Issue/PR posting | [Human Review Gate](human-review-gate.md) | Wrong content published to public upstream repo |
| Issue/PR posting | [gh --body-file](gh-body-file.md) | Corrupted body (literal `\n`, stripped backticks) |

## Source

These practices were extracted from the nixify skill
(`src/current/skills/software-dev/nixify/`), which has run against
multiple upstream projects. The skill encodes them as procedural steps;
this bundle extracts the generalizable knowledge so it applies to any
fork-PR work, not just Nix flake additions.

## Compounding

New lessons from future fork-PR work should be filed as new concept
pages. The trigger for adding a concept is: a review comment, rejected
PR, or debugging session that revealed a practice the bundle doesn't
yet cover. Append to `log.md` when adding.

## Related Knowledge Bundles

These contribution practices apply whenever filing new concepts into any of the
domain bundles produced by the upsert skills:

- [container-best-practices](../container-best-practices/overview.md)
- [java-best-practices](../java-best-practices/overview.md)
- [data-engineering-best-practices](../data-engineering-best-practices/overview.md)
- [typescript-monorepo-best-practices](../typescript-monorepo-best-practices/overview.md)
- [devsecops-codeguard](../devsecops-codeguard/overview.md)

# Citations

[1] [nixify skill](https://github.com/levonk/skills-src/tree/main/src/current/skills/software-dev/nixify)
[2] [yusukebe/ax PR #27](https://github.com/yusukebe/ax/pull/27) — source of the format-artifacts lesson
