---
name: "monorepo-extractor"
description: "Safely extract projects from monorepos while preserving git history and ensuring team coordination. Use when needing to split a monorepo project into its own repository, extract a subdirectory with history, or restructure a monorepo. Triggers on 'extract project', 'split monorepo', 'move to separate repo', 'preserve history', or 'monorepo extraction'."
version: 1.0.0
owner: "https://github.com/levonk"
status: "ready"
date:
  created: "2025-02-01"
  updated: "2026-07-02"
  last-used: "2026-07-02"
tags: ["ai/skill", "software-development", "git-operations", "monorepo", "devops"]
dependencies:
  - type: debian
    name: git
    url: https://git-scm.com/
  - type: nix
    name: git
    url: https://search.nixos.org/packages?query=git
  - type: skill
    name: project-detection
  - type: url
    name: Git Filter Repo
    url: https://github.com/newren/git-filter-repo
see-also:
  - name: project-detection
    type: dependency
  - name: repository-health-review
    type: related
  - name: base-ai-guidance
    type: base-framework
---

{{{ include "includes/base-ai-guidance.md" . }}}

## Monorepo Extractor

### Quick Start

**Strict Extraction (Recommended for Production):**

```bash
# Auto-detect single branch and extract
./scripts/extract-project-strict.sh /path/to/monorepo project-name /path/to/new-repo

# Specify branch explicitly
./scripts/extract-project-strict.sh --branch main /path/to/monorepo project-name /path/to/new-repo

# With git identity rewrite
./scripts/extract-project-strict.sh --committer-name "John Doe" --committer-email "john@company.com" /path/to/monorepo project-name /path/to/new-repo

# Test extraction without making changes
./scripts/extract-project-strict.sh --dry-run --verbose /path/to/monorepo project-name /path/to/new-repo

# Force extraction despite repository issues (DANGEROUS)
./scripts/extract-project-strict.sh --force /path/to/monorepo project-name /path/to/new-repo
```

**Flexible Extraction (Development/Testing):**

```bash
# Extract with flexible validation (allows uncommitted changes with --force)
./scripts/extract-project-flexible.sh --force /path/to/monorepo project-name /path/to/new-repo
```

**Advanced Extraction (Full Pipeline):**

```bash
# Verify tools and environment
./scripts/verify-tools.sh

# Detect build systems and CI/CD platforms
./scripts/detect-build-systems.sh /path/to/monorepo
./scripts/detect-ci-cd-systems.sh /path/to/monorepo

# Analyze workspace configurations and shared resources
./scripts/analyze-workspace-configs.sh /path/to/monorepo project-name

# Extract using improved script
./scripts/extract-project-flexible.sh --branch main /path/to/monorepo project-name /path/to/new-repo

# Validate project-specific targets work in new repository
./scripts/validate-project-targets.sh /path/to/new-repo

# Final validation
./scripts/validate-extraction.sh /path/to/new-repo
```

## Instructions

### When to Use

- **Project extraction**: Moving a project from monorepo to standalone repository
- **Team reorganization**: Splitting teams that need separate repositories
- **Dependency management**: Projects that need independent versioning
- **Compliance requirements**: Projects requiring separate access controls

**Keywords that trigger this skill**: "extract project", "split monorepo", "move to separate repo", "preserve history", "monorepo extraction"

### Strict Validation Philosophy

The `extract-project-strict.sh` script enforces **clean repository state** as a prerequisite for extraction:

#### Required Clean State

1. **No Uncommitted Changes**: All changes must be committed
2. **No Stashed Entries**: Repository must have no stashed changes
3. **Remote Synchronization**: Repository must be pushed to remote origin
4. **Branch Remote Existence**: Current branch must exist on remote
5. **No Unpushed Commits**: All commits must be pushed to remote
6. **Repository Integrity**: `git fsck` must pass (unless `--force` is used)
7. **Branch Clarity**: Either single branch (auto-detect) or explicit `--branch` specification

#### Why Strict Validation?

- **History Preservation**: Clean state ensures git history extraction is accurate
- **Reproducibility**: Extraction results are predictable and repeatable
- **Safety**: Prevents accidental extraction of incomplete or corrupted state
- **Compliance**: Meets enterprise requirements for repository splitting
- **Remote Backup**: Ensures all commits exist remotely before extraction (prevents data loss)
- **Team Coordination**: Guarantees team members have access to all changes before repository restructuring

#### When to Use Strict vs Flexible

- **Production Extracts**: Use `extract-project-strict.sh` for final repository splits
- **Development/Testing**: Use `extract-project-improved.sh` for experimental extractions
- **Emergency Recovery**: Use `--force` flag only when you understand the risks

### Core Workflow Overview

1. **Tool Verification**: Ensure all required tools are available with minimum versions
2. **Monorepo State Validation**: Verify repository is fully committed, pushed, and validated remotely
3. **System Detection**: Detect build systems, package managers, and CI/CD platforms
4. **Workspace Analysis**: Analyze workspace configurations and shared resources
5. **Repository Duplication**: Duplicate entire monorepo to preserve structure and shared content
6. **Intelligent Pruning**: Remove unrelated projects and history while preserving shared resources
7. **Workspace Updates**: Update workspace configurations to reflect single-project structure
8. **Target Validation**: Verify project-specific targets (bootstrap, build, lint, test, etc.) work properly
9. **Final Validation**: Verify repository integrity and history completeness
10. **Cleanup**: Safely remove project from original monorepo with reference to new location

> **See also**: [Core Workflow Details](references/core-workflow.md) for detailed implementation steps, tool verification scripts, git history extraction, validation, and team safety procedures.

## Best Practices

- **Always verify tools first** - Don't start extraction without confirming environment
- **Create backups** - Tag the monorepo before any extraction
- **Communicate with team** - Ensure no active work will be disrupted
- **Validate thoroughly** - Don't assume extraction worked without verification
- **Document the migration** - Leave clear references for future developers

## Examples

### Example 1: Basic Project Extraction

```bash
# Extract a web application from company monorepo
./scripts/verify-tools.sh
./scripts/extract-project.sh /opt/company-monorepo webapp /opt/webapp-repo
./scripts/validate-extraction.sh /opt/webapp-repo
```

### Example 2: Complex Multi-Team Extraction

```bash
# Extract shared library with coordination
./scripts/verify-tools.sh

# Create announcement in team chat
echo "Extracting shared-utils library to standalone repo. Please pause work."

# Wait for confirmation (manual step)
read -p "Press enter after team confirmation..."

./scripts/extract-project.sh /opt/company-monorepo libs/shared-utils /opt/shared-utils-repo
./scripts/validate-extraction.sh /opt/shared-utils-repo
./scripts/safe-cleanup.sh /opt/company-monorepo libs/shared-utils git@github.com:company/shared-utils.git
```

## Resources

### Core Scripts

- `scripts/extract-project-strict.sh` - **Recommended for Production**: Strict validation, auto-branch detection, git identity rewrite, AI/IDE analysis
- `scripts/extract-project-flexible.sh` - Development/Testing: Flexible validation with branch support
- `scripts/extract-project.sh` - Legacy extraction script (strict validation)
- `scripts/verify-tools.sh` - Tool verification script
- `scripts/validate-monorepo-state.sh` - Monorepo state validation script
- `scripts/duplicate-and-prune.sh` - Repository duplication and intelligent pruning
- `scripts/validate-extraction.sh` - Repository validation script
- `scripts/safe-cleanup.sh` - Monorepo cleanup script

### Detection Scripts

- `scripts/detect-build-systems.sh` - Detect build systems and package managers
- `scripts/detect-ci-cd-systems.sh` - Detect CI/CD systems and deployment platforms

### Analysis Scripts

- `scripts/analyze-workspace-configs.sh` - Analyze workspace configurations and monorepo structures
- `scripts/analyze-monorepo-structure.sh` - Legacy structure analysis (replaced by modular scripts)

### Validation Scripts

- `scripts/validate-project-targets.sh` - Validate project-specific targets and commands
- `scripts/validate-monorepo-targets.sh` - Legacy targets validation (replaced by modular script)

### Documentation

- `REFERENCE.md` - Detailed technical reference

## References

- [Extraction Improvements](references/extraction-improvements.md) - Key improvements in v3.0 and v2.0 of the extraction scripts
- [Core Workflow](references/core-workflow.md) - Detailed workflow steps, tool verification, git history extraction, validation, and team safety
- [AI/IDE Analysis](references/ai-ide-analysis.md) - AI/IDE configuration analysis scripts and repository health analysis details

## Limitations

- **Large repositories**: Extraction may be slow for repositories with extensive history
- **Complex dependencies**: Projects with circular dependencies may require manual intervention
- **Binary files**: Large binary files in history may cause performance issues
- **Submodules**: Git submodules require special handling

## Security Notes

- **Access control**: Ensure new repository has appropriate permissions
- **Secrets handling**: Verify no secrets are accidentally extracted
- **CI/CD updates**: Update automation to point to new repository
- **Token rotation**: Rotate any tokens that may be embedded in history

## Context Declaration

### File Paths

- Main skill: `config/ai/skills/software-dev/monorepo-extractor/SKILL.md`
- Scripts: `scripts/extract-project-strict.sh`, `scripts/extract-project-flexible.sh`, `scripts/extract-project.sh`, `scripts/verify-tools.sh`, `scripts/validate-monorepo-state.sh`, `scripts/duplicate-and-prune.sh`, `scripts/validate-extraction.sh`, `scripts/safe-cleanup.sh`, `scripts/detect-build-systems.sh`, `scripts/detect-ci-cd-systems.sh`, `scripts/analyze-workspace-configs.sh`, `scripts/analyze-monorepo-structure.sh`, `scripts/validate-project-targets.sh`, `scripts/validate-monorepo-targets.sh`, `scripts/analyze-ai-ide-configs.sh`, `scripts/smart-content-filter.sh`
- References: `references/extraction-improvements.md`, `references/core-workflow.md`, `references/ai-ide-analysis.md`

### Related Skills

- `project-detection` (dependency)
- `repository-health-review` (related)
- `base-ai-guidance` (base-framework)

### Project Information

- Project: levonk/dotfiles
- Repository: https://github.com/levonk/dotfiles

<!-- vim: set ft=markdown -->
