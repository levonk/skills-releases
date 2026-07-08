---
name: git-repository-management
description: Comprehensive git repository workflow for status analysis, change organization, and commit management with secret scanning and rollback-safe ordering. Use when needing to organize and commit changes, manage git workflow, batch commits, push with backup branches, or tag releases. Triggers on 'commit changes', 'organize git', 'git workflow', 'batch commit', or 'repository management'.
version: 1.6.0
owner: "https://github.com/levonk"
status: "ready"
date:
  created: "2026-03-24"
  updated: "2026-07-02"
  last-used: "2026-07-02"
tags: ["ai/skill", "git", "version-control", "repository-management", "commit-organization", "tagging", "rollback-safety"]
see-also:
  - skill: project-detection
    relationship: "dependency"
    description: "For detecting project types and environment management systems"
  - skill: code-quality-validation
    relationship: "related"
    description: "For comprehensive code quality checks that integrate with git workflow"
  - skill: ai-development-loop
    relationship: "dependent"
    description: "Development loop depends on this skill for commit organization"
  - skill: base-ai-guidance
    relationship: "base-framework"
    description: "Base AI guidance framework for all AI skills"
dependencies:
  - type: skill
    name: project-detection
  - type: url
    name: Git Documentation
    url: https://git-scm.com/docs
---

{{{ include "includes/base-ai-guidance.md" . }}}

# Git Repository Management

Systematic workflow for managing git repositories from dirty state to clean with proper organization, validation, and documentation.

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

## Key Features

### Generic Repository Support
The script works with **any git repository** without hardcoded paths or assumptions:
- Auto-detects repository root from any working directory
- Supports multiple environment managers (devbox, mise, nix, native)
- Language-agnostic quality check detection
- No project-specific assumptions

### Deterministic Script Operations
The script only performs mechanical operations:
- Git operations (status, add, commit, push)
- Data collection with structured output
- Quality check execution (lint, test, format)
- Returns machine-readable data for AI analysis

### AI-Driven Intelligence
The AI agent handles all decision-making:
- **Change grouping**: Analyze semantic relationships between files
- **Commit messages**: Write meaningful titles and descriptions
- **Failure handling**: Decide how to address build/test failures
- **Documentation updates**: Update changelog, architecture docs, project status

### Commit Organization

For vertical commit grouping rules, data collection format, batch commit format, AI commit guidelines, no AI signatures rule, mandatory commit bodies, message format, grouping strategy, quality standards, and example messages, see [Commit Organization](references/commit-organization.md).

### Quality Checks and Security

For quality check results, quality check integration, security considerations, error handling, script failures, git conflicts, missing dependencies, and subdirectory/repository root failures, see [Quality Checks](references/quality-checks.md).

### Tagging and Pushing

For tagging HEAD, automatic run tagging, tag format, tag creation commands, tagging rules, usage patterns (complete repository management, cleanup, analysis, dry run), environment integration, script command reference, RTK usage, and development loop integration, see [Tagging and Pushing](references/tagging-and-pushing.md).

---

## Context Declaration

### File Paths
- Main skill: `config/ai/skills/software-dev/git-repository-management/SKILL.md`
- Scripts: `scripts/git-collect.sh`, `scripts/git-commit-batch.sh`, `scripts/git-push.sh`, `scripts/git-tag.sh`, `scripts/git-repo-manager.sh`, `scripts/git-status-helper.sh`
- References: `references/workflow-phases.md`, `references/commit-organization.md`, `references/quality-checks.md`, `references/tagging-and-pushing.md`, `references/git-status-digest.md`

### Related Skills
- project-detection (dependency)
- code-quality-validation (related)
- ai-development-loop (dependent)
- base-ai-guidance (base-framework)

### Project Information
- Project: levonk/dotfiles
- Repository: https://github.com/levonk/dotfiles
