<!-- Managed by skills-src build pipeline. Do not edit; changes will be overwritten. -->
<!-- Generated from SKILL.md frontmatter + body by `just catalog` -->

# Skills: the script is materialized into scripts/cli-tool-discovery.sh at build time

> Category: **software-dev** · Status: ready · Version: 1.0.0

Mine git history for bug-fix commits and generate the regression tests they are missing. Scans `git log` for conventional `fix:` prefixes, `Fixes #N` / `Closes #N` trailers, revert commits, and `git blame`-identified bug-introducing commits; inventories which fixes lack a regression test; then dispatches `unit-test-writing` to author each missing test in the project's detected framework, with every new test referencing the fix commit SHA that exposed the original bug. Use when users want to backfill regression tests from history, find untested bug fixes, mine commit history for test opportunities, generate regression tests from past bugs, audit which fixes have no test, or harden a codebase against regressions of already-fixed defects. Triggers on 'mine regression tests', 'find untested bug fixes', 'backfill regression tests', 'regression test from history', 'audit fix commits for tests', 'git history test opportunities', or 'which bug fixes have no test'. Make sure to use this skill whenever the user mentions regression test mining, bug-fix commit analysis for test gaps, history-driven test generation, or wants to ensure every past fix has a covering test, even if they don't explicitly ask for 'regression-test-mining'. Do NOT trigger on writing a single unit test for known code (use unit-test-writing), running an existing test suite (use code-quality-validation), planning a refactor (use refactor-planning), organizing commits (use git-repository-management), or general bug triage — this skill mines history for missing tests, it does not fix bugs or author tests in isolation.

## Metadata

| Field | Value |
|-------|-------|
| Name | `regression-test-mining` |
| Category | `software-dev` |
| Version | `1.0.0` |
| Status | `ready` |
| Owner | https://github.com/levonk |

## Related Skills
- **unit-test-writing** (skill, dependency) — Dispatched for the actual Osherove-style test authoring once this skill has identified the bug-fix commits to target. This skill identifies *what* to test; unit-test-writing handles *how* to write the test
- **git-repository-management** (skill, complement) — Provides the `git log`, `git blame`, and `git bisect` patterns this skill reuses for history mining
- **project-detection** (skill, dependency) — Detects the project's test framework (Vitest, pytest, Jest, Go testing, etc.) so generated tests use the framework the project already uses — never imposes a framework the project doesn't use
- **code-quality-validation** (skill, complement) — Runs the test suite after new regression tests are added to confirm they pass against the fixed code and fail against the buggy code (when reproducible)
- **refactor-planning** (skill, related) — Characterization tests and regression tests share the 'capture behavior before changing it' philosophy; refactor-planning consumes regression tests as the foundation of safe refactoring
- **** (, reference) — CI/CD testing patterns for integrating mined regression tests into the pipeline

---

- **Full skill**: [`skills/software-dev/regression-test-mining/SKILL.md`](skills/software-dev/regression-test-mining/SKILL.md)
- **Install**: `pnpm dlx skills add levonk/skills-releases`
- **Generated**: 2026-09-02T09:14:22Z
