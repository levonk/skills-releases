# Operations: Ingest, Query, Lint

A knowledge bundle is not a one-time deliverable — it is a persistent,
compounding artifact. The Create mode produces the initial structure. These
three operations keep the bundle useful as it grows.

## Ingest

You drop a new source into the raw collection and tell the agent to process it.
The agent:

1. Reads the source
2. Discusses key takeaways (optional — depends on supervision level)
3. Writes a summary page in the bundle
4. Updates the index (`index.md`)
5. Updates relevant entity and concept pages across the bundle
6. Appends an entry to the log (`log.md`)

A single source might touch 10-15 bundle pages. Extract concepts, not pages — a
single source document may produce many concept files. One concept per file.

### Normative Stance During Ingest

When a source contains choices that violate your standards, **fold the
corrections inline** as "Avoid" callouts next to the relevant practice — do
not create a standalone "Corrections to Article X" section or an
"Article says / Correct practice" comparison table. The source remains in
`sources:` frontmatter as provenance. See the Normative Stance rule in
`best-practices.md`.

### Supervision Levels

- **One-at-a-time (recommended)**: Ingest sources one at a time, stay involved —
  read the summaries, check the updates, guide the agent on what to emphasize.
- **Batch**: Ingest many sources at once with less supervision. Faster but less
  curated.

Document the chosen workflow in the bundle's schema for future sessions.

### Bundle-Specific Search (Before Adding a Concept)

When researching before adding a new concept page to a knowledge bundle:

1. **Check the index**: Read `index.md` for existing concepts covering the same
   topic.
2. **Search the bundle**: Grep the bundle directory for keywords related to the
   new concept.
3. **Check for contradictions**: If a similar concept exists, verify the new
   source doesn't contradict it. If it does, update the existing page rather
   than creating a duplicate.

## Query

You ask questions against the bundle. The agent:

1. Reads the index first to find relevant pages
2. Drills into the relevant concept documents
3. Synthesizes an answer with citations

Answers can take different forms depending on the question — a markdown page, a
comparison table, a chart.

**File good answers back.** Good answers and analyses are valuable and should
not disappear into chat history. A comparison you asked for, an analysis, a
connection you discovered — file it back into the bundle as a new concept
document. This way explorations compound in the knowledge base just like
ingested sources do.

## Lint

Periodically health-check the bundle. Look for:

- **Contradictions** between pages (newer sources superseding stale claims)
- **Orphan pages** with no inbound links
- **Missing pages** — important concepts mentioned in prose but lacking their own page
- **Missing cross-references** between related concepts
- **Broken links** that should be filled (not-yet-written knowledge that has become relevant)
- **Data gaps** that could be filled with a web search or a new source
- **Article-comparison sections** in Practice pages — standalone "Corrections
  to Article X" sections or "Article says / Correct practice" tables violate
  the Normative Stance rule (see `best-practices.md`). Flag them for refactor:
  fold the corrections inline as "Avoid" callouts next to the relevant
  practice, keep the source in `sources:` frontmatter only.

### OKF v0.2 Conformance Checks

Verify the 3 hard conformance rules (§11):

1. Every non-reserved `.md` file has parseable YAML frontmatter
2. Every frontmatter has a non-empty `type` field
3. Reserved filenames (`index.md`, `log.md`) follow their specified structure

Soft checks for the optional v0.2 families (absence is conformant — these are
guidance, not failures):

- **`sources`**: If present, each entry has a `resource`; footnotes in the body
  reference valid `sources[].id` values

### Sources Accessibility Validation

In addition to the structural conformance check above, run
`scripts/knowledge/validate_sources.py` to verify that every
`sources[].resource` entry is actually accessible:

- **URLs** (`http://`/`https://`): HTTP HEAD request with a 10s timeout,
  following redirects. 2xx/3xx = accessible; 4xx/5xx/timeout/connection
  error = warning. URLs on [RFC 2606](https://www.rfc-editor.org/rfc/rfc2606)
  reserved domains are always treated as accessible — they are
  placeholders, not real sources to validate. The reserved domains are:
  - **Second-level domains**: `example.com`, `example.org`, `example.net`
    (and any subdomain thereof, e.g. `foo.example.com`)
  - **Top-level domains**: `.test`, `.example`, `.invalid`, `.localhost`
    (any hostname ending in these TLDs, e.g. `myapp.test`,
    `demo.example`, `broken.invalid`, `loopback.localhost`)
- **Local paths** (no scheme): resolved relative to the markdown file's
  directory; file must exist. Missing file = warning.
- **Other schemes** (`mailto:`, `ftp:`, etc.): skipped, no warning.

The script emits **warnings, not errors** — never removes a source
automatically. Review each warning and decide:

1. **Update** the URL if the resource moved (search for the new location)
2. **Mark stale** by adding a `last_modified` date and a note in the
   concept's `log.md` entry
3. **Remove** the source only if it's truly obsolete and the claim it
   supports is no longer needed

**Disabling network checks**: pass `--no-network` to skip URL
accessibility checks and only validate local paths. Useful in
airgapped environments or when the lint pass should be fast.

**Strict mode**: pass `--strict` to exit non-zero on any warning — useful
in CI gates.

**Markdown extensions scanned**: `.md`, `.md.tmpl`, `.mmd`, `.mmd.tmpl`,
`.md.template`, `.md.j2`, `.mmd.j2`, `.markdown`, `.mdown`, `.mdtxt`,
`.mdtext`, `.mkd`, `.mdx`, `.mkdn`, `.mkdwn` — covers plain markdown,
templater files, and common markdown variants.
- **`generated`**: If present, has `by` (an actor) and `at` (ISO 8601 datetime)
- **`verified`**: If present, each entry has `by` and `at`; a bare mapping is
  treated as a one-element list
- **`status`**: If present, is `draft`, `stable`, or `deprecated`
- **`stale_after`**: If present, is a valid `YYYY-MM-DD` date; flag concepts
  where `today >= stale_after` as stale
- **`Attested Computation`**: If `type: Attested Computation`, verify `runtime`
  is present and `parameters` entries have `name`, `type`, `required`
- **Legacy fields**: `timestamp` and `# Citations` are superseded but consumers
  MAY still parse them — flag for migration to `generated` and `sources`

The agent is good at suggesting new questions to investigate and new sources to
seek. File lint findings as new concept documents or log entries.

## Indexing and Logging

Two reserved filenames help navigate the bundle as it grows:

- **`index.md`** is content-oriented — a catalog of everything in the bundle,
  each page listed with a link and a one-line description. The agent updates it
  on every ingest. When answering a query, the agent reads the index first.
- **`log.md`** is chronological — an append-only record of what happened and
  when (ingests, queries, lint passes). Newest first, ISO 8601 date headings.

See `index-files.md` and `log-files.md` for the detailed formats.

<!-- vim: set ft=markdown -->
