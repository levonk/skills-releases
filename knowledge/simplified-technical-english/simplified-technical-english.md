---
type: Practice
title: Simplified Technical English (STE100-Inspired)
description: STE100-inspired guidelines for technical prose output — active voice, short sentences, one-word-one-meaning, imperative mood for instructions, approved modifiers only, acronyms defined on first use. STE-inspired (not full ASD-STE100 vocabulary restriction); domain terms are permitted.
tags: [technical-writing, ste100, simplified-technical-english, documentation, active-voice, imperative-mood]
date:
  created: "2026-07-26"
  knowledge-basis: "2026-08-27"
  last-used: "2026-08-27"
sources:
  - id: asd-ste100
    resource: "https://www.asd-ste100.org/"
    title: "ASD-STE100 Simplified Technical English specification"
  - id: proxmox-twsg
    resource: "https://pve.proxmox.com/wiki/Technical_Writing_Style_Guide"
    title: "Proxmox VE Technical Writing Style Guide"
  - id: writing-for-developers
    resource: "https://github.com/scynthiadunlop/WritingForDevelopersBook"
    title: "Writing For Developers: Blogs That Get Read by Piotr Sarna and Cynthia Dunlop"
---

# Simplified Technical English (STE100-Inspired)

This page is the canonical, publicly-reachable home for the STE100-inspired
guidelines. The build-time include
`includes/ste100-simplified-technical-english.md.tmpl` carries the same core
principles and is inlined into skills and other bundles at build time. This
page exists so that consumer projects have a stable URL to reference when they
need the full reasoning behind each principle.

For the full writing rules, before/after examples, and the 10-step self-check
protocol, see the [Detailed Guide](detailed-guide.md).

## Core Principles

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

## What Counts as Technical English

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

## Quick Self-Check

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

## STE-Inspired, Not Full STE100

These are **STE-inspired guidelines**, not the full ASD-STE100 vocabulary
restriction. Domain terms (Dockerfile, pnpm, devbox, Nx, Ansible, Kubernetes,
Helm, Terraform) are permitted when they are the correct technical term —
STE100's 1000-word approved vocabulary is too narrow for this domain. The goal
is the *clarity discipline* of STE100, not its word list.

## Beyond Clarity: Style and Mechanics

The 8 core principles above cover the *clarity discipline* of STE100 — active
voice, short sentences, one-word-one-meaning, imperative mood. Technical
documentation also needs *style and mechanics* guidance: punctuation,
capitalization, procedure structure, and word choice. The companion concept
pages cover these topics:

- [Punctuation](punctuation.md) — Oxford commas, comma placement, semicolons,
  hyphens, em dashes, slashes
- [Capitalization and Articles](capitalization.md) — title-style vs
  sentence-style headlines, basic capitalization, a/an by vowel sound
- [Procedures and Lists](procedures-and-lists.md) — front-loading important
  information, procedure structure, list formatting, transitions
- [Word Choice and Consistency](word-choice.md) — slang/jargon/idioms,
  contractions, abbreviations, e.g./i.e., acronym nuances, gender-neutral
  pronouns, tested examples

## Beyond Mechanics: Engineering Blog Writing

The clarity and mechanics pages cover technical prose at the sentence and
paragraph level. Engineering blog writing applies these rules to a specific
medium — the blog post — with its own patterns, process, and promotion
practices. The companion concept pages cover this domain:

- [Engineering Blog Fundamentals](engineering-blog-fundamentals.md) — why
  write engineering blogs, topic selection, and characteristics of compelling
  posts
- [Blog Writing Process](blog-writing-process.md) — the full lifecycle from
  idea to published post: capture, draft, optimize, feedback, ship
- [Engineering Blog Patterns](engineering-blog-patterns.md) — the seven
  canonical patterns (Bug Hunt, Rewrote It in X, How We Built It, Lessons
  Learned, Thoughts on Trends, Non-Markety Product, Benchmarks) with dos,
  don'ts, and real-world examples
- [Blog Promotion and Expansion](blog-promotion-and-expansion.md) — promoting
  posts, squeezing more value from each post, turning a post into a conference
  talk, and considerations for book writing

For the full writing rules, approved-words guidance, and before/after examples,
see the [Detailed Guide](detailed-guide.md).
