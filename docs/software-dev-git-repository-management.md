<!-- Managed by skills-src build pipeline. Do not edit; changes will be overwritten. -->
<!-- Generated from SKILL.md frontmatter + body by `just catalog` -->

# Skills: the script is materialized into scripts/cli-tool-discovery.sh at build time

> Category: **software-dev** · Status: ready · Version: 1.8.0

Comprehensive git repository workflow for status analysis, change organization, and commit management with secret scanning and rollback-safe ordering. Use when needing to organize and commit changes, manage git workflow, batch commits, push with backup branches, tag releases, or make a single checkpoint commit. Triggers on 'commit changes', 'organize git', 'git workflow', 'batch commit', 'checkpoint commit', or 'repository management'. Do NOT trigger on general git questions, branch creation, or merge requests.

## Metadata

| Field | Value |
|-------|-------|
| Name | `git-repository-management` |
| Category | `software-dev` |
| Version | `1.8.0` |
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

## Quick Start

```bash
# The skill orchestrates the workflow with minimal AI-script handoffs
# This is an AI skill - invoke it through your AI agent interface

# Workflow (3-4 handoffs total, +1-2 if the target is not a git repo):
# 0. (conditional) If git-collect.sh emits NOT_A_GIT_REPO, AI runs git-repo-init.bash then re-collects
# 1. AI calls git-collect.sh - gets all data (changes + quality checks)
# 2. AI analyzes data and makes decisions
# 3. AI calls git-commit-batch.sh with all commit decisions (auto-creates pre/post tags)
# 4. AI calls git-push.sh to push (handles divergence automatically — never manually rebase)
# 5. AI calls git-tag.sh if the user requests an additional tag

./scripts/git-collect.sh [--json] [path]           # Collect all data in one call (text or JSON; emits NOT_A_GIT_REPO + exit 2 if target is not a git repo)
bash ./scripts/git-repo-init.bash --init-only [TARGET-DIR]  # (conditional) Full CREATE init on a non-git dir; run from inside the dir; --dry-run -v to preview
./scripts/git-commit-batch.sh [--slug <slug>] [--amend] [--dry-run] [path]  # Execute all commits + auto-tag (or validate with --dry-run)
./scripts/git-push.sh [remote] [branch] [path] [--slug <slug>]  # Push commits + tags
./scripts/git-tag.sh --category <cat> --slug <slug> [--message <msg>] [path]  # Tag HEAD (user-requested only)
./scripts/git-rollback.sh --to <tag-or-sha> [--slug <slug>] [path]  # Roll back to a tag/SHA (creates backup branch)
```

> **Working in a subdirectory?** All scripts automatically discover the repository root from any subdirectory. You can also pass the target path explicitly:
> ```bash
> ./scripts/git-collect.sh /path/to/repo
> ```
>
> **Why:** Git commands like `status`, `add`, and `commit` operate on the repository root. The scripts automatically resolve the root from any subdirectory.

## Core Workflow

### Architecture: Hybrid AI + Deterministic Script

This skill uses a **hybrid architecture** where:

- **Bash Script (git-repo-manager.sh)**: Deterministic operations only
  - Git operations (status, add, commit, push)
  - Data collection (file lists, diffs, test results)
  - Quality check execution (lint, test)
  - Returns structured data for AI analysis

- **AI Agent (this skill)**: Intelligent decision-making
  - Analyze changes and group them into logical commits
  - Write meaningful commit messages (title + body)
  - Decide how to handle build/test failures (fix vs skip vs abort)
  - Create implementation plans with explicit file groupings

### Workflow Phases

The workflow consists of 7 phases: Script Discovery, Repository Initialization (conditional), Data Collection, AI Analysis & Planning, Execution, Documentation & Summary, plus optional Tagging. For detailed phase descriptions including Phase 0 (Script Discovery), Phase 1 (Repository Initialization — conditional, handles non-git targets via the bundled `git-repo-init.bash`), Phase 2 (Data Collection), Phase 3 (AI Analysis & Planning with rollback-safe ordering and submodule handling), Phase 4 (Execution), Phase 5 (Documentation), and Phase 6 (Tagging), see [Workflow Phases](references/workflow-phases.md).

> **Pre-Task Commit Checkpoint**: The checkpoint protocol used before the first commit in a batch (and before subagent dispatch in `execute-upsert`) is shared via the `pre-task-commit-checkpoint` include. Both this skill and `execute-upsert` inline the same protocol, so consumers only need the checkpoint logic documented once.

## Related Skills
- **project-detection** (skill, dependency) — For detecting project types and environment management systems
- **code-quality-validation** (skill, related) — For comprehensive code quality checks that integrate with git workflow
- **ai-development-loop** (skill, dependent) — Development loop depends on this skill for commit organization
- **execute-upsert** (skill, dependent) — Project execution controller uses the pre-task commit checkpoint protocol (shared via include) before each subagent dispatch
- **base-ai-guidance** (skill, base-framework) — Base AI guidance framework for all AI skills

---

- **Full skill**: [`skills/software-dev/git-repository-management/SKILL.md`](skills/software-dev/git-repository-management/SKILL.md)
- **Install**: `pnpm dlx skills add levonk/skills-releases`
- **Generated**: 2026-07-20T22:00:35Z
