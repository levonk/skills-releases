<!-- Managed by skills-src build pipeline. Do not edit; changes will be overwritten. -->
<!-- Generated from SKILL.md frontmatter + body by `just catalog` -->

# Skills: the script is materialized into scripts/cli-tool-discovery.sh at build time

> Category: **software-dev** · Status: ready · Version: 1.6.0

Comprehensive git repository workflow for status analysis, change organization, and commit management with secret scanning and rollback-safe ordering. Use when needing to organize and commit changes, manage git workflow, batch commits, push with backup branches, or tag releases. Triggers on 'commit changes', 'organize git', 'git workflow', 'batch commit', or 'repository management'.

## Metadata

| Field | Value |
|-------|-------|
| Name | `git-repository-management` |
| Category | `software-dev` |
| Version | `1.6.0` |
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

# Workflow (3-4 handoffs total):
# 1. AI calls git-collect.sh - gets all data (changes + quality checks)
# 2. AI analyzes data and makes decisions
# 3. AI calls git-commit-batch.sh with all commit decisions (auto-creates pre/post tags)
# 4. AI calls git-push.sh if needed (pushes commits + auto-tags via --follow-tags)
# 5. AI calls git-tag.sh if the user requests an additional tag

./scripts/git-collect.sh [path]              # Collect all data in one call
./scripts/git-commit-batch.sh [--slug <slug>] [path]  # Execute all commits + auto-tag
./scripts/git-push.sh [remote] [branch] [path] [--slug <slug>]  # Push commits + tags
./scripts/git-tag.sh --category <cat> --slug <slug> [--message <msg>] [path]  # Tag HEAD (user-requested only)
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

The workflow consists of 5 phases: Script Discovery, Data Collection, AI Analysis & Planning, Execution, and Documentation & Summary, plus optional Tagging. For detailed phase descriptions including Phase 0 (Script Discovery), Phase 1 (Data Collection), Phase 2 (AI Analysis & Planning with rollback-safe ordering and submodule handling), Phase 3 (Execution), Phase 4 (Documentation), and Phase 5 (Tagging), see [Workflow Phases](references/workflow-phases.md).

> **Pre-Task Commit Checkpoint**: The checkpoint protocol used before the first commit in a batch (and before subagent dispatch in `execute-upsert`) is shared via the `pre-task-commit-checkpoint` include. Both this skill and `execute-upsert` inline the same protocol, so consumers only need the checkpoint logic documented once.

## Related Skills
- **project-detection** (skill, dependency) — For detecting project types and environment management systems
- **code-quality-validation** (skill, related) — For comprehensive code quality checks that integrate with git workflow
- **ai-development-loop** (skill, dependent) — Development loop depends on this skill for commit organization
- **execute-upsert** (skill, dependent) — Project execution controller uses the pre-task commit checkpoint protocol (shared via include) before each subagent dispatch
- **base-ai-guidance** (skill, base-framework) — Base AI guidance framework for all AI skills

---

- **Full skill**: [`skills/software-dev/git-repository-management/SKILL.md`](skills/software-dev/git-repository-management/SKILL.md)
- **Install**: `npx skills add levonk/skills-releases`
- **Generated**: 2026-07-12T01:27:53Z
