<!-- Managed by skills-src build pipeline. Do not edit; changes will be overwritten. -->
<!-- Generated from SKILL.md frontmatter + body by `just catalog` -->

# Skills: the script is materialized into scripts/cli-tool-discovery.sh at build time

> Category: **software-dev** · Status: ready · Version: 1.0.0

Create or update UI/UX tests for web and mobile applications using a two-tier testing model: deterministic requirements coverage (agent-browser for web, agent-device for mobile — no API keys needed) and AI-driven usability testing (Stagehand for web, finalrun-agent for mobile — BYOK). Generates coverage test specs from requirements documents, usability test specs from natural-language user tasks, wires them into CI with graceful missing-key handling, and ensures the quality gate degrades gracefully when LLM keys are absent. Use when setting up UI/UX testing for a project, creating UI requirements coverage tests, creating UX usability tests, adding agent-browser or agent-device to CI, integrating Stagehand or finalrun-agent, or enforcing UI/UX quality standards. Triggers on 'set up UI testing', 'create UX tests', 'UI requirements coverage', 'UX usability testing', 'agent-browser tests', 'agent-device tests', 'Stagehand tests', 'finalrun tests', 'UI/UX quality gate', or 'ui-ux test upsert'. Make sure to use this skill whenever the user mentions UI/UX testing setup, requirements coverage testing, usability test creation, or wants to enforce that all UI requirements are represented and users can accomplish tasks without documentation, even if they don't explicitly ask for 'ui-ux-test-upsert'. Do NOT trigger on writing unit tests (use unit-test-writing), running existing test suites (use code-quality-validation), planning refactors (use refactor-planning), setting up CI/CD pipelines (use cicd-upsert), or general testing questions — this skill creates and wires UI/UX tests, it does not run them or manage the pipeline.

## Metadata

| Field | Value |
|-------|-------|
| Name | `ui-ux-test-upsert` |
| Category | `software-dev` |
| Version | `1.0.0` |
| Status | `ready` |
| Owner | https://github.com/levonk |

## Related Skills
- **unit-test-writing** (skill, sibling) — Peer test-writing skill for unit tests (Osherove style). This skill is the UI/UX equivalent — it creates UI requirements coverage tests and UX usability tests. Both are foundational test-writing skills that other skills dispatch to
- **project-adopter** (skill, dependent) — Project-adopter sets up project infrastructure and can dispatch this skill to wire UI/UX testing into the project's quality gate during adoption
- **code-quality-validation** (skill, complement) — Runs the test suite including UI/UX tests created by this skill. This skill creates the tests; code-quality-validation executes them
- **cicd-upsert** (skill, complement) — Builds the CI/CD pipeline. This skill provides the UI/UX test steps that cicd-upsert wires into the pipeline
- **project-detection** (skill, dependency) — Detects the project's platform (web, iOS, Android, React Native) and test framework so generated tests use the project's existing tooling
- **regression-test-mining** (skill, related) — Mines git history for bug-fix commits and dispatches unit-test-writing. This skill is the UI/UX counterpart — it creates tests from requirements and user tasks rather than from git history
- **** (, reference) — Knowledge bundle containing the UI requirements coverage and UX usability testing practices this skill implements

---

- **Full skill**: [`skills/software-dev/ui-ux-test-upsert/SKILL.md`](skills/software-dev/ui-ux-test-upsert/SKILL.md)
- **Install**: `pnpm dlx skills add levonk/skills-releases`
- **Generated**: 2026-08-10T21:38:16Z
