# Granularity Guidance

## What Is a Requirement?

A requirement is a **durable constraint or capability** that survives
across features. It outlives the feature that created it. It persists
until superseded by a newer version.

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

This exception is documented in
`src/shared/includes/naming-convention-date-embedded.md`.

History files do not need the `_` joiner because the path
(`history/YYYY/MM/{proj}/{module}/`) carries the project and module —
the filename only needs `req-` + date + `{slug}`.
