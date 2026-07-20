<!-- Managed by skills-src build pipeline. Do not edit; changes will be overwritten. -->
<!-- Generated from SKILL.md frontmatter + body by `just catalog` -->

# Skills: the script is materialized into scripts/cli-tool-discovery.sh at build time

> Category: **software-dev** · Status: ready · Version: 2.2.0

Adopt and establish best practices for projects by overwriting existing preferences with standardized developer UX flow. Use when onboarding a new project to standard tooling, setting up devbox/just/direnv, establishing CI/CD, or applying ADR-compliant project structure. Triggers on 'adopt project', 'set up dev environment', 'standardize project', 'apply best practices', or 'project adoption'.

## Metadata

| Field | Value |
|-------|-------|
| Name | `project-adopter` |
| Category | `software-dev` |
| Version | `2.2.0` |
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
10. **Set up** AGENTS.md for AI workflow (run **agent-file-upsert** if available; otherwise create a minimal AGENTS.md that references ai-development-loop). README generation in step 10b requires AGENTS.md to exist first so the README can link to it and the consistency checker can verify name/section agreement.
11. **Add** docker-compose.yml if needed
12. **Create** LICENSE.md (Proprietary)
13. **Generate or update README.md** - Delegate to the **readme-upsert** skill: it creates a README from `references/README-project-root-template.md.tmpl` for greenfield projects, or preserves accurate sections and updates stale ones for brownfield projects, then runs `scripts/verify_consistency.py {REPO_ROOT}` to check README↔AGENTS.md agreement (project name match, no content duplication, no wrong sections in either file). Do NOT hand-write README content or inline heredocs in `configure-*.sh` / `adopt-project.sh` — that duplicates readme-upsert's template, required-sections list, and consistency checks, and diverges over time.
14. **Install knowledge bundles** - Run `uv run --script scripts/install-knowledge-bundles.py .` with stack-matched bundles based on project-detection output (universal bundles installed by default; add `--bundles typescript-monorepo-best-practices,container-best-practices` etc. for detected stacks)
15. **Configure** dependencies and tooling using surgical-config skill
16. **Generate ignore files** - Delegate to the **ignorefile-manager** skill: run `generate_ignores.py reconcile --target .` then `audit --target .` then `generate --target .` to produce `.gitignore`, `.dockerignore`, `.codeiumignore`, `.cursorignore`, `.aiexclude`, `.npmignore`, VS Code excludes, and ripgrep config from modular concern sources (covers git, docker, jj `.jj/`, AI tool exhaust, etc.). Do NOT hand-write `.gitignore` — that duplicates ignorefile-manager and diverges over time.
17. **Initialize git repo and commit adoption changeset** - Delegate to the **git-repository-management** skill: run `git-collect.sh` (emits `NOT_A_GIT_REPO` + exit 2 if the dir isn't a repo yet) → if so, run `git-repo-init.bash` (full CREATE or `--no-init-structure` mode based on directory contents) → re-collect → analyze → `git-commit-batch.sh --slug project-adoption` to commit the adoption changeset as one logical commit with pre/post auto-tags for rollback safety → optionally `git-push.sh` if a remote is configured. Do NOT call `git init` / `git add` / `git commit` directly — that bypasses the secret-scanning, vertical-grouping, and rollback-safety guarantees of git-repository-management.
18. **Integrate** with ai-development-loop for systematic workflow
19. **Post-Adoption Validation** - Run repository health review to verify improvements

## References

For ADR references and detailed configuration links, see [ADR References](references/adr-references.md).

---

## Related Skills
- **project-configuration** (skill, alternative-approach) — For adding compatible preferences without overwriting existing workflows
- **project-detection** (skill, dependency) — Required for analyzing current project state and tooling
- **surgical-config** (skill, dependency) — Required for safe configuration file modifications
- **repository-health-review** (skill, optional) — Optional for pre/post-adoption health assessment
- **ai-development-loop** (skill, optional) — Optional for systematic development workflow integration
- **git-repository-management** (skill, dependency) — Required for initializing new repos and committing the adoption changeset (init + collect + batch-commit + push)
- **ignorefile-manager** (skill, dependency) — Required for generating .gitignore, .dockerignore, .codeiumignore, .cursorignore, .aiexclude, .npmignore, VS Code excludes, and ripgrep config from modular concern sources
- **readme-upsert** (skill, dependency) — Required for creating or updating README.md (human-facing entry point). Handles both greenfield (create from template) and brownfield (preserve accurate sections, update stale ones). Runs the README↔AGENTS.md consistency checker after AGENTS.md is in place.
- **base-ai-guidance** (skill, base-framework) — Base AI guidance framework for all AI skills
- **** (, preference-source) — Provides standardized project templates and preference definitions

---

- **Full skill**: [`skills/software-dev/project-adopter/SKILL.md`](skills/software-dev/project-adopter/SKILL.md)
- **Install**: `pnpm dlx skills add levonk/skills-releases`
- **Generated**: 2026-07-20T22:00:35Z
