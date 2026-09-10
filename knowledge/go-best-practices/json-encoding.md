---
type: Practice
title: JSON Encoding
description: Use encoding/json/v2 for new JSON code with stricter defaults, and use omitzero for bool, numeric, struct, and time fields whose zero value should be omitted (Go 1.24-1.27).
tags: [go, golang, json, encoding, omitzero, omitempty, json-v2]
date:
  created: "2026-09-04"
  knowledge-basis: "2026-09-04"
  last-used: "2026-09-04"

sources:
  - id: jetbrains-go-modern-guidelines
    resource: "FEATURES.md"
    title: "JetBrains/go-modern-guidelines"
---

# JSON Encoding

## Failure Mode

`encoding/json` v1 encodes nil slices and maps as `null` instead of empty arrays
and objects, which breaks consumers expecting consistent JSON shapes. It does not
reject invalid UTF-8 or duplicate object names. Using `omitempty` on bool,
numeric, struct, and time fields omits legitimate zero values (`false`, `0`,
zero time) when the intent is to omit only absent values.

## Practice

### json v2 (Go 1.27, High)

Use `encoding/json/v2` for new JSON code. It has stricter, more interoperable
defaults: it rejects invalid UTF-8 and duplicate object names, encodes nil
slices and maps as empty arrays and objects, and reports invalid JSON-related
Go types.

```go
// Before
import "encoding/json"

type Pet struct {
    Name      string
    Nicknames []string
}

body, err := json.Marshal(Pet{Name: "Remi"})
// body is {"Name":"Remi","Nicknames":null}

// After
import "encoding/json/v2"

type Pet struct {
    Name      string
    Nicknames []string
}

// New code uses v2's stricter defaults.
body, err := json.Marshal(Pet{Name: "Remi"})
// body is {"Name":"Remi","Nicknames":[]}
```

Do not replace `encoding/json` in existing code unless migration is explicitly
requested, because even a compiling import change can alter wire behavior. For
an explicit migration, begin with `jsonv1.DefaultOptionsV1()`, test serialized
output and accepted input, then remove or override compatibility options
deliberately.

```go
// Explicit migration — retain existing wire behavior first
import (
    jsonv1 "encoding/json"
    json "encoding/json/v2"
)

body, err := json.Marshal(
    Pet{Name: "Remi"},
    jsonv1.DefaultOptionsV1(),
)
// Existing consumers still receive {"Name":"Remi","Nicknames":null}.
```

### json omitzero (Go 1.24, Medium)

Use `omitzero` on JSON-tagged bool, numeric, struct, and time fields whose zero
value should be omitted. Keep `omitempty` for empty strings, slices, and maps.

```go
// Before
type CacheEntry struct {
    Name      string    `json:"name,omitempty"`
    Warm      bool      `json:"warm,omitempty"`
    Hits      int64     `json:"hits,omitempty"`
    ExpiresAt time.Time `json:"expiresAt,omitempty"`
}

// After
type CacheEntry struct {
    Name      string    `json:"name,omitempty"`
    Warm      bool      `json:"warm,omitzero"`
    Hits      int64     `json:"hits,omitzero"`
    ExpiresAt time.Time `json:"expiresAt,omitzero"`
}
```

## Related Concepts

- [Types and Generics](types-generics.md) — generic types used in JSON struct definitions
- [Time and Utilities](time-utilities.md) — time.Time fields with omitzero in JSON
- [Fmt Utilities](fmt-utilities.md) — fmt.Appendf for non-JSON formatted output
