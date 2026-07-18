# Directory Update Log

## 2026-07-17

* **Initialization**: Created the `cicd-testing-practices` knowledge bundle to consolidate CI/CD and testing practices from three ADRs in levonk-base-boilerplate and the bookkeep-saas PRD.
* **Creation**: Authored 5 concept pages covering the testing stack.
  - [hybrid-playwright-stagehand.md](hybrid-playwright-stagehand.md) — 80/20 split, deterministic vs AI-powered tests
  - [shared-quality-scripts.md](shared-quality-scripts.md) — single Docker-based quality script for hooks and CI
  - [vitest-unified-runner.md](vitest-unified-runner.md) — Vitest for all TypeScript testing
  - [pre-commit-ci-parity.md](pre-commit-ci-parity.md) — same checks locally and in CI
  - [accessibility-testing.md](accessibility-testing.md) — axe-core in CI, WCAG 2.1 AA from day one
* **Creation**: Established [overview.md](overview.md) synthesis and [index.md](index.md) directory listing.
* **Note**: Concepts extracted from ADR-20260104001 (hybrid Playwright/Stagehand, 261 lines), ADR-20251218002 (shared quality scripts, 115 lines), ADR-20251106002 (Vitest, 83 lines) in boilerplate, and bookkeep-saas PRD NFR21-NFR24 (a11y).
