---
type: Practice
title: Vitest Testing Framework
description: Vitest as primary framework for all TypeScript testing — unit, integration, and E2E test runner with Stagehand/Playwright. Fast, ESM-native, Jest-compatible, monorepo-integrated.
tags: [vitest, testing, typescript, e2e, stagehand, playwright, jest]
timestamp: 2026-07-17T00:00:00Z
---

# Vitest Testing Framework

## Failure Mode

Jest is slower than modern alternatives and requires complex configuration for
TypeScript and ESM. Using different test runners for different test types
fragments the developer experience and increases cognitive overhead.

## Practice

Use **Vitest** as the primary framework for all TypeScript testing.

### Test Types

- **Unit & Integration Tests**: Vitest directly for writing and running tests
- **E2E Tests**: Vitest as test runner, orchestrating Stagehand (with Playwright
  for browser automation)

### Why Vitest

1. **Performance**: Built on Vite, significantly faster than Jest
2. **Modern Tooling**: Out-of-the-box TypeScript and ESM support
3. **Unified Experience**: Single API for unit, integration, and E2E
4. **Jest Compatibility**: API largely compatible with Jest for easy migration
5. **Monorepo Integration**: Workspace feature works with pnpm/Nx setup

### Configuration

- Global `vitest.config.ts` at monorepo root
- Individual packages extend root configuration as needed
- `package.json` scripts standardized: `"test"`, `"test:e2e"` use `vitest`
- New features must include unit tests written with Vitest
- E2E suites in dedicated test packages using Vitest + Stagehand

### Why Not Alternatives

- **Jest**: Slower, complex TS/ESM config
- **Mocha & Chai**: Lacks integrated "all-in-one" experience
- **Playwright Test Runner**: Excellent for E2E but doesn't unify all test types

## Related Concepts

- [Code Style Conventions](code-style-conventions.md) — Test files use .test.mts
- [ESLint Composition API](eslint-composition-api.md) — Vitest rules in ESLint config

## Citations

[1] `internal-docs/adr/adr-20251106002-vitest-for-testing.md` — levonk-base-boilerplate
