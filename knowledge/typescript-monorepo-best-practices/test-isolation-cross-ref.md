---
type: CrossReference
title: Test Isolation — Mock Pollution Is Process-Global and Irreversible
description: Cross-reference to the cicd-testing-practices bundle's test-isolation-mock-pollution concept page; the TypeScript monorepo bundle links to it because mock.module pollution affects Bun/Vitest test suites and is the canonical example of process-global, irreversible test contamination.
tags: [typescript, testing, test-isolation, mock-pollution, cross-reference, bun, vitest, jest]
date:
  created: "2026-08-10"
  knowledge-basis: "2026-08-10"
  last-used: "2026-08-10"
sources:
  - id: archon-test-isolation
    resource: https://github.com/coleam00/archon/blob/main/AGENTS.md
    title: 'archon AGENTS.md — Test isolation (mock.module pollution) section'
  - id: bun-issue-7823
    resource: https://github.com/oven-sh/bun/issues/7823
    title: 'oven-sh/bun#7823 — mock.module() permanently replaces modules; mock.restore() does not undo'
---

# Test Isolation — Mock Pollution Is Process-Global and Irreversible

> **This is a cross-reference page.** The full concept lives in the
> [cicd-testing-practices](https://github.com/levonk/skills-releases/blob/main/knowledge/cicd-testing-practices/test-isolation-mock-pollution.md)
> bundle. This page exists to link the TypeScript monorepo bundle to that
> concept, because mock pollution is a frequent failure mode in TypeScript
> test suites (Bun `mock.module()`, Vitest `vi.mock()`, Jest
> `jest.mock()`).

## Why This Matters for TypeScript Monorepos

TypeScript monorepos typically run test suites across many packages. When a
test file mocks a module at the process level (e.g. Bun's `mock.module()` or
Jest's `jest.mock()`), the mock persists for the lifetime of the process —
`mock.restore()` does **not** undo it ([oven-sh/bun#7823](https://github.com/oven-sh/bun/issues/7823)).
If two test files in the same process mock the same module differently, the
second file's mock silently overwrites the first's, or the first's persists
and the second's never takes effect.

### The TypeScript Instance

In a Bun workspace, the workaround is to split test files that have
conflicting `mock.module()` calls into separate `bun test` invocations —
each invocation gets a fresh process. Packages with many conflicting mocks
may need 5–20 separate test batches. Always use the workspace's test runner
(`bun run test`, which uses `bun --filter '*' test` for per-package
isolation) rather than `bun test` from the repo root, which discovers all
test files across all packages and runs them in one process.

### The General Rule

The full treatment — why mock pollution is process-global and irreversible,
how to structure test batches, and cross-stack instances (Bun, Jest, pytest)
— lives in:

**→ [Test Isolation: Mock Pollution](https://github.com/levonk/skills-releases/blob/main/knowledge/cicd-testing-practices/test-isolation-mock-pollution.md)**

## Related Concepts

- [Vitest Testing](vitest-testing.md) — Vitest's project-based testing
  provides some isolation, but `vi.mock()` has the same process-global
  persistence risk as Bun's `mock.module()`.
- [Linter Zero-Tolerance](linter-zero-tolerance.md) — test files that
  disable lint rules to work around mock pollution are masking the real
  problem (test isolation), not fixing it.
