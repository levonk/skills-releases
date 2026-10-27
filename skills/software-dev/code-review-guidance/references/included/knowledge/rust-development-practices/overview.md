---
type: Synthesis
title: Rust Development Practices Overview
description: Synthesis of Rust development practices — project structure, Cargo config, formatting/linting, testing, error handling, async, serialization, CLI standards, container support, security, quality gates, plus API design, type/trait design, naming, documentation, stability attributes, implementation idioms, unsafe, macros, ownership, builders, visibility, concurrency, performance, review, porting, and Bevy ECS.
tags: [rust, development, cargo, cli, overview, synthesis]
date:
  created: "2026-07-18"
  knowledge-basis: "2026-07-17"
  last-used: "2026-10-27"

sources:
  - id: levonk-base-boilerplate
    resource: "internal-docs/adr/adr-20260128001-rust-package-boilerplate-requirements.md"
    title: "levonk-base-boilerplate"
  - id: levonk-base-boilerplate-adr-20260607001-cli-tool-standards
    resource: "internal-docs/adr/adr-20260607001-cli-tool-standards.md"
    title: "levonk-base-boilerplate"
  - id: google-rust-style-guide
    resource: "https://google.github.io/styleguide/rustguide.html"
    title: "Google Rust Style Guide"
  - id: beautifulrust
    resource: "https://github.com/morganlinton/BeautifulRust"
    title: "BeautifulRust"
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


# Rust Development Practices Overview

This bundle documents practices for creating production-ready Rust packages and
CLI tools. Each concept was extracted from real boilerplate requirements and CLI
standards ADRs — the rules that ensure Rust packages are well-structured,
properly tested, secure, and maintainable across the monorepo ecosystem.

## The Rust Development Lifecycle

```
project-structure → cargo-config → formatting → testing → error-handling → async → serde
                                                                              ↓
                            cli-standards ← container ← security ← quality-gates
```

| Phase | Practice | Prevents |
|-------|----------|----------|
| Structure | [Project Structure](project-structure.md) | Inconsistent layouts, missing modules, poor public API |
| Manifest | [Cargo Configuration](cargo-configuration.md) | Unpinned deps, missing metadata, unguarded features |
| Formatting | [Rustfmt and Clippy](rustfmt-clippy-config.md) | Style drift, complexity creep, linting gaps |
| Testing | [Testing Strategy](testing-strategy.md) | Untested code, missing benchmarks, no property tests |
| Errors | [Error Handling](error-handling.md) | Panics in libraries, unstructured errors, poor context |
| Async | [Async Patterns](async-patterns.md) | Wrong runtime, blocking in async, missing async tests |
| Serialization | [Serde Serialization](serde-serialization.md) | Missing serde derives, over-serialized optional fields |
| CLI | [CLI Tool Standards](cli-tool-standards.md) | Inconsistent UX, no agent mode, missing daemon support, no skill emission, no agent-hook wiring, unsafe telemetry |
| Container | [Container Support](container-support.md) | Bloated images, root containers, missing healthchecks |
| Security | [Security and Auditing](security-auditing.md) | Vulnerable deps, leaked secrets, unsafe FFI |
| Quality | [Quality Gates](quality-gates.md) | Unformatted commits, single-version testing, no CI audit |
| AST | [Tree-Sitter AST Queries](tree-sitter-ast-queries.md) | Brittle pattern matching, no multi-language query reuse, slow large-codebase scans |
| CLI | [Clap CLI Patterns](clap-cli-patterns.md) | Inconsistent argument parsing, missing shell completion, poor help text |
| Config | [TOML Config Validation](toml-config-validation.md) | Invalid configs accepted silently, no profile merging, no config migration |
| Logging | [Structured Logging with tracing](structured-logging-tracing.md) | Unstructured logs, no severity filtering, missing IDE hook event context |
| Watching | [File Watcher Patterns](file-watcher-patterns.md) | Watch limit exhaustion, FS race conditions, missed events on slow disks |
| Paths | [Cross-Platform Path Handling](cross-platform-path-handling.md) | Path display corruption, symlink loops, Windows UNC path failures |
| Errors | [Anyhow + Thiserror Combination](anyhow-thiserror-combination.md) | Library errors leaking into application context, untestable error variants |
| Imports | [Import Organization](import-organization.md) | Hidden name origins, noisy diffs, unqualified non-local calls |
| API | [API Design Principles](api-design-principles.md) | Concrete-container signatures, premature allocation, unreadable bool params |
| Types | [Type and Trait Design](type-and-trait-design.md) | Ambiguous aliases, manual impls, dyn overhead, organizational traits |
| Naming | [Rust Naming Conventions](rust-naming-conventions.md) | Misleading conversion names, unguessable constructors, obscure abbreviations |
| Docs | [Documentation Comments](documentation-comments.md) | Undocumented APIs, signature-parroting comments, hidden panic conditions |
| Stability | [API Stability Attributes](api-stability-attributes.md) | Breaking enum additions, dropped must-use results, unstable-feature lock-in |
| Idioms | [Implementation Idioms](implementation-idioms.md) | Reflexive Rc/Arc, clone-driven design, unreadable inference and combinator chains |
| Unsafe | [Unsafe Code Practices](unsafe-code-practices.md) | Scattered unsafe blocks, unjustified UB risk, poisoned state propagation |
| Macros | [Macro Guidelines](macro-guidelines.md) | Language dialects, tooling degradation, refactor-hostile metaprogramming |
| Ownership | [Ownership and Borrowing](ownership-and-borrowing.md) | Borrow-checker clones, runtime borrow failures, lifetime-propagating structs |
| Construction | [Builders and Constructors](builders-and-constructors.md) | Constructor proliferation, call-site validation, swappable loose arguments |
| Evolution | [Visibility and API Evolution](visibility-and-api-evolution.md) | Locked representations, duplicate API paths, accidental breaking changes |
| Concurrency | [Concurrency and Async Design](concurrency-and-async-design.md) | `!Send` futures, leaked lock guards, runtime-assuming libraries |
| Performance | [Performance Practices](performance-practices.md) | Blind optimization, per-item allocation and locking, unreclaimed capacity |
| Review | [Rust Code Review](rust-code-review.md) | Style-nit noise hiding soundness holes, uncited findings, rewrite-as-review |
| Porting | [Porting to Rust](porting-to-rust.md) | Transliterated foreign idioms, changed behavior, unverifiable parity |
| Bevy | [Bevy ECS Conventions](bevy-ecs-conventions.md) | Wrong "fixes" to system signatures, first-frame panics that compile clean |

## Scope

This bundle covers **Rust package and CLI development** — structure, tooling,
testing, security, and deployment. It does **not** cover:

- Devbox/Nix environment setup — see
  [dev-environment-practices](../dev-environment-practices/overview.md).
- Container runtime hardening — see
  [container-best-practices](../container-best-practices/overview.md).
- Monorepo build orchestration — see
  [typescript-monorepo-best-practices](../typescript-monorepo-best-practices/overview.md).

## Sources

- `internal-docs/adr/adr-20260128001-rust-package-boilerplate-requirements.md` — boilerplate (756 lines)
- `internal-docs/adr/adr-20260607001-cli-tool-standards.md` — boilerplate (v5.0.0, 2026-07-29; 437 lines)
- [Google Rust Style Guide](https://google.github.io/styleguide/rustguide.html) — ingested 2026-10-21 (codebase-tagged `[chrome]`/`[Fuchsia]` rules excluded)
- [BeautifulRust](https://github.com/morganlinton/BeautifulRust) — ingested 2026-10-27 (agent skills + tested `[lints]` config synthesizing the Google guide, Rust API Guidelines, Effective Rust, Rust Design Patterns, and Microsoft's Pragmatic Rust Guidelines; eval/benchmark harness content excluded)

## Related Knowledge Bundles

- [dev-environment-practices](../dev-environment-practices/overview.md) —
  Environment management for Rust projects
- [container-best-practices](../container-best-practices/overview.md) — Container
  patterns for Rust binaries
- [devsecops-codeguard](../devsecops-codeguard/overview.md) — Security practices
  for Rust code
