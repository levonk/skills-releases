---
type: Synthesis
title: AI Primitives Overview
description: Synthesis of the entire skills-src primitive system and how the pieces fit together.
tags: [ai-primitives, overview, synthesis, architecture]
date:
  created: "2026-07-11"
  knowledge-basis: "2026-07-28"
  last-used: "2026-07-28"
sources:
  - id: skills-src-readme
    resource: https://github.com/levonk/skills-src
    title: "skills-src README"
  - id: okf-v0-2-specification
    resource: https://github.com/GoogleCloudPlatform/knowledge-catalog/blob/main/okf/SPEC.md
    title: "OKF v0.2 Specification"
  - id: eve-filesystem-agents
    resource: https://github.com/vercel/eve
    title: "vercel/eve — filesystem-first framework for durable AI agents"
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


# AI Primitives Overview

The skills-src system is built from composable AI primitives arranged in a
hierarchy of increasing scope and autonomy. Each primitive has a distinct
role, loading behavior, and composition relationship with the others.

## The Primitive Hierarchy

From narrowest to broadest scope:

1. **Snippets** — Generated code fragments for specific features
2. **Templates** — Reusable structures with variable schemas
3. **Prompts** — Precision-crafted instruction sets
4. **Rules** — Always-on binding constraints (no trigger)
5. **Hooks** — Event-driven guardrail scripts
6. **Memory/Context** — Always-on identity, tools, and user state
7. **Workflows** — Multi-step repeatable processes (aka commands)
8. **Skills** — Capabilities loaded on demand for focused tasks
9. **Agents** — Autonomous orchestrators that channel domain expertise
10. **Committees** — Groups of agents that deliberate and synthesize

## Two Loading Modes

- **Always-on**: Rules, context/memory, hooks — loaded into the system prompt
  permanently. Token cost is ongoing; conciseness is critical.
- **On-demand**: Skills, workflows, agents, committees — loaded only when
  triggered by description match or explicit invocation. Token cost is
  pay-per-use; can be more detailed.

## The Composition Chain

Primitives compose bottom-up:

```
Templates → Prompts → Workflows → Skills → Agents → Committees
```

- **Templates** provide reusable structures that **prompts** instantiate
- **Prompts** are used by **workflows** as step instructions
- **Workflows** are invoked by **skills** for multi-step procedures
- **Skills** are tools that **agents** use to accomplish tasks
- **Agents** are members of **committees** that deliberate together

See [Composition Chain](composition/composition-chain.md) for the full chain.

## The Producer Layer

Every primitive type has a corresponding **upsert skill** that creates and
maintains it:

| Primitive | Producer Skill |
|-----------|---------------|
| Skills | `ai-upsert` |
| Workflows | `ai-workflow-upsert` |
| Agents | `agent-upsert` (ai-upsert routes to it) |
| AGENTS.md docs | `agent-file-upsert` |
| Prompts | `prompt-upsert` |
| Templates | `template-upsert` |
| Knowledge bundles | `ai-upsert` |
| Rules | `rule-upsert` |
| READMEs | `readme-upsert` |

`ai-upsert` is the entry point for skills, knowledge bundles, and agents —
it determines which artifact type the user needs and routes accordingly.
For skills and knowledge bundles it handles the full lifecycle directly; for
agents it recognizes the request and routes to the dedicated `agent-upsert`
skill. Plus two cross-cutting skills: `ai-guidance-improver` (audits any
guidance type) and `handoff` (session continuity).

See [Upsert Skills Family](upsert-skills/upsert-family.md) for details.

## The Build System

All primitives are authored as Go `text/template` files (`.tmpl`) with custom
triple-brace delimiters. The templater renders them into self-contained
modules at build time, inlining shared includes. See
[Templater](build-system/templater.md) for details.

## Key Design Principles

1. **Progressive disclosure** — metadata → body → references; load detail on
   demand, not upfront.
2. **Build-time composition** — includes are inlined at render time; built
   artifacts are self-contained.
3. **Trigger-based loading** — skills/workflows/agents load only when their
   description matches the task; rules/context are always-on.
4. **Single responsibility** — each primitive type has one job; the upsert
   skills enforce this with "Do NOT trigger on..." clauses.
5. **Compounding knowledge** — knowledge bundles file good answers back as
   new concepts; explorations compound over time.

## Related Knowledge Bundles

- [container-best-practices](https://github.com/levonk/skills-releases/blob/main/knowledge/container-best-practices/overview.md) —
  canonical example of a domain-specific OKF bundle produced by the upsert skills.
- [java-best-practices](https://github.com/levonk/skills-releases/blob/main/knowledge/java-best-practices/overview.md) — Java/JVM domain bundle.
- [data-engineering-best-practices](https://github.com/levonk/skills-releases/blob/main/knowledge/data-engineering-best-practices/overview.md)
  — data engineering domain bundle.
- [typescript-monorepo-best-practices](https://github.com/levonk/skills-releases/blob/main/knowledge/typescript-monorepo-best-practices/overview.md)
  — TypeScript monorepo domain bundle.
- [devsecops-codeguard](https://github.com/levonk/skills-releases/blob/main/knowledge/devsecops-codeguard/overview.md) — DevSecOps domain bundle.

## Real-World Reference

- [Eve filesystem-first agents](cross-domain/eve-filesystem-agents.md) —
  vercel/eve is a production framework that implements the agent primitive
  using filesystem conventions, mapping closely to the skills-src primitive
  system. See the cross-domain page for the full layout mapping and design
  lessons.
- [Agent integration standards](cross-domain/agent-integration-standards.md)
  — the bridge contract for how an external CLI tool participates in the
  primitive system from outside: skill emission (`--gen-skill`), coding-agent
  hook wiring with per-agent `config.toml`, and non-identifiable telemetry.
  Canonical source: ADR-20260607001 §46–§48. Reference implementation: apmw.

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

