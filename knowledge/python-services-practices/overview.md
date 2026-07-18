---
type: Synthesis
title: Python Services Practices Overview
description: Synthesis of Python services and packages practices — pyproject.toml, FastAPI layout, Docker standards, Makefile conventions, pytest testing, and nox orchestration.
tags: [python, fastapi, services, packages, overview, synthesis]
timestamp: 2026-07-17T00:00:00Z
---

# Python Services Practices Overview

This bundle documents practices for Python services and packages in the monorepo.
Each concept was extracted from the Python services ADR — the standards that
ensure consistent project layout, tooling, testing, and orchestration across all
Python projects.

## The Python Service Lifecycle

```
pyproject.toml → project-layout → docker → makefile → testing → orchestration
```

| Phase | Practice | Prevents |
|-------|----------|----------|
| Manifest | [pyproject.toml Manifest](pyproject-toml-manifest.md) | Duplicative requirements.txt, weak PEP 621 integration |
| Service | [FastAPI Service Layout](fastapi-service-layout.md) | Inconsistent app structure, missing health endpoints |
| Library | [Python Package Layout](python-package-layout.md) | Missing src/ layout, inconsistent test placement |
| Container | [Docker Standards](docker-standards.md) | Root containers, missing healthchecks, env var drift |
| Commands | [Makefile Conventions](makefile-conventions.md) | Missing down target, inconsistent command names |
| Testing | [pytest Testing Baseline](pytest-testing-baseline.md) | Python browser automation duplication, missing async tests |
| Orchestration | [nox Orchestration](nox-orchestration.md) | No monorepo-wide Python checks, Bazel/Pants over-engineering |

## Scope

This bundle covers **Python services and packages** — project layout, tooling,
testing, and orchestration. It does **not** cover:

- Devbox/Nix environment setup — see
  [dev-environment-practices](../dev-environment-practices/overview.md).
- Container runtime hardening — see
  [container-best-practices](../container-best-practices/overview.md).
- TypeScript monorepo orchestration — see
  [typescript-monorepo-best-practices](../typescript-monorepo-best-practices/overview.md).

## Sources

- `internal-docs/adr/adr-20251129003-python-services-and-packages-standard.md` — boilerplate (353 lines)

## Related Knowledge Bundles

- [dev-environment-practices](../dev-environment-practices/overview.md) —
  Environment management for Python projects
- [container-best-practices](../container-best-practices/overview.md) — Container
  patterns for Python services
- [typescript-monorepo-best-practices](../typescript-monorepo-best-practices/overview.md)
  — Monorepo orchestration that integrates with Python via nox

## Citations

[1] `internal-docs/adr/adr-20251129003-python-services-and-packages-standard.md` — levonk-base-boilerplate
