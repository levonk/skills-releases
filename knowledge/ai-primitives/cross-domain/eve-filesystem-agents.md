---
type: Concept
title: Eve Filesystem-First Agents
description: Cross-link to vercel/eve — a filesystem-first framework for durable AI agents that implements the agent primitive using path-as-name conventions, mapping closely to the skills-src primitive system.
tags: [ai-primitives, cross-domain, eve, filesystem-first, agents, real-world-reference]
date:
  created: "2026-07-28"
  knowledge-basis: "2026-07-28"
  last-used: "2026-07-28"
sources:
  - id: eve-readme
    resource: https://github.com/vercel/eve
    title: "vercel/eve README"
  - id: eve-project-structure
    resource: https://eve.dev/docs/project-structure
    title: "Eve Project Structure docs"
  - id: eve-docs
    resource: https://eve.dev/docs
    title: "Eve documentation"
---

# Eve Filesystem-First Agents

[vercel/eve](https://github.com/vercel/eve) is a filesystem-first framework
for durable AI agents. Core agent capabilities live in conventional locations,
so projects are easier to inspect, extend, and operate. This page maps eve's
filesystem conventions to the skills-src primitive system and extracts
transferable design lessons.

## Why This Matters for ai-primitives

The skills-src primitive system defines agents, skills, tools, and
composition chains abstractly. Eve is a **real-world production framework**
that implements the same primitives using filesystem conventions — it
validates the primitive model against an independent, widely-adopted
design (4.1k stars, Vercel-backed). Studying eve's choices sharpens the
local primitive definitions and surfaces conventions worth adopting.

## The Eve Agent Layout

A minimal eve agent:

```text
my-agent/
├── package.json
├── agent/
│   ├── agent.ts            # Optional: model and runtime config
│   └── instructions.md     # Required: the always-on system prompt
└── evals/                  # Checks that measure task completion
```

Capabilities are added as directories under `agent/`:

| Path | Purpose | skills-src equivalent |
|------|---------|----------------------|
| `agent/instructions.md` | Always-on system prompt | [Memory/Context](../primitives/memory.md) — `IDENTITY.md`, `SOUL.md` |
| `agent/agent.ts` | Model selection and runtime config | Agent frontmatter `model-level`, `model`, `runtime` |
| `agent/tools/` | Typed functions the model can call | Agent frontmatter `tools` (with i/o contracts) |
| `agent/skills/` | Procedures loaded on demand | [Skills](../primitives/skills.md) — direct match |
| `agent/channels/` | HTTP, Slack, Discord entry points | No direct equivalent (runtime transport) |
| `agent/connections/` | MCP and OpenAPI services | No direct equivalent (external service bindings) |
| `agent/subagents/` | Specialist agents the root delegates to | [Committees](../primitives/committees.md) / agent delegation |
| `agent/schedules/` | Recurring cron jobs | No direct equivalent (runtime scheduling) |
| `agent/sandbox/` | Controlled workspace files and commands | No direct equivalent (execution isolation) |
| `agent/lib/` | Shared code imported by agent files | Includes / shared scripts |
| `evals/` | Task completion checks | [Skill evals](../primitives/skills.md) — direct match |

## Path-as-Name Convention

Eve's central design rule: **the path supplies the name.** A file at
`agent/tools/get_weather.ts` becomes the `get_weather` tool automatically —
no duplicate `name` or `id` field in the definition. The same rule applies
to connections, skills, and subagents.

This contrasts with skills-src, where the `name` field in YAML frontmatter
is the authoritative identifier and the directory path is organizational.
Both conventions work; eve's path-as-name reduces boilerplate while
skills-src's frontmatter `name` allows the skill name to differ from the
directory (useful when a skill moves or is aliased).

**Transferable lesson**: skills-src could adopt path-as-name as an optional
convention for tools and subagents to reduce frontmatter duplication, while
keeping `name` for skills (which need stable identifiers across moves).

## Composition in Eve

Eve demonstrates the [composition chain](../composition/composition-chain.md)
in production:

```
instructions.md (context) → tools/ (capabilities) → skills/ (procedures) → subagents/ (delegation)
```

- **instructions.md** is the always-on context (Layer 6 in the composition
  chain — memory/context).
- **tools/** are typed capabilities the model calls directly.
- **skills/** are procedures loaded on demand — the direct analogue of
  skills-src skills, including the same on-demand loading behavior.
- **subagents/** are specialist agents the root delegates to — the
  committee/delegation pattern, but invoked by a single root agent rather
  than a deliberating council.

Unlike skills-src's build-time composition (`{{{ include }}}` inlining),
eve composes at runtime via filesystem discovery. Both approaches produce
self-contained agents; they differ in when composition happens (build vs
boot).

## Filesystem-First vs Template-First

| Aspect | Eve (filesystem-first) | skills-src (template-first) |
|--------|------------------------|-----------------------------|
| Authoring interface | The filesystem itself | Go `text/template` `.tmpl` files |
| Composition timing | Runtime (filesystem discovery) | Build-time (templater inlines includes) |
| Capability naming | Path-as-name (no duplicate field) | Frontmatter `name` (authoritative) |
| Shared content | `lib/` imports | `{{{ include }}}` inlining |
| Output | Running TypeScript agent | Self-contained markdown skill modules |
| Target runtime | eve runtime (Node.js 24+) | Any AI agent that reads markdown |

Both are "convention over configuration" designs. Eve's filesystem-first
approach is optimized for a single runtime; skills-src's template-first
approach is optimized for portability across AI agent runtimes.

## Design Lessons for skills-src

1. **Evals as a peer directory** — eve places `evals/` beside `agent/`, not
   nested inside it. skills-src already does this (`evals/` inside each
   skill directory), confirming the convention.

2. **Subagents as a first-class slot** — eve elevates agent delegation to
   a filesystem slot (`agent/subagents/`). skills-src models this as
   committees, which are heavier (deliberation protocols, synthesis).
   Eve's lighter "subagent" concept may suit single-agent delegation
   without the committee overhead.

3. **Channels and schedules as runtime slots** — eve bakes transport
   (channels) and recurrence (schedules) into the agent layout. skills-src
   treats these as out-of-scope (runtime concerns). This is a deliberate
   boundary: skills-src produces portable guidance artifacts, not running
   services.

4. **Path-as-name reduces boilerplate** — for tools and subagents, the
   path-as-name convention eliminates a redundant identifier field.
   skills-src could adopt this for tool definitions inside agent
   frontmatter without changing the skill `name` contract.

## Related Primitives

- [Agents](../primitives/agents.md) — the primitive eve implements
- [Skills](../primitives/skills.md) — eve's `agent/skills/` is a direct match
- [Composition Chain](../composition/composition-chain.md) — eve demonstrates
  the chain in production
- [Committees](../primitives/committees.md) — eve's `subagents/` is a lighter
  delegation variant

## Producer Skill

This cross-domain reference was added by
[`ai-upsert`](../upsert-skills/ai-upsert.md) (Mode B: Ingest) using the
vercel/eve README and project-structure docs as sources.
