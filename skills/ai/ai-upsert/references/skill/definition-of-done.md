# Definition of Done

## Table of Contents

1. [Phased Pipeline](#phased-pipeline)
2. [Phase 4 Concurrency Lock](#phase-4-concurrency-lock)
3. [Run Log (Crash-Safe Progress)](#run-log-crash-safe-progress)
4. [Blocked Items and Human Handoff Routing](#blocked-items-and-human-handoff-routing)
5. [Artifact Structure (Skills)](#artifact-structure-skills)
6. [Artifact Structure (Knowledge Bundles)](#artifact-structure-knowledge-bundles)
7. [Frontmatter/Metadata](#frontmattermetadata)
8. [Content Quality](#content-quality)
9. [Build/Validation](#buildvalidation)
10. [Commit (Phase 5)](#commit-phase-5)
11. [Hygiene](#hygiene)
12. [Not Done (common false-completion signals)](#not-done-common-false-completion-signals)

Before declaring the ai-upsert run complete, verify every item below.
Items marked **[script]** are deterministically verified by a script — if
the script exits non-zero, the item is NOT done. Items marked **[manual]**
require the agent to check something the scripts cannot verify.

## Phased Pipeline

- [ ] **[manual]** Phase 0 (Pre-flight) completed — clean-repo check ran; if dirty, only upsert-touched files will be staged in Phase 5 (Phase 0)
- [ ] **[manual]** Human handoff reconciliation ran — any human handoffs in `human/todo/` whose GitHub issues are closed were archived via `git mv` (Phase 0)
- [ ] **[manual]** Phase 1 (Self-Update) completed — `pnpm dlx skills add levonk/skills-releases --all` ran; if versions changed, the skill was re-invoked (Phase 1)
- [ ] **[script]** Phase 2 (Establish Technologies) — `detect-all-systems.sh . --json` ran and produced a tech context block that constrains all tool references in the generated artifact (Phase 2)
- [ ] **[manual]** Phase 3 (Decision + Mode) — the correct artifact type (Skill / Knowledge Bundle / Agent) was determined; if the user asked for the wrong type, a recommendation was made and the user chose (Phase 3)

## Phase 4 Concurrency Lock

- [ ] **[script]** `scripts/lock/acquire-lock.sh --repo <root> --skill <slug> --slug <run-slug>` ran and returned exit 0 (acquired) or exit 2 (locked — skip policy applied) (Phase 4)
- [ ] **[manual]** If lock was acquired (exit 0), `scripts/lock/release-lock.sh --lock-file <path>` ran after Phase 4.6 passed (Phase 4)
- [ ] **[manual]** If lock was active (exit 2), Phase 4 sub-phases (4.1-4.6) were skipped and the run log records `Phase 4: SKIP` with the lock file path (Phase 4)
- [ ] **[manual]** If Phase 4 was skipped, the workflow auto-merge step was skipped — the PR stays open for a later run to run Phase 4 and merge (Phase 4)

## Run Log (Crash-Safe Progress)

- [ ] **[manual]** Run log initialized in `.agents/log/YYYYMMDDHHmm-ai-upsert-{slug}.md` at the start of Phase 0 (Run Log)
- [ ] **[manual]** Each completed phase has an entry in the run log with status and summary (Run Log)
- [ ] **[manual]** Run log committed alongside the upsert changes in Phase 5 (Run Log)

## Blocked Items and Human Handoff Routing

- [ ] **[manual]** Every `[!]` task follows the blocked-item format contract (BLOCKED ON, NEEDED FROM, WHY CAN'T PROCEED, TRIED, ROUTES TO) (Blocked Items)
- [ ] **[manual]** Every `[!]` task with a HUMAN blocker has a corresponding human handoff in `.agents/handoffs/human/todo/` (Blocked Items)
- [ ] **[manual]** Human handoffs were created immediately when the blocker was identified, not batched at end-of-run (Blocked Items)
- [ ] **[manual]** Human handoffs include Project Context, Feature Context, and Current State sections so the human can understand the full picture without reading the agent handoff (Blocked Items)
- [ ] **[manual]** If `gh` is available and the repo has a GitHub remote, a GitHub issue was created from the human handoff file via `gh issue create --body-file --label "human-handoff"` (Blocked Items)

## Artifact Structure (Skills)

- [ ] **[script]** `scripts/skill/init_skill.py <skill-name> --path <output-directory>` ran successfully (Mode A Step 1) — skill directory, `SKILL.md` scaffold, and example resource directories created
- [ ] **[script]** `scripts/skill/package_skill.py` passes (Mode A Step 11 / Mode B) — skill structure is valid, no forbidden files
- [ ] **[manual]** `SKILL.md` has YAML frontmatter with `name`, `description`, `version`, `date`, `tags`, `see-also` (Mode A Step 2)
- [ ] **[manual]** The skill body does not exceed ~500 lines — detail moved to `references/`, deterministic phases extracted to `scripts/` (Mode A Step 4-5)
- [ ] **[manual]** INSTRUCTIONS.md (if present) source body does not exceed ~500 lines — detail moved to `references/` (Progressive Disclosure)
- [ ] **[manual]** Step numbering uses sequential integers — no lettered sub-steps (`5a`, `5b`, `7a`) (Step Numbering Discipline)

## Artifact Structure (Knowledge Bundles)

- [ ] **[manual]** The bundle follows OKF v0.2 structure: `index.md`, `overview.md`, `log.md`, and concept pages (KB Mode A)
- [ ] **[manual]** OKF v0.2 self-check passes — no contradictions, orphans, or broken links (KB Mode D / Phase 4.3)

## Frontmatter/Metadata

- [ ] **[manual]** `date.last-used` is set to the current date (YYYY-MM-DD) in the generated/updated artifact's frontmatter (Phase 5)
- [ ] **[manual]** `date.knowledge-basis` is updated when content is changed in Mode C (Mode C)
- [ ] **[manual]** `see-also` entries use the correct format — `template:` for build-time, `skill:`/`workflow:` for runtime; no circular dependencies (Cross-Linking)

## Content Quality

- [ ] **[manual]** Every tool reference in the generated artifact agrees with the tech context block from Phase 2 — no `npm`/`npx` in a pnpm project, no `jest` in a Vitest project (Phase 2)
- [ ] **[manual]** The `description` field includes a "Do NOT trigger on..." clause and is wired with `trigger-guard` (Mode A Step 2)
- [ ] **[manual]** `base-ai-guidance` is included via `{{{ includeForCache "includes/base-ai-guidance.md" . }}}` in the header block (Mode A Step 6)
- [ ] **[manual]** The generated skill honors the local project override layer — `base-ai-guidance` (with `project-overrides`) is wired in (CRITICAL: Honor Local Project Overrides)

## Build/Validation

- [ ] **[script]** `scripts/skill/package_skill.py` passes for skills (Phase 4.3)
- [ ] **[script]** `scripts/scan-artifacts.sh` passes — no resolved `$HOME` paths, usernames, or hostnames in generated artifacts (Phase 4.3)
- [ ] **[script]** `scripts/knowledge/validate_sources.py <path>` passes for any markdown file with a `sources:` frontmatter field (Phase 4.3)
- [ ] **[manual]** Shell scripts pass `shellcheck` and `shfmt -d` (Phase 4.2)
- [ ] **[manual]** Python scripts pass `ruff check` and `ruff format --check` with PEP 723 headers and devbox/rtk/uv detection (Phase 4.2)
- [ ] **[manual]** If the artifact is a skill `INSTRUCTIONS.md`, it has a `## Definition of Done` section matching the standardized pattern (Phase 4.5)

## Commit (Phase 5)

- [ ] **[manual]** Only upsert-touched files were staged — never `git add -A` or `git add .` (Phase 5)
- [ ] **[manual]** Commit conventions followed — no AI attribution boilerplate, no "Generated with", no "Co-Authored-By" trailers (Phase 5)
- [ ] **[manual]** Pre/post auto-tags were created by the `git-repository-management` skill (Phase 5)

## Hygiene

- [ ] **[manual]** No secrets, API keys, or tokens in the generated artifact (Security)
- [ ] **[manual]** No hardcoded absolute paths — use indirect references and the Context Declaration (Security)
- [ ] **[manual]** All bundled scripts include PEP 723 headers and devbox/rtk/uv detection patterns (Script Execution Standards)

## Not Done (common false-completion signals)

If any of these are true, the run is NOT complete:

- `package_skill.py` passes but the skill references `npm`/`npx` in a pnpm project → the tech context block from Phase 2 was not applied to the generated artifact (Phase 2)
- `init_skill.py` ran but `SKILL.md` still has TODO placeholders → the scaffolder created the structure but the AI never filled in the content (Mode A Step 2-4)
- `scan-artifacts.sh` passes but was not run on the generated scripts → identity leaks may be present in files the scanner didn't check (Phase 4.3)
- The artifact type was chosen without checking the decision tree → the user may get a skill when they needed a knowledge bundle (or vice versa) (Phase 3)
- Phase 5 committed with `git add -A` → unrelated dirty files from Phase 0 were swept into the upsert commit (Phase 5)
- The generated skill does not include `base-ai-guidance` → the local project override layer is not honored (CRITICAL: Honor Local Project Overrides)
- A `[!]` task has a vague blocker like "waiting on API" without the full format contract (BLOCKED ON, NEEDED FROM, WHY, TRIED, ROUTES TO) → the next reader cannot act on it (Blocked Items)
- A `[!]` task with a HUMAN blocker has no corresponding file in `.agents/handoffs/human/todo/` → the human action request is not durable and will be lost on crash (Blocked Items)
- A human handoff lacks Project Context, Feature Context, or Current State → the human can't understand the request without reading the agent handoff (Blocked Items)
- A human handoff was created but no GitHub issue was created (when `gh` and a remote are available) → the human won't see the action request in their issue list (Blocked Items)
- The run log was not initialized in Phase 0 → a crash loses all progress records (Run Log)
- INSTRUCTIONS.md source body exceeds ~500 lines → progressive disclosure was not applied, detail should be in `references/` (Progressive Disclosure)
- Step numbering uses lettered sub-steps (`5a`, `5b`, `7a`) → the author avoided renumbering; fix before declaring done (Step Numbering Discipline)
