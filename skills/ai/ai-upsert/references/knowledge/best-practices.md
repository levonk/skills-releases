# Best Practices

## Type Naming

- Use descriptive, self-explanatory type names
- Avoid overly generic types ("Resource", "Item")
- Prefer domain-specific types ("BigQuery Table", "REST API Endpoint")
- Consumers MUST tolerate unknown types gracefully

## Progressive Disclosure

- Use `index.md` files to organize large collections
- Start with high-level categories, drill down as needed
- Keep individual concept documents focused
- Link to related concepts rather than duplicating content

## Cross-linking

- Prefer absolute (bundle-relative) links for stability
- Link to concepts rather than duplicating information
- Use descriptive link text
- Accept that some links may be broken (not-yet-written knowledge)

## Maintenance

- Update `date.knowledge-basis` when concepts change meaningfully
- Update `date.knowledge-basis` when 3rd-party tech references are re-verified
- Update `date.last-used` when the bundle is queried or referenced
- Use `log.md` for tracking major updates
- Keep frontmatter extensions minimal
- Preserve unknown keys when round-tripping documents

## OKF v0.2 Families — When to Use Them

All v0.2 frontmatter families are optional. Use them when they add value, not
by default:

- **`sources` (provenance)** — Use for concepts derived from external material
  (documentation, dashboards, papers). Record `resource`, `id` (for footnote
  attribution), and credibility signals (`author`, `usage_count`,
  `last_modified`) when available. Supersedes the v0.1 `# Citations` body list.
- **`generated`** — Use for agent-maintained bundles to record who produced the
  content and when. Supersedes the v0.1 `timestamp` field. Always include
  `generated.by` (an actor) and `generated.at` (ISO 8601 datetime).
- **`verified` (trust tiers)** — Use for agent-maintained bundles where human or
  process review matters. A `human:<id>` verifier raises the trust tier to
  human-reviewed; a `process:<id>` verifier yields machine-confirmed. Absence
  yields unverified (still consumable).
- **`status`** — Use `draft` for work-in-progress concepts, `deprecated` for
  concepts kept for links/history but no longer current. Absent ⇒ `stable`.
- **`stale_after`** — Use for time-sensitive knowledge (e.g., metrics, pricing,
  API quotas). Set an absolute `YYYY-MM-DD` date after which the content should
  be considered stale. An absolute date (not a relative TTL) keeps the
  staleness decision a plain date comparison.
- **`Attested Computation`** — Use when a value must be produced by a sanctioned
  computation rather than agent-improvised code. Create a standalone concept of
  `type: Attested Computation` with `runtime`, `parameters`, `executor`, and
  `attester`. Concepts that need the value link to it with a normal markdown
  link. See `okf-spec.md` — Attested Computation fields (§10).

## Lint (Health Checks)

Periodically health-check the bundle. Look for:

- Contradictions between pages (newer sources superseding stale claims)
- Orphan pages with no inbound links
- Important concepts mentioned in prose but lacking their own page
- Missing cross-references between related concepts
- Broken links that should be filled (not-yet-written knowledge that has become relevant)
- Data gaps that could be filled with a web search or a new source

The lint pass keeps the bundle healthy as it grows. File lint findings as new
concept documents or log entries — the bundle is a living artifact, not a
one-time deliverable.

## Compounding (File Answers Back)

Good answers and analyses produced during bundle use are valuable and should
not disappear into chat history. When a query produces a comparison, an
analysis, or a discovered connection, file it back into the bundle as a new
concept document. This way explorations compound in the knowledge base just like
ingested sources do — the bundle gets richer with every question asked.

## General Principles

- The bundle is just a git repo of markdown files — you get version history,
  branching, and collaboration for free.
- The tedious part of maintaining a knowledge base is the bookkeeping (updating
  cross-references, keeping summaries current, noting contradictions). Agents
  don't get bored, don't forget to update a cross-reference, and can touch 15
  files in one pass. The bundle stays maintained because the cost of maintenance
  is near zero.
- The human's job is to curate sources, direct the analysis, ask good questions,
  and think about what it all means. The agent's job is everything else.
- Lint regularly — a healthy bundle is more useful than a large one.
- When in doubt about whether to file something, file it. Compounding is the
  whole point.

## Normative Stance — Practice Pages State What to Do

Concept pages of `type: Practice` (or any normative type) state **what to do
and what to avoid**. They must not become academic comparisons of a specific
article or source. The source remains in `sources:` frontmatter as
provenance — that is the correct place for it.

### The Rule

- **Do** state the correct practice authoritatively ("Use `node:22-slim`",
  "Avoid `npx` inside containers").
- **Do** fold per-source corrections inline as "Avoid" callouts next to the
  relevant code block or decision — e.g., a `> **Avoid X.** Use Y instead —
  see [concept].` callout directly under the practice it contradicts.
- **Do not** create standalone "Corrections to Article X" sections, "Article
  says / Correct practice" comparison tables, or any section whose primary
  content is reacting to one specific source.
- **Do not** frame the page `description` as a critique of a source ("Corrects
  common article mistakes…"). Frame it as the normative practice.

### Why

- An AI reading a "Corrections to Article X" section sees the article's bad
  choices given equal weight with the correct practices. Without the article
  as context, the negative examples are noise; with it, the page reads as
  derivative rather than authoritative.
- Per-source critique sections do not compound — they are tied to one source
  that will go stale. Normative practices compound because they apply to every
  future source in the same domain.
- Token cost is small but the framing cost is real: a bundle that becomes
  "reactions to articles" instead of "what to do" loses its authority over
  time.

### When a Comparison Is the Concept

If the concept **is** a comparison (e.g., "pnpm vs bun in containers",
"Bun vs Node.js runtime performance"), that is a legitimate `type: Comparison`
or `type: Practice` page where the comparison **is** the knowledge. The rule
above targets per-source critique interleaved into normative pages, not
comparison-as-concept.

<!-- vim: set ft=markdown -->
