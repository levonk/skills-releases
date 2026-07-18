---
type: Practice
title: Monorepo Structure — active vs icebox, categories, platforms, and domains
description: Organize packages and apps by status (active/icebox), category (core/features/services/ui/tools), platform (node/web/shared), and domain to keep boundaries clear and dependencies acyclic.
tags: [typescript, monorepo, structure, packages, apps, active, icebox]
timestamp: 2026-07-17T00:00:00Z
---

# Monorepo Structure

## Failure Mode

A monorepo becomes a tangled dependency graph because packages are organized by
team or historical accident, not by stability and reuse. Prototype code in
`icebox` is treated as production, and `core` packages depend on `features`
packages, creating circular references.

## Symptoms

- Finding where to put a new package takes 10 minutes of discussion.
- A `core` utility imports from an `app` or `features` package.
- `icebox` prototypes are imported by `active` production apps.
- Two packages named `utils` or `types` collide.

## Practice

### Status

| Status | Meaning |
|--------|---------|
| `active` | Currently maintained, production or actively developed |
| `icebox` | Prototype, experiment, or temporarily paused; not for production dependency |

`active` packages may depend on other `active` packages. `active` packages must
not depend on `icebox` packages.

### Package Categories

```
packages/{status}/{category}/{platform}/{domain}/{package-name}/{language}
```

| Category | Purpose | Examples |
|----------|---------|----------|
| `core` | Foundational, shared, product-agnostic | `runtime-guards`, `types`, `utils` |
| `features` | Core business logic and product features | `auth`, `pdf-converter` |
| `services` | Clients/adapters for external services | `ai`, `blob`, `kv`, `oltp` |
| `ui` | Shared UI components and design system | (future) |
| `tools` | Tooling configuration packages | `eslint-config`, `typescript-config`, `vitest-config` |

### Application Categories

```
apps/{status}/{product-suite}/{app-name}/{platform}/{language}
```

- `apps/active/job/ai-resume-analyzer/web/typescript`
- `apps/active/politics/left-parody/web/typescript`
- `apps/active/cli/ticketr` (Rust, no language suffix)

### Platform

| Platform | Environment |
|----------|---------------|
| `node` | Node.js runtime |
| `web` | Browser/runtime-agnostic web code |
| `shared` | Platform-agnostic code |

### Domain

- Use a domain name when a category contains multiple subdomains.
- Example: `packages/active/services/any/ai/core/typescript` (`any` platform,
  `ai` domain, `core` package name).

### Dependency Direction

Allowed: `apps` → `features` → `core` / `services`
Forbidden: `core` → `features`, `active` → `icebox`, circular references.

## Citations

[1] [job-aide ARCHITECTURE.md](https://github.com/lrepo52/job-aide/blob/main/internal-docs/ARCHITECTURE.md) — monorepo structure and naming conventions
