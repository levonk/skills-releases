<!-- Managed by skills-src build pipeline. Do not edit; changes will be overwritten. -->
<!-- Generated from SKILL.md frontmatter + body by `just catalog` -->

# Agent File Upsert

> Category: **ai** · Status: ready · Version: 2.0.0

Generate hierarchical AGENTS.md documentation for AI agents working in codebases. Use when onboarding an AI agent to an existing codebase (Brownfield) to establish context and conventions. Triggers on requests like "create AGENTS.md", "generate agent documentation", "help AI understand this codebase", or "set up agent guidance for this repo".

## Metadata

| Field | Value |
|-------|-------|
| Name | `agent-file-upsert` |
| Category | `ai` |
| Version | `2.0.0` |
| Status | `ready` |
| Owner | https://github.com/levonk |

## Tags
- `ai/skill`
- `software-development`
- `documentation`
- `agents`
- `brownfield`
- `hierarchical-docs`

## Quick Start

When invoked, this skill analyzes the codebase and creates:
- `AGENTS.md` (Root)
- `apps/**/AGENTS.md` (Sub-projects)
- `packages/**/AGENTS.md` (Sub-packages)
- `internal-docs/oos/` (Out-of-scope documentation)

## Instructions

- **Token Efficiency**: Prioritize small, actionable guidance over encyclopedic text
- **Examples**: Always provide real file paths as examples
- **Commands**: Ensure commands are copy-paste ready
- **Hierarchy**: Agents should read the closest `AGENTS.md` first
- **Structured Data**: Use markdown tables for any tabular data in AGENTS.md files (categories, compliance scores, file inventories, etc.). Markdown tables are readable by both humans and AI agents without learning a custom format. Avoid JSON blocks, TOON, or other custom notations in documentation — markdown tables are the standard.

Example:
```markdown
| Category | Rating | Status | Source Files |
|----------|--------|--------|--------------|
| Auth     | 100%   | ✅ Full | src/auth/    |
| API      | 75%    | ⚠️ Partial | src/api/  |
```

## Related Skills
- **readme-upsert** (skill, related) — Generate or update README documentation with similar hierarchical principles
- **ai-skill-upsert** (skill, complement) — For creating new AI skills — pairs with agent-file-upsert for full AI guidance setup
- **base-ai-guidance** (template, base-framework) — Shared framework for creating all AI guidance types

---

- **Full skill**: [`skills/ai/agent-file-upsert/SKILL.md`](skills/ai/agent-file-upsert/SKILL.md)
- **Install**: `npx skills add levonk/skills-releases`
- **Generated**: 2026-07-08T09:27:24Z
