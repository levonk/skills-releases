# Skill Orchestration Map

Which sibling skill owns which fixup domain during Stage B. The rule is
**delegate, never duplicate**: read and follow the owning skill's SKILL.md
(or run its scripts per its docs). Do not hand-write artifacts the sibling
owns — bypassed templates diverge silently over time.

| Fixup domain | Owning skill | Resolution | Notes |
|---|---|---|---|
| Project stack detection | `project-detection` | bundled: `references/included/skills/software-dev/project-detection/` | Runs first — its output is the binding tech context for everything else |
| AGENTS.md / agent files | `agent-file-upsert` | bundled: `references/included/skills/ai/agent-file-upsert/SKILL.md` | Greenfield + brownfield; runs BEFORE readme-upsert so the README can link to it |
| README.md | `readme-upsert` | bundled: `references/included/skills/ai/readme-upsert/SKILL.md` | Handles greenfield + brownfield; runs the README↔AGENTS.md consistency check |
| Dev environment trio | `dev-env-upsert` | runtime (resolve-reference) | Owns devbox.json + .envrc + justfile prime_impl as a coupled unit |
| Non-destructive tooling adds | `project-configuration` | runtime | Adds compatible preferences without overwriting workflows |
| Surgical config edits | `surgical-config` | runtime | For precise edits to package.json/devbox.json/YAML/TOML without clobbering |
| Ignore files | `ignorefile-manager` | runtime | .gitignore/.dockerignore/.cursorignore family from modular concern sources |
| Boilerplate alignment | `project-configuration` + `surgical-config` | runtime | Reconcile project files against the canonical boilerplate; larger adoption → `project-adopter` (alternative path, asks user first) |
| Health audit sweep | `repository-health-review` | runtime: `scripts/resolve-reference.sh skills/software-dev/repository-health-review/` | Deterministic sweep that seeds the doctor phase |
| Model prompting brief | `model-card-review` (workflow) | same distribution | Fallback: references/model-card-brief.md |
| Prompt migration after model change | `ai-model-migration` (workflow) | same distribution | Only when existing prompts must be adapted to the new model |
| Commits | `git-repository-management` | runtime | Commit conventions for auto-fixed + approved change sets |

## Anti-patterns

- Hand-writing README/AGENTS.md content inline — duplicates the owning
  skills' templates and bypasses their consistency checks.
- Running `repository-health-review.sh` and stopping — its categories are
  the floor of the doctor phase, not the ceiling (see doctor-checklist.md).
- Calling `project-adopter` from inside this skill — it is the overwrite
  path; if the fixups reveal the project needs full adoption, surface that
  as a proposed cluster change and let the user choose.
