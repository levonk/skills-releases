# Directory Update Log

## 2026-07-17

* **Initialization**: Created the `python-services-practices` knowledge bundle to consolidate Python services and packages standards from ADR-20251129003 in levonk-base-boilerplate.
* **Creation**: Authored 7 concept pages covering the Python service lifecycle.
  - [pyproject-toml-manifest.md](pyproject-toml-manifest.md) — pyproject.toml as single source of truth
  - [fastapi-service-layout.md](fastapi-service-layout.md) — standard FastAPI service layout
  - [python-package-layout.md](python-package-layout.md) — non-service library layout
  - [docker-standards.md](docker-standards.md) — multi-stage builds, non-root, env vars, healthcheck
  - [makefile-conventions.md](makefile-conventions.md) — matching up/down, standard command set
  - [pytest-testing-baseline.md](pytest-testing-baseline.md) — pytest + asyncio, Node-based E2E
  - [nox-orchestration.md](nox-orchestration.md) — nox for Python pipelines, turborepo for Node
* **Creation**: Established [overview.md](overview.md) synthesis and [index.md](index.md) directory listing.
* **Note**: Concepts extracted from ADR-20251129003 (Python services and packages standard, 353 lines) in levonk-base-boilerplate.
