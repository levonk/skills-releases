---
type: Practice
title: Package Naming Convention
description: Packages follow packages/{active|icebox}/{category}/{platform}/{domain}/{package-name}/{language} — status, category (core/features/services/ui), platform (node/web/shared), domain, name, and language are all explicit in the path.
tags: [typescript, monorepo, package-naming, directory-structure, conventions]
timestamp: 2026-07-17T00:00:00Z
---

# Package Naming Convention

## Failure Mode

Placing packages in ad-hoc directories without a consistent structure. Without
explicit naming, the purpose, platform, and domain of every package are unclear
from its path:

- Is this package for Node.js or the browser?
- Is it actively maintained or archived?
- Is it core infrastructure or a feature-specific module?
- What domain does it belong to?

## Practice

All packages follow this structure:

```
packages/{active|icebox}/{category}/{platform}/{domain}/{package-name}/{language}
```

### Path Segments

| Segment | Values | Purpose |
|---------|--------|---------|
| `{active\|icebox}` | `active`, `icebox` | Maintenance status |
| `{category}` | `core`, `features`, `services`, `ui` | Highest-level grouping |
| `{platform}` | `node`, `web`, `shared` | Target runtime |
| `{domain}` | e.g. `auth`, `data-access`, `ai` | Business area |
| `{package-name}` | e.g. `client`, `auth-types` | Specific functionality |
| `{language}` | typically `typescript` | Primary language |

### Categories

- **`core`**: Foundational, shared, product-agnostic code (e.g., logging,
  utils).
- **`features`**: Core business logic and product features (e.g., auth,
  kanban).
- **`services`**: Clients or adapters for external services (e.g., stripe,
  openai).
- **`ui`**: Shared UI components and design system elements.

### Platforms

- **`node`**: Code intended for Node.js (backend servers, CLI tools).
- **`web`**: Code intended for web browsers.
- **`shared`**: Platform-agnostic code (TypeScript types, data contracts,
  universal business logic).

### Examples

- **Active Node.js logging client**:
  `packages/active/core/node/logging/client/typescript`
- **Shared AI data contracts in the icebox**:
  `packages/icebox/features/shared/ai/instrumentation-types/typescript`
- **Active web UI component for authentication**:
  `packages/active/features/web/auth/auth-ui/typescript`

## Rationale

1. **Self-documenting**: The directory path alone tells you the package's
   status, category, platform, domain, and language.
2. **Platform safety**: Prevents platform-specific code from being used in the
   wrong context (e.g., Node.js `fs` in a browser package).
3. **Status clarity**: `active` vs `icebox` immediately shows maintenance
   status.
4. **Domain organization**: Grouping by domain makes it easy to find related
   packages.
5. **Monorepo navigation**: IDE file trees and `find` commands produce
   meaningful, sorted output.

## Related Concepts

- [App Naming Convention](/app-naming-convention.md) — the parallel structure
  for applications.
- [Monorepo Structure](/monorepo-structure.md) — the overall layout that
  packages live within.
- [pnpm and Nx](/pnpm-nx-monorepo.md) — workspace globs consume
  this directory structure.

## Citations

[1] [ARCHITECTURE.md](https://github.com/levonk/job-aide/blob/main/internal-docs/ARCHITECTURE.md) — Package Structure section
[2] [ADR-20251014001: Refined Package Organization](https://github.com/levonk/job-aide/blob/main/internal-docs/adr/adr-20251014001-refined-package-organization.md)
[3] [ADR-20251016001: Package Path Modifier](https://github.com/levonk/job-aide/blob/main/internal-docs/adr/adr-20251016001-package-path-modifier.md)
