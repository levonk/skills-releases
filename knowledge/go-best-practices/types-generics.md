---
type: Practice
title: Types and Generics
description: Use any instead of interface{}, generic methods on types, promoted field literals, reflect.TypeFor[T], and new(value) for pointer creation (Go 1.18-1.27).
tags: [go, golang, types, generics, any, reflect, new, promoted-fields]
date:
  created: "2026-09-04"
  knowledge-basis: "2026-09-04"
  last-used: "2026-09-04"

sources:
  - id: jetbrains-go-modern-guidelines
    resource: "FEATURES.md"
    title: "JetBrains/go-modern-guidelines"
---

# Types and Generics

## Failure Mode

`interface{}` is outdated terminology — `any` is the built-in alias that reads
in current Go. Package-level generic helper functions scatter operations that
naturally belong to a type across the package namespace. Constructing embedded
structs explicitly in literals is verbose when promoted field names are
available. `reflect.TypeOf((*T)(nil)).Elem()` uses nil-pointer tricks. Custom
pointer helper functions or temporary variables just to get `&value` add
unnecessary boilerplate.

## Practice

### any (Go 1.18, Critical)

```go
// Before
func Decode(v interface{}) error {
    return nil
}

// After
func Decode(v any) error {
    return nil
}
```

### generic methods (Go 1.27, Medium)

Use generic methods instead of package-level generic helper functions when the
operation naturally belongs to the type itself.

```go
// Before
type Set[T comparable] map[T]struct{}

func Map[T comparable, U any](s Set[T], f func(T) U) []U {
    out := make([]U, 0, len(s))
    for value := range s {
        out = append(out, f(value))
    }
    return out
}

names := Map(users, func(user User) string {
    return user.Name
})

// After
type Set[T comparable] map[T]struct{}

func (s Set[T]) Map[U any](f func(T) U) []U {
    out := make([]U, 0, len(s))
    for value := range s {
        out = append(out, f(value))
    }
    return out
}

names := users.Map(func(user User) string {
    return user.Name
})
```

### promoted field literals (Go 1.27, Medium)

Set embedded struct fields directly with promoted field names in struct literals
instead of constructing the embedded struct explicitly.

```go
// Before
doc := Document{
    AuditInfo: AuditInfo{
        CreatedBy: "alice",
        UpdatedBy: "alice",
    },
    Name: "report.pdf",
    Path: "/documents/report.pdf",
}

// After
doc := Document{
    CreatedBy: "alice",
    UpdatedBy: "alice",
    Name:      "report.pdf",
    Path:      "/documents/report.pdf",
}
```

Do not mix a promoted field with the embedded field that promotes it;
pointer-embedded paths are not supported.

### reflect.TypeFor (Go 1.22, Low)

```go
// Before
typ := reflect.TypeOf((*T)(nil)).Elem()

// After
typ := reflect.TypeFor[T]()
```

### new expression (Go 1.26, High)

Use `new(value)` for pointer fields or arguments instead of generic or
type-specific pointer helper functions or temporary variables used only for
`&value`.

```go
// Before
func Pointer[T any](value T) *T {
    return &value
}

cfg := Config{
    Timeout: Pointer(30),
    Debug:   Pointer(true),
}

// After
cfg := Config{
    Timeout: new(30),
    Debug:   new(true),
}
```

```go
// Before — temporary variables just for address-taking
timeout := 30
debug := true
cfg := Config{
    Timeout: &timeout,
    Debug:   &debug,
}

// After
cfg := Config{
    Timeout: new(30),
    Debug:   new(true),
}
```

## Related Concepts

- [Error Handling](error-handling.md) — errors.AsType[T] uses generic type parameters
- [Collections: Slices and Maps](collections-slices-maps.md) — generic slices and maps functions
- [JSON Encoding](json-encoding.md) — struct field tags with promoted fields
