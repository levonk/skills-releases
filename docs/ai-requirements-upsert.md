<!-- Managed by skills-src build pipeline. Do not edit; changes will be overwritten. -->
<!-- Generated from SKILL.md frontmatter + body by `just catalog` -->

# Skills: the script is materialized into scripts/cli-tool-discovery.sh at build time

> Category: **ai** · Status:  · Version: 2.0.0

Create, update, and maintain a durable requirements ledger that tracks the evolving statement of what a system must do — distinct from feature-scoped PRDs (ephemeral) and ADRs (decision-scoped). Maintains a four-state lifecycle: proposed/ (draft plans, not ready), todo/ (ready change descriptions with a plan), current/ (how the system works now — pure description), and history/ (evolution log with completed plans and superseded snapshots). Supports monorepo decomposition via project/module/slug identity, with a {proj}=skills convention for skill-imposed constraints in consumer repos. Before each edit to current/, snapshots the pre-change version to history/ with a timestamp; edits the current file in place; bumps last-revised; appends a Change Log entry; regenerates INDEX.md and INDEX.html. The process-todo.sh script handles the todo→history+current transition when execute-upsert implements a planned change. Validates ledger consistency across all four states (no orphan history, every current has a creation snapshot, frontmatter dates aligned, proposed/todo status fields correct). Use when users want to codify a durable constraint or capability that survives across features, plan a change to an existing requirement, track how requirements evolved over time, consult the current requirements before starting work, or audit the requirements ledger for consistency. Triggers on "add a requirement", "update requirement", "requirements ledger", "track requirements", "what are the current requirements", "requirement history", "plan a requirement change", or "codify this constraint". Requirements are authored using EARS patterns (5 templates with SHALL) to eliminate vague phrasing at authoring time, and an EARS linter validates the ledger on every validate run. For provability-critical requirements (idempotency, money-moving, auth, concurrency, safety-critical), an optional parallel FSL spec provides Z3 bounded model checking. Do NOT trigger on feature PRD creation (use execute-upsert or greenfield-prd workflow), architectural decisions (use ADRs), rejected scope (use OOS), or one-off task descriptions — this skill is for durable, evolving requirements that outlive any single feature.

## Metadata

| Field | Value |
|-------|-------|
| Name | `requirements-upsert` |
| Category | `ai` |
| Version | `2.0.0` |
| Status | `` |
| Owner |  |

## Related Skills
- **base-ai-guidance** (template, base-framework) — Shared framework for creating all AI guidance types
- **naming-convention-date-embedded** (template, dependency) — Date-embedded naming convention for institutional memory documents — defines the req- and todo- prefixes and YYYY/MM directory structure used by history snapshots and archived todos
- **work-lifecycle** (template, sibling) — Two-stage lifecycle for completable work (features, handoffs). Requirements use a four-state lifecycle (proposed→todo→current+history) because requirements evolve rather than complete
- **execute-upsert** (skill, consumer) — Bundles requirements-upsert via includeTree. Phase 4 reads the ledger (todo/ and current/) before PRD creation; Phase 8 processes todo/ files via process-todo.sh, updates current/, and archives todos to history/ after feature completion
- **agent-file-upsert** (skill, consumer) — Consults the requirements ledger when generating AGENTS.md so agent documentation reflects the project's durable constraints
- **handoff** (skill, consumer) — Bundles requirements-upsert write machinery via includeTree. Writes to todo/ (ready plans) and proposed/ (draft plans) during context capture when new durable constraints are identified
- **ai-upsert** (skill, consumer) — Bundles requirements-upsert write machinery via includeTree. Writes to current/ in skills-src (skill IS the product) or todo/ in consumer repos (using {proj}=skills convention for skill-imposed constraints)

---

- **Full skill**: [`skills/ai/requirements-upsert/SKILL.md`](skills/ai/requirements-upsert/SKILL.md)
- **Install**: `pnpm dlx skills add levonk/skills-releases`
- **Generated**: 2026-09-04T10:32:01Z
