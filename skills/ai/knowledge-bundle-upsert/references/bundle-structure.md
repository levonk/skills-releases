# Bundle Structure

## Directory Layout

```
knowledge-bundle/
├── index.md                      # Optional. Directory listing for progressive disclosure
├── log.md                        # Optional. Chronological history of updates
├── <concept>.md                  # A concept at the bundle root
└── <subdirectory>/               # Subdirectories organize concepts into groups
    ├── index.md
    ├── <concept>.md
    └── <subdirectory>/
        └── …
```

## Reserved Filenames

These filenames have defined meaning at any level and MUST NOT be used for
concept documents:

| Filename   | Purpose |
|------------|---------|
| `index.md` | Directory listing for progressive disclosure |
| `log.md`   | Chronological history of updates |

## Design Focus

- Create bundles that organize knowledge hierarchically
- Use descriptive `type` values that are self-explanatory
- Leverage conventional headings for consistency
- Design for both human readability and agent parseability
- Support progressive disclosure with index files

## Inputs

- Knowledge domain or topic area
- Types of concepts to include (tables, APIs, metrics, playbooks, etc.)
- Organizational structure preferences
- Existing documentation or resources to reference

## Operation

1. **Initialize**: Define bundle purpose, scope, and target directory
2. **Plan**: Design directory structure and concept types. Extract concepts,
   not pages — a single source document may produce many concept files. One
   concept per file; do not bundle multiple concepts into a single document.
3. **Apply**: Implement the bundle:
   - Create bundle directory structure
   - Create concept documents with proper frontmatter
   - Add `index.md` files for progressive disclosure
   - Establish cross-links between related concepts
4. **Verify**: Validate OKF v0.1 conformance (see `okf-spec.md` — OKF v0.1
   Conformance Criteria)
5. **Deliver**: Save bundle to the knowledge directory with documentation

<!-- vim: set ft=markdown -->
