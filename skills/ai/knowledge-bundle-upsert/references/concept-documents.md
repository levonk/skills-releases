# Concept Document Structure

Every concept is a UTF-8 markdown file with two parts: frontmatter (YAML) and
body (markdown).

## 1. Frontmatter (YAML)

```yaml
---
type: <Type name>                  # REQUIRED
title: <Optional display name>
description: <Optional one-line summary>
resource: <Optional canonical URI for the underlying asset>
tags: [<tag>, <tag>, …]            # Optional
timestamp: <ISO 8601 datetime>     # Optional last-modified time
okf_version: "0.1"                 # Optional, bundle-root index.md ONLY
# … other producer-defined key/value pairs
---
```

### Required Fields

- `type` — Short string identifying the kind of concept (e.g., "BigQuery
  Table", "API Endpoint", "Metric", "Playbook"). Type values are NOT registered
  centrally — pick descriptive, self-explanatory values. Consumers MUST tolerate
  unknown types gracefully.

### Recommended Fields (in priority order)

- `title` — Human-readable display name. If omitted, consumers MAY derive a
  title from the filename.
- `description` — Single sentence summary for search snippets/previews
- `resource` — URI uniquely identifying the underlying asset (for physical
  resources). Absent for abstract concepts.
- `tags` — YAML list of short strings for cross-cutting categorization
- `timestamp` — ISO 8601 datetime of last meaningful change

### Extensions

Producers MAY include any additional keys. Consumers SHOULD preserve unknown
keys when round-tripping and SHOULD NOT reject documents with unrecognized
fields.

### Versioning

Bundles MAY declare the OKF version they target by including `okf_version: "0.1"`
in a bundle-root `index.md` frontmatter block (the only place frontmatter is
permitted in an `index.md`). Consumers that do not understand the declared
version SHOULD attempt best-effort consumption rather than refusing the bundle.

## 2. Body (Markdown)

Producers SHOULD favor structural markdown — headings, lists, tables, fenced
code blocks — over freeform prose, since structure aids both human reading and
agent retrieval.

Standard markdown with conventional headings when applicable:

| Heading        | Purpose |
|----------------|---------|
| `# Schema`     | Structured description of columns/fields |
| `# Examples`   | Concrete usage examples (fenced code blocks) |
| `# Citations`  | External sources backing claims |

## Cross-linking Concepts

Use standard markdown links to express relationships between concepts.

### Absolute (bundle-relative) links (RECOMMENDED)
```markdown
See the [customers table](/tables/customers.md) for the join key.
```

### Relative links
```markdown
See the [neighboring concept](./other.md).
```

Link semantics are conveyed by surrounding prose, not the link itself. Consumers
MUST tolerate broken links (not-yet-written knowledge).

### Cross-linking Best Practices

- Prefer absolute (bundle-relative) links for stability
- Link to concepts rather than duplicating information
- Use descriptive link text
- Accept that some links may be broken (not-yet-written knowledge)

<!-- vim: set ft=markdown -->
