---
type: Synthesis
title: Software Architecture Essentials Overview
description: Synthesis of software architecture practices — philosophy, project structure, data access, configuration, distribution, theming, terminal state, tool detection, extensibility, and auth/environment.
tags: [architecture, overview, synthesis, modular, separation-of-concerns]
timestamp: 2026-07-18T00:00:00Z
---

# Software Architecture Essentials Overview

This bundle documents architectural practices for building modular,
maintainable software. Each concept captures a specific architectural concern
and the practice that addresses it — from the top-level philosophy down to
specific subsystems like theming, terminal state, and tool detection.

## The Architecture Landscape

```
philosophy → project-structure → data-access → configuration → distribution
                                ↓
                  theme → terminal-state → tool-detection → adding-tools → auth-env
```

| Concern | Practice | Prevents |
|---------|----------|----------|
| Philosophy | [Architecture Philosophy](philosophy.md) | Cross-domain leakage, untestable modules, refactoring risk |
| Structure | [Project Structure](project-structure.md) | Flat package sprawl, scattered feature code, unclear ownership |
| Data | [Data Access Layer](data-access-layer.md) | Duplicated data logic, missing auth checkpoints, debugging pain |
| Config | [Configuration System](configuration-system.md) | Override confusion, invalid configs, silent failures |
| Distribution | [Distribution and Packaging](distribution.md) | Heavy runtimes, untracked sizes, undocumented install paths |
| Theming | [Theme System](theme-system.md) | Color drift, broken runtime switching, inconsistent state colors |
| Terminal | [Terminal State Management](terminal-state.md) | Buffer clearing, input races, corrupted terminal state |
| Detection | [Tool Detection Architecture](tool-detection.md) | Brittle PATH assumptions, missing tools, slow re-detection |
| Extensibility | [Adding New Tools](adding-tools.md) | Inconsistent CLI surfaces, scattered wiring, missing tests/docs |
| Auth/Env | [Authentication and Environment Management](auth-env.md) | Browser auth in headless, duplicated env detection, silent auth failures |

## Scope

This bundle covers **software architecture practices** — the structural
decisions and subsystem patterns that keep a codebase modular, maintainable,
and extensible. It does **not** cover:

- Build orchestration (Nx, Turborepo) — see
  [typescript-monorepo-best-practices](../typescript-monorepo-best-practices/overview.md).
- Container build environments — see
  [container-best-practices](../container-best-practices/overview.md).
- Cloud provider infrastructure — see
  [cloud-provider-essentials](../cloud-provider-essentials/overview.md).
- Developer environment setup — see
  [dev-environment-practices](../dev-environment-practices/overview.md).

## Compounding

New lessons from future architecture work — new subsystem patterns, cross-cutting
concerns, scaling thresholds — should be filed as new concept pages. Append to
`log.md` when adding.

## Related Knowledge Bundles

- [dev-environment-practices](../dev-environment-practices/overview.md) —
  Environment setup that hosts the architecture.
- [typescript-monorepo-best-practices](../typescript-monorepo-best-practices/overview.md)
  — Monorepo structure conventions that implement project-structure.md.
- [cloud-provider-essentials](../cloud-provider-essentials/overview.md) —
  Cloud infrastructure that the distribution practice deploys to.
- [container-best-practices](../container-best-practices/overview.md) —
  Container packaging that implements the distribution practice.

## Sources

- `src/current/rules/software-dev/general/architecture/*.md` — 10 architecture rule files migrated 2026-07-18.
