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

## Quick Start

```bash
# Gather GitHub metadata for a list of repos (outputs JSON)
uv run --script scripts/gather_github_metadata.py owner1/repo1 owner2/repo2 owner3/repo3
# Or directly (uv on PATH, script is executable):
./scripts/gather_github_metadata.py owner1/repo1 owner2/repo2 owner3/repo3

# Gather local project metadata (tech stack, build system, CI/CD)
uv run --script scripts/gather_local_metadata.py /path/to/project-a /path/to/project-b

# Both scripts support --verbose for full detail and --dry-run for preview
```

After gathering metadata, follow the workflow below to classify, assess, and
emit the feature matrix.

## When to Use

| Situation | Use this skill? |
|---|---|
| Compare 2+ projects to see if they're in the same category | Yes — canonical case |
| Build a feature matrix across multiple projects | Yes — canonical case |
| Landscape analysis: map what slice of a category each project covers | Yes — canonical case |
| Benchmark alternatives before choosing one | Yes |
| Evaluate project maintainability across alternatives | Yes |
| Single project analysis | No — use `project-detection` or `repository-health-review` |
| Technology choice with no project list | No — use `tech-maturity` |
| Business competitive analysis (companies, markets) | No — use competitive-intelligence skills |

## References

- [category-discovery.md](references/category-discovery.md) — the 3-tier
  category classification process (known names → category search → adjacent
  categories) and how to handle mismatches
- [coverage-mapping.md](references/coverage-mapping.md) — how to define
  category dimensions and map each project's coverage with the 5-level
  🏆/✅/➖/⚠️/❌ scale
- [architectural-comparison.md](references/architectural-comparison.md) — how
  to compare project architectures, when to produce mermaid diagrams vs. a
  brief "no difference" note, and diagram patterns
- [maintainability-scoring.md](references/maintainability-scoring.md) — the
  maintainability scoring rubric combining activity, health, and maturity
  signals into 🏆/✅/➖/⚠️/❌ ratings
- [matrix-output-format.md](references/matrix-output-format.md) — the feature
  matrix output format with meta-features, category features, identical-value
  rows, and recommendation section

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
- **Generated**: 2026-07-30T19:45:30Z
