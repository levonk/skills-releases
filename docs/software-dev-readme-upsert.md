<!-- Managed by skills-src build pipeline. Do not edit; changes will be overwritten. -->
<!-- Generated from SKILL.md frontmatter + body by `just catalog` -->

# Skills: the script is materialized into scripts/cli-tool-discovery.sh at build time

> Category: **software-dev** · Status: ready · Version: 1.2.0

Generate a project's README.md from scratch (greenfield) or update an existing one (brownfield). Use when creating a new project's README, onboarding a human to an existing codebase, or refreshing a stale README. Triggers on requests like "create README", "generate readme", "update README", "write project readme", or "set up readme for this repo". Do NOT trigger on AGENTS.md generation (use agent-file-upsert), general coding questions, or skill creation (use ai-upsert).

## Metadata

| Field | Value |
|-------|-------|
| Name | `readme-upsert` |
| Category | `software-dev` |
| Version | `1.2.0` |
| Status | `ready` |
| Owner | https://github.com/levonk |

## Tags
- `ai/skill`
- `software-development`
- `documentation`
- `readme`
- `brownfield`
- `greenfield`

## Related Skills
- **agent-file-upsert** (skill, complement) — Generates AGENTS.md hierarchy — run first, then readme-upsert so README can link to AGENTS.md
- **ai-upsert** (skill, sibling) — Same upsert family — handles AI skill creation and updates
- **ai-guidance-improver** (skill, complement) — Quality analysis and improvement of existing AI guidance files
- **project-adopter** (skill, caller) — project-adopter delegates README.md generation to this skill for both greenfield (create-next-app, copier scaffolds, etc.) and brownfield adoptions; see its 'Repository & Ignore File Management' section for the contract
- **** (, complement) — Mermaid syntax conventions (quoted decision labels, <br/> inside quotes) followed by this skill's workflow diagram

---

- **Full skill**: [`skills/software-dev/readme-upsert/SKILL.md`](skills/software-dev/readme-upsert/SKILL.md)
- **Install**: `pnpm dlx skills add levonk/skills-releases`
- **Generated**: 2026-08-10T21:38:16Z
