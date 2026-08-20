<!-- Managed by skills-src build pipeline. Do not edit; changes will be overwritten. -->
<!-- Generated from SKILL.md frontmatter + body by `just catalog` -->

# Skills: the script is materialized into scripts/cli-tool-discovery.sh at build time

> Category: **ai** · Status: ready · Version: 1.13.0

Comprehensive git repository workflow for status analysis, change organization, and commit management with secret scanning and rollback-safe ordering. Use when needing to organize and commit changes, manage git workflow, batch commits, push with backup branches, tag releases, or make a single checkpoint commit. Triggers on 'commit changes', 'organize git', 'git workflow', 'batch commit', 'checkpoint commit', or 'repository management'. Do NOT trigger on general git questions, branch creation, or merge requests.

## Metadata

| Field | Value |
|-------|-------|
| Name | `git-repository-management` |
| Category | `ai` |
| Version | `1.13.0` |
| Status | `ready` |
| Owner | https://github.com/levonk |

## Tags
- `ai/skill`
- `git`
- `version-control`
- `repository-management`
- `commit-organization`
- `tagging`
- `rollback-safety`

## Related Skills
- **project-detection** (skill, dependency) — For detecting project types and environment management systems
- **code-quality-validation** (skill, related) — For comprehensive code quality checks that integrate with git workflow
- **ai-development-loop** (skill, dependent) — Development loop depends on this skill for commit organization
- **execute-upsert** (skill, dependent) — Project execution controller uses the pre-task commit checkpoint protocol (shared via include) before each subagent dispatch
- **base-ai-guidance** (skill, base-framework) — Base AI guidance framework for all AI skills

---

- **Full skill**: [`skills/ai/git-repository-management/SKILL.md`](skills/ai/git-repository-management/SKILL.md)
- **Install**: `pnpm dlx skills add levonk/skills-releases`
- **Generated**: 2026-08-20T21:38:06Z
