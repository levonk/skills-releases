<!-- Managed by skills-src build pipeline. Do not edit; changes will be overwritten. -->
<!-- Generated from SKILL.md frontmatter + body by `just catalog` -->

# Skills: the script is materialized into scripts/cli-tool-discovery.sh at build time

> Category: **ai** · Status:  · Version: 2.6.0

Capture and restore AI conversation context for seamless work continuation across sessions. Use when needing to preserve conversation state, decisions made, and work progress to start a fresh AI session with full context without requiring re-explanation.

## Metadata

| Field | Value |
|-------|-------|
| Name | `handoff` |
| Category | `ai` |
| Version | `2.6.0` |
| Status | `` |
| Owner |  |

## Related Skills
- **base-ai-guidance** (template, base-framework) — Shared framework for creating all AI guidance types
- **base-frontmatter** (template, structure-standard) — Standard frontmatter template for AI guidance files
- **work-lifecycle** (template, dependency) — Shared two-stage lifecycle protocol (todo → archive) for handoff documents — inlined so handoff archives from todo/ to archive/YYYY/MM/ via git mv when all DoD tasks are [x], with frontmatter dates (created, completed, last-activity). Supports audience variants (agent vs human) — human handoffs route to .agents/handoffs/human/ when a task is blocked on human-only action, include self-contained Project/Feature/Current State context, and create a GitHub issue (labeled human-handoff) for visibility
- **gh-posting-guard** (template, dependency) — Shared guard for posting GitHub issue bodies via gh --body-file — required when human handoffs create GitHub issues, prevents the two corruption modes (literal \\n and stripped backticks) that ship broken posts
- **** (, complement) — Mermaid syntax conventions (quoted decision labels, <br/> inside quotes) followed by this skill's workflow diagram
- **git-repository-management** (skill, dependency) — Commits pending work before context capture and commits the handoff document after save, so the handoff's git commit hash pins a clean, reproducible repo state

---

- **Full skill**: [`skills/ai/handoff/SKILL.md`](skills/ai/handoff/SKILL.md)
- **Install**: `pnpm dlx skills add levonk/skills-releases`
- **Generated**: 2026-08-17T03:55:48Z
