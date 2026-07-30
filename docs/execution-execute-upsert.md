<!-- Managed by skills-src build pipeline. Do not edit; changes will be overwritten. -->
<!-- Generated from SKILL.md frontmatter + body by `just catalog` -->

# Skills: the script is materialized into scripts/cli-tool-discovery.sh at build time

> Category: **execution** · Status:  · Version: 1.2.0

Generic project execution controller that drives feature implementation from request to completion through a PRD → tasks → execute pipeline. Assesses request size, creates a PRD if one doesn't exist (for large requests), breaks the PRD into parallelizable task stories, executes each story via subagents, updates the PRD and task files when scope changes, and updates project documentation as the final phase. Runs as much as possible: when a story is blocked, marks it [!] Blocked with the reason in the index and proceeds to the next runnable story, then presents a final blocker report with the question, the options, the recommendation, and why it was recommended. Use when users want to implement a feature or change that is large enough to warrant structured planning, when they say "execute", "implement this feature", "build this project", "run the project executor", "drive this to completion", or reference a PRD or task list they want executed. Do NOT trigger on quick fixes, single-file edits, bug fixes with a known root cause, or questions about how something works — this skill is for multi-step project execution, not trivial changes.

## Metadata

| Field | Value |
|-------|-------|
| Name | `execute-upsert` |
| Category | `execution` |
| Version | `1.2.0` |
| Status | `` |
| Owner |  |

## Overview

This skill is a generalized version of the Infrahub project controller
(`do-proj-infrahub.md`). Where the Infrahub controller assumes tasks already
exist and simply chains subagents through them, this skill has the
intelligence to:

1. **Assess** whether a request is large enough to warrant the full pipeline
2. **Create a PRD** if one doesn't exist (for large requests)
3. **Break the PRD into tasks** if task files don't exist
4. **Execute tasks** via subagents, chaining through the project
5. **Update the PRD** when scope changes, and regenerate affected tasks
6. **Update documentation** (project docs + PRD/task files) as the final phase

## Related Skills
- **base-ai-guidance** (template, base-framework) — Shared framework for creating all AI guidance types
- **trigger-guard** (template, over-triggering-guard) — Prevents triggering on requests that don't need the full pipeline
- **** (, complement) — Source workflow for PRD creation — content inlined at build time into references/greenfield-prd.md (not a runtime dependency; workflows are not published to distribution repos)
- **** (, complement) — Source workflow for task breakdown — content inlined at build time into references/tasks-from-prd.md (not a runtime dependency; workflows are not published to distribution repos)
- **** (, complement) — Source workflow for task execution — content inlined at build time into references/tasks-processor.md (not a runtime dependency; workflows are not published to distribution repos)
- **git-repository-management** (skill, dependency) — Provides the commit checkpoint protocol used before each subagent dispatch — shared via pre-task-commit-checkpoint include. Execute-upsert also runs it at story start (to flush any dirty repo state before the story begins) and at story finish (to commit the story's work), and adds per-story tags under tags/auto/execute-upsert/YYYY/MM/{story-id+slug}-{pre,post} via git-tag.sh so the story boundaries are greppable separately from the grm skill's own tags/auto/grm/... tags
- **handoff** (skill, dependency) — Invoked when execution stops with work remaining (blocked stories, context limit, user pause) — captures context so a fresh session can resume from the task index. Shared via disruption-handoff include

---

- **Full skill**: [`skills/execution/execute-upsert/SKILL.md`](skills/execution/execute-upsert/SKILL.md)
- **Install**: `pnpm dlx skills add levonk/skills-releases`
- **Generated**: 2026-07-30T19:45:30Z
