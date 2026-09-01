# Directory Update Log

## 2026-08-30

* **Update**: Added "Keeping Per-Step Verification Fast" guidance to
  Phase 4 in [INSTRUCTIONS.md.tmpl](INSTRUCTIONS.md.tmpl). The
  evolutionary workflow runs the full verification gate after every
  task; if the suite is slow the temptation is to skip tests — instead,
  run only affected tests (git-based change detection + the test
  runner's dependency-aware filtering: Vitest `--changed`, Jest
  `--findRelatedTests`, pytest-testmon, cargo-nextest). Never weaken
  the gate. Run the full suite at Phase 5.
* **Update**: Updated the during-refactor checklist in
  [references/refactor-checklist.md](references/refactor-checklist.md)
  with selective-test guidance and a callout pointing to the
  cicd-testing-practices knowledge bundle → *Fast Test Feedback*.
* **Update**: Updated the Definition of Done execution item and added a
  false-completion signal for gate-weakening in
  [INSTRUCTIONS.md.tmpl](INSTRUCTIONS.md.tmpl).
* **Update**: Added `knowledge: cicd-testing-practices` see-also entry
  in [SKILL.md.tmpl](SKILL.md.tmpl).

## 2026-07-18

* **Initialization**: Created the `refactor-planning` skill from the
  `rules/software-dev/general/code-plan-refactor.md` rule (442 lines).
  Condensed the evolutionary refactor workflow into the SKILL body and moved
  detailed catalogs to references.
* **Creation**: Authored [SKILL.md.tmpl](SKILL.md.tmpl) with frontmatter,
  base-ai-guidance include, five-phase evolutionary refactor workflow, code
  smell quick reference, and refactoring techniques summary.
* **Creation**: Authored reference files:
  - [references/code-smell-catalog.md](references/code-smell-catalog.md) —
    full code smell catalog (Bloaters, OO Abusers, Change Preventers,
    Dispensables, Couplers, AI-specific) with remediation guidance.
  - [references/legacy-code-techniques.md](references/legacy-code-techniques.md)
    — Michael Feathers' seam, characterization test, and dependency-breaking
    techniques.
  - [references/refactor-checklist.md](references/refactor-checklist.md) —
    pre-refactor, during-refactor, and post-refactor checklists plus the
    business-impact prioritization procedure.
