<!-- Managed by skills-src build pipeline. Do not edit; changes will be overwritten. -->
<!-- Generated from SKILL.md frontmatter + body by `just catalog` -->

# Skills: the script is materialized into scripts/cli-tool-discovery.sh at build time

> Category: **ai** · Status: ready · Version: 3.1.0

Generate or update hierarchical AGENTS.md documentation for AI agents working in codebases. Context-aware — detects and follows the project's existing convention (AGENTS.md, CLAUDE.md, AGENT.md, or combinations via referral/symlink). When updating existing docs, runs delta analysis (git changes since last update) via a script + subagent to extract positive findings, anti-patterns, and improvement candidates. Use when onboarding an AI agent to an existing codebase (Brownfield) to establish context and conventions, or when updating existing agent documentation after significant repo changes. Triggers on requests like "create AGENTS.md", "create CLAUDE.md", "generate agent documentation", "update AGENTS.md", "help AI understand this codebase", or "set up agent guidance for this repo". Do NOT trigger on README generation (use readme-upsert), general coding questions, or skill creation (use ai-upsert).

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

## Related Skills
- **readme-upsert** (skill, related) — Generate or update README documentation with similar hierarchical principles
- **ai-upsert** (skill, complement) — For creating new AI skills — pairs with agent-file-upsert for full AI guidance setup
- **ai-guidance-improver** (skill, complement) — Cross-file analysis and system-wide consistency for AI guidance — use when agent-file-upsert surfaces conflicts that span multiple guidance files
- **base-ai-guidance** (template, base-framework) — Shared framework for creating all AI guidance types
- **research-phase** (template, shared-include) — Shared research phase — search for existing artifacts and anti-patterns before creating or improving
- **** (, complement) — Mermaid syntax conventions (quoted decision labels, <br/> inside quotes) followed by this skill's workflow diagram

---

- **Full skill**: [`skills/ai/agent-file-upsert/SKILL.md`](skills/ai/agent-file-upsert/SKILL.md)
- **Install**: `pnpm dlx skills add levonk/skills-releases`
- **Generated**: 2026-08-20T21:35:57Z
