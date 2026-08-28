<!-- Managed by skills-src build pipeline. Do not edit; changes will be overwritten. -->
<!-- Generated from SKILL.md frontmatter + body by `just catalog` -->

# Skills: the script is materialized into scripts/cli-tool-discovery.sh at build time

> Category: **general** · Status:  · Version: 1.0.0

End-of-day workspace orchestrator that runs maintenance, review, and planning before signing off. Sweeps all git repos (fetch, prune, stale branches, devbox refresh), reviews AI sessions for skill-improvement opportunities, compiles a daily summary of accomplishments, updates tickets with progress, crafts a scrum update, reviews the calendar, and produces a prioritized plan for the next day. Optionally identifies and prompts to launch long-running background work for overnight execution. Use when the user says "sign off", "done for the day", "good night", "wrapping up", "end of day", "calling it a day", "signing off", "done for today", "night", "bedtime", "see you tomorrow", or otherwise indicates they are finishing work for the day and want a closing routine. Make sure to use this skill whenever the user mentions ending their workday, doing end-of-day chores, end-of-day maintenance, daily wrap-up, closing out the day, or preparing for tomorrow, even if they don't explicitly say "sign off." Do NOT trigger on landing a single development session (use ai-land-plane), committing changes in a single repo (use git-repository-management or chore-ai20-vcs), evening journaling/reflection (use journal-daily-evening), or general planning questions without the end-of-day context.

## Metadata

| Field | Value |
|-------|-------|
| Name | `sign-off` |
| Category | `general` |
| Version | `1.0.0` |
| Status | `` |
| Owner |  |

## References

- [`references/process.md`](references/process.md) — detailed phase-by-phase process with decision points
- [`references/scrum-update.md`](references/scrum-update.md) — scrum update format, examples, and tone guidance
- [`references/next-day-planning.md`](references/next-day-planning.md) — planning methodology and prioritized task list template
- [`references/ai-session-review.md`](references/ai-session-review.md) — how to review AI sessions for skill-improvement opportunities

---

## Related Skills
- **base-ai-guidance** (template, base-framework) — Shared framework for creating all AI guidance types
- **base-frontmatter** (template, structure-standard) — Standard frontmatter template for AI guidance files
- **git-repository-management** (skill, dependency) — Commits any pending changes found during the git sweep before declaring repos clean
- **handoff** (skill, dependency) — Creates handoff documents for any in-progress work that will continue tomorrow
- **** (, complement) — Lands a single active development session — sign-off calls this per-repo if the sweep finds uncommitted work in a repo with an active session
- **repository-health-review** (skill, complement) — Deeper health audit for repos flagged by the sweep — sign-off surfaces these as candidates, the user chooses whether to run the full review
- **task-triage** (skill, dependency) — Prioritizes tomorrow's work using the 26-tier framework — sign-off feeds it the compiled task list from tickets, handoffs, and ongoing projects
- **ai-guidance-improver** (skill, complement) — Acts on AI session review findings — sign-off identifies improvement opportunities, ai-guidance-improver implements them

---

- **Full skill**: [`skills/general/sign-off/SKILL.md`](skills/general/sign-off/SKILL.md)
- **Install**: `pnpm dlx skills add levonk/skills-releases`
- **Generated**: 2026-08-28T23:22:25Z
