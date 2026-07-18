---
type: Concept
title: Upsert Skills Family
description: Overview of the skill family that creates and maintains all AI primitives, sharing common includes, patterns, and cross-linking.
tags: [ai-primitives, upsert-skills, family, producers, lifecycle]
timestamp: 2026-07-11T10:30:00Z
---

# Upsert Skills Family

The upsert skills are a family of skills in `src/current/skills/ai/` that
create, update, and audit all AI primitive types. Each upsert skill is the
**producer** for one primitive type.

## Family Members

| Skill | Produces | Version |
|------|----------|---------|
| [ai-skill-upsert](ai-skill-upsert.md) | Skills | 2.3.0 |
| [ai-workflow-upsert](ai-workflow-upsert.md) | Workflows | 3.1.0 |
| [agent-upsert](agent-upsert.md) | Agent definitions | 1.0.0 |
| [agent-file-upsert](agent-file-upsert.md) | AGENTS.md hierarchy docs | 3.1.0 |
| [prompt-upsert](prompt-upsert.md) | Prompts | 1.0.0 |
| [template-upsert](template-upsert.md) | Templates | 1.0.0 |
| [knowledge-bundle-upsert](knowledge-bundle-upsert.md) | OKF knowledge bundles | 2.0.0 |
| [rule-upsert](rule-upsert.md) | Rules | 1.0.0 |
| [readme-upsert](readme-upsert.md) | README.md documentation | 1.1.0 |
| [ai-guidance-improver](ai-guidance-improver.md) | Audits any AI guidance type | 1.1.0 |
| [handoff](handoff.md) | Session context handoff | 2.0.0 |

## Common Patterns

### Shared Includes

All upsert skills pull in the same shared includes at build time:

```go
{{{ include "includes/base-ai-guidance.md" . }}}    # Hub: creation framework
{{{ include "includes/trigger-guard.md" . }}}       # Prevents over-triggering
{{{ include "includes/research-phase.md" . }}}       # Search before creating
{{{ include "includes/cross-linking.md" . }}}        # see-also relationships
{{{ include "includes/date-management.md" . }}}     # date.updated / date.last-used
{{{ include "includes/clarifying-questions.md" . }}} # Ask before generating
{{{ include "includes/script-materialization.md" . }}} # Materialize cli-tool-discovery.sh
```

### Common Frontmatter

All upsert skills share this frontmatter pattern:

```yaml
name: <skill-name>
description: <detailed with trigger guidance + "Do NOT trigger on..." clause>
version: <semver>
user-invocable: true
disable-model-invocation: true
date:
  created: "YYYY-MM-DD"
  updated: "YYYY-MM-DD"
  last-used: "YYYY-MM-DD"
tags:
  - "ai/skill"  # or "ai/agent", "ai/prompt/upsert", etc.
  - <domain-specific tags>
see-also:
  - template: "base-ai-guidance"
    relationship: "base-framework"
  - template: "base-frontmatter"
    relationship: "structure-standard"
  - template: "research-phase"
    relationship: "shared-include"
  - skill: <sibling-skill>
    relationship: "sibling" | "complement"
```

### Common Modes

Most upsert skills follow this mode structure:

- **Mode A: Create** — Create a new artifact from scratch
  - Step 0: Research existing artifacts
  - Step 1: Ask clarifying questions
  - Step 2: Initialize (scaffold)
  - Step 3: Plan (design)
  - Step 4: Apply (create)
  - Step 5: Verify (validate)
  - Step 6: Deliver (save)
- **Mode B: Convert** (some skills) — Convert between formats
- **Mode C: Update** — Update an existing artifact (upsert)
- **Mode D: Audit** — Audit for relevance and correctness

### Trigger Guard

All upsert skills include a "Do NOT trigger on..." clause in their
description to prevent over-triggering. The `trigger-guard.md` include
provides the protocol for this.

### Cross-Linking

All upsert skills declare `see-also` relationships with their siblings:
- `relationship: "sibling"` — same upsert family, different target type
- `relationship: "complement"` — related but different purpose
- `relationship: "base-framework"` — shared framework include
- `relationship: "structure-standard"` — shared structural template

## Two Cross-Cutting Skills

### ai-guidance-improver

Audits and improves **any** AI guidance type (skills, workflows, agents,
prompts, AGENTS.md). It's the quality assurance skill for the whole family.

### handoff

Captures and restores conversation context for seamless work continuation
across sessions. Not a producer of primitives, but a utility for the agent
system.

## Skills Without a Producer Skill

Some primitives don't have a dedicated upsert skill:

| Primitive | Status |
|-----------|--------|
| Committees | Hand-authored (no `committee-upsert`) |
| Hooks | Hand-authored (no `hook-upsert`) |
| Snippets | Feature-generated (no `snippet-upsert`) |
| Memory/Context | Hand-authored (no `context-upsert`) |

Use `ai-guidance-improver` to audit these.

# Citations

[1] [AI skills directory](src/current/skills/ai/)
[2] [Skills AGENTS.md](src/current/skills/AGENTS.md)
