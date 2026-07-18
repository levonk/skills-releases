---
type: Practice
title: Vitest for TypeScript Testing
description: Use Vitest as the standard test runner with .test.mts extension for test files, project-based testing for unit/integration separation, and environment configuration per project.
tags: [typescript, monorepo, testing, vitest, vite, esm, test-files]
timestamp: 2026-07-17T00:00:00Z
---

# Vitest for TypeScript Testing

## Failure Mode

Using Jest in a TypeScript ESM monorepo. Problems:

1. **Slow**: Jest is significantly slower than Vitest, especially with ESM.
2. **Complex ESM config**: Jest requires complex configuration and
   transpilation steps for modern TypeScript and ESM projects.
3. **Inconsistent experience**: Different test types (unit, integration, E2E)
   often use different runners with different APIs.
4. **Monorepo friction**: Jest workspace support is limited and awkward.
5. **Ambiguous test extensions**: `.test.ts` files inherit module system from
   `package.json`, causing the same ambiguity as source files.

## Practice

Use **Vitest** as the primary framework for all TypeScript testing.

### Test File Extension

Test files **must** use `.test.mts` extension (not `.test.ts`):

```bash
# Correct
src/utils.test.mts
src/components/button.test.mts

# Incorrect (ambiguous module system)
src/utils.test.ts
```

This is consistent with the [Explicit File Extensions](/explicit-file-extensions.md)
practice — `.mts` immediately indicates ESM.

### Test Types

- **Unit & Integration Tests**: Vitest directly.
- **End-to-End (E2E) Tests**: Vitest as the runner, orchestrating tests that
  use Stagehand (with Playwright for browser automation).

### Project-Based Testing

Vitest's workspace feature enables isolated testing of individual packages:

```ts
// vitest.config.ts (root)
import { defineConfig } from "vitest/config";

export default defineConfig({
  test: {
    projects: [
      {
        name: "unit",
          test: {
            environment: "node",
            include: ["**/*.test.mts"],
            exclude: ["**/*.integration.test.mts"],
          },
      },
      {
        name: "integration",
          test: {
            environment: "node",
            include: ["**/*.integration.test.mts"],
          },
      },
    ],
  },
});
```

### Environment Configuration

Configure test environments per project:

- `node` — for backend/CLI packages.
- `jsdom` or `happy-dom` — for web/UI packages.
- `edge` — for edge runtime packages.

### Standard Scripts

```json
{
  "scripts": {
    "test": "vitest",
    "test:run": "vitest run",
    "test:e2e": "vitest --project e2e"
  }
}
```

## Rationale

- **Performance**: Built on Vite, significantly faster than Jest. Leverages
  native ESM and smart test filtering.
- **Modern tooling**: Out-of-the-box TypeScript and ESM support, eliminating
  complex transpilation configuration.
- **Unified experience**: Single API across unit, integration, and E2E
  testing reduces cognitive overhead.
- **Jest compatibility**: API is largely compatible with Jest, making it
  familiar and simplifying migration.
- **Monorepo integration**: Vitest's workspace feature works seamlessly with
  pnpm and Nx.

## Consequences

### Positive

- Fast, modern, unified testing experience.
- Reduced configuration overhead.
- Faster CI/CD pipeline execution.
- Clear strategy for different levels of testing.

### Negative

- Developers accustomed to Jest need a brief adjustment period (minimized by
  API similarity).

## Related Concepts

- [Explicit File Extensions](/explicit-file-extensions.md) — `.test.mts` is the
  test-file application of the extension rule.
- [pnpm and Nx](/pnpm-nx-monorepo.md) — Vitest integrates with
  Nx's `test` task pipeline.
- [ESM over CommonJS](/esm-over-commonjs.md) — Vitest's native ESM support is
  why ESM is preferred.

## Citations

[1] [ADR-20251106002: Use Vitest for TypeScript Testing](https://github.com/levonk/job-aide/blob/main/internal-docs/adr/adr-20251106002-vitest-for-testing.md)
[2] [typescript-rules.md](https://github.com/levonk/job-aide/blob/main/.devin/rules/typescript-rules.md) — Testing section
[3] [ARCHITECTURE.md](https://github.com/levonk/job-aide/blob/main/internal-docs/ARCHITECTURE.md) — Testing Standards section
[4] [Vitest](https://vitest.dev/)
[5] [Stagehand](https://docs.stagehand.dev/)
