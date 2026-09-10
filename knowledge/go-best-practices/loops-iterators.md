---
type: Practice
title: Loops and Iterators
description: Use range over int for count loops and remove redundant loop-variable copies before closures (Go 1.22).
tags: [go, golang, loops, range, iterators, closures, loopvar]
date:
  created: "2026-09-04"
  knowledge-basis: "2026-09-04"
  last-used: "2026-09-04"

sources:
  - id: jetbrains-go-modern-guidelines
    resource: "FEATURES.md"
    title: "JetBrains/go-modern-guidelines"
---

# Loops and Iterators

## Failure Mode

Traditional `for i := 0; i < n; i++` loops are verbose for the common case of
iterating from 0 to n-1. Before Go 1.22, loop variables were shared across
iterations, requiring defensive copies (`v := v`) before closures, goroutines,
deferred functions, or taking addresses. These copies are now redundant noise
that obscures the actual logic.

## Practice

### range over int (Go 1.22, Critical)

```go
// Before
for i := 0; i < len(items); i++ {
    process(items[i])
}

// After
for i := range len(items) {
    process(items[i])
}
```

Keep a traditional for loop when you need a non-zero start, custom step, or
changing bound.

### loopvar capture (Go 1.22, High)

Go 1.22 gives each loop iteration its own variables, so defensive copies are
usually redundant.

```go
// Before — redundant copy before goroutine
for _, item := range items {
    item := item
    go func() {
        process(item)
    }()
}

// After — no copy needed
for _, item := range items {
    go func() {
        process(item)
    }()
}
```

The same applies when taking addresses:

```go
// Before — redundant copy before appending pointer
var selected []*Item
for _, item := range items {
    item := item
    if item.Enabled {
        selected = append(selected, &item)
    }
}

// After — no copy needed
var selected []*Item
for _, item := range items {
    if item.Enabled {
        selected = append(selected, &item)
    }
}
```

Keep an explicit copy only when it serves another purpose. If you need a pointer
to the original slice element rather than the per-iteration copy, use
`&slice[i]`.

## Related Concepts

- [Collections: Slices and Maps](collections-slices-maps.md) — slices.Collect and slices.Sorted for iterator materialization
- [Sync and Concurrency](sync-concurrency.md) — sync.WaitGroup.Go for goroutine lifecycle management
- [Strings and Bytes](strings-bytes.md) — strings.SplitSeq for iterator-based string splitting
