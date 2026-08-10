<!-- Managed by skills-src build pipeline. Do not edit; changes will be overwritten. -->
<!-- Generated from SKILL.md frontmatter + body by `just catalog` -->

# Skills: the script is materialized into scripts/cli-tool-discovery.sh at build time

> Category: **ai** · Status: ready · Version: 2.0.0

Comprehensive detection of project types, build systems, package managers, and CI/CD platforms. Use when needing to analyze a project's tech stack, detect build systems, identify CI/CD platforms, extract build targets, or understand project structure. Triggers on 'detect project type', 'analyze project', 'identify build system', 'detect CI/CD', or 'project analysis'.

## Metadata

| Field | Value |
|-------|-------|
| Name | `project-detection` |
| Category | `ai` |
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

## Related Skills
- **project-adopter** (skill, dependent) — Uses project-detection for comprehensive project analysis before adoption
- **project-configuration** (skill, dependent) — Uses project-detection to understand existing tooling before configuration
- **surgical-config** (skill, complementary) — Often used together for safe configuration modifications
- **** (, reference-source) — Provides detection patterns for standard project structures
- **base-ai-guidance** (template, base-framework) — Shared framework for creating all AI guidance types

---

- **Full skill**: [`skills/ai/project-detection/SKILL.md`](skills/ai/project-detection/SKILL.md)
- **Install**: `pnpm dlx skills add levonk/skills-releases`
- **Generated**: 2026-08-10T21:38:16Z
