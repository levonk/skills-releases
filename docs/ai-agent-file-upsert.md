<!-- Managed by skills-src build pipeline. Do not edit; changes will be overwritten. -->
<!-- Generated from SKILL.md frontmatter + body by `just catalog` -->

# Skills: the script is materialized into scripts/cli-tool-discovery.sh at build time

> Category: **ai** · Status: ready · Version: 3.1.0

Generate or update hierarchical AGENTS.md documentation for AI agents working in codebases. Context-aware — detects and follows the project's existing convention (AGENTS.md, CLAUDE.md, AGENT.md, or combinations via referral/symlink). When updating existing docs, runs delta analysis (git changes since last update) via a script + subagent to extract positive findings, anti-patterns, and improvement candidates. Use when onboarding an AI agent to an existing codebase (Brownfield) to establish context and conventions, or when updating existing agent documentation after significant repo changes. Triggers on requests like "create AGENTS.md", "create CLAUDE.md", "generate agent documentation", "update AGENTS.md", "help AI understand this codebase", or "set up agent guidance for this repo". Do NOT trigger on README generation (use readme-upsert), general coding questions, or skill creation (use ai-skill-upsert).

## Metadata

| Field | Value |
|-------|-------|
| Name | `agent-file-upsert` |
| Category | `ai` |
| Version | `3.1.0` |
| Status | `ready` |
| Owner | https://github.com/levonk |

## Tags
- `ai/skill`
- `software-development`
- `documentation`
- `agents`
- `brownfield`
- `hierarchical-docs`
- `convention-detection`
- `delta-analysis`

## Quick Start

When invoked, this skill analyzes the codebase and creates or updates:
- `AGENTS.md` (Root — primary; CLAUDE.md/AGENT.md maintained as referral or symlink)
- `apps/**/AGENTS.md` (Sub-projects)
- `packages/**/AGENTS.md` (Sub-packages)
- `internal-docs/oos/` (Out-of-scope documentation)
- `internal-docs/improvements/` (Potential improvements — INDEX.md + date-stamped files)
- `internal-docs/anti-patterns/` (Things NOT to do — INDEX.md with 🛑 + date-stamped files)

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
- **ai-guidance-improver** (skill, complement) — Cross-file analysis and system-wide consistency for AI guidance — use when agent-file-upsert surfaces conflicts that span multiple guidance files
- **base-ai-guidance** (template, base-framework) — Shared framework for creating all AI guidance types
- **research-phase** (template, shared-include) — Shared research phase — search for existing artifacts and anti-patterns before creating or improving

---

- **Full skill**: [`skills/ai/agent-file-upsert/SKILL.md`](skills/ai/agent-file-upsert/SKILL.md)
- **Install**: `npx skills add levonk/skills-releases`
- **Generated**: 2026-07-16T08:35:31Z
