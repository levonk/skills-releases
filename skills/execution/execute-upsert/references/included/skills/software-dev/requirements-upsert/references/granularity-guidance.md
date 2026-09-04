# Granularity Guidance

## What Is a Requirement?

A requirement is a **durable constraint or capability** that survives
across features. It outlives the feature that created it. It persists
until superseded by a newer version.

## The Four-State Lifecycle

The requirements ledger has four states. Each state is a directory under
`internal-docs/reqs/`:

```
internal-docs/reqs/
├── proposed/    ← draft plans, not ready to work on
├── todo/        ← ready plans (change descriptions)
├── current/     ← how the system works now (pure description)
├── history/     ← evolution log (completed plans + superseded snapshots)
└── INDEX.md     ← auto-generated view across all four states
```

### What each state holds

| Directory | What it holds | Question it answers |
|-----------|---------------|---------------------|
| `proposed/` | Draft change descriptions — not ready to be worked on | "What might we change someday?" |
| `todo/` | Ready change descriptions — a plan for implementing a change | "What are we about to change and why?" |
| `current/` | How the system works right now — pure description, no plan baggage | "What does the system do today?" |
| `history/` | Evolution log — completed plans and superseded snapshots | "How did it get to be this way?" |

### Key distinction: `current/` is NOT work to be done

`current/` is always a clean record of how things work now. You can read
`current/` and trust that it describes reality, not aspirations. When a
todo is implemented, `current/` is updated to reflect the new reality,
and the todo file moves to `history/` as the record of that evolution
step.

### Transitions

```
proposed/ ──(matures, becomes ready)──→ todo/
todo/ ──(execute-upsert implements)──→ current/ updated + todo archived to history/
current/ ──(superseded by next change)──→ history/ (old version snapshotted)
```

- **proposed → todo**: When a draft plan is validated and ready to be
  picked up. Set `date.ready` in the frontmatter and move the file from
  `proposed/` to `todo/`.
- **todo → history**: When execute-upsert implements the change described
  in the todo. The `process-todo.sh` script snapshots the pre-change
  `current/` version to `history/`, archives the todo to `history/` with
  a timestamp prefix, and the AI updates `current/` to reflect the new
  behavior.
- **current → history**: When a current requirement is superseded by a
  new version. The `snapshot-requirement.sh` script copies the pre-change
  version to `history/` before the current file is edited in place.

### What belongs in `todo/` (not `proposed/`)

A todo is a **commitment to implement**. It has a `date.ready` set,
meaning someone has decided this change should happen. The format is
flexible — it can be a three-part structure (previous state, desired
state, gap), a checklist, a narrative, or any format that communicates
the plan. The point is that it's a plan, not a requirement.

A proposed item is a **draft that hasn't been validated**. It may have
open questions, unresolved dependencies, or unclear motivation. It sits
in `proposed/` until those are resolved, then moves to `todo/`.

### What does NOT belong in the ledger

An idea you're not convinced of isn't a requirement yet. It hasn't
passed the Survival Test. It belongs in notes, a discussion, or an ADR
draft — not in the requirements ledger. When you become convinced, it
moves to `proposed/`. If you decide against it, that's an OOS (out of
scope) entry.

## Requirements vs PRDs vs ADRs vs OOS

| Artifact | Scope | Lifespan | Question it answers |
|----------|-------|----------|---------------------|
| **Requirement** | System-wide | Durable (evolving) | What must the system do? |
| **PRD** | Feature-scoped | Ephemeral (archived) | What will this feature build? |
| **ADR** | Decision-scoped | Durable (superseded) | Why was this approach chosen? |
| **OOS** | Rejected scope | Durable | What was explicitly not built? |

## Decision Guide

**Is it a requirement?**

- YES: "All API endpoints must be versioned" — survives across features
- YES: "Auth must support MFA via TOTP" — survives until superseded
- YES: "CI build must complete in under 60 seconds" — non-functional, durable
- YES: "All database writes must go through the repository layer" —
  architectural constraint, durable
- NO: "Add a settings page" — feature-scoped, belongs in a PRD
- NO: "Fix the login redirect bug" — task-scoped, belongs in a ticket/PRD
- NO: "Refactor auth to use Result pattern" — refactor-scoped, belongs in
  a PRD or ADR
- NO: "We chose TOTP over SMS because SMS is insecure" — decision-scoped,
  belongs in an ADR
- NO: "We will not build a mobile app this quarter" — rejected scope,
  belongs in OOS

## The Survival Test

Ask: "Will this statement still be true after the feature that
implements it ships and is archived?"

- If YES → it is a requirement
- If NO → it belongs in the PRD

## The Supersession Test

Ask: "Could this statement change without the system being rewritten?"

- If YES → it is a requirement (requirements evolve)
- If NO → it might be an architectural invariant (consider an ADR with a
  linked requirement)

## Project Identity: `{proj}` Convention

The ledger uses a three-part identity: `{proj}/{module}/{slug}`.

- `{proj}` — a **logical project name**, not strictly the repo name. The
  repo name is the default for single-project repos, but the structure
  supports multiple logical projects within one repo.
- `{module}` — the module or package within the project. Use `_root` if
  the project has no module subdivision.
- `{slug}` — kebab-case, 3-6 words, describing the requirement (not the
  feature that created it).

### Skills-src (this repo)

In skills-src, the skills ARE the product. Use `{proj}` = `skills-src`
and `{module}` = the skill category:

```
skills-src/ai/handoff-context-capture
skills-src/execution/execute-upsert-pipeline
skills-src/templater/request-validation
```

### Consumer repos (where skills are installed)

In a consumer repo (e.g. `my-store`, a web app), the product has its own
requirements and installed skills impose constraints on how the product
is built. These are different concerns and should be separated:

- **Product requirements**: `{proj}` = repo name (e.g. `my-store`)
- **Skill-imposed constraints**: `{proj}` = `skills`

```
my-store/_root/api-versioning              → product requirement
my-store/auth/mfa-totp                     → product requirement
skills/_root/pnpm-only                     → skill-imposed constraint
skills/ai-guidance/pep723-headers          → skill-imposed constraint
```

The `skills` project groups all skill-imposed constraints together in
INDEX.md, keeping them separate from product requirements without
fragmenting across 30 individual skill projects. Skills are a single
logical project with modules for categories.

### Who writes where

| Skill | In skills-src | In consumer repos |
|-------|---------------|-------------------|
| `ai-upsert` | `current/` (skill IS the product, active immediately) | `todo/` (skill imposes a constraint the consumer hasn't adopted yet) |
| `handoff` | `todo/` or `proposed/` (plans identified during context capture) | `todo/` or `proposed/` |
| `execute-upsert` | Processes `todo/`, updates `current/`, archives to `history/` | Same |

## Composite Identity Joiner

Current requirement filenames use `_` to join the project, module, and
slug components: `{proj}_{module}_{slug}.md`. This is a deliberate
exception to the repo's kebab-case naming convention.

Rationale: `{proj}`, `{module}`, and `{slug}` are each kebab-case
internally (they may contain `-`). Using `_` as the joiner lets you
distinguish the three components when parsing the filename. For example,
`skills-src_templater_request-validation` unambiguously splits into
`skills-src`, `templater`, `request-validation` on `_`. If `-` were the
joiner, `skills-src-templater-request-validation` would be ambiguous.

This exception is documented in the `naming-convention-date-embedded`
include, published at
<https://github.com/levonk/skills-releases/blob/main/includes/naming-convention-date-embedded.md>.

History files do not need the `_` joiner because the path
(`history/YYYY/MM/{proj}/{module}/`) carries the project and module —
the filename only needs `req-` + date + `{slug}` (for snapshots) or
`todo-` + date + `{slug}` (for archived todos).
