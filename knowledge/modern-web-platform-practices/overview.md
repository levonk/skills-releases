---
type: Synthesis
title: "Modern Web Platform Practices — Overview"
description: "Synthesis of modern web platform practices — native browser APIs, CSS, forms, UI behaviors and components, performance, security, accessibility, and Chrome extension development — ingested from the stewarded GoogleChrome/modern-web-guidance corpus to keep agent output off legacy patterns."
tags: [modern-web-platform, css, html, javascript, accessibility, performance, security, forms, ui-components, chrome-extension, overview, synthesis]
date:
  created: "2026-11-13"
  knowledge-basis: "2026-11-13"
  last-used: "2026-11-13"
sources:
  - id: modern-web-guidance-repo
    resource: "https://github.com/GoogleChrome/modern-web-guidance"
    title: "Modern Web Guidance — GoogleChrome"
    last_modified: "2026-11-10"
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

9. **No em dashes.** Do not use em dashes (—). Use commas or parentheses
   instead. AI overuses em dashes for dramatic pauses and parenthetical
   asides. See the
   [AI Writing Tells](https://github.com/levonk/skills-releases/blob/main/knowledge/simplified-technical-english/ai-writing-tells.md)
   concept page for the full rationale.

#### AI Writing Tells

AI-generated text has recognizable overuse patterns that survive the clarity
rules above. A sentence can be active, short, and one-topic-per-sentence and
still read as AI slop. The tells include: negative parallelism ("It's not X,
it's Y"), magic adverbs ("quietly", "deeply"), "delve" and friends, "tapestry"
and "landscape", anaphora abuse, tricolon abuse, "Here's the kicker", false
vulnerability, grandiose stakes inflation, fractal summaries, signposted
conclusions, and more. For the full catalog and self-check, see the
[AI Writing Tells](https://github.com/levonk/skills-releases/blob/main/knowledge/simplified-technical-english/ai-writing-tells.md)
concept page in the `simplified-technical-english` knowledge bundle.

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
- [ ] Are em dashes avoided? (Use commas or parentheses instead.)
- [ ] Is the prose free of AI writing tells? (Negative parallelism, anaphora
      abuse, tricolon abuse, "delve", "tapestry", "Here's the kicker", fractal
      summaries, signposted conclusions. See the AI Writing Tells concept page.)

If any answer is "no," revise before publishing.


# Modern Web Platform Practices — Overview

This bundle documents what the modern web platform can already do, so agents
reach for native browser capabilities instead of legacy JavaScript patterns,
heavy polyfills, or framework dependencies. Each concept is a self-contained,
normative guide — one platform feature or UI pattern per page, with runnable
code and explicit do/don't rules.

The corpus was ingested verbatim (plus OKF frontmatter and cross-link rewrites)
from [GoogleChrome/modern-web-guidance](https://github.com/GoogleChrome/modern-web-guidance)
at commit `4dd9683` (2026-11-10, Apache-2.0). The upstream guides are
expert-curated and token-efficient by design — they are pruned by evals so they
carry only what models do not already know.

## How the Bundle Is Organized

Nineteen categories, each with its own `index.md`. Most categories also ship a
broad **discipline guide** (e.g. `css/css.md`, `forms/forms.md`,
`security/security.md`) that states the baseline rules for the whole category —
read that first, then drill into the specific guide for the pattern at hand.

| Concern | Category | Covers |
|---------|----------|--------|
| Page structure | [html](html/index.md) | Semantic elements, dialogs, popovers, `details`, search |
| Styling | [css](css/index.md), [visual-design](visual-design/index.md) | Container queries, `:has()`, fluid scaling, color, motion, elevation |
| UI atoms | [ui-atoms](ui-atoms/index.md) | Buttons, inputs, tables, icons, tooltips — single-element patterns |
| UI behavior | [ui-behaviors](ui-behaviors/index.md) | View transitions, scroll-driven animation, drag/drop, top-layer UI |
| UI components | [ui-components](ui-components/index.md) | Cards, carousels, menus, toolbars — composite widgets |
| Forms | [forms](forms/index.md) | Autofill, validation, selects, OTP — the highest-conversion surface |
| Experience | [user-experience](user-experience/index.md), [accessibility](accessibility/index.md) | UX flows plus assistive-tech correctness |
| Runtime | [js](js/index.md), [wasm](wasm/index.md), [webmcp](webmcp/index.md) | Client JS patterns, Emscripten, agent-callable page tools |
| Built-in AI | [built-in-ai](built-in-ai/index.md) | Prompt API, Summarizer, Translator, Language Detector |
| Quality gates | [performance](performance/index.md), [security](security/index.md), [privacy](privacy/index.md) | Core Web Vitals, passkeys, sanitization, permissions |
| Distribution | [pwa](pwa/index.md), [chrome-extensions](chrome-extensions/index.md), [chrome-webstore](chrome-webstore/index.md) | Installability, extension APIs, store publishing |

## Reading Patterns

- **Building a specific widget** → open the category index, then the concept
  page. Concepts cross-link (e.g. toolbar → navbar, menu, icons).
- **Starting a web UI task** → read the discipline guide for the category
  (`css/css.md`, `forms/forms.md`, `accessibility/accessibility.md`) before the
  specific pattern.
- **Modernizing legacy code** → the upstream CLI offers `legacy-scan`; this
  bundle holds the guidance corpus itself, not the scanner.
- **Checking freshness** → upstream evolves with the platform. Re-ingest from
  the repo (or query `pnpm dlx modern-web-guidance@latest search`/`retrieve`)
  when `date.knowledge-basis` grows stale.

## Source and Licensing

- Upstream: <https://github.com/GoogleChrome/modern-web-guidance> —
  docs at <https://developer.chrome.com/docs/modern-web-guidance>,
  source at <https://github.com/GoogleChrome/modern-web-guidance-src>,
  eval dashboard at <https://googlechrome.github.io/modern-web-guidance-src/>.
- License: Apache-2.0 (permissive; this bundle preserves per-page provenance
  in `sources:` frontmatter pinned to the ingested commit).
- Stewardship: Google Chrome, Microsoft Edge, Mozilla Firefox, and MDN teams
  with the web development community.

<!-- vim: set ft=markdown -->

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

