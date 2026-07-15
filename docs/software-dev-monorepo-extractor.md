<!-- Managed by skills-src build pipeline. Do not edit; changes will be overwritten. -->
<!-- Generated from SKILL.md frontmatter + body by `just catalog` -->

# Skills: the script is materialized into scripts/cli-tool-discovery.sh at build time

> Category: **software-dev** · Status: ready · Version: 1.0.0

Safely extract projects from monorepos while preserving git history and ensuring team coordination. Use when needing to split a monorepo project into its own repository, extract a subdirectory with history, or restructure a monorepo. Triggers on 'extract project', 'split monorepo', 'move to separate repo', 'preserve history', or 'monorepo extraction'.

## Metadata

| Field | Value |
|-------|-------|
| Name | `monorepo-extractor` |
| Category | `software-dev` |
| Version | `1.0.0` |
| Status | `ready` |
| Owner | https://github.com/levonk |

## Tags
- `ai/skill`
- `software-development`
- `git-operations`
- `monorepo`
- `devops`

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

## References

- [Extraction Improvements](references/extraction-improvements.md) - Key improvements in v3.0 and v2.0 of the extraction scripts
- [Core Workflow](references/core-workflow.md) - Detailed workflow steps, tool verification, git history extraction, validation, and team safety
- [AI/IDE Analysis](references/ai-ide-analysis.md) - AI/IDE configuration analysis scripts and repository health analysis details

## Related Skills
- **** (, ) — 
- **** (, ) — 
- **** (, ) — 

---

- **Full skill**: [`skills/software-dev/monorepo-extractor/SKILL.md`](skills/software-dev/monorepo-extractor/SKILL.md)
- **Install**: `npx skills add levonk/skills-releases`
- **Generated**: 2026-07-15T22:13:34Z
