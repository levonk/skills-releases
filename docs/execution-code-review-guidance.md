<!-- Managed by skills-src build pipeline. Do not edit; changes will be overwritten. -->
<!-- Generated from SKILL.md frontmatter + body by `just catalog` -->

# Skills: the script is materialized into scripts/cli-tool-discovery.sh at build time

> Category: **execution** · Status: ready · Version: 1.4.0

Systematic code review checklist covering infrastructure, schemas, integrations, security, performance, accessibility, and cross-cutting concerns. Use when reviewing a pull request, conducting a PR review, working through a code review checklist before merging, or reviewing a single story commit as part of an automated execution pipeline. Triggers on 'review this code', 'code review checklist', 'PR review', 'pull request review', 'review this PR', or 'review story commit'. Do NOT trigger on general coding questions, bug fixes, feature implementation, or writing new code — this skill is for reviewing existing changes, not authoring them.

## Metadata

| Field | Value |
|-------|-------|
| Name | `code-review-guidance` |
| Category | `execution` |
| Version | `1.4.0` |
| Status | `ready` |
| Owner | https://github.com/levonk |

## Tags
- `ai/skill`
- `code-review`
- `pr-review`
- `checklist`
- `story-review`
- `automated-review`

## Related Skills
- **code-quality-validation** (skill, bundled-dependency) — Bundled via includeTree for offline availability. Provides the quality-validator.sh orchestrator and language-specific detectors/scanners that the reviewer runs during the Dynamic pass to get deterministic lint/format/test/security results before applying the manual checklist. Without this bundle, the reviewer must rely on ad-hoc tool invocation; with it, the reviewer gets the same phased validation pipeline (lint → format → test → security) that CI uses
- **refactor-planning** (skill, related) — For review findings that warrant a structured refactoring effort
- **execute-upsert** (skill, dependent) — Project execution controller that invokes this skill for per-story code review during the execution loop
- **** (, bundled-dependency) — Bundled via includeTree for offline availability. Provides the actual security patterns (banned C functions, hardcoded credential detection, crypto algorithm governance, certificate validation, SSH hardening, security audit playbook) that the Security review category references. Without this bundle, the security category is advisory only — the review subagent has no patterns to check against
- **** (, bundled-dependency) — Bundled via includeTree for offline availability. Provides secret storage and egress firewall patterns (Ansible vault distribution, hybrid vault storage, iron-proxy egress firewall, shared-path cleanliness) that the Security and Infrastructure review categories reference for secret-handling and network-egress review
- **** (, bundled-dependency) — Bundled via includeTree for offline availability. Provides shell-scripting-best-practices.md (shellcheck, shfmt, strict mode, PATH guards) used in the Cross-Cutting Concerns / Testing category to validate generated shell scripts
- **** (, bundled-dependency) — Bundled via includeTree for offline availability. Provides standalone-scripts.md (PEP 723, uv run --script) and pytest-testing-baseline.md used in the Cross-Cutting Concerns / Testing category to validate generated Python scripts and test suites
- **** (, bundled-dependency) — Bundled via includeTree for offline availability. Provides rustfmt-clippy-config.md, quality-gates.md, testing-strategy.md, error-handling.md, and security-auditing.md used in the Cross-Cutting Concerns / Testing category to validate generated Rust code

---

- **Full skill**: [`skills/execution/code-review-guidance/SKILL.md`](skills/execution/code-review-guidance/SKILL.md)
- **Install**: `pnpm dlx skills add levonk/skills-releases`
- **Generated**: 2026-08-20T22:53:30Z
