<!-- Managed by skills-src build pipeline. Do not edit; changes will be overwritten. -->
<!-- Generated from SKILL.md frontmatter + body by `just catalog` -->

# Skills: the script is materialized into scripts/cli-tool-discovery.sh at build time

> Category: **software-dev** · Status: ready · Version: 1.0.0

Write unit tests in the style of Roy Osherove's 'The Art of Unit Testing' — readable, maintainable, and trustworthy. Use when writing unit tests, adding test coverage, creating test cases for existing code, or learning unit testing best practices. Triggers on 'write unit tests', 'create tests', 'test this code', 'add test coverage', 'unit test best practices', or 'Roy Osherove style tests'. Do NOT trigger on general coding questions, bug fixes, feature implementation, or end-to-end/integration test setup — this skill is for unit test authoring, not integration or e2e testing.

## Metadata

| Field | Value |
|-------|-------|
| Name | `unit-test-writing` |
| Category | `software-dev` |
| Version | `1.0.0` |
| Status | `ready` |
| Owner | https://github.com/levonk |

## Quick Start

1. **Pick a unit** — one behavior of one logical unit (a function, a class method).
2. **Name the test** using the three-part pattern: `MethodUnderTest_Scenario_ExpectedOutcome`.
3. **Arrange** — set up the minimal state and inputs.
4. **Act** — call the unit under test exactly once.
5. **Assert** — verify the single observable outcome.
6. **Run** — the test should fail for the right reason before the code exists (TDD), or pass for the right reason after.
7. **Review against the three pillars** — readable? maintainable? trustworthy? (see below)

## Related Skills
- **code-quality-validation** (skill, related) — Test execution and validation as part of the broader quality gate
- **code-review-guidance** (skill, related) — Review test code with the same rigor as production code
- **refactor-planning** (skill, related) — Characterization tests are the foundation of safe refactoring
- **** (, reference) — CI/CD testing patterns and pipeline integration

---

- **Full skill**: [`skills/software-dev/unit-test-writing/SKILL.md`](skills/software-dev/unit-test-writing/SKILL.md)
- **Install**: `pnpm dlx skills add levonk/skills-releases`
- **Generated**: 2026-07-20T22:00:35Z
