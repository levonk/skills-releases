<!-- Managed by skills-src build pipeline. Do not edit; changes will be overwritten. -->
<!-- Generated from SKILL.md frontmatter + body by `just catalog` -->

# Skills: the script is materialized into scripts/cli-tool-discovery.sh at build time

> Category: **execution** · Status:  · Version: 1.5.0

Generic project execution controller that drives feature implementation from request to completion through a self-update → assess → establish-tech → PRD → tasks → execute pipeline. Self-updates all skills to the latest version before starting, establishes the project's tech stack as a binding constraint for all subagents (so they never use npm when the project uses pnpm, never use npx when the project uses pnpm dlx, etc.), assesses request size, creates a PRD if one doesn't exist (for large requests), breaks the PRD into parallelizable task stories, executes each story via subagents with a per-story code review before commit, updates the PRD and task files when scope changes, and updates project documentation as the final phase. Runs as much as possible: when a story is blocked, marks it [!] Blocked with the reason in the index and proceeds to the next runnable story, then presents a final blocker report with the question, the options, the recommendation, and why it was recommended. Use when users want to implement a feature or change that is large enough to warrant structured planning, when they say "execute", "implement this feature", "build this project", "run the project executor", "drive this to completion", or reference a PRD or task list they want executed. Do NOT trigger on quick fixes, single-file edits, bug fixes with a known root cause, or questions about how something works — this skill is for multi-step project execution, not trivial changes.

## Metadata

| Field | Value |
|-------|-------|
| Name | `execute-upsert` |
| Category | `execution` |
| Version | `1.5.0` |
| Status | `` |
| Owner |  |

## Overview

This skill is a generalized version of the Infrahub project controller
(`do-proj-infrahub.md`). Where the Infrahub controller assumes tasks already
exist and simply chains subagents through them, this skill has the
intelligence to:

1. **Self-update** all skills to the latest version before starting
2. **Assess** whether a request is large enough to warrant the full pipeline
3. **Establish technologies** — detect the project's tech stack and inject it
   as a binding constraint into every subagent dispatch (so subagents never
   use npm when the project uses pnpm, never use npx when the project uses
   pnpm dlx, etc.)
4. **Create a PRD** if one doesn't exist (for large requests)
5. **Break the PRD into tasks** if task files don't exist
6. **Execute tasks** via subagents, with a per-story code review before
   commit, chaining through the project
7. **Update the PRD** when scope changes, and regenerate affected tasks
8. **Update documentation** (project docs + PRD/task files) as the final phase

## Related Skills
- **base-ai-guidance** (template, base-framework) — Shared framework for creating all AI guidance types
- **trigger-guard** (template, over-triggering-guard) — Prevents triggering on requests that don't need the full pipeline
- **tech-stack-table** (template, dependency) — Canonical tech-stack choices table — inlined into execute-upsert at build time so the skill carries the authoritative pnpm/Vitest/ESLint/devbox/just choices and never reaches for npm/npx/yarn/Jest/Biome
- **devbox-remediation** (template, dependency) — Shared devbox missing-package remediation guidance — inlined so subagents add missing tools to devbox.json instead of installing on the host
- **** (, complement) — Source workflow for PRD creation — content inlined at build time into references/greenfield-prd.md (not a runtime dependency; workflows are not published to distribution repos)
- **** (, complement) — Source workflow for task breakdown — content inlined at build time into references/tasks-from-prd.md (not a runtime dependency; workflows are not published to distribution repos)
- **** (, complement) — Source workflow for task execution — content inlined at build time into references/tasks-processor.md (not a runtime dependency; workflows are not published to distribution repos)
- **git-repository-management** (skill, dependency) — Provides the commit checkpoint protocol used before each subagent dispatch — shared via pre-task-commit-checkpoint include. Execute-upsert also runs it at story start (to flush any dirty repo state before the story begins) and at story finish (to commit the story's work), and adds per-story tags under tags/auto/execute-upsert/YYYY/MM/{story-id+slug}-{pre,post} via git-tag.sh so the story boundaries are greppable separately from the grm skill's own tags/auto/grm/... tags. grm also runs scan-artifacts.sh before every commit to catch identity leaks
- **handoff** (skill, dependency) — Invoked when execution stops with work remaining (blocked stories, context limit, user pause) — captures context so a fresh session can resume from the task index. Shared via disruption-handoff include
- **project-detection** (skill, dependency) — Bundled via includeTree for offline availability. Execute-upsert runs it in Phase 3 (Establish Technologies) to detect the project's package manager, build system, test runner, and linter. The detected tech stack becomes a binding constraint injected into every subagent dispatch
- **code-review-guidance** (skill, dependency) — Bundled via includeTree for offline availability. Execute-upsert dispatches a review subagent that follows this skill's checklist on each story commit before final commit. Supports automated mode (default, preserves autonomous execution) and human-in-the-loop mode (configurable via skill-config.toml)

---

- **Full skill**: [`skills/execution/execute-upsert/SKILL.md`](skills/execution/execute-upsert/SKILL.md)
- **Install**: `pnpm dlx skills add levonk/skills-releases`
- **Generated**: 2026-08-01T22:01:31Z
