<!-- Managed by skills-src build pipeline. Do not edit; changes will be overwritten. -->
<!-- Generated from SKILL.md frontmatter + body by `just catalog` -->

# Skills: the script is materialized into scripts/cli-tool-discovery.sh at build time

> Category: **software-dev** · Status:  · Version: 1.0.0

Create, update, and maintain a durable requirements ledger that tracks the evolving statement of what a system must do — distinct from feature-scoped PRDs (ephemeral) and ADRs (decision-scoped). Maintains a two-layer structure: current/ (the living spec, one file per requirement) and history/ (snapshots taken before each substantive change). Supports monorepo decomposition via project/module/slug identity. Before each edit, snapshots the pre-change version to history/ with a timestamp; edits the current file in place; bumps last-revised; appends a Change Log entry; regenerates INDEX.md. Validates ledger consistency (no orphan history, every current has a creation snapshot, frontmatter dates aligned). Use when users want to codify a durable constraint or capability that survives across features, track how requirements evolved over time, consult the current requirements before starting work, or audit the requirements ledger for consistency. Triggers on "add a requirement", "update requirement", "requirements ledger", "track requirements", "what are the current requirements", "requirement history", or "codify this constraint". Requirements are authored using EARS patterns (5 templates with SHALL) to eliminate vague phrasing at authoring time, and an EARS linter validates the ledger on every validate run. For provability-critical requirements (idempotency, money-moving, auth, concurrency, safety-critical), an optional parallel FSL spec provides Z3 bounded model checking. Do NOT trigger on feature PRD creation (use execute-upsert or greenfield-prd workflow), architectural decisions (use ADRs), rejected scope (use OOS), or one-off task descriptions — this skill is for durable, evolving requirements that outlive any single feature.

## Metadata

| Field | Value |
|-------|-------|
| Name | `requirements-upsert` |
| Category | `software-dev` |
| Version | `1.0.0` |
| Status | `` |
| Owner |  |

## Related Skills
- **base-ai-guidance** (template, base-framework) — Shared framework for creating all AI guidance types
- **naming-convention-date-embedded** (template, dependency) — Date-embedded naming convention for institutional memory documents — defines the req- prefix and YYYY/MM directory structure used by history snapshots
- **work-lifecycle** (template, sibling) — Two-stage lifecycle for completable work (features, handoffs). Requirements use a different lifecycle (current→history-on-supersession) because requirements evolve rather than complete
- **execute-upsert** (skill, consumer) — Bundles requirements-upsert via includeTree. Phase 4 reads the ledger before PRD creation; Phase 8 snapshots changed requirements to history after feature completion
- **agent-file-upsert** (skill, consumer) — Consults the requirements ledger when generating AGENTS.md so agent documentation reflects the project's durable constraints

---

- **Full skill**: [`skills/software-dev/requirements-upsert/SKILL.md`](skills/software-dev/requirements-upsert/SKILL.md)
- **Install**: `pnpm dlx skills add levonk/skills-releases`
- **Generated**: 2026-09-02T09:55:48Z
