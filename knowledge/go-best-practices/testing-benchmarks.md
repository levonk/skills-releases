---
type: Practice
title: Testing and Benchmarks
description: Use testing.T.Context for test-scoped contexts and testing B.Loop for modern benchmark loops (Go 1.24).
tags: [go, golang, testing, benchmarks, context, b-loop, t-context]
date:
  created: "2026-09-04"
  knowledge-basis: "2026-09-04"
  last-used: "2026-09-04"

sources:
  - id: jetbrains-go-modern-guidelines
    resource: "FEATURES.md"
    title: "JetBrains/go-modern-guidelines"
---

# Testing and Benchmarks

## Failure Mode

Manual `context.WithCancel(context.Background())` plus `defer cancel()` in tests
is boilerplate that does not properly tie the context to the test lifetime — if
the test fails or is interrupted, the context may not be canceled promptly. The
traditional `for i := 0; i < b.N; i++` benchmark loop requires manual timer
control and does not leverage the benchmark framework's iteration management.

## Practice

### testing.T.Context (Go 1.24, High)

Use `t.Context()` when a test function needs a context tied to the test
lifetime. It removes manual background context setup when helper work should stop
as the test is ending.

```go
// Before
func TestFoo(t *testing.T) {
    ctx, cancel := context.WithCancel(context.Background())
    defer cancel()
    result := doSomething(ctx)
}

// After
func TestFoo(t *testing.T) {
    ctx := t.Context()
    result := doSomething(ctx)
}
```

### testing B.Loop (Go 1.24, Medium)

Use `b.Loop()` for the main loop in benchmark functions. It manages benchmark
iteration mechanics and can remove the need for manual timer control in the
benchmark body.

```go
// Before
func BenchmarkFoo(b *testing.B) {
    for i := 0; i < b.N; i++ {
        doWork()
    }
}

// After
func BenchmarkFoo(b *testing.B) {
    for b.Loop() {
        doWork()
    }
}
```

## Related Concepts

- [Context Patterns](context-patterns.md) — context.AfterFunc and WithCancelCause for test cancellation
- [Error Handling](error-handling.md) — errors.Is and errors.AsType for test assertions
- [Sync and Concurrency](sync-concurrency.md) — testing concurrent code with sync.WaitGroup.Go
