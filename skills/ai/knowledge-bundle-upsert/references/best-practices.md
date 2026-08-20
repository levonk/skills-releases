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

- Update timestamps when concepts change meaningfully
- Use `log.md` for tracking major updates
- Keep frontmatter extensions minimal
- Preserve unknown keys when round-tripping documents

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

<!-- vim: set ft=markdown -->
