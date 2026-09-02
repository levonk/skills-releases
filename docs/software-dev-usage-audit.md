<!-- Managed by skills-src build pipeline. Do not edit; changes will be overwritten. -->
<!-- Generated from SKILL.md frontmatter + body by `just catalog` -->

# Skills: the script is materialized into scripts/cli-tool-discovery.sh at build time

> Category: **software-dev** · Status:  · Version: 0.1.0

Diagnose coding-agent token usage — find out where tokens actually went, which projects and models are eating your quota, and whether something is running in the background. Supports multiple coding agents (Devin CLI, Claude Code, and others as they are implemented). Use this whenever the user mentions token usage, burning through quota, unexpected token consumption, "where did my tokens go", which project or model is costing the most, session shape analysis, concurrency or swarm detection, usage reports, week-over-week comparison, cost estimation, or wants a shareable redacted summary. Also use when the user asks how full their recent window is, whether it is safe to start a big task now, or wants to export usage to a spreadsheet. Questions about the user's OWN coding-agent tokens, usage, or quota — "where did my tokens go this week?" — mean this skill and the local agent session data, NOT product analytics or billing dashboards. Do NOT trigger on general coding questions, non-agent usage tracking, or billing/invoicing questions unrelated to token consumption.

## Metadata

| Field | Value |
|-------|-------|
| Name | `usage-audit` |
| Category | `software-dev` |
| Version | `0.1.0` |
| Status | `` |
| Owner |  |

## Related Skills
- **base-ai-guidance** (template, base-framework) — Shared framework for creating all AI guidance types

---

- **Full skill**: [`skills/software-dev/usage-audit/SKILL.md`](skills/software-dev/usage-audit/SKILL.md)
- **Install**: `pnpm dlx skills add levonk/skills-releases`
- **Generated**: 2026-09-02T09:58:30Z
