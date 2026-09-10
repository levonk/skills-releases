---
type: Practice
title: Context Patterns
description: Use context.AfterFunc for cleanup on cancellation, context.WithTimeoutCause/WithDeadlineCause for diagnostic causes, context.WithCancelCause for cancellation reasons, and testing.T.Context for test-scoped contexts (Go 1.20-1.24).
tags: [go, golang, context, cancellation, after-func, cause, testing]
date:
  created: "2026-09-04"
  knowledge-basis: "2026-09-04"
  last-used: "2026-09-04"

sources:
  - id: jetbrains-go-modern-guidelines
    resource: "FEATURES.md"
    title: "JetBrains/go-modern-guidelines"
---

# Context Patterns

## Failure Mode

Starting a goroutine whose only job is to wait on `ctx.Done()` wastes a
goroutine and complicates cleanup. Plain `context.WithCancel` and
`context.WithTimeout` do not carry a cause, so callers cannot distinguish why a
context was canceled — `ctx.Err()` is too coarse for diagnostics. In tests,
manual `context.WithCancel(context.Background())` plus `defer cancel()` is
boilerplate that ties the context to the test lifetime incorrectly.

## Practice

### context.AfterFunc (Go 1.21, Medium)

Use `context.AfterFunc` to run cleanup when a context is canceled. It registers
work to run after cancellation and returns a stop function, avoiding a goroutine
whose only job is to wait on `ctx.Done()`.

```go
// Before
go func() {
    <-ctx.Done()
    cleanup()
}()

// After
stop := context.AfterFunc(ctx, cleanup)
defer stop()
```

### context.WithTimeoutCause and context.WithDeadlineCause (Go 1.21, Low)

Use timeout and deadline contexts with causes when callers need to inspect the
cancellation reason. Callers can use `context.Cause` to distinguish the reason.

```go
// Before
ctx, cancel := context.WithTimeout(parent, d)
defer cancel()

// After
ctx, cancel := context.WithTimeoutCause(parent, d, errTimeout)
defer cancel()
```

### context.WithCancelCause (Go 1.20, Medium)

Use `context.WithCancelCause` and `context.Cause` when cancellation needs to
carry an error cause. Callers can inspect `context.Cause(ctx)` instead of only
seeing the broad `ctx.Err` result.

```go
// Before
ctx, cancel := context.WithCancel(parent)
cancel()

// After
ctx, cancel := context.WithCancelCause(parent)
cancel(err)
cause := context.Cause(ctx)
```

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

## Related Concepts

- [Error Handling](error-handling.md) — errors.Is and errors.Join for error inspection
- [Testing and Benchmarks](testing-benchmarks.md) — testing.T.Context and B.Loop for modern test patterns
- [Sync and Concurrency](sync-concurrency.md) — sync.WaitGroup.Go for goroutine lifecycle
