<!-- Managed by skills-src build pipeline. Do not edit; changes will be overwritten. -->
<!-- Generated from SKILL.md frontmatter + body by `just catalog` -->

# Skills: the script is materialized into scripts/cli-tool-discovery.sh at build time

> Category: **software-dev** · Status: ready · Version: 2.0.0

Configure existing projects with compatible preferences without overwriting established workflows. Use when adding missing tooling to existing projects, making open source projects compatible with your environment, or enhancing projects non-disruptively. Triggers on 'configure project', 'add linting', 'add CI', 'add devbox', 'compatible config', or 'non-destructive setup'.

## Metadata

| Field | Value |
|-------|-------|
| Name | `project-configuration` |
| Category | `software-dev` |
| Version | `2.0.0` |
| Status | `ready` |
| Owner | https://github.com/levonk |

## Tags
- `ai/skill`
- `software-development`
- `project-configuration`
- `compatibility`
- `preference-enhancement`
- `non-disruptive`

## Quick Start

```bash
# Configure current project with compatible preferences
./scripts/configure-project.sh --mode=compatible

# Add specific tooling without overwriting
./scripts/configure-project.sh --add-linting --add-ci --preserve-existing

# Use specific boilerplate preferences
./scripts/configure-project.sh --preferences-from=typescript-nextjs
```

## What This Skill Does

Unlike `project-adopter` which overwrites preferences, this skill:
- **Analyzes existing tooling** using project-detection
- **Adds missing components** without removing existing ones
- **Enhances compatibility** with your preferred development environment
- **Preserves existing workflows** and conventions
- **Uses boilerplate templates** as reference for standard configurations

## When to Use

Use this skill when:
- Working with **existing open source projects** where you don't want to change established workflows
- Adding **missing tooling** (like linting, formatting, or CI) to a project
- Making a project **compatible** with your development environment without breaking existing processes
- Enhancing a project with **additional features** while preserving existing functionality
- You want to be a **good citizen** in someone else's codebase

## Examples

### Example 1: Adding Linting to Existing TypeScript Project

```bash
# Project has package.json but no linting
./scripts/configure-project.sh --add-linting --preserve-existing

# Result:
# - .eslintrc.js added (without overwriting if exists)
# - ESLint dependencies added to package.json devDependencies
# - lint script added to package.json (without overwriting existing scripts)
# - GitHub Actions lint job added (if .github/workflows exists)
```

### Example 2: Making Open Source Project Compatible

```bash
# Working with someone else's open source project
./scripts/configure-project.sh --mode=compatible --add-dev-env

# Result:
# - devbox.json added with detected packages
# - justfile added with standard targets (without replacing Makefile if exists)
# - .envrc added for direnv support
# - Existing workflows and tools preserved
```

### Example 3: Enhancing Project with Missing CI

```bash
# Project has code but no CI/CD
./scripts/configure-project.sh --add-ci --preserve-workflows

# Result:
# - .github/workflows/ci.yml added based on detected language
# - CI configured to run existing test scripts
# - No changes to existing development workflow
```

## References

- [Project Detection Skill](../project-detection/SKILL.md) - Required for project analysis
- [Project Adopter Skill](../project-adopter/SKILL.md) - Alternative approach for overwriting preferences
- [Surgical Configuration Skill](../surgical-config/SKILL.md) - Required for safe edits
- [Boilerplates](https://github.com/lrepo52/job-aide/tree/main/boilerplate) - Source of preference templates
- [Standard Developer UX Flow](https://github.com/levonk/job-aide/blob/main/internal-docs/adr/adr-20260131001-standard-developer-ux-flow.md) - Devbox + direnv primary environment
- [Devbox + direnv Environment ADR](https://github.com/lrepo52/job-aide/blob/main/internal-docs/adr/adr-20251226001-devbox-direnv-dev-environment.md) - Devbox as primary environment interface
- [NX Monorepo Build Tool ADR](https://github.com/lrepo52/job-aide/blob/main/internal-docs/adr/adr-20260419001-nx-monorepo-build-tool.md) - NX preferred over Turborepo for polyglot support
- [Shared Quality Scripts ADR](https://github.com/lrepo52/job-aide/blob/main/internal-docs/adr/adr-20251218002-shared-quality-scripts.md) - Docker-based quality scripts
- [Vitest for Testing ADR](https://github.com/lrepo52/job-aide/blob/main/internal-docs/adr/adr-20251106002-vitest-for-testing.md) - Vitest as standard testing framework
- [GitHub Actions CI/CD ADR](https://github.com/lrepo52/job-aide/blob/main/internal-docs/adr/adr-20251106014-cicd-strategy.md) - GitHub Actions as primary CI/CD platform

---

## Related Skills
- **project-adopter** (skill, alternative-approach) — For overwriting existing preferences with standardized workflows
- **project-detection** (skill, dependency) — Required for analyzing current project state and existing tooling
- **surgical-config** (skill, dependency) — Required for safe, non-destructive configuration modifications
- **** (, preference-source) — Provides standardized preference templates and tooling configurations
- **base-ai-guidance** (template, base-framework) — Shared framework for creating all AI guidance types

---

- **Full skill**: [`skills/software-dev/project-configuration/SKILL.md`](skills/software-dev/project-configuration/SKILL.md)
- **Install**: `npx skills add levonk/skills-releases`
- **Generated**: 2026-07-12T19:44:04Z
