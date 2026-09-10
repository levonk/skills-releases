---
type: Practice
title: Strings and Bytes
description: Use strings.Cut/bytes.Cut, strings.CutPrefix/CutSuffix, strings.CutLast/bytes.CutLast, strings.Clone/bytes.Clone, and strings.SplitSeq for modern string and byte slice operations (Go 1.18-1.27).
tags: [go, golang, strings, bytes, cut, clone, split, prefix, suffix]
date:
  created: "2026-09-04"
  knowledge-basis: "2026-09-04"
  last-used: "2026-09-04"

sources:
  - id: jetbrains-go-modern-guidelines
    resource: "FEATURES.md"
    title: "JetBrains/go-modern-guidelines"
---

# Strings and Bytes

## Failure Mode

Manual `strings.Index` plus slicing duplicates the index check and requires
separator-length arithmetic. `HasPrefix` followed by `TrimPrefix` repeats the
same condition twice. `LastIndex` plus manual slicing around the last separator
is error-prone. Append-copy boilerplate (`append([]byte(nil), b...)`) obscures
the intent of copying. `strings.Split` allocates a full slice when only
iteration is needed.

## Practice

### strings.Cut (Go 1.18, Medium)

```go
// Before
i := strings.Index(s, ":")
if i < 0 {
    return "", "", false
}
key, value := s[:i], s[i+1:]

// After
key, value, found := strings.Cut(s, ":")
```

### bytes.Cut (Go 1.18, Medium)

```go
// Before
i := bytes.Index(b, sep)
if i < 0 {
    return nil, nil, false
}
before, after := b[:i], b[i+len(sep):]

// After
before, after, found := bytes.Cut(b, sep)
```

### strings.CutPrefix and strings.CutSuffix (Go 1.20, High)

```go
// Before
if strings.HasPrefix(s, "pre:") {
    rest := strings.TrimPrefix(s, "pre:")
    use(rest)
}

// After
if rest, ok := strings.CutPrefix(s, "pre:"); ok {
    use(rest)
}
```

### strings.CutLast and bytes.CutLast (Go 1.27, Medium)

```go
// Before
i := strings.LastIndex(path, "/")
if i < 0 {
    return "", path, false
}
dir, file := path[:i], path[i+1:]

// After
dir, file, found := strings.CutLast(path, "/")
```

```go
// Before (bytes)
i := bytes.LastIndex(line, []byte(":"))
if i < 0 {
    return nil, line, false
}
name, value := line[:i], line[i+1:]

// After (bytes)
name, value, found := bytes.CutLast(line, []byte(":"))
```

### strings.Clone (Go 1.18, Medium)

Use `strings.Clone` to copy a string without retaining shared backing memory.

```go
// Before
copied := string([]byte(s))

// After
copied := strings.Clone(s)
```

### bytes.Clone (Go 1.20, Medium)

```go
// Before
copied := append([]byte(nil), b...)

// After
copied := bytes.Clone(b)
```

### strings.SplitSeq and strings.FieldsSeq (Go 1.24, High)

Use `strings.SplitSeq`, `strings.FieldsSeq`, `bytes.SplitSeq`, or
`bytes.FieldsSeq` when iterating over split results. They stream substrings
instead of allocating a slice of all parts.

```go
// Before
for _, part := range strings.Split(s, ",") {
    process(part)
}

// After
for part := range strings.SplitSeq(s, ",") {
    process(part)
}
```

```go
// Before (bytes)
for _, field := range bytes.Fields(b) {
    process(field)
}

// After (bytes)
for field := range bytes.FieldsSeq(b) {
    process(field)
}
```

## Related Concepts

- [Collections: Slices and Maps](collections-slices-maps.md) — slices.Collect for materializing string iterators
- [Loops and Iterators](loops-iterators.md) — range over iterators from SplitSeq
- [HTTP Routing](http-routing.md) — strings.TrimPrefix replaced by ServeMux path patterns
