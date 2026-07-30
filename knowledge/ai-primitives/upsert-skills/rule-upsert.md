---
type: Skill Reference
title: rule-upsert
description: Creates and maintains AI agent rules. The producer skill for the rule primitive.
resource: src/current/skills/ai/rule-upsert/
tags: [upsert-skills, rule-creation, rule-management, rule-audit]
date:
  created: "2026-07-11"
  knowledge-basis: "2026-07-11"
  last-used: "2026-07-11"
sources:
  - id: rule-upsert-skill-md
    resource: src/current/skills/ai/rule-upsert/SKILL.md.tmpl
    title: "rule-upsert SKILL.md"
---

# rule-upsert

## Summary

Creates new AI agent rules or audits and updates existing rules. The
producer skill for the rule primitive.

## Version

1.0.0

## Modes

- **Mode A: Create** — Create a new rule from scratch (scaffold from rule template, customize frontmatter, write body)
- **Mode C: Update** — Audit and update an existing rule

## Key Capabilities

- Scaffold new rules from the rule template
- Customize frontmatter (severity, scope, examples, fix strategy)
- Write the rule body as binding contracts
- Audit checklist: severity appropriateness, scope accuracy, example validity, fix strategy applicability, codebase compliance

## Tags

`ai/skill`, `rule-creation`, `rule-management`, `rule-audit`

## File Location

`src/current/skills/ai/rule-upsert/SKILL.md.tmpl`

## Produces

[Rules](../primitives/rules.md) — always-on binding constraints for AI agents.
