<!-- Managed by skills-src build pipeline. Do not edit; changes will be overwritten. -->
<!-- Generated from SKILL.md frontmatter + body by `just catalog` -->

# Skills: the script is materialized into scripts/cli-tool-discovery.sh at build time

> Category: **software-dev** · Status: ready · Version: 1.0.0

Orchestrate full onboarding for a new project or a newly selected AI model: runs sibling skills to fix up README, AGENTS.md, build/tooling, docs, and boilerplate; reviews the model card of the selected model (via the model-card-review workflow) so requests are phrased for that model; then runs a doctor phase that reads the entire project and finds everything broken, inconsistent, inefficient, or no longer needed — auto-fixing what is certain and emitting a report where every proposed and optional change has a letter+number ID (letter = change cluster, number = specific change) so the user can reply 'apply B2, all of D, skip S1'. Use when adopting a new project, switching or adding an AI model, or asking an agent to 'read this whole project and tell me what needs fixing.' Triggers on 'new project', 'onboard project', 'new model', 'switch model', 'project onboarding', 'project doctor', 'audit this whole repo and fix it', or 'set up this project for <model>'. Do NOT trigger on single-file reviews, PR reviews (use code-review-guidance), pure repo health scoring (use repository-health-review), opinionated full best-practices adoption that overwrites preferences (use project-adopter), or creating skills/workflows (use ai-upsert).

## Metadata

| Field | Value |
|-------|-------|
| Name | `project-onboarding` |
| Category | `software-dev` |
| Version | `1.0.0` |
| Status | `ready` |
| Owner | https://github.com/levonk |

## Tags
- `ai/skill`
- `software-development`
- `project-management`
- `onboarding`
- `project-doctor`
- `model-card`
- `orchestrator`
- `repository-management`
- `quality-assurance`

## References

- [Skill Orchestration Map](references/skill-orchestration-map.md) — which
  sibling skill owns which fixup; the delegation contract
- [Doctor Checklist](references/doctor-checklist.md) — the whole-project
  audit sweep, organized by change cluster
- [Change ID Scheme](references/change-id-scheme.md) — the letter+number
  report format and selection syntax (`B2`, `all-D`, `!S1`)
- [Model Card Brief](references/model-card-brief.md) — brief schema and
  the fallback when the model-card-review workflow is not installed

---

## Related Skills
- **project-detection** (skill, dependency) — Detects the project's stack, build system, and tooling — establishes the baseline the fixups and doctor phase audit against. Bundled via includeTree for offline availability.
- **readme-upsert** (skill, dependency) — Owns README.md creation/update. Read and follow the bundled SKILL.md — never hand-write README content.
- **agent-file-upsert** (skill, dependency) — Owns AGENTS.md creation/update. Read and follow the bundled SKILL.md — runs before readme-upsert so the README can link to it.
- **repository-health-review** (skill, dependency) — Provides the deterministic audit sweep (scripts/repository-health-review.sh) and health categories the doctor phase extends with whole-project AI judgment.
- **project-adopter** (skill, alternative-approach) — For opinionated full adoption that overwrites existing preferences — project-onboarding is the review-first, non-destructive path.
- **project-configuration** (skill, complement) — Non-destructive tooling additions — invoked from the fixup stage when missing tooling needs installing.
- **dev-env-upsert** (skill, complement) — Owns the devbox.json + .envrc + justfile trio — delegated to for environment fixups.
- **ignorefile-manager** (skill, complement) — Owns ignore-file generation/audit — delegated to for .gitignore-family fixups.
- **surgical-config** (skill, complement) — Delegated to for surgical edits to config files (package.json, devbox.json, YAML/TOML) during fixups.
- **git-repository-management** (skill, dependency) — Commit conventions for the auto-fixed and user-approved change sets.
- **** (, dependency) — Reviews the selected model's card/system card/prompting guide and produces the prompting brief used to phrase the doctor-phase audit request.
- **** (, complement) — For adapting existing prompts after the model brief reveals conventions the project's prompts violate.
- **** (, reference) — The 22-criterion model assessment framework — the model-card-review workflow applies its prompting-relevant subset.

---

- **Full skill**: [`skills/software-dev/project-onboarding/SKILL.md`](skills/software-dev/project-onboarding/SKILL.md)
- **Install**: `pnpm dlx skills add levonk/skills-releases`
- **Generated**: 2026-11-21T04:07:51Z
