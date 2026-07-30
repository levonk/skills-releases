---
type: Skill Reference
title: ai-upsert
description: Creates and maintains three types of compounding AI artifacts — skills, OKF knowledge bundles, and agents. Determines which type the user needs, recommends the best fit, and uses progressive disclosure to branch into type-specific workflows. Routes agent requests to the dedicated agent-upsert skill.
resource: src/current/skills/ai/ai-upsert/
tags: [upsert-skills, skill-creation, skill-evaluation, skill-conversion, okf, knowledge-management, knowledge-bundle, lifecycle, agent-routing]
date:
  created: "2026-07-11"
  knowledge-basis: "2026-07-28"
  last-used: "2026-07-28"
sources:
  - id: ai-upsert-skill-md
    resource: src/current/skills/ai/ai-upsert/SKILL.md.tmpl
    title: "ai-upsert SKILL.md"
  - id: okf-v0-2-specification
    resource: https://github.com/GoogleCloudPlatform/knowledge-catalog/blob/main/okf/SPEC.md
    title: "OKF v0.2 Specification"
  - id: eve-filesystem-agents
    resource: https://github.com/vercel/eve
    title: "vercel/eve — filesystem-first framework for durable AI agents"
---

# ai-upsert

## Summary

Creates and maintains three types of compounding AI artifacts — **skills**
(executable procedures), **OKF knowledge bundles** (compounding knowledge
wikis), and **agents** (autonomous orchestrators). This skill consolidates
the former `ai-skill-upsert` and `knowledge-bundle-upsert` into a single
entry point that determines which artifact type the user needs, recommends
the best fit if they ask for the wrong one, and uses progressive disclosure
to branch into type-specific workflows. For agents, it recognizes agent
requests and routes to the dedicated `agent-upsert` skill.

## Version

3.2.0

## Decision: Skill vs Knowledge Bundle vs Agent

The first branching point — the three types have fundamentally different
structures, lifecycles, and purposes:

- **Skill** — A procedure/workflow the AI executes step-by-step. Best for "how
  to do X" — repeatable procedures, tool integrations.
- **Knowledge Bundle** — A compounding knowledge base the AI references on
  demand. Best for "what we know about X" — curated knowledge, best practices.
- **Agent** — An autonomous orchestrator that channels domain expertise. Best
  for "be an expert in X" — autonomous domain ownership with personality and
  tools. Routed to `agent-upsert`.

If the user explicitly asks for one type but another is clearly better, the
skill makes a recommendation, explains why, and asks the user to choose.

## Skill Path Modes

- **Mode A: Create** — Create a new skill from scratch (research → scaffold → customize → verify → deliver)
- **Mode B: Convert** — Convert a workflow into a skill (preserving git history via `git mv`)
- **Mode C: Update** — Update an existing skill (upsert)
- **Mode D: Eval** — Run evals to test a skill, benchmark performance with variance analysis

## Knowledge Bundle Path Modes

- **Mode A: Create** — Scaffold a new OKF-compliant knowledge bundle from scratch
- **Mode B: Ingest** — Add a new source to an existing bundle
- **Mode C: Query** — Answer a question using the bundle, then file good answers back
- **Mode D: Lint** — Health-check the bundle for contradictions, orphans, broken links

## Agent Path

Recognizes agent creation/update requests and **routes to `agent-upsert`**
(the dedicated producer skill for the agent primitive). Does not duplicate
the agent lifecycle — `agent-upsert` owns scaffolding (`init-agent.py`),
frontmatter customization, verification (`verify-agent.py`), and auditing.

## Key Capabilities

### Skill Capabilities
- Research existing skills locally, on skills.sh, and on GitHub
- Scaffold new skills with `init_skill.py`
- Convert workflows to skills (and vice versa via `ai-workflow-upsert`)
- Run evals and benchmark skill performance
- Optimize skill descriptions for better triggering accuracy

### Knowledge Bundle Capabilities
- Create OKF v0.2-compliant knowledge bundles
- Ingest sources and extract concepts (one concept per file)
- Query bundles with progressive disclosure (index → concept → synthesis)
- Lint for contradictions, orphan pages, missing pages, broken links
- File good answers back as new concept documents (compounding)

### Agent Routing Capabilities
- Recognize agent creation/update requests vs skill/knowledge bundle requests
- Disambiguate agent vs skill (autonomous domain expert vs repeatable procedure)
- Route to `agent-upsert` for the full agent lifecycle
- Recommend agents when the user asks for a "skill" but means an autonomous expert

## Tags

`ai/skill`, `skill-creation`, `skill-development`, `skill-testing`, `skill-evaluation`, `skill-optimization`, `skill-discovery`, `okf`, `knowledge-management`, `knowledge-bundle`, `lifecycle`, `ingest`, `lint`, `compounding`, `ai/agent`, `agent-routing`

## File Location

`src/current/skills/ai/ai-upsert/SKILL.md.tmpl`

## Produces

- [Skills](../primitives/skills.md) — capabilities loaded on demand for focused tasks.
- OKF knowledge bundles — compounding, structured knowledge bases following
  the Open Knowledge Format v0.2. This very bundle is an example of the
  skill's output.
- Routes to [agents](../primitives/agents.md) (produced by
  [`agent-upsert`](./agent-upsert.md)) — autonomous orchestrators that channel
  domain expertise.

## Three-Layer Architecture (Knowledge Bundles)

1. **Raw sources** — immutable source documents (read-only)
2. **The bundle (wiki)** — markdown concept files following OKF v0.2 (agent-owned)
3. **The schema** — the skill files that tell the agent how the bundle works (co-evolved)

## References

### Skill References
- `references/skill/anatomy.md` — Skill structure, frontmatter, scripts, references
- `references/skill/progressive-disclosure.md` — Patterns and anti-patterns
- `references/skill/script-execution-standards.md` — PEP 723, devbox, rtk, uv detection
- `references/skill/security.md` — Security review guidelines
- `references/skill/skill-discovery.md` — Research phase workflow
- `references/skill/skill-template.md` — Full skill structure and frontmatter reference
- `references/skill/skill-upsert.md` — Update workflow and audit checklist
- `references/skill/workflow-conversion.md` — Workflow-to-skill conversion process
- `references/skill/evals-schema.md` — Eval schema and how to run evals

### Knowledge Bundle References
- `references/knowledge/bundle-structure.md` — Directory layout and reserved filenames
- `references/knowledge/okf-spec.md` — OKF v0.2 design principles and conformance criteria
- `references/knowledge/concept-documents.md` — Frontmatter fields and body structure
- `references/knowledge/index-files.md` — Progressive disclosure with index files
- `references/knowledge/log-files.md` — Chronological update history
- `references/knowledge/best-practices.md` — Type naming, maintenance, lint
- `references/knowledge/example-concepts.md` — Resource-bound and abstract concept examples
- `references/knowledge/operations.md` — Ingest, query, and lint workflows

### Agent Routing References
- `src/current/skills/ai/agent-upsert/SKILL.md.tmpl` — The dedicated agent producer skill
- [Agents primitive](../primitives/agents.md) — Agent structure, frontmatter, body sections
- [Eve filesystem-first agents](../cross-domain/eve-filesystem-agents.md) — Real-world agent framework reference
