---
type: Synthesis
title: AI Primitives Overview
description: Synthesis of the entire skills-src primitive system and how the pieces fit together.
tags: [ai-primitives, overview, synthesis, architecture]
timestamp: 2026-07-11T10:30:00Z
---

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
| Skills | `ai-skill-upsert` |
| Workflows | `ai-workflow-upsert` |
| Agents | `agent-upsert` |
| AGENTS.md docs | `agent-file-upsert` |
| Prompts | `prompt-upsert` |
| Templates | `template-upsert` |
| Knowledge bundles | `knowledge-bundle-upsert` |
| Rules | `rule-upsert` |
| READMEs | `readme-upsert` |

Plus two cross-cutting skills: `ai-guidance-improver` (audits any guidance
type) and `handoff` (session continuity).

See [Upsert Skills Family](upsert-skills/upsert-family.md) for details.

## The Build System

All primitives are authored as Go `text/template` files (`.tmpl`) with custom
delimiters (`{{{`/`}}}`). The templater renders them into self-contained
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

- [container-best-practices](../container-best-practices/overview.md) —
  canonical example of a domain-specific OKF bundle produced by the upsert skills.
- [java-best-practices](../java-best-practices/overview.md) — Java/JVM domain bundle.
- [data-engineering-best-practices](../data-engineering-best-practices/overview.md)
  — data engineering domain bundle.
- [typescript-monorepo-best-practices](../typescript-monorepo-best-practices/overview.md)
  — TypeScript monorepo domain bundle.
- [devsecops-codeguard](../devsecops-codeguard/overview.md) — DevSecOps domain bundle.

# Citations

[1] [skills-src README](https://github.com/levonk/skills-src)
[2] [OKF v0.1 Specification](https://github.com/GoogleCloudPlatform/knowledge-catalog/blob/main/okf/SPEC.md)
