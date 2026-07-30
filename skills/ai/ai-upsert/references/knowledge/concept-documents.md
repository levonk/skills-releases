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
# --- Optional OKF v0.2 families (all optional, §5/§10) ---
sources:                           # Provenance — materials a concept derives from
  - id: <stable-key>               #   Optional; used for footnote attribution
    resource: <URL or path>        #   REQUIRED within entry
    title: <Optional label>
    author: <actor>                #   Optional credibility signal
    usage_count: <integer>         #   Optional credibility signal
    last_modified: <YYYY-MM-DD>    #   Optional credibility signal
usage_window: { from: <YYYY-MM-DD>, to: <YYYY-MM-DD> }  # Frames usage_count
generated: { by: <actor>, at: <ISO 8601 datetime> }     # Who/when content was produced
verified:                          # Trust — verification events
  - { by: <actor>, at: <ISO 8601 datetime> }
status: stable                     # draft | stable | deprecated (absent ⇒ stable)
stale_after: <YYYY-MM-DD>          # Absolute staleness date
# --- Attested Computation fields (§10, only for type: Attested Computation) ---
runtime: <runtime>                 # REQUIRED for Attested Computation
parameters:                        # Typed, named holes the agent may fill
  - { name: <name>, type: <type>, required: true }
computation: <path>                # Optional; else body # Computation fence
executor: { resource: <path>, receipt: [<fields>] }
attester: { resource: <path> }
# … other producer-defined key/value pairs
---
```

### Required Fields

- `type` — Short string identifying the kind of concept (e.g., "BigQuery
  Table", "API Endpoint", "Metric", "Playbook", "Attested Computation"). Type
  values are NOT registered centrally — pick descriptive, self-explanatory
  values. Consumers MUST tolerate unknown types gracefully.

### Recommended Fields (in priority order)

- `title` — Human-readable display name. If omitted, consumers MAY derive a
  title from the filename.
- `description` — Single sentence summary for search snippets/previews
- `resource` — URI uniquely identifying the underlying asset (for physical
  resources). Absent for abstract concepts.
- `tags` — YAML list of short strings for cross-cutting categorization

### Optional v0.2 Families (all optional — §5, §10)

The provenance, trust, lifecycle, and computation families are all optional.
Their absence yields a plain v0.1-style concept and is fully conformant under
v0.2. See `okf-spec.md` for the full field-by-field reference.

- **`sources`** — List of materials a concept derives from, with optional
  credibility signals (`author`, `usage_count`, `last_modified`) and a sibling
  `usage_window`. Supersedes the body `# Citations` list from v0.1.
- **`generated`** — `{ by, at }` recording who/what produced the content and
  when. Supersedes the legacy `timestamp` field from v0.1.
- **`verified`** — List (or bare mapping) of `{ by, at }` verification events.
  Drives trust tier derivation (unverified / machine-confirmed / human-reviewed).
- **`status`** — `draft | stable | deprecated` (absent ⇒ `stable`).
- **`stale_after`** — Absolute date (`YYYY-MM-DD`) after which content is stale.
- **Attested Computation fields** (`runtime`, `parameters`, `computation`,
  `executor`, `attester`) — Only for `type: Attested Computation` concepts.

### Actor Convention (§7)

Fields that record an identity (`generated.by`, `verified[].by`) use:

- `<producer>/<version>` for agents and tools (e.g., `reference_agent/gemini-2.5-pro`)
- `human:<id>` for people (e.g., `human:ahormati`)
- `process:<id>` for automated processes (e.g., `process:finance-nightly`)

### Extensions

Producers MAY include any additional keys. Consumers SHOULD preserve unknown
keys when round-tripping and MUST NOT reject documents with unrecognized
fields.

### Versioning

Bundles MAY declare the OKF version they target by including `okf_version: "0.2"`
in a bundle-root `index.md` frontmatter block (the only place frontmatter is
permitted in an `index.md`). Consumers that do not understand the declared
version SHOULD attempt best-effort consumption rather than refusing the bundle.

## 2. Body (Markdown)

Producers SHOULD favor structural markdown — headings, lists, tables, fenced
code blocks — over freeform prose, since structure aids both human reading and
agent retrieval.

Standard markdown with conventional headings when applicable:

| Heading          | Purpose |
|------------------|---------|
| `# Schema`       | Structured description of columns/fields |
| `# Examples`     | Concrete usage examples (fenced code blocks) |
| `# Computation`  | The sanctioned computation of an Attested Computation (§10) |

> **Note:** The `# Citations` heading from v0.1 is superseded by the `sources`
> frontmatter field and per-claim footnote attribution (§5.1, §13.1). Consumers
> MAY still parse legacy `# Citations` body lists for v0.1 documents.

### Per-Claim Attribution (§5.1)

To attribute a specific claim to a source, use a markdown footnote whose label
is a `sources[].id`:

```markdown
The `events_` table is sharded daily as `events_YYYYMMDD`.[^ga4-schema]

[^ga4-schema]: GA4 BigQuery Export schema
```

The footnote label is the join key into `sources`; consumers resolve attribution
through the matching entry, not by parsing the footnote prose. Labels are keyed
(not positional) so they survive list reordering.

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
