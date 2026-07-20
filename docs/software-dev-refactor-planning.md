<!-- Managed by skills-src build pipeline. Do not edit; changes will be overwritten. -->
<!-- Generated from SKILL.md frontmatter + body by `just catalog` -->

# Skills: the script is materialized into scripts/cli-tool-discovery.sh at build time

> Category: **software-dev** · Status: ready · Version: 1.0.0

Plan and execute systematic evolutionary refactors based on Michael Feathers' 'Working Effectively with Legacy Code'. Analyzes codebases for code smells, security issues, legacy dependencies, and pattern opportunities, then produces a prioritized task plan executed in safe increments with verification gates. Use when users want to plan a refactor, refactor existing code, migrate legacy code, analyze code smells, or apply 'Working Effectively with Legacy Code' techniques. Triggers on 'plan a refactor', 'refactor this code', 'legacy code migration', 'code smell analysis', 'working effectively with legacy code', 'evolutionary refactor', or 'technical debt remediation plan'. Do NOT trigger on general coding questions, single bug fixes, feature implementation, or routine code review — this skill is for multi-step refactor planning, not everyday development.

## Metadata

| Field | Value |
|-------|-------|
| Name | `refactor-planning` |
| Category | `software-dev` |
| Version | `1.0.0` |
| Status | `ready` |
| Owner | https://github.com/levonk |

## Quick Start

```
1. Verify clean state — typecheck, build, lint, tests pass; git tree clean; on a feature branch
2. Analyze the codebase — identify code smells, security issues, legacy tech, pattern opportunities
3. Create a prioritized task list — urgent first, foundational second, dependent/low-priority last
4. Execute tasks in order — verify (typecheck/build/lint/test) after each step, commit after each step
5. Confirm clean state at the end — same gates as step 1
```

> **Why evolutionary?** Big-bang refactors break things silently. Small,
> verified increments keep the system working at every step and make rollback
> trivial (revert the last commit).

## Related Skills
- **code-quality-validation** (skill, related) — For comprehensive code quality checks that validate each refactor step
- **git-repository-management** (skill, related) — For commit organization and rollback-safe checkpoints between refactor steps
- **** (, reference) — Architectural patterns and design principles to apply during refactoring

---

- **Full skill**: [`skills/software-dev/refactor-planning/SKILL.md`](skills/software-dev/refactor-planning/SKILL.md)
- **Install**: `pnpm dlx skills add levonk/skills-releases`
- **Generated**: 2026-07-20T22:00:35Z
