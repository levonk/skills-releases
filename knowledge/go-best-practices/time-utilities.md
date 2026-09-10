---
type: Practice
title: Time and Utilities
description: Use time.Until and time.Since for time calculations, time.Tick with GC recovery, stdlib uuid instead of third-party libraries, and url.Clone for deep-copying URLs (Go 1.0-1.27).
tags: [go, golang, time, uuid, url, clone, tick, until, since]
date:
  created: "2026-09-04"
  knowledge-basis: "2026-09-04"
  last-used: "2026-09-04"

sources:
  - id: jetbrains-go-modern-guidelines
    resource: "FEATURES.md"
    title: "JetBrains/go-modern-guidelines"
---

# Time and Utilities

## Failure Mode

`deadline.Sub(time.Now())` reads in the wrong direction — the caller cares about
remaining time before a deadline, not the deadline minus now. `time.Now().Sub(start)`
calls `time.Now` outside the time package helper. Unreferenced `time.NewTicker`
instances could not be garbage collected before Go 1.23, requiring explicit
`Stop` calls. Third-party UUID libraries add unnecessary dependencies when the
standard library covers common cases. Manual URL copying with field-by-field
assignment can accidentally share mutable slices or miss URL fields.

## Practice

### time.Since (Go 1.0, High)

```go
// Before
elapsed := time.Now().Sub(start)

// After
elapsed := time.Since(start)
```

### time.Until (Go 1.8, Medium)

```go
// Before
remaining := deadline.Sub(time.Now())

// After
remaining := time.Until(deadline)
```

### time.Tick GC (Go 1.23, Low)

Go 1.23 made unreferenced tickers recoverable by the garbage collector. Use
`time.Tick` for simple forever loops, and use `time.NewTicker` when you need
`Stop` or `Reset`.

```go
// Before
ticker := time.NewTicker(time.Second)
defer ticker.Stop()
for range ticker.C {
    poll()
}

// After
for range time.Tick(time.Second) {
    poll()
}
```

### stdlib uuid (Go 1.27, Medium)

Use the standard library `uuid` package instead of third-party libraries or
custom UUID implementations when targeting Go 1.27+.

```go
// Before
import googleuuid "github.com/google/uuid"

id := googleuuid.New()
text := id.String()

// After
import "uuid"

id := uuid.New()
text := id.String()
```

```go
// Before
id, err := googleuuid.Parse(raw)
if err != nil {
    return err
}

// After
id, err := uuid.Parse(raw)
if err != nil {
    return err
}
```

### url.Clone (Go 1.27, Low)

Use `URL.Clone` and `Values.Clone` from `net/url` to copy URLs and URL values
instead of manual copying. They create deep copies and avoid partial manual
copies that can accidentally share mutable slices or miss URL fields.

```go
// Before
copy := new(url.URL)
*copy = *base
if base.User != nil {
    username := base.User.Username()
    if password, ok := base.User.Password(); ok {
        copy.User = url.UserPassword(username, password)
    } else {
        copy.User = url.User(username)
    }
}

// After
copy := base.Clone()
```

```go
// Before
copy := make(url.Values, len(values))
for key, items := range values {
    copy[key] = append([]string(nil), items...)
}

// After
copy := values.Clone()
```

## Related Concepts

- [Context Patterns](context-patterns.md) — context.WithTimeoutCause for deadline-based cancellation
- [HTTP Routing](http-routing.md) — url.Clone for copying request URLs in HTTP handlers
- [JSON Encoding](json-encoding.md) — time.Time fields with omitzero in JSON
