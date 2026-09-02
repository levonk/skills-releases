<!-- Managed by skills-src build pipeline. Do not edit; changes will be overwritten. -->
<!-- Generated from SKILL.md frontmatter + body by `just catalog` -->

# Skills: the script is materialized into scripts/cli-tool-discovery.sh at build time

> Category: **software-dev** · Status: ready · Version: 2.8.0

Adopt and establish best practices for projects by overwriting existing preferences with standardized developer UX flow. Use when onboarding a new project to standard tooling, setting up devbox/just/direnv, establishing CI/CD, or applying ADR-compliant project structure. Triggers on 'adopt project', 'set up dev environment', 'standardize project', 'apply best practices', or 'project adoption'.

## Metadata

| Field | Value |
|-------|-------|
| Name | `project-adopter` |
| Category | `software-dev` |
| Version | `2.8.0` |
| Status | `ready` |
| Owner | https://github.com/levonk |

## Tags
- `ai/skill`
- `software-development`
- `project-management`
- `best-practices`
- `development-experience`
- `project-adoption`
- `preference-overwrite`

## Related Skills
- **project-configuration** (skill, alternative-approach) — For adding compatible preferences without overwriting existing workflows
- **project-detection** (skill, dependency) — Required for analyzing current project state and tooling
- **surgical-config** (skill, dependency) — Required for safe configuration file modifications
- **repository-health-review** (skill, optional) — Optional for pre/post-adoption health assessment
- **ai-development-loop** (skill, optional) — Optional for systematic development workflow integration
- **git-repository-management** (skill, dependency) — Required for initializing new repos and committing the adoption changeset (init + collect + batch-commit + push)
- **ignorefile-manager** (skill, dependency) — Required for generating .gitignore, .dockerignore, .codeiumignore, .cursorignore, .aiexclude, .npmignore, VS Code excludes, and ripgrep config from modular concern sources
- **agent-file-upsert** (skill, dependency) — Required for creating or updating AGENTS.md (AI-facing entry point). Handles both greenfield (create from template) and brownfield (preserve accurate sections, update stale ones, delta analysis). Bundled via includeTree for offline availability.
- **readme-upsert** (skill, dependency) — Required for creating or updating README.md (human-facing entry point). Handles both greenfield (create from template) and brownfield (preserve accurate sections, update stale ones). Runs the README↔AGENTS.md consistency checker after AGENTS.md is in place.
- **dev-env-upsert** (skill, dependency) — Required for devbox.json package management, .envrc generation/update, and justfile prime_impl line additions. Owns the devbox+direnv+justfile coupled trio per the Standard Developer UX Flow.
- **base-ai-guidance** (skill, base-framework) — Base AI guidance framework for all AI skills
- **** (, preference-source) — Provides standardized project templates and preference definitions

---

- **Full skill**: [`skills/software-dev/project-adopter/SKILL.md`](skills/software-dev/project-adopter/SKILL.md)
- **Install**: `pnpm dlx skills add levonk/skills-releases`
- **Generated**: 2026-09-02T09:17:25Z
