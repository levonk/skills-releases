<!-- Managed by skills-src build pipeline. Do not edit; changes will be overwritten. -->
<!-- Generated from SKILL.md frontmatter + body by `just catalog` -->

# Skills: the script is materialized into scripts/cli-tool-discovery.sh at build time

> Category: **software-dev** · Status: ready · Version: 1.0.0

Systematic code review checklist covering infrastructure, schemas, integrations, security, performance, accessibility, and cross-cutting concerns. Use when reviewing a pull request, conducting a PR review, or working through a code review checklist before merging. Triggers on 'review this code', 'code review checklist', 'PR review', 'pull request review', or 'review this PR'. Do NOT trigger on general coding questions, bug fixes, feature implementation, or writing new code — this skill is for reviewing existing changes, not authoring them.

## Metadata

| Field | Value |
|-------|-------|
| Name | `code-review-guidance` |
| Category | `software-dev` |
| Version | `1.0.0` |
| Status | `ready` |
| Owner | https://github.com/levonk |

## Tags
- `ai/skill`
- `code-review`
- `pr-review`
- `checklist`

## Quick Start

1. **Gather context** — read the PR description, linked issues, and the diff.
2. **Understand data flow** — trace how data moves through the app; note any new
   patterns and why they were introduced.
3. **Run the checklist** — work through each category below; flag blockers and
   suggestions separately.
4. **Surface schema/integration risk** — call out anything that requires
   coordination (migrations, API consumers, feature flags).
5. **Write the review** — lead with blockers, then suggestions, then nits.
   Reference the specific checklist item for each finding.

## Related Skills
- **code-quality-validation** (skill, related) — Automated quality checks (lint, test, security scan) that complement manual review
- **refactor-planning** (skill, related) — For review findings that warrant a structured refactoring effort
- **** (, reference) — Security patterns and banned-function checks for the security review category

---

- **Full skill**: [`skills/software-dev/code-review-guidance/SKILL.md`](skills/software-dev/code-review-guidance/SKILL.md)
- **Install**: `npx skills add levonk/skills-releases`
- **Generated**: 2026-07-18T08:27:30Z
