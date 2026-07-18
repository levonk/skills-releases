---
type: Practice
title: App Naming Convention
description: Applications follow apps/{status}/{product-suite}/{app-name}/{platform}/{language} — status, product suite, app name, platform, and language are all explicit in the path.
tags: [typescript, monorepo, app-naming, directory-structure, conventions]
timestamp: 2026-07-17T00:00:00Z
---

# App Naming Convention

## Failure Mode

Placing applications in flat or ad-hoc directories without consistent
structure. Without explicit naming, it's unclear:

- Is this app actively maintained or a prototype?
- Which product suite does it belong to?
- What platform does it target?
- What language is it written in?

## Practice

All applications follow this structure:

```
apps/{status}/{product-suite}/{app-name}/{platform}/{language}
```

### Path Segments

| Segment | Values | Purpose |
|---------|--------|---------|
| `{status}` | `active`, `icebox` | Maintenance status |
| `{product-suite}` | e.g. `jobs-apps` | Logical grouping |
| `{app-name}` | e.g. `ai-resume-analyzer` | Specific application |
| `{platform}` | `web`, `node`, etc. | Runtime target |
| `{language}` | typically `typescript` | Primary language |

### Status Values

- **`active`**: Applications currently being worked on or fixed.
- **`icebox`**: Applications not being actively maintained (prototypes,
  archived).

### Examples

- **Active web app in the jobs suite**:
  `apps/active/jobs-apps/ai-resume-analyzer/web/typescript`
- **Icebox Node.js CLI app**:
  `apps/icebox/jobs-apps/batch-processor/node/typescript`

## Rationale

1. **Self-documenting**: The directory path tells you the app's status, suite,
   name, platform, and language.
2. **Status clarity**: `active` vs `icebox` separates working apps from
   prototypes.
3. **Product suite grouping**: Related apps are clustered together in the file
   tree.
4. **Platform explicit**: Prevents confusion about deployment targets.
5. **Parallel to packages**: The structure mirrors the [Package Naming
   Convention](/package-naming-convention.md), making the monorepo consistent.

## Relationship to Packages

Apps consume packages from `packages/active/`. The parallel structure makes
the dependency direction clear:

```
apps/active/jobs-apps/ai-resume-analyzer/web/typescript
  → depends on →
packages/active/core/node/logging/client/typescript
packages/active/features/web/auth/auth-ui/typescript
```

## Related Concepts

- [Package Naming Convention](/package-naming-convention.md) — the parallel
  structure for packages.
- [Monorepo Structure](/monorepo-structure.md) — the overall layout.
- [pnpm and Nx](/pnpm-nx-monorepo.md) — workspace globs consume
  this directory structure.

## Citations

[1] [ARCHITECTURE.md](https://github.com/levonk/job-aide/blob/main/internal-docs/ARCHITECTURE.md) — Application Structure section
[2] [ADR-20251014002: Application Organization](https://github.com/levonk/job-aide/blob/main/internal-docs/adr/adr-20251014002-application-organization.md)
