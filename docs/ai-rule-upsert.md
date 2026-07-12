<!-- Managed by skills-src build pipeline. Do not edit; changes will be overwritten. -->
<!-- Generated from SKILL.md frontmatter + body by `just catalog` -->

# Skills: the script is materialized into scripts/cli-tool-discovery.sh at build time

> Category: **ai** · Status:  · Version: 1.0.0

Create new AI agent rules or audit and update existing rules. Scaffolds new rules from the rule template, customizes frontmatter (severity, scope, examples, fix strategy), and writes the rule body. When updating, runs a rule-specific audit checklist covering severity appropriateness, scope accuracy, example validity, fix strategy applicability, and codebase compliance. Use when users want to create a new rule from scratch, update an existing rule's frontmatter or body, audit a rule for continued relevance, adjust a rule's severity, or verify that a rule is still followed in the codebase. Make sure to use this skill whenever the user mentions rule creation, rule authoring, rule scaffolding, rule updating, rule auditing, rule review, severity adjustment, or wants to package a binding constraint as an always-on context rule, even if they don't explicitly ask for a "rule creator." Do NOT trigger on general coding questions, skill creation (use ai-skill-upsert), workflow creation (use ai-workflow-upsert), AGENTS.md generation (use agent-file-upsert), README generation (use readme-upsert), or general code review — this skill is for rule lifecycle management only.

## Metadata

| Field | Value |
|-------|-------|
| Name | `rule-upsert` |
| Category | `ai` |
| Version | `1.0.0` |
| Status | `` |
| Owner |  |

## Related Skills
- **ai-skill-upsert** (skill, sibling) — Full lifecycle management for skills (create/update/convert/eval). Same upsert family — handles skill artifacts, not rules.
- **ai-workflow-upsert** (skill, sibling) — Full lifecycle management for workflows (create/update/convert). Same upsert family — handles workflow artifacts, not rules.
- **agent-file-upsert** (skill, sibling) — Generates and updates AGENTS.md hierarchies. Same upsert family — handles agent documentation files, not rules.
- **readme-upsert** (skill, sibling) — Generates and updates README.md files. Same upsert family — handles human-facing documentation, not rules.
- **base-ai-guidance** (template, base-framework) — Shared framework for creating all AI guidance types
- **research-phase** (template, shared-include) — Shared research phase — search for existing artifacts before creating or improving
- **audit-methodology** (template, shared-include) — Shared audit methodology — propose-confirm-apply discipline for updates

---

- **Full skill**: [`skills/ai/rule-upsert/SKILL.md`](skills/ai/rule-upsert/SKILL.md)
- **Install**: `npx skills add levonk/skills-releases`
- **Generated**: 2026-07-12T01:27:53Z
