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
