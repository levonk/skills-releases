<!-- Managed by skills-src build pipeline. Do not edit; changes will be overwritten. -->
<!-- Generated from SKILL.md frontmatter + body by `just catalog` -->

# Skills: the script is materialized into scripts/cli-tool-discovery.sh at build time

> Category: **software-dev** · Status: ready · Version: 2.0.0

Comprehensive detection of project types, build systems, package managers, and CI/CD platforms. Use when needing to analyze a project's tech stack, detect build systems, identify CI/CD platforms, extract build targets, or understand project structure. Triggers on 'detect project type', 'analyze project', 'identify build system', 'detect CI/CD', or 'project analysis'.

## Metadata

| Field | Value |
|-------|-------|
| Name | `project-detection` |
| Category | `software-dev` |
| Version | `2.0.0` |
| Status | `ready` |
| Owner | https://github.com/levonk |

## Tags
- `ai/skill`
- `software-development`
- `project-detection`
- `build-systems`
- `ci-cd`
- `project-analysis`
- `tooling`
- `foundational-component`

## Quick Start

```bash
# Detect all systems in a project
./scripts/detect-all-systems.sh /path/to/project

# Detect specific categories
./scripts/detect-build-systems.sh /path/to/project
./scripts/detect-ci-cd-systems.sh /path/to/project
./scripts/detect-workspace-configs.sh /path/to/project

# Extract build targets from existing configurations
./scripts/extract-build-targets.sh generate /path/to/project
./scripts/extract-build-targets.sh show /path/to/project

# Get detailed analysis
./scripts/analyze-project-structure.sh /path/to/project --verbose
```

## Related Skills
- **project-adopter** (skill, dependent) — Uses project-detection for comprehensive project analysis before adoption
- **project-configuration** (skill, dependent) — Uses project-detection to understand existing tooling before configuration
- **surgical-config** (skill, complementary) — Often used together for safe configuration modifications
- **** (, reference-source) — Provides detection patterns for standard project structures
- **base-ai-guidance** (template, base-framework) — Shared framework for creating all AI guidance types

---

- **Full skill**: [`skills/software-dev/project-detection/SKILL.md`](skills/software-dev/project-detection/SKILL.md)
- **Install**: `npx skills add levonk/skills-releases`
- **Generated**: 2026-07-18T08:27:30Z
