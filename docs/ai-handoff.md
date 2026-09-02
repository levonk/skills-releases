<!-- Managed by skills-src build pipeline. Do not edit; changes will be overwritten. -->
<!-- Generated from SKILL.md frontmatter + body by `just catalog` -->

# Skills: the script is materialized into scripts/cli-tool-discovery.sh at build time

> Category: **ai** · Status:  · Version: 2.8.0

Capture and restore AI conversation context for seamless work continuation across sessions. Use when needing to preserve conversation state, decisions made, and work progress to start a fresh AI session with full context without requiring re-explanation.

## Metadata

| Field | Value |
|-------|-------|
| Name | `handoff` |
| Category | `ai` |
| Version | `2.8.0` |
| Status | `` |
| Owner |  |

## Related Skills
- **base-ai-guidance** (template, base-framework) — Shared framework for creating all AI guidance types
- **base-frontmatter** (template, structure-standard) — Standard frontmatter template for AI guidance files
- **work-lifecycle** (template, dependency) — Shared two-stage lifecycle protocol (todo → archive) for handoff documents — inlined so handoff archives from todo/ to archive/YYYY/MM/ via git mv when all DoD tasks are [x], with frontmatter dates (created, completed, last-activity). Supports audience variants (agent vs human) — human handoffs route to .agents/handoffs/human/ when a task is blocked on human-only action
- **** (, complement) — Mermaid syntax conventions (quoted decision labels, <br/> inside quotes) followed by this skill's workflow diagram
- **git-repository-management** (skill, dependency) — Commits pending work before context capture and commits the handoff document after save, so the handoff's git commit hash pins a clean, reproducible repo state
- **execute-upsert** (skill, dependency) — The execution skill that handoff always defers to. The handoff's Execution Plan block maps each task to an execute-upsert story with a type tag (trivial/standard/research), base SHA, and per-story DoD. execute-upsert enforces worktree-per-story, checkpoint commits, story branches, PRs, and clean-tree-before-stop uniformly across all task types
- **requirements-upsert** (skill, consult) — Consult the requirements ledger when capturing handoff context so the next session knows the project's durable constraints
- **** (, dependency) — Provides the restart-proof-state concept page that the handoff system's state-as-file, append-only-event-log, fold-based-derivation principle is based on. The handoff file is just another state file, not a special artifact

---

- **Full skill**: [`skills/ai/handoff/SKILL.md`](skills/ai/handoff/SKILL.md)
- **Install**: `pnpm dlx skills add levonk/skills-releases`
- **Generated**: 2026-09-02T09:52:56Z
