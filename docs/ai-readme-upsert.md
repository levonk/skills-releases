<!-- Managed by skills-src build pipeline. Do not edit; changes will be overwritten. -->
<!-- Generated from SKILL.md frontmatter + body by `just catalog` -->

# Skills: the script is materialized into scripts/cli-tool-discovery.sh at build time

> Category: **ai** · Status: ready · Version: 1.2.0

Generate a project's README.md from scratch (greenfield) or update an existing one (brownfield). Use when creating a new project's README, onboarding a human to an existing codebase, or refreshing a stale README. Triggers on requests like "create README", "generate readme", "update README", "write project readme", or "set up readme for this repo". Do NOT trigger on AGENTS.md generation (use agent-file-upsert), general coding questions, or skill creation (use ai-skill-upsert).

## Metadata

| Field | Value |
|-------|-------|
| Name | `readme-upsert` |
| Category | `ai` |
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

## Instructions

- **Human tone**: Write for a developer browsing GitHub, not an AI loading context. Full sentences are fine; marketing language is acceptable for the overview
- **Copy-paste ready**: Every command block must be runnable as-is
- **Real paths**: Use actual file paths from the project, not template placeholders
- **Concise**: Aim for 100-200 lines. A README is a landing page, not a manual
- **No duplication**: If content exists in AGENTS.md or the developer guide, link to it rather than copying

## Related Skills
- **agent-file-upsert** (skill, complement) — Generates AGENTS.md hierarchy — run first, then readme-upsert so README can link to AGENTS.md
- **ai-skill-upsert** (skill, sibling) — Same upsert family — handles AI skill creation and updates
- **ai-guidance-improver** (skill, complement) — Quality analysis and improvement of existing AI guidance files
- **project-adopter** (skill, caller) — project-adopter delegates README.md generation to this skill for both greenfield (create-next-app, copier scaffolds, etc.) and brownfield adoptions; see its 'Repository & Ignore File Management' section for the contract
- **** (, complement) — Mermaid syntax conventions (quoted decision labels, <br/> inside quotes) followed by this skill's workflow diagram

---

- **Full skill**: [`skills/ai/readme-upsert/SKILL.md`](skills/ai/readme-upsert/SKILL.md)
- **Install**: `pnpm dlx skills add levonk/skills-releases`
- **Generated**: 2026-07-20T22:00:35Z
