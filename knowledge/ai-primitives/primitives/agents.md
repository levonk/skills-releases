---
type: Primitive Definition
title: Agents
description: Autonomous orchestrators that channel specific domain expertise and work autonomously using workflows, prompts, and templates.
resource: src/current/agents/
tags: [ai-primitives, agents, orchestrator, autonomy, expertise]
date:
  created: "2026-07-11"
  knowledge-basis: "2026-07-28"
  last-used: "2026-07-28"
sources:
  - id: agents-directory
    resource: src/current/agents/
    title: "Agents directory"
  - id: agent-template
    resource: src/current/templates/meta/agent-template.md.tmpl
    title: "Agent template"
  - id: agent-structure-reference
    resource: src/current/skills/ai/agent-upsert/references/agent-structure.md
    title: "Agent structure reference"
  - id: eve-filesystem-agents
    resource: https://github.com/vercel/eve
    title: "vercel/eve — filesystem-first framework for durable AI agents"
---

# Agents

## Definition

Agents are autonomous orchestrators that channel specific domain expertise
(tax strategy, software architecture, spiritual guidance) and work
autonomously after initial questioning. They use workflows, prompts, and
templates as tools to accomplish tasks.

## Primary Role

**Orchestrator** — an agent coordinates skills, workflows, prompts, and
templates to accomplish a broad, multi-step task within its domain
expertise.

## Scope

Broad, multi-step tasks. An agent owns a domain and can execute complex
workflows within it.

## Frontmatter

```yaml
agent: <agent-name>
description: <One-sentence purpose>
use: <When to use this agent; the trigger or scenario>
personality:
  name: <Display name>
  role: <Primary role: Critic, Requirements Analyst, Code Generator, etc.>
  color: <UI hex color>
  icon: <UI emoji>
  personality-archetype: <wise-elder | curious-explorer | empathetic-guide | etc.>
  voice:
    voice-id: <Optional voice ID>
    voice-stability: <0.28-1.00>
    voice-similarity-boost: <0.0-1.0>
    voice-rate-wpm: <180-280>
aliases: [<alternative names>]
categories: [<business, code, docs, dev, ops, etc.>]
capabilities: [<what this agent can perform>]
model-level: <default | background | reasoning | long | websearch>
model: <Optional specific model override>
tools:
  - name: <tool-name>
    description: <what it does>
    inputs:
      - name: <input-name>
        type: <string | boolean | etc.>
        required: <true | false>
        description: <what it is>
    outputs:
      - name: <output-name>
        type: <string | boolean | etc.>
        description: <what it is>
version: <semver>
owner: <owner URL>
agent-status: <draft | ready | deprecated>
visibility: <public | internal>
compliance: [<GDPR, HIPAA, etc.>]
runtime:
  duration:
    min: <duration>
    max: <duration>
    avg: <duration>
  terminate: <condition or timeout>
tags: ["ai/agent", ...]
```

## Body Structure

1. **Goal** — The single most important outcome, with measurable success criteria
2. **Role** — Primary stance, responsibilities, and boundaries
3. **i/o** — Context, required/suggested context, inputs (with schema), outputs/deliverables
4. **Primary Workflow** — Initialize, Plan, Act, Verify, Deliver
5. **Tools** — Tool manifest with constraints
6. **Instructions** — Non-negotiable execution rules
7. **Templates** — Input and output templates
8. **Guardrails** — Feature, process, and maintenance guardrails
9. **Design By Contract** — Preconditions, postconditions, invariants, assertions
10. **Quality Evaluation** — Were objectives met?
11. **Handoffs** — Who receives outputs next
12. **References** — Supporting links

## Loading Behavior

Loaded always when selected or triggered. An agent, once activated, stays
loaded for the duration of the task.

## Reusability

Reusable across agents — no. Agents are specific to their domain. But an
agent can be a member of multiple committees.

## Autonomy Level Changes

Yes — agents can change their own autonomy level based on the task and
supervision level.

## Personality/Behavior

Yes — agents have a full personality definition: name, role, archetype,
voice parameters, color, icon.

## Planning and Reasoning

Yes — agents plan (decompose tasks) and reason (make decisions, apply
expertise).

## File Location

`src/current/agents/<category>/<agent-name>.md.tmpl` (or `.md`)

## How Agents Compose Other Primitives

- **Skills** — agents invoke skills as capabilities
- **Workflows** — agents execute workflows for multi-step procedures
- **Prompts** — agents use prompts as structured instructions
- **Templates** — agents use templates for output generation
- **Tools** — agents declare tools with input/output contracts

## Examples

- `agents/software-dev/agent-designer.md.tmpl` — Designs expert agents
- `agents/software-dev/skill-designer.md.tmpl` — Designs skills
- `agents/software-dev/code-reviewer.md` — Reviews code
- `agents/software-dev/senior-software-engineer.md` — Senior eng expertise

## Real-World Reference

[vercel/eve](../cross-domain/eve-filesystem-agents.md) is a production
filesystem-first framework for durable AI agents. It implements the agent
primitive using path-as-name conventions: `agent/instructions.md` (always-on
prompt), `agent/tools/` (typed capabilities), `agent/skills/` (on-demand
procedures — direct match), and `agent/subagents/` (delegation). See the
cross-domain page for the full layout mapping and design lessons.

## Producer Skill

[`agent-upsert`](../upsert-skills/agent-upsert.md) — creates, updates, and
audits agent definitions.
