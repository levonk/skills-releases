<!-- Managed by skills-src build pipeline. Do not edit; changes will be overwritten. -->
<!-- Generated from SKILL.md frontmatter + body by `just catalog` -->

# Skills: the script is materialized into scripts/cli-tool-discovery.sh at build time

> Category: **software-dev** · Status: ready · Version: 2.1.0

Configure existing projects with compatible preferences without overwriting established workflows. Use when adding missing tooling to existing projects, making open source projects compatible with your environment, or enhancing projects non-disruptively. Triggers on 'configure project', 'add linting', 'add CI', 'add devbox', 'compatible config', or 'non-destructive setup'.

## Metadata

| Field | Value |
|-------|-------|
| Name | `project-configuration` |
| Category | `software-dev` |
| Version | `2.1.0` |
| Status | `ready` |
| Owner | https://github.com/levonk |

## Tags
- `ai/skill`
- `software-development`
- `project-configuration`
- `compatibility`
- `preference-enhancement`
- `non-disruptive`

## Related Skills
- **project-adopter** (skill, alternative-approach) — For overwriting existing preferences with standardized workflows
- **project-detection** (skill, dependency) — Required for analyzing current project state and existing tooling
- **surgical-config** (skill, dependency) — Required for safe, non-destructive configuration modifications
- **** (, preference-source) — Provides standardized preference templates and tooling configurations
- **base-ai-guidance** (template, base-framework) — Shared framework for creating all AI guidance types

---

- **Full skill**: [`skills/software-dev/project-configuration/SKILL.md`](skills/software-dev/project-configuration/SKILL.md)
- **Install**: `pnpm dlx skills add levonk/skills-releases`
- **Generated**: 2026-09-02T09:55:48Z
