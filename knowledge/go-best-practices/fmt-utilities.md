---
type: Practice
title: Fmt Utilities
description: Use fmt.Appendf for appending formatted text to byte slices and cmp.Or for picking the first non-zero value in a fallback chain (Go 1.19-1.22).
tags: [go, golang, fmt, appendf, cmp, or, formatting, fallback]
date:
  created: "2026-09-04"
  knowledge-basis: "2026-09-04"
  last-used: "2026-09-04"

sources:
  - id: jetbrains-go-modern-guidelines
    resource: "FEATURES.md"
    title: "JetBrains/go-modern-guidelines"
---

# Fmt Utilities

## Failure Mode

Using `fmt.Sprintf` to format text and then appending it to a byte slice via
`append(buf, []byte(...)...)` allocates an intermediate string unnecessarily.
Fallback chains written as `if x == "" { x = "default" }` are verbose for a
common pattern. These patterns add allocations and boilerplate that the standard
library already handles.

## Practice

### fmt.Appendf (Go 1.19, Medium)

Use `fmt.Appendf` when appending formatted text to a byte slice and an
intermediate `fmt.Sprintf` string is unnecessary. It writes formatted output
directly into a byte slice.

```go
// Before
buf = append(buf, []byte(fmt.Sprintf("x=%d", x))...)

// After
buf = fmt.Appendf(buf, "x=%d", x)
```

### cmp.Or (Go 1.22, High)

Use `cmp.Or` to pick the first non-zero value from a fallback chain. It returns
the first non-zero value from its arguments. Remember that all arguments are
evaluated before the call.

```go
// Before
name := os.Getenv("NAME")
if name == "" {
    name = "default"
}

// After
name := cmp.Or(os.Getenv("NAME"), "default")
```

## Related Concepts

- [Collections: Slices and Maps](collections-slices-maps.md) — slices.SortFunc uses cmp.Compare
- [Error Handling](error-handling.md) — fmt.Appendf for formatting error messages
- [Strings and Bytes](strings-bytes.md) — byte slice accumulation patterns
