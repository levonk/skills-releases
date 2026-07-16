<!-- Managed by skills-src build pipeline. Do not edit; changes will be overwritten. -->
<!-- Generated from SKILL.md frontmatter + body by `just catalog` -->

# Skills: the script is materialized into scripts/cli-tool-discovery.sh at build time

> Category: **software-dev** · Status: ready · Version: 2.0.0

Adopt and establish best practices for projects by overwriting existing preferences with standardized developer UX flow. Use when onboarding a new project to standard tooling, setting up devbox/just/direnv, establishing CI/CD, or applying ADR-compliant project structure. Triggers on 'adopt project', 'set up dev environment', 'standardize project', 'apply best practices', or 'project adoption'.

## Metadata

| Field | Value |
|-------|-------|
| Name | `project-adopter` |
| Category | `software-dev` |
| Version | `2.0.0` |
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

## Quick Start

When adopting best practices for a project (per ADR 20260131001 Standard Developer UX Flow):

1. **Health Review** - Run repository health analysis to assess current state (using repository-health-review skill)
2. **Detect** project type and existing configuration (using project-detection skill)
3. **Configure** devbox.json with appropriate packages (per ADR 20251226001)
4. **Set up** justfile with standard targets (build-internal, test-internal, lint-internal, etc.)
5. **Configure** .envrc for direnv integration (per ADR 20251226001)
6. **Set up** technology-specific build tools (cargo, nx, pytest, etc. per ADR 20260131001)
7. **Add** shared quality scripts (per ADR 20251218002)
8. **Configure** testing framework (Vitest for TypeScript per ADR 20251106002)
9. **Set up** GitHub Actions CI/CD (per ADR 20251106014)
10. **Update** README.md with development setup
11. **Add** docker-compose.yml if needed
12. **Create** LICENSE.md (Proprietary)
13. **Set up** AGENTS.md for AI workflow
14. **Configure** dependencies and tooling using surgical-config skill
15. **Integrate** with ai-development-loop for systematic workflow
16. **Post-Adoption Validation** - Run repository health review to verify improvements

## References

For ADR references and detailed configuration links, see [ADR References](references/adr-references.md).

---

## Related Skills
- **project-configuration** (skill, alternative-approach) — For adding compatible preferences without overwriting existing workflows
- **project-detection** (skill, dependency) — Required for analyzing current project state and tooling
- **surgical-config** (skill, dependency) — Required for safe configuration file modifications
- **repository-health-review** (skill, optional) — Optional for pre/post-adoption health assessment
- **ai-development-loop** (skill, optional) — Optional for systematic development workflow integration
- **base-ai-guidance** (skill, base-framework) — Base AI guidance framework for all AI skills
- **** (, preference-source) — Provides standardized project templates and preference definitions

---

- **Full skill**: [`skills/software-dev/project-adopter/SKILL.md`](skills/software-dev/project-adopter/SKILL.md)
- **Install**: `npx skills add levonk/skills-releases`
- **Generated**: 2026-07-16T08:35:31Z
