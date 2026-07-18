---
type: Synthesis
title: Frontend Stack Practices Overview
description: Synthesis of frontend stack practices — explicit file extensions, path alias safety, ESLint composition API, Vitest testing, and code style conventions for TypeScript/React projects.
tags: [typescript, react, eslint, vitest, frontend, overview, synthesis]
timestamp: 2026-07-17T00:00:00Z
---

# Frontend Stack Practices Overview

This bundle documents practices for the TypeScript/React frontend stack. Each
concept was extracted from real project ADRs — the standards that ensure
consistent module systems, safe imports, flexible linting, and unified testing
across all frontend projects.

## The Frontend Stack

```
file-extensions → path-aliases → eslint-config → testing → code-style
```

| Phase | Practice | Prevents |
|-------|----------|----------|
| Modules | [Explicit File Extensions](explicit-file-extensions.md) | Ambiguous module system, tooling confusion, ESM/CJS errors |
| Imports | [Path Alias Safety](path-alias-safety.md) | npm scope conflicts, import confusion, monorepo ambiguity |
| Linting | [ESLint Composition API](eslint-composition-api.md) | Rigid configs, forced forks, plugin divergence |
| Testing | [Vitest Testing Framework](vitest-testing-framework.md) | Slow tests, Jest config complexity, fragmented test runners |
| Style | [Code Style Conventions](code-style-conventions.md) | Inconsistent formatting, style debates, mixed conventions |

## Scope

This bundle covers **frontend TypeScript/React development practices** — file
extensions, path aliases, ESLint configuration, testing, and code style. It does
**not** cover:

- Monorepo build orchestration — see
  [typescript-monorepo-best-practices](../typescript-monorepo-best-practices/overview.md).
- Dev environment setup — see
  [dev-environment-practices](../dev-environment-practices/overview.md).
- Container patterns — see
  [container-best-practices](../container-best-practices/overview.md).

## Sources

- `internal-docs/adr/adr-20251019001-explicit-file-extensions.md` — job-aide (204 lines)
- `internal-docs/adr/adr-20251019002-path-alias-safety.md` — job-aide (253 lines)
- `internal-docs/adr/adr-20251019003-plugin-composition-api.md` — job-aide (266 lines)
- `internal-docs/adr/adr-20251106002-vitest-for-testing.md` — boilerplate (83 lines)

## Related Knowledge Bundles

- [typescript-monorepo-best-practices](../typescript-monorepo-best-practices/overview.md)
  — Monorepo orchestration that uses these frontend conventions
- [dev-environment-practices](../dev-environment-practices/overview.md) —
  Environment management for frontend projects
- [web-resource-catalog](../web-resource-catalog/overview.md) — External
  resources for frontend development

## Citations

[1] `internal-docs/adr/adr-20251019001-explicit-file-extensions.md` — job-aide
[2] `internal-docs/adr/adr-20251019002-path-alias-safety.md` — job-aide
[3] `internal-docs/adr/adr-20251019003-plugin-composition-api.md` — job-aide
[4] `internal-docs/adr/adr-20251106002-vitest-for-testing.md` — levonk-base-boilerplate
