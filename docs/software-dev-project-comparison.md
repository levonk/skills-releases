<!-- Managed by skills-src build pipeline. Do not edit; changes will be overwritten. -->
<!-- Generated from SKILL.md frontmatter + body by `just catalog` -->

# Skills: the script is materialized into scripts/cli-tool-discovery.sh at build time

> Category: **software-dev** · Status: ready · Version: 1.0.0

Compare multiple software projects to determine whether they belong to the same category, map what parts of that category each project addresses, and produce a feature matrix comparing them across features, maintainability, activity, and meta-features (license, stars, forks, last commit, tech stack, platform support, setup difficulty, community). Use when the user asks to compare projects, evaluate alternatives, build a feature matrix, landscape analysis, benchmark projects, assess which projects are in the same space, determine category overlap, or decide between multiple tools/libraries/frameworks addressing the same problem. Triggers on 'compare projects', 'feature matrix', 'project comparison', 'landscape analysis', 'benchmark projects', 'evaluate alternatives', 'which projects are similar', 'category analysis', 'head to head', 'compare these repos', or 'project landscape'. Do NOT trigger on single-project analysis (use project-detection or repository-health-review), technology choice questions with no project list (use tech-maturity), or business competitive analysis (use competitive-intelligence skills).

## Metadata

| Field | Value |
|-------|-------|
| Name | `project-comparison` |
| Category | `software-dev` |
| Version | `1.0.0` |
| Status | `ready` |
| Owner | https://github.com/levonk |

## Related Skills
- **project-detection** (skill, dependency) — Provides per-project tech stack, build system, and CI/CD detection
- **repository-health-review** (skill, dependency) — Provides per-project health score for the maintainability axis
- **tech-maturity** (skill, complement) — Provides per-project maturity scoring (42 capabilities, 6 dimensions) for deep maintainability assessment
- **** (, output-format) — Defines the output format for the feature matrix (icons, meta-features, table layout)
- **comparison-methodology** (template, shared-methodology) — Shared comparison methodology (category discovery, coverage mapping, matrix output) — also used by ai-upsert
- **base-ai-guidance** (template, base-framework) — Shared framework for creating all AI guidance types

---

- **Full skill**: [`skills/software-dev/project-comparison/SKILL.md`](skills/software-dev/project-comparison/SKILL.md)
- **Install**: `pnpm dlx skills add levonk/skills-releases`
- **Generated**: 2026-08-20T22:53:30Z
