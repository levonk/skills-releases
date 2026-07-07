---
name: project-configuration
description: "Configure existing projects with compatible preferences without overwriting established workflows. Use when adding missing tooling to existing projects, making open source projects compatible with your environment, or enhancing projects non-disruptively. Triggers on 'configure project', 'add linting', 'add CI', 'add devbox', 'compatible config', or 'non-destructive setup'."
version: 2.0.0
owner: "https://github.com/levonk"
status: "ready"
date:
  created: "2025-02-01"
  updated: "2026-07-02"
  last-used: "2026-07-02"
tags: ["ai/skill", "software-development", "project-configuration", "compatibility", "preference-enhancement", "non-disruptive"]
see-also:
  - skill: project-adopter
    relationship: "alternative-approach"
    description: "For overwriting existing preferences with standardized workflows"
  - skill: project-detection
    relationship: "dependency"
    description: "Required for analyzing current project state and existing tooling"
  - skill: surgical-config
    relationship: "dependency"
    description: "Required for safe, non-destructive configuration modifications"
  - templates: boilerplates
    relationship: "preference-source"
    description: "Provides standardized preference templates and tooling configurations"
  - template: base-ai-guidance
    relationship: "base-framework"
    description: "Shared framework for creating all AI guidance types"
dependencies:
  - type: skill
    name: project-detection
    reason: "Required for comprehensive project analysis and existing tooling detection"
  - type: skill
    name: surgical-config
    reason: "Required for non-destructive configuration file editing"
  - type: templates
    name: boilerplates
    url: https://github.com/lrepo52/job-aide/tree/main/boilerplate
    reason: "Source of preference templates and compatible tooling configurations"
  - type: nix
    name: devbox
    url: https://github.com/jetify-com/devbox
    reason: "Optional: For adding standardized development environment"
  - type: nix
    name: just
    url: https://github.com/casey/just
    reason: "Optional: For adding standardized command runner"
  - type: node
    name: direnv
    url: https://direnv.net/
    reason: "Optional: For adding environment management"
---

{{{ include "includes/base-ai-guidance.md" . }}}

# Project Configuration Skill

This skill helps configure **existing projects** with compatible preferences without disrupting established workflows. It's designed for situations where you want to enhance a project with missing tooling or make it compatible with your preferred development environment without overwriting the project's existing conventions.

## When to Use This Skill

Use this skill when:
- Working with **existing open source projects** where you don't want to change established workflows
- Adding **missing tooling** (like linting, formatting, or CI) to a project
- Making a project **compatible** with your development environment without breaking existing processes
- Enhancing a project with **additional features** while preserving existing functionality
- You want to be a **good citizen** in someone else's codebase

## What This Skill Does

Unlike `project-adopter` which overwrites preferences, this skill:
- **Analyzes existing tooling** using project-detection
- **Adds missing components** without removing existing ones
- **Enhances compatibility** with your preferred development environment
- **Preserves existing workflows** and conventions
- **Uses boilerplate templates** as reference for standard configurations

## Quick Start

```bash
# Configure current project with compatible preferences
./scripts/configure-project.sh --mode=compatible

# Add specific tooling without overwriting
./scripts/configure-project.sh --add-linting --add-ci --preserve-existing

# Use specific boilerplate preferences
./scripts/configure-project.sh --preferences-from=typescript-nextjs
```

## Usage Examples

### Example: Adding Missing Tooling to an Existing Project

```bash
# Project currently has only package.json with basic scripts
# This skill will add:
# - ESLint configuration (if missing)
# - Prettier configuration (if missing)
# - GitHub Actions CI (if missing)
# - devbox.json (if missing and compatible)
# - justfile (if missing and compatible)

./scripts/configure-project.sh --add-missing --preserve-workflows
```

### Example: Making Project Compatible with Your Environment

```bash
# Make project work with your standard devbox/direnv setup
# Without breaking existing npm scripts or workflows
./scripts/configure-project.sh --add-devbox-support --keep-npm-scripts
```

## Integration with Other Skills

### Project Detection Skill
- **Purpose**: Analyze existing project structure and tooling
- **Usage**: Essential for understanding what's already configured
- **Benefit**: Prevents conflicts with existing tooling

### Surgical Configuration Skill  
- **Purpose**: Make non-destructive edits to configuration files
- **Usage**: Add configuration sections without overwriting existing ones
- **Benefit**: Preserves existing settings while adding new capabilities

### Boilerplates
- **Purpose**: Reference templates for standard configurations
- **Usage**: Extract preference patterns from boilerplate templates
- **Benefit**: Ensures consistency with your standard project structure

## Configuration Options

The skill supports three modes (compatible, enhance, minimal), multiple tool categories (linting, CI, dev-env, docs, tests), and preservation options for existing configs, workflows, and tools.

For detailed configuration options, modes, tool categories, and preservation options, see [references/configuration-options.md](references/configuration-options.md).

## Deterministic Configuration

This skill uses deterministic scripts with `jq`, `yq`, and `surgical-config` for predictable, repeatable configuration changes to JSON and YAML files.

For detailed deterministic configuration examples with jq and yq commands, see [references/deterministic-config.md](references/deterministic-config.md).

## Boilerplate Integration

This skill references the boilerplates directory for standard configurations, including preference templates for TypeScript, Rust, and Python projects.

For detailed boilerplate integration and configuration patterns, see [references/boilerplate-integration.md](references/boilerplate-integration.md).

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

## Quality Checklist

- [ ] Used project-detection to analyze existing tooling
- [ ] Verified no existing configurations are overwritten
- [ ] Added only missing or compatible tooling
- [ ] Used surgical-config for safe configuration edits
- [ ] Referenced boilerplates for standard patterns
- [ ] Preserved existing workflows and scripts
- [ ] Tested that existing functionality still works
- [ ] Documented what was added and why

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

## Context Declaration

### File Paths
- Main skill: `config/ai/skills/software-dev/project-configuration/SKILL.md`
- Scripts: `scripts/configure-project.sh`
- References: `references/configuration-options.md`, `references/deterministic-config.md`, `references/boilerplate-integration.md`

### Related Skills
- project-adopter (alternative-approach)
- project-detection (dependency)
- surgical-config (dependency)
- base-ai-guidance (base-framework)

### Project Information
- Project: levonk/dotfiles
- Repository: https://github.com/levonk/dotfiles

---

*This skill focuses on compatibility and enhancement rather than replacement, making it ideal for existing projects and open source contributions.*
