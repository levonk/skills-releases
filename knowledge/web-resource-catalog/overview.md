---
type: Synthesis
title: Web Resource Catalog Overview
description: Synthesis of the curated web resource domain catalog and its maintenance workflow.
tags: [web-resource-catalog, overview, synthesis, toon]
date:
  created: "2026-07-12"
  knowledge-basis: "2026-07-11"
  last-used: "2026-07-11"
sources:
  - id: toon-format
    resource: https://toonformat.dev/
    title: TOON Format
  - id: toon-format-overview
    resource: https://toonformat.dev/guide/format-overview
    title: TOON Format Overview
  - id: devin-cli-config
    resource: src/current/templates/
    title: Devin CLI config
---

---
description: STE100-inspired Simplified Technical English guidelines for technical prose output — active voice, short sentences, one-word-one-meaning, imperative for instructions
---

### Simplified Technical English (STE100-Inspired)

This artifact produces technical English (instructions, procedures, descriptions,
reference documentation). Apply these STE100-inspired guidelines to all technical
prose output so the result is unambiguous, translatable, and easy to read for
non-native speakers and for AI agents that must execute the steps precisely.

These are **STE-inspired guidelines**, not the full ASD-STE100 vocabulary
restriction. Domain terms (Dockerfile, pnpm, devbox, Nx, etc.) are permitted
when they are the correct technical term — STE100's 1000-word approved
vocabulary is too narrow for this domain. The goal is the *clarity discipline*
of STE100, not its word list.

For the full writing rules, before/after examples, and the approved-words
reference, see the
[Simplified Technical English](https://github.com/levonk/skills-releases/blob/main/knowledge/simplified-technical-english/simplified-technical-english.md)
and
[Detailed Guide](https://github.com/levonk/skills-releases/blob/main/knowledge/simplified-technical-english/detailed-guide.md)
concept pages in the `simplified-technical-english` knowledge bundle. The
bundle is the canonical, publicly-reachable home for these guidelines; this
include is the build-time gist that gets inlined into skills and other
bundles.

#### Core Principles

1. **One word, one meaning.** Pick one term for each concept and use it
   everywhere. Do not alternate between "image" and "container image" and
   "docker image" for the same thing. Pick one, define it once, reuse it.

2. **Short sentences.** Keep procedural sentences under 20 words. Keep
   descriptive sentences under 25 words. Split long sentences into two.

3. **Active voice.** Write "The build copies the file" not "The file is copied
   by the build." The actor does the action. Passive voice hides who does what
   and is the single largest source of ambiguity in technical prose.

4. **Imperative mood for instructions.** Write "Run the tests" not "You should
   run the tests" or "The tests should be run." Instructions tell the reader
   (or agent) what to do, directly.

5. **One topic per sentence.** One idea per sentence. Do not chain unrelated
   clauses with "and" or "while." If a sentence has two ideas, split it.

6. **Consistent verb forms.** Use the same verb for the same action across the
   document. If you "run" a script in section 1, do not "execute" it in
   section 2. Pick one verb per action and keep it.

7. **Approved modifiers only.** Avoid decorative adjectives and adverbs
   ("very", "extremely", "simply", "just"). Keep modifiers that carry
   information ("non-root", "read-only", "idempotent"). Drop modifiers that
   carry only emphasis.

8. **Define every acronym on first use.** Write "Continuous Integration (CI)"
   on first use, then "CI" thereafter. Never assume the reader knows the
   acronym.

#### What Counts as Technical English

Apply these guidelines to:

- Procedural instructions ("Run `just build`", "Add the user to the group")
- Descriptions of failure modes, symptoms, and practices
- Reference documentation and concept pages
- Checklists and review guidance
- Synthesis and overview prose in knowledge bundles

Do **not** apply these guidelines to:

- Code, commands, and file paths (those have their own syntax)
- Frontmatter and structured data (YAML, JSON)
- Diagrams and their source syntax (Mermaid, PlantUML)
- Business communication, marketing copy, or creative content
- Log entries and change logs (those are append-only records)

#### Quick Self-Check

Before finishing a piece of technical prose, run this checklist:

- [ ] Is every sentence under 25 words? (Procedural: under 20.)
- [ ] Is every sentence active voice? (Or is the passive voice intentional and
      necessary?)
- [ ] Are instructions in imperative mood?
- [ ] Does each technical term have one and only one form in this document?
- [ ] Is every acronym defined on first use?
- [ ] Are decorative modifiers removed?
- [ ] Does each sentence carry one topic?

If any answer is "no," revise before publishing.


# Web Resource Catalog Overview

This knowledge bundle documents the curated set of web resource domains allowed
in the Devin CLI configuration. Domains are organized into categories that
reflect how the user discovers and references these resources during
AI-assisted development work.

## Categories

| Category | Domains | Purpose |
|----------|---------|---------|
| VCS & Forge | 22 | Code hosting and open-source collaboration |
| Project Tracking | 28 | Issue trackers and project management |
| Design & UI | 73 | Design systems, components, icons, fonts |
| Color Palettes | 27 | Color tools and palette generators |
| Stock Media | 57 | Stock photos, audio, and video |
| Deny List | 22 | IP logger domains blocked for security |

**Total allowed domains**: 627 (plus 5 wildcard patterns)
**Total denied domains**: 22

## TOON Format

Domain lists in each concept are encoded in [TOON](https://toonformat.dev/)
(Token-Oriented Object Notation) rather than JSON. TOON is the project's
preferred format for bulk data transfer to LLMs (see
`src/current/workflows/ai/includes/data-format-requirements.md.tmpl`):

- ~40% fewer tokens than JSON for the same data
- Human-readable in any editor
- Schema-aware: array length `[N]` helps LLMs validate structure
- Round-trips losslessly via the `@toon-format/toon` library

Example TOON primitive array (used for domain lists):

```
domains[3]: github.com,gitlab.com,bitbucket.org
```

## Maintenance

The bundle is synchronized with `~/.config/devin/config.json` (the deployed
config) and the source at
`src/current/templates/ (devin config)`.

When new domains are added to the config:

1. Update the relevant category concept file
2. Update the domain count in this overview
3. Append an entry to `log.md`
4. Re-sort the domain list alphabetically within the concept

## Source of Truth

The config file is the source of truth. This bundle is a derived, organized
view of the config's `permissions.allow` and `permissions.deny` arrays,
designed for progressive disclosure and LLM-friendly consumption.

---

## Content Ordering

This artifact is optimized for machine consumption. Generic framework content
(shared includes, knowledge bundles) appears before the skill-specific body.
This ordering maximizes cross-skill prefix caching: skills that share the same
includes produce identical byte prefixes, so an LLM context cache warmed by one
skill serves all skills that share the same preamble.

This is sub-optimal for human reading — the skill-specific content starts deep
in the file, after the generic preamble. Human readers can jump to the
skill-specific body by searching for the first `# ` heading that follows the
generic sections. Each section is self-contained and documented with its own
heading hierarchy.

