---
type: Practice
title: nox Orchestration
description: nox as primary orchestration for Python test/lint pipelines across projects. Discovers pyproject.toml, installs -e .[dev], provides tests and lint sessions. Turborepo handles Node tasks.
tags: [python, nox, orchestration, turborepo, monorepo, ci-cd]
timestamp: 2026-07-17T00:00:00Z
---

# nox Orchestration

## Failure Mode

No monorepo-wide Python checks means Python projects drift independently. Using
Bazel/Pants as a unified build system replaces native Python tooling and creates
high migration cost.

## Practice

Use **nox** as the primary orchestration layer for Python test/lint pipelines
across projects.

### noxfile.py

- Discovers Python projects by scanning for `pyproject.toml`
- For each project, installs `-e .[dev]`
- Provides standard sessions:
  - `tests`: run pytest for all projects with `tests/`
  - `lint`: run ruff + mypy for `app/` and `tests/`

### Turborepo Integration

- Turborepo remains the orchestrator for Node/TypeScript tasks
- May invoke Python service commands via `package.json` scripts
- Does **not** replace Python's build system
- Possible future: `turbo test` invoking `nox -s tests`

### Why nox Over Bazel/Pants

- **Augments** native Python tooling instead of replacing it
- Lower mental model and migration cost
- Easier to extract projects into standalone repos
- Preserves pytest, uv, pip, FastAPI ecosystem

## Related Concepts

- [pyproject.toml Manifest](pyproject-toml-manifest.md) — nox installs from dev extras
- [pytest Testing Baseline](pytest-testing-baseline.md) — nox runs pytest

## Citations

[1] `internal-docs/adr/adr-20251129003-python-services-and-packages-standard.md` — levonk-base-boilerplate
