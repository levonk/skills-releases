---
type: Practice
title: Collections: Slices and Maps
description: Use the slices and maps packages, min/max builtins, and clear builtin for collection operations instead of manual loops and hand-written helpers (Go 1.21-1.23).
tags: [go, golang, collections, slices, maps, sort, contains, clone, clear]
date:
  created: "2026-09-04"
  knowledge-basis: "2026-09-04"
  last-used: "2026-09-04"

sources:
  - id: jetbrains-go-modern-guidelines
    resource: "FEATURES.md"
    title: "JetBrains/go-modern-guidelines"
---

# Collections: Slices and Maps

## Failure Mode

Manual search loops, hand-written sort closures, and append-copy boilerplate are
verbose and error-prone. They duplicate logic that the standard library already
provides, introduce off-by-one risks in index math, and obscure the intent of
the code. Using `sort.Slice` with index-based closures loses type safety and
requires indexing back into the slice.

## Practice

### slices.Contains (Go 1.21, Critical)

```go
// Before
found := false
for _, item := range items {
    if item == x {
        found = true
        break
    }
}

// After
found := slices.Contains(items, x)
```

### slices.Index and slices.IndexFunc (Go 1.21, Medium)

```go
// Before
index := -1
for i, item := range items {
    if item == x {
        index = i
        break
    }
}

// After
index := slices.Index(items, x)

// IndexFunc for predicate-based lookup
index := slices.IndexFunc(items, func(item Item) bool {
    return item.ID == id
})
```

### slices.Sort (Go 1.21, High)

```go
// Before
sort.Ints(values)

// After
slices.Sort(values)
```

### slices.SortFunc (Go 1.21, High)

```go
// Before
sort.Slice(items, func(i, j int) bool {
    return items[i].X < items[j].X
})

// After
slices.SortFunc(items, func(a, b Item) int {
    return cmp.Compare(a.X, b.X)
})
```

### slices.Max and slices.Min (Go 1.21, Medium)

```go
// Before
maxValue := values[0]
for _, value := range values[1:] {
    if value > maxValue {
        maxValue = value
    }
}

// After
maxValue := slices.Max(values)
```

### slices.Reverse (Go 1.21, Medium)

```go
// Before
for i, j := 0, len(items)-1; i < j; i, j = i+1, j-1 {
    items[i], items[j] = items[j], items[i]
}

// After
slices.Reverse(items)
```

### slices.Compact (Go 1.21, Low)

```go
// Before
out := values[:0]
for i, value := range values {
    if i == 0 || value != values[i-1] {
        out = append(out, value)
    }
}
values = out

// After
values = slices.Compact(values)
```

### slices.Clone (Go 1.21, Medium)

```go
// Before
copied := append([]T(nil), values...)

// After
copied := slices.Clone(values)
```

### slices.Clip (Go 1.21, Low)

```go
// Before
s = s[:len(s):len(s)]

// After
s = slices.Clip(s)
```

### maps.Clone (Go 1.21, Medium)

```go
// Before
copied := make(map[string]int, len(src))
for k, v := range src {
    copied[k] = v
}

// After
copied := maps.Clone(src)
```

### maps.Copy (Go 1.21, Medium)

```go
// Before
for k, v := range src {
    dst[k] = v
}

// After
maps.Copy(dst, src)
```

### maps.DeleteFunc (Go 1.21, Low)

```go
// Before
for k, v := range m {
    if shouldDelete(k, v) {
        delete(m, k)
    }
}

// After
maps.DeleteFunc(m, func(k string, v int) bool {
    return shouldDelete(k, v)
})
```

### maps.Keys and maps.Values as iterators (Go 1.23, High)

```go
// Before
for k := range m {
    process(k)
}

// After
for k := range maps.Keys(m) {
    process(k)
}
```

### slices.Collect (Go 1.23, Medium)

```go
// Before
keys := make([]string, 0, len(m))
for k := range m {
    keys = append(keys, k)
}

// After
keys := slices.Collect(maps.Keys(m))
```

### slices.Sorted (Go 1.23, Medium)

```go
// Before
keys := make([]string, 0, len(m))
for k := range m {
    keys = append(keys, k)
}
slices.Sort(keys)

// After
keys := slices.Sorted(maps.Keys(m))
```

### min and max builtins (Go 1.21, High)

```go
// Before
if b > a {
    a = b
}

// After
a = max(a, b)
```

### clear builtin (Go 1.21, Medium)

```go
// Before
for k := range m {
    delete(m, k)
}

// After
clear(m)
```

## Related Concepts

- [Loops and Iterators](loops-iterators.md) — range over int and iterator-based collection traversal
- [Strings and Bytes](strings-bytes.md) — strings.SplitSeq and bytes.SplitSeq for streaming splits
- [Fmt Utilities](fmt-utilities.md) — cmp.Or for fallback value selection
