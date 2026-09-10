---
type: Practice
title: Sync and Concurrency
description: Use sync.OnceFunc/OnceValue for one-time initialization, sync.WaitGroup.Go for tracked goroutines, and typed atomic values instead of untyped atomic functions (Go 1.19-1.25).
tags: [go, golang, sync, concurrency, atomic, waitgroup, once, goroutine]
date:
  created: "2026-09-04"
  knowledge-basis: "2026-09-04"
  last-used: "2026-09-04"

sources:
  - id: jetbrains-go-modern-guidelines
    resource: "FEATURES.md"
    title: "JetBrains/go-modern-guidelines"
---

# Sync and Concurrency

## Failure Mode

`sync.Once` plus a wrapper closure is verbose for one-time initialization.
Manual `wg.Add(1)` and `defer wg.Done()` in each goroutine is error-prone — a
missed `Done` call hangs `wg.Wait()` forever. Untyped atomic functions
(`atomic.StoreInt32`, `atomic.LoadPointer`) hide the value type, risk accidental
non-atomic access, and carry old pointer-alignment pitfalls.

## Practice

### sync.OnceFunc (Go 1.21, Medium)

```go
// Before
var once sync.Once
cleanup := func() {
    once.Do(func() {
        close(ch)
    })
}

// After
cleanup := sync.OnceFunc(func() {
    close(ch)
})
```

### sync.OnceValue (Go 1.21, Medium)

```go
// Before
var once sync.Once
var value T
getter := func() T {
    once.Do(func() {
        value = computeValue()
    })
    return value
}

// After
getter := sync.OnceValue(func() T {
    return computeValue()
})
```

### sync.WaitGroup.Go (Go 1.25, High)

`WaitGroup.Go` starts a goroutine and handles the matching `Add` and `Done`
calls.

```go
// Before
var wg sync.WaitGroup
for _, item := range items {
    wg.Add(1)
    go func() {
        defer wg.Done()
        process(item)
    }()
}
wg.Wait()

// After
var wg sync.WaitGroup
for _, item := range items {
    wg.Go(func() {
        process(item)
    })
}
wg.Wait()
```

### atomic types (Go 1.19, Medium)

Use typed atomics such as `atomic.Bool`, `atomic.Int64`, and `atomic.Pointer[T]`
instead of untyped atomic functions.

```go
// Before
var enabled int32
atomic.StoreInt32(&enabled, 1)
if atomic.LoadInt32(&enabled) != 0 {
    run()
}

// After
var enabled atomic.Bool
enabled.Store(true)
if enabled.Load() {
    run()
}
```

```go
// Before
var ptr unsafe.Pointer
atomic.StorePointer(&ptr, unsafe.Pointer(cfg))

// After
var ptr atomic.Pointer[Config]
ptr.Store(cfg)
```

## Related Concepts

- [Context Patterns](context-patterns.md) — context.AfterFunc for cleanup on cancellation
- [Loops and Iterators](loops-iterators.md) — loopvar capture semantics for goroutines in loops
- [Testing and Benchmarks](testing-benchmarks.md) — testing patterns for concurrent code
