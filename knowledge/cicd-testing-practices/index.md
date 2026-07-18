---
okf_version: "0.1"
---

# CI/CD Testing Practices

A compounding knowledge base documenting practices for CI/CD pipelines and
testing strategies — hybrid Playwright/Stagehand testing, shared Dockerized
quality scripts, Vitest as unified test runner, and pre-commit/CI parity.

## Concepts

* [Overview](overview.md) - Synthesis of the full CI/CD testing practice set
* [hybrid-playwright-stagehand](hybrid-playwright-stagehand.md) - 80/20 split: Playwright for deterministic, Stagehand for AI-powered resilient tests
* [shared-quality-scripts](shared-quality-scripts.md) - Single Docker-based quality script for pre-commit and CI parity
* [vitest-unified-runner](vitest-unified-runner.md) - Vitest as test runner for unit, integration, and E2E
* [pre-commit-ci-parity](pre-commit-ci-parity.md) - Same checks run locally and in CI, reducing "works on my machine"
* [accessibility-testing](accessibility-testing.md) - axe-core in CI, WCAG 2.1 AA compliance from day one
