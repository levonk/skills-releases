---
type: Practice
title: Error Handling
description: Use errors.Is for wrapped error matching, errors.Join for combining errors, and errors.AsType[T] for type-safe error matching (Go 1.13-1.26).
tags: [go, golang, errors, error-handling, errors.Is, errors.Join, errors.AsType]
date:
  created: "2026-09-04"
  knowledge-basis: "2026-09-04"
  last-used: "2026-09-04"

sources:
  - id: jetbrains-go-modern-guidelines
    resource: "FEATURES.md"
    title: "JetBrains/go-modern-guidelines"
---

# Error Handling

## Failure Mode

Direct equality checks (`err == target`) miss errors wrapped with `fmt.Errorf`
or custom wrappers. Manual error concatenation with `fmt.Errorf("%v; %w", ...)`
does not preserve error matching for all wrapped errors. The `errors.As`
pointer-to-target pattern requires a separate temporary variable and is less
type-safe than a generic alternative.

## Practice

### errors.Is (Go 1.13, Critical)

Use `errors.Is(err, target)` instead of `err == target` so wrapped errors are
handled correctly. `errors.Is` walks wrapped errors and honors custom `Is`
methods.

```go
// Before
if err == os.ErrNotExist {
    return nil
}

// After
if errors.Is(err, os.ErrNotExist) {
    return nil
}
```

### errors.Join (Go 1.20, High)

Use `errors.Join` to combine multiple errors while preserving error matching.
It returns `nil` when there are no non-nil errors.

```go
// Before
if err1 != nil && err2 != nil {
    return fmt.Errorf("%v; %w", err1, err2)
}

// After
return errors.Join(err1, err2)
```

### errors.AsType[T] (Go 1.26, Medium)

Use `errors.AsType[T](err)` when checking whether an error matches a specific
type. It returns the matched error value and a boolean directly, avoiding a
separate temporary variable and the pointer-to-target pattern required by
`errors.As`.

```go
// Before
var pathErr *os.PathError
if errors.As(err, &pathErr) {
    handle(pathErr)
}

// After
if pathErr, ok := errors.AsType[*os.PathError](err); ok {
    handle(pathErr)
}
```

## Related Concepts

- [Context Patterns](context-patterns.md) — context.WithCancelCause for carrying error causes in cancellation
- [Types and Generics](types-generics.md) — generic type parameters used by errors.AsType[T]
- [Fmt Utilities](fmt-utilities.md) — fmt.Appendf for formatting error messages into byte slices
