---
type: Comparison
title: Primitive Comparison Matrix
description: Full comparison of all AI primitives across every dimension — role, scope, autonomy, loading, reusability, personality, reasoning, and more.
tags: [ai-primitives, comparison, matrix, dimensions, reference]
timestamp: 2026-07-11T10:30:00Z
---

# Primitive Comparison Matrix

Complete comparison of all AI primitives across every dimension.

## Full Dimension Matrix

| Dimension | Committees | Agents | Skills | Workflows | Templates | Prompts | Memory/Context | Rules | Hooks | Snippets |
|-----------|-----------|--------|--------|----------|-----------|---------|----------------|-------|-------|----------|
| **Primary Role** | Orchestrator of orchestrators | Orchestrator | Capability | Process | Structure provider | Instruction | State | Constraint | Guardrail | Code generation |
| **Scope** | Broad, multi-perspective | Broad, multi-step | Narrow, focused | Multi-step | Narrow, structural | Narrow, task-specific | Always-on, permanent | Always-on, permanent | Narrow, event-specific | Narrowest, single file |
| **Personality/Behavior** | Yes (inherits members' + deliberation style) | Yes (full personality definition) | No | No | No | No | Yes (SOUL.md) | No | No | No |
| **Planning & Reasoning** | Yes (deliberation, synthesis) | Yes (decomposition, expertise) | No (follows procedure) | No (follows steps) | No (static structure) | No (thinking triggers only) | No (state, not process) | No (constraints) | No (deterministic checks) | No (static templates) |
| **Loading Behavior** | Triggered (user/agent) | Always when selected/triggered | Only when relevant/called | Triggered (user/agent) | Referenced by caller | Invoked by user/workflow | Always-on (system prompt) | Always-on (system prompt) | Event-driven (per-action) | Generated on-demand |
| **Reusable Across Agents** | Yes (same committee, different questions) | No (domain-specific) | Yes | Yes | Yes | Yes | No (agent/operator specific) | Yes (across projects) | Yes (across projects) | Yes (across projects) |
| **Changes Autonomy Level** | Yes (weights member input) | Yes (adjusts based on task) | No | No | No | No | No | No | No | No |
| **Has Frontmatter** | Yes (committee, slug, members, protocols) | Yes (agent, description, personality, tools) | Yes (name, description, version, tags) | Yes (workflow, slug, use, role) | Yes (template, slug, variables) | Yes (prompt, description) | No (embedded docs) | No | No | No |
| **Has Subdirectories** | No | No | Yes (scripts, references, evals, assets) | No | No | No | No | No | No | No |
| **Format** | Markdown (.md.tmpl) | Markdown (.md.tmpl) | Markdown + scripts | Markdown (Template/Wrapper) | Markdown (.md.tmpl) | Markdown | Markdown stubs | Markdown | Python scripts | Code templates (.tmpl) |
| **Token Cost** | On-demand | On-demand (when active) | On-demand | On-demand | On-demand | On-demand | Permanent (always-on) | Permanent (always-on) | Per-event (minimal) | None (generated, not loaded) |
| **Producer Skill** | None (hand-authored) | agent-upsert | ai-skill-upsert | ai-workflow-upsert | template-upsert | prompt-upsert | None (hand-authored) | rule-upsert | None (hand-authored) | None (feature-generated) |
| **File Location** | `committees/<cat>/` | `agents/<cat>/` | `skills/<cat>/<name>/` | `workflows/<cat>/` + `templates/<cat>/` | `templates/<cat>/` | `internal-docs/prompts/` | `context/` | `rules/<cat>/` | `hooks/<event>/` | `snippets/features/<feat>/` |

## Detailed Dimension Analysis

### Primary Role

- **Committees**: Orchestrate multiple agents to produce a synthesis
- **Agents**: Orchestrate skills/workflows/prompts/templates to accomplish
  domain tasks
- **Skills**: Provide a specific capability on demand
- **Workflows**: Define a repeatable multi-step process
- **Templates**: Provide reusable output structures
- **Prompts**: Provide structured instructions for a specific task
- **Memory/Context**: Provide persistent state (identity, tools, user)
- **Rules**: Provide binding constraints (always-on)
- **Hooks**: Guard actions with validation (event-driven)
- **Snippets**: Generate boilerplate code for features

### Scope

- **Broadest**: Committees (multi-perspective deliberation)
- **Broad**: Agents (full domain ownership)
- **Medium**: Workflows (multi-step procedures), Skills (focused capabilities)
- **Narrow**: Templates (one structure), Prompts (one task), Hooks (one event)
- **Narrowest**: Snippets (one code file)

### Autonomy Level

Only **committees** and **agents** can change autonomy levels:
- Committees decide how much weight to give each member's input
- Agents adjust their autonomy based on task and supervision level

All other primitives are fixed in their behavior.

### Loading Behavior (Two Modes)

**Always-on** (permanent token cost):
- Rules — binding constraints
- Memory/Context — identity, tools, user state

**On-demand** (pay-per-use token cost):
- Skills — triggered by description match
- Workflows — triggered by user/agent
- Agents — loaded when selected/triggered
- Committees — triggered by user/agent
- Templates — referenced by caller
- Prompts — invoked by user/workflow

**Event-driven** (per-action, minimal token cost):
- Hooks — fire on file read/write/run events

**Generated** (no token cost — not loaded into context):
- Snippets — generated as code files, not loaded as context

### Reusability

**Reusable across agents**:
- Skills, Workflows, Templates, Prompts, Committees, Rules, Hooks, Snippets

**Not reusable (instance-specific)**:
- Agents (domain-specific)
- Memory/Context (agent/operator specific)

### Personality/Behavior

**Has personality**:
- Committees (inherit members' personalities + add deliberation style)
- Agents (full personality: name, role, archetype, voice, color, icon)
- Memory/Context (SOUL.md defines values, voice, principles)

**No personality**:
- Skills, Workflows, Templates, Prompts, Rules, Hooks, Snippets

### Planning and Reasoning

**Plans and reasons**:
- Committees (deliberation, synthesis, conflict resolution)
- Agents (task decomposition, expertise application, decision-making)

**Does not plan or reason**:
- Skills (follow defined procedures)
- Workflows (follow defined steps)
- Templates (static structures)
- Prompts (instructions, though thinking triggers can encourage reasoning
  within execution)
- Memory/Context (state, not process)
- Rules (constraints)
- Hooks (deterministic checks)
- Snippets (static templates)

## Hierarchy of Composition

```
Snippets ─────────────────────────────────────────────────────┐
                                                               │
Templates ──→ Prompts ──→ Workflows ──→ Skills ──→ Agents ──→ Committees
                                                               │
Rules ──────────────────────────────────────────────────────────┤
                                                               │
Memory/Context ────────────────────────────────────────────────┤
                                                               │
Hooks ─────────────────────────────────────────────────────────┘
```

- **Snippets** are generated code, used by the project, not by other primitives
- **Templates** are used by prompts, workflows, skills, and agents
- **Prompts** are used by workflows and agents
- **Workflows** are used by skills and agents
- **Skills** are used by agents
- **Agents** are used by committees
- **Rules, Memory/Context, Hooks** are cross-cutting — they apply to all
  primitives as constraints, state, and guardrails

# Citations

[1] [skills-src README](https://github.com/levonk/skills-src)
[2] [OKF v0.1 Specification](https://github.com/GoogleCloudPlatform/knowledge-catalog/blob/main/okf/SPEC.md)
