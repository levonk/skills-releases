---
type: Synthesis
title: CI/CD Testing Practices Overview
description: Synthesis of CI/CD and testing practices — hybrid Playwright/Stagehand testing, shared Dockerized quality scripts, Vitest unified runner, pre-commit/CI parity, and accessibility testing.
tags: [ci-cd, testing, playwright, stagehand, vitest, quality, overview, synthesis]
timestamp: 2026-07-17T00:00:00Z
---

# CI/CD Testing Practices Overview

This bundle documents practices for CI/CD pipelines and testing strategies.
Each concept was extracted from real boilerplate ADRs — the decisions that
ensure consistent quality enforcement, resilient browser testing, and unified
test runners across all projects.

## The Testing Stack

```
vitest-runner → playwright-stagehand → quality-scripts → pre-commit-parity → a11y-testing
```

| Phase | Practice | Prevents |
|-------|----------|----------|
| Runner | [Vitest Unified Runner](vitest-unified-runner.md) | Fragmented test runners, Jest config complexity |
| Browser | [Hybrid Playwright/Stagehand](hybrid-playwright-stagehand.md) | Brittle selectors, slow AI tests, high token costs |
| Quality | [Shared Quality Scripts](shared-quality-scripts.md) | Hook/CI drift, duplicated tool pinning, slow feedback |
| Parity | [Pre-Commit CI Parity](pre-commit-ci-parity.md) | "Works on my machine", inconsistent enforcement |
| A11y | [Accessibility Testing](accessibility-testing.md) | WCAG violations, missing a11y in CI |

## Scope

This bundle covers **CI/CD pipelines and testing strategies**. It does **not**
cover:

- Frontend code conventions — see
  [frontend-stack-practices](../frontend-stack-practices/overview.md).
- Dev environment setup — see
  [dev-environment-practices](../dev-environment-practices/overview.md).
- Security scanning — see
  [secrets-egress-security](../secrets-egress-security/overview.md).

## Sources

- `internal-docs/adr/adr-20260104001-hybrid-webui-testing-playwright-stagehand.md` — boilerplate (261 lines)
- `internal-docs/adr/adr-20251218002-shared-quality-scripts.md` — boilerplate (115 lines)
- `internal-docs/adr/adr-20251106002-vitest-for-testing.md` — boilerplate (83 lines)

## Related Knowledge Bundles

- [frontend-stack-practices](../frontend-stack-practices/overview.md) —
  Conventions for test files
- [dev-environment-practices](../dev-environment-practices/overview.md) —
  Environment for running tests
- [secrets-egress-security](../secrets-egress-security/overview.md) — Egress
  firewall for CI pipelines

## Citations

[1] `internal-docs/adr/adr-20260104001-hybrid-webui-testing-playwright-stagehand.md` — levonk-base-boilerplate
[2] `internal-docs/adr/adr-20251218002-shared-quality-scripts.md` — levonk-base-boilerplate
[3] `internal-docs/adr/adr-20251106002-vitest-for-testing.md` — levonk-base-boilerplate
