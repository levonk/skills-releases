---
type: Synthesis
title: Go Best Practices Overview
description: Synthesis of modern Go programming practices — collections, loops, error handling, context, strings/bytes, concurrency, JSON, generics, testing, HTTP routing, formatting, and time utilities from Go 1.0 through 1.27.
tags: [go, golang, best-practices, modern, overview, synthesis]
date:
  created: "2026-09-04"
  knowledge-basis: "2026-09-04"
  last-used: "2026-09-04"

sources:
  - id: jetbrains-go-modern-guidelines
    resource: "FEATURES.md"
    title: "JetBrains/go-modern-guidelines"
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


# Go Best Practices Overview

This bundle documents modern Go programming practices sourced from the JetBrains
go-modern-guidelines project. Each concept captures specific guidelines that help
developers write idiomatic, modern Go — using the latest standard library
additions, language features, and patterns available from Go 1.0 through Go 1.27.
The guidelines address two problems: training-data lag (models do not know about
features added after their training cutoff) and frequency bias (models default to
older patterns even when newer ones exist). By following these practices, agents
and developers write modern Go from the start, reducing the need for later
modernization.

## The Modern Go Practice Lifecycle

```
collections → loops → errors → context → strings → sync → json → types → testing → http → fmt → time
```

| Phase | Practice | Prevents |
|-------|----------|----------|
| Collections | [Collections: Slices and Maps](collections-slices-maps.md) | Manual search loops, hand-written sort, unsafe slice copies, missing map helpers |
| Loops | [Loops and Iterators](loops-iterators.md) | Verbose count loops, redundant loop-variable copies, closure capture bugs |
| Errors | [Error Handling](error-handling.md) | Direct equality on wrapped errors, manual error concatenation, unsafe type assertions |
| Context | [Context Patterns](context-patterns.md) | Leaked goroutines waiting on Done, coarse cancellation reasons, manual test contexts |
| Strings | [Strings and Bytes](strings-bytes.md) | Manual Index+slicing, duplicated prefix/suffix checks, unnecessary allocations |
| Sync | [Sync and Concurrency](sync-concurrency.md) | Untracked goroutines, untyped atomics, verbose Once patterns |
| JSON | [JSON Encoding](json-encoding.md) | Inconsistent nil encoding, wrong omit semantics, missing v2 defaults |
| Types | [Types and Generics](types-generics.md) | Verbose interface{} spelling, misplaced generic helpers, nil-pointer reflect tricks |
| Testing | [Testing and Benchmarks](testing-benchmarks.md) | Manual test contexts, outdated benchmark loops, timer control errors |
| HTTP | [HTTP Routing](http-routing.md) | Manual method checks, fragile path trimming, missing path wildcards |
| Fmt | [Fmt Utilities](fmt-utilities.md) | Unnecessary string allocations, verbose fallback chains |
| Time | [Time and Utilities](time-utilities.md) | Reversed Sub calls, leaked tickers, third-party UUID dependencies, shallow URL copies |

## Scope

This bundle covers **modern Go programming practices** — standard library
additions, language features, and idiomatic patterns from Go 1.0 through Go 1.27.
It does **not** cover:

- Go project structure and module management — see
  [dev-environment-practices](https://github.com/levonk/skills-releases/blob/main/knowledge/dev-environment-practices/overview.md).
- Rust-specific development practices — see
  [rust-development-practices](https://github.com/levonk/skills-releases/blob/main/knowledge/rust-development-practices/overview.md).
- Container deployment patterns — see
  [container-best-practices](https://github.com/levonk/skills-releases/blob/main/knowledge/container-best-practices/overview.md).

## Sources

- `FEATURES.md` — JetBrains/go-modern-guidelines (50+ guidelines, Go 1.0 through 1.27)

## Related Knowledge Bundles

- [dev-environment-practices](https://github.com/levonk/skills-releases/blob/main/knowledge/dev-environment-practices/overview.md) —
  Environment management for Go projects
- [rust-development-practices](https://github.com/levonk/skills-releases/blob/main/knowledge/rust-development-practices/overview.md) —
  Rust development practices for comparison
- [container-best-practices](https://github.com/levonk/skills-releases/blob/main/knowledge/container-best-practices/overview.md) — Container
  patterns for Go binaries

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

