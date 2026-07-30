---
type: Skill Reference
title: agent-file-upsert
description: Generates and updates hierarchical AGENTS.md documentation for AI agents working in codebases.
resource: src/current/skills/ai/agent-file-upsert/
tags: [upsert-skills, agents-md, documentation, brownfield, hierarchical]
date:
  created: "2026-07-11"
  knowledge-basis: "2026-07-11"
  last-used: "2026-07-11"
sources:
  - id: agent-file-upsert-skill-md
    resource: src/current/skills/ai/agent-file-upsert/SKILL.md.tmpl
    title: "agent-file-upsert SKILL.md"
---

# agent-file-upsert

## Summary

Generates or updates hierarchical AGENTS.md documentation for AI agents
working in codebases. Context-aware — detects and follows the project's
existing convention (AGENTS.md, CLAUDE.md, AGENT.md, or combinations via
referral/symlink).

## Version

3.1.0

## Modes

- **Mode A: Brownfield** — Onboard an AI agent to an existing codebase by establishing context and conventions
- **Mode C: Update** — Update existing agent documentation after significant repo changes (runs delta analysis via git)

## Key Capabilities

- Detects and follows existing convention (AGENTS.md, CLAUDE.md, AGENT.md)
- Delta analysis: extracts positive findings, anti-patterns, and improvement candidates from git changes
- Hierarchical documentation: root AGENTS.md + subtree AGENTS.md files
- Convention-aware: respects existing patterns

## Tags

`ai/skill`, `software-development`, `documentation`, `agents`, `brownfield`, `hierarchical-docs`, `convention-detection`, `delta-analysis`

## File Location

`src/current/skills/ai/agent-file-upsert/SKILL.md.tmpl`

## Produces

AGENTS.md hierarchy documentation — not agent definitions (use `agent-upsert`
for those). This skill generates the binding contract documentation that
tells AI agents how to work in a specific codebase.

## Key Difference from agent-upsert

| Aspect | agent-file-upsert | agent-upsert |
|--------|-------------------|-------------|
| Produces | AGENTS.md documentation files | Agent definition files |
| Purpose | Tell agents how to work in a codebase | Define an agent's personality and capabilities |
| Location | Target codebase root + subtrees | `internal-docs/agents/` |
