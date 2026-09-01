---
type: Practice
title: Two-Tier Skill Layout
description: Distinguish internal skills (metadata.internal: true, not for public distribution) from public skills (standalone, discoverable, installable by anyone). Internal skills are the project's private tooling; public skills are the project's distributable artifacts. The two tiers have different audiences, different distribution paths, and different quality bars.
tags: [agent-orchestration, skill-layout, internal-skills, public-skills, distribution, metadata]
date:
  created: "2026-08-30"
  knowledge-basis: "2026-08-30"
  last-used: "2026-08-30"
sources:
  - id: firstmate-two-tier
    resource: "https://github.com/kunchenguid/firstmate"
    title: "firstmate .agents/skills/ vs skills/ distinction"
---

# Two-Tier Skill Layout

## The General Rule

Not all skills are for everyone. Some skills are **internal** — they
encode project-specific workflows, private conventions, or tooling that
only makes sense within one project. Other skills are **public** — they
are standalone, discoverable, and installable by anyone who wants the
capability.

The two-tier layout distinguishes these explicitly:

- **Internal skills** use `metadata.internal: true` in their frontmatter
  (or, in this repository, live under `src/private/skills/`). They are
  not published to the public distribution repo. They are the project's
  private tooling.
- **Public skills** are standalone and discoverable. They live under
  `src/current/skills/` and are published to the public distribution
  repo. Anyone can install them.

### Why Two Tiers

A single-tier layout (all skills are public) has two failure modes:

1. **Internal skills leak.** Project-specific workflows, private
   conventions, or tooling that references internal infrastructure get
   published to the public distribution repo. External users install
   them and they do not work (they reference internal paths, internal
   services, or internal conventions).
2. **Public skills get cluttered.** The public distribution repo fills
   with skills that are not meant for external use. External users
   cannot tell which skills are for them and which are internal. The
   signal-to-noise ratio drops.

The two-tier layout solves both: internal skills stay private; public
skills are curated for external consumption.

### How firstmate Does It

firstmate distinguishes `.agents/skills/` (internal, project-specific)
from `skills/` (public, distributable). The `.agents/` directory is
project-local and not published. The `skills/` directory is the public
distribution surface.

### How This Repository Does It

This repository uses a **profile-based** two-tier layout:

- `src/current/skills/` — the **public** profile. Skills here are
  rendered and published to `skills-releases` (the public distribution
  repo). Anyone can install them via `pnpm dlx skills add`.
- `src/private/skills/` — the **private** profile. Skills here are
  rendered and published to `skills-private` (the private distribution
  repo). Only authorized users can install them.

The profile system is more granular than a single `metadata.internal`
flag — it allows multiple distribution targets (current, private,
prototype) with different audiences. But the principle is the same:
internal skills are not published to the public distribution surface.

### The metadata.internal Question

Should this repository adopt a `metadata.internal: true` frontmatter
flag in addition to the profile system?

**Decision: no.** The profile system already handles the two-tier
distinction. A `metadata.internal` flag would be redundant with the
profile placement (`src/private/` vs `src/current/`). Adding it would
create two sources of truth for the same property — the profile
directory and the frontmatter flag — and they could diverge.

The profile system is the single source of truth for distribution
target. A skill in `src/private/` is internal; a skill in
`src/current/` is public. No additional flag is needed.

If a future use case requires a skill to be in `src/current/` but
marked as internal (e.g., a skill that is published to the public repo
but should not be advertised), the `metadata.internal` flag can be
revisited. Until then, the profile system suffices.

## Concrete Instances

### Internal Skill Example

A skill that encodes a project-specific deployment workflow (deploy to
the internal staging server, run the internal smoke tests, notify the
internal Slack channel). This skill references internal infrastructure
and is useless to external users. It lives in `src/private/skills/` and
is published to `skills-private` only.

### Public Skill Example

A skill that encodes a general code review checklist. This skill is
useful to anyone who reviews code. It lives in
`src/current/skills/software-dev/code-review-guidance/` and is published
to `skills-releases` for anyone to install.

### Borderline Case

A skill that encodes a testing convention that is project-specific in
its details but general in its structure. The structure (write tests
first, run them, verify) is public; the details (specific test
commands, specific test paths) are internal. The resolution: publish
the structure as a public skill with parameterized commands, and keep
the project-specific configuration in an internal config file that the
skill reads at runtime.

## Anti-Patterns

- **All skills public** — no internal tier. Internal skills leak to the
  public distribution repo.
- **All skills internal** — no public tier. External users have nothing
  to install. The project's reusable capabilities are not shared.
- **metadata.internal flag + profile placement** — two sources of truth
  for the same property. They diverge. Use one or the other, not both.
- **Internal skills in the public profile with a "do not install"
  comment** — the comment is advisory; the skill is still published.
  Use the profile system to keep it private.

## See Also

- [Encode Lessons in Structure](encode-lessons-in-structure.md) — the
  profile system is a structural enforcement of the two-tier layout.
  A skill in `src/private/` cannot be published to the public repo —
  the build system enforces it, not a text instruction.
