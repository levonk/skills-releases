# Index Files (Progressive Disclosure)

Optional `index.md` files in any directory enumerate contents for humans/agents
to see what's available before opening individual documents.

## Format

Index files contain no frontmatter (exception: the bundle-root `index.md` MAY
contain `okf_version`). The body uses one or more sections, each grouping
concepts under a heading:

```markdown
# Section / Group Heading

* [Title 1](relative-url-1) - short description of item 1
* [Title 2](relative-url-2) - short description of item 2

# Another Section

* [Subdirectory](subdir/) - short description of the subdirectory
```

## Conventions

- Entries SHOULD include the description from the linked concept's frontmatter.
- Producers MAY generate `index.md` automatically; consumers MAY synthesize one
  on the fly when none is present.
- The agent updates `index.md` on every ingest.
- When answering a query, the agent reads the index first. This works well at
  moderate scale and avoids the need for embedding-based RAG infrastructure.

## Progressive Disclosure Principles

- Use `index.md` files to organize large collections
- Start with high-level categories, drill down as needed
- Keep individual concept documents focused
- Link to related concepts rather than duplicating content

<!-- vim: set ft=markdown -->
