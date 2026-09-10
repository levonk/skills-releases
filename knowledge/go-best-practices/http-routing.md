---
type: Practice
title: HTTP Routing
description: Use method-aware ServeMux patterns and r.PathValue for path parameters instead of manual method checks and path trimming (Go 1.22).
tags: [go, golang, http, servemux, routing, pathvalue, patterns]
date:
  created: "2026-09-04"
  knowledge-basis: "2026-09-04"
  last-used: "2026-09-04"

sources:
  - id: jetbrains-go-modern-guidelines
    resource: "FEATURES.md"
    title: "JetBrains/go-modern-guidelines"
---

# HTTP Routing

## Failure Mode

Manual method checks inside handler functions (`if r.Method != http.MethodGet`)
are repetitive and easy to forget. Manual path trimming with
`strings.TrimPrefix(r.URL.Path, "/api/")` is fragile — it breaks when the path
structure changes and does not handle path wildcards. These patterns scatter
routing logic across handlers instead of declaring it at registration time.

## Practice

### http.ServeMux patterns (Go 1.22, Medium)

Use method-aware `ServeMux` patterns and `r.PathValue` for path parameters. The
modern `ServeMux` pattern syntax can include an HTTP method and named path
wildcards. `r.PathValue` retrieves wildcard values without manual path trimming.

```go
// Before
mux.HandleFunc("/api/", func(w http.ResponseWriter, r *http.Request) {
    if r.Method != http.MethodGet {
        http.Error(w, "method not allowed", http.StatusMethodNotAllowed)
        return
    }
    id := strings.TrimPrefix(r.URL.Path, "/api/")
    handleID(w, r, id)
})

// After
mux.HandleFunc("GET /api/{id}", func(w http.ResponseWriter, r *http.Request) {
    handleID(w, r, r.PathValue("id"))
})
```

## Related Concepts

- [Strings and Bytes](strings-bytes.md) — strings.CutPrefix replaces manual path trimming
- [Context Patterns](context-patterns.md) — context for HTTP request lifecycles
- [Time and Utilities](time-utilities.md) — url.Clone for copying request URLs
