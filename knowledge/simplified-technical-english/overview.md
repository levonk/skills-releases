---
type: Synthesis
title: Simplified Technical English Overview
description: Synthesis of STE100-inspired Simplified Technical English practices — active voice, short sentences, one-word-one-meaning, imperative mood for instructions, approved modifiers, acronym definitions. STE-inspired (not full ASD-STE100 vocabulary restriction); domain terms are permitted.
tags: [technical-writing, ste100, simplified-technical-english, documentation, overview, synthesis]
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
  - id: writethat-blog
    resource: "https://writethatblog.substack.com/"
    title: "Write That Blog — newsletter with writing tips from expert bloggers"
  - id: ste100-include
    resource: "../../includes/ste100-simplified-technical-english.md.tmpl"
    title: "Build-time include (gist) inlined into skills and bundles"
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


# Simplified Technical English Overview

This bundle is the canonical, publicly-reachable home for the STE100-inspired
Simplified Technical English guidelines. The guidelines apply to technical
prose output — procedural instructions, failure-mode descriptions, reference
documentation, checklists, and synthesis prose in knowledge bundles.

## Why a Bundle

The build-time include
`includes/ste100-simplified-technical-english.md.tmpl` carries the gist and is
inlined into skills and other bundles at build time. But the include is not a
reachable URL after installation — it is inlined and the directive disappears.
Consumer projects that install a skill need a public URL to point at when they
want the full writing rules, before/after examples, and the self-check protocol.

This bundle solves that. It is published to
`skills-releases/knowledge/simplified-technical-english/` and every concept page
has a stable public URL of the form
`https://github.com/levonk/skills-releases/blob/main/knowledge/simplified-technical-english/<page>.md`.

## The Two-Tier Structure

| Tier | Location | Audience | Loading |
|------|----------|----------|---------|
| Gist (include) | `includes/ste100-simplified-technical-english.md.tmpl` | AI agents reading skills | Inlined at build time |
| Full detail (bundle) | `knowledge/simplified-technical-english/` | Humans and agents seeking depth | Public URL on skills-releases |

The gist links to the bundle. The bundle does not link back to the include —
the bundle is the canonical source.

## Concepts

### STE100-Inspired Clarity and Mechanics

| Concept | Purpose |
|---------|---------|
| [Simplified Technical English](simplified-technical-english.md) | The core 8 principles + quick self-check. The same content as the build-time include, with OKF frontmatter and sources. |
| [Detailed Guide](detailed-guide.md) | The full 10 writing rules, approved-words guidance, 3 before/after examples, and the 10-step self-check protocol. |
| [Punctuation](punctuation.md) | Oxford commas, comma placement, semicolons for independent clauses, hyphens for compound modifiers, em dashes, slashes. |
| [Capitalization and Articles](capitalization.md) | Title-style vs sentence-style headlines, basic capitalization rules, a/an by vowel sound. |
| [Procedures and Lists](procedures-and-lists.md) | Front-loading important information, procedure structure (intro sentence, single-step, sub-step numbering), list formatting, transitions. |
| [Word Choice and Consistency](word-choice.md) | Slang/jargon/idioms, contractions, abbreviations, e.g./i.e., acronym nuances, US/UK English, gender-neutral pronouns, tested examples. |

### Engineering Blog Writing

| Concept | Purpose |
|---------|---------|
| [Engineering Blog Fundamentals](engineering-blog-fundamentals.md) | Why write engineering blogs, topic selection, and the characteristics of compelling posts. |
| [Blog Writing Process](blog-writing-process.md) | The full lifecycle from idea to published post: capture, draft, optimize, feedback, ship. |
| [Engineering Blog Patterns](engineering-blog-patterns.md) | The seven canonical patterns (Bug Hunt, Rewrote It in X, How We Built It, Lessons Learned, Thoughts on Trends, Non-Markety Product, Benchmarks) with dos, don'ts, and real-world examples. |
| [Blog Promotion and Expansion](blog-promotion-and-expansion.md) | Promoting posts, squeezing more value from each post, turning a post into a conference talk, and considerations for book writing. |

## Scope

These guidelines apply to:

- Procedural instructions ("Run `just build`", "Add the user to the group")
- Descriptions of failure modes, symptoms, and practices
- Reference documentation and concept pages
- Checklists and review guidance
- Synthesis and overview prose in knowledge bundles
- Engineering blog posts — topic selection, writing process, patterns, and
  promotion (see the Engineering Blog Writing concept pages above)

These guidelines do **not** apply to:

- Code, commands, and file paths (those have their own syntax)
- Frontmatter and structured data (YAML, JSON)
- Diagrams and their source syntax (Mermaid, PlantUML)
- Business communication, marketing copy, or creative content
- Log entries and change logs (those are append-only records)

## Relationship to the Include

The include
`includes/ste100-simplified-technical-english.md.tmpl`
is wired into:

- All 21 knowledge bundle overviews (including this one)
- All 24 software-dev skills
- The 8 upsert-family skills
- tech-maturity, briefingmemo, execute-upsert, peer-review

The include is NOT wired into business/creative skills
(professional-communication, biz-email-upsert, youtube, diagram-upsert) where
technical-prose rules do not apply.

The include links to this bundle's
[Detailed Guide](detailed-guide.md) for the full depth. This is progressive
disclosure: the gist loads with every skill, the detail loads on demand.

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

