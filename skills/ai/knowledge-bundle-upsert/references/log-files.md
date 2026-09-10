# Log Files (Update History)

Optional `log.md` files provide chronological history of updates. The format is
a flat list of date-grouped entries, **newest first**:

```markdown
# Directory Update Log

## 2026-05-22
* **Update**: Added new BigQuery table reference for [Customer Metrics](/tables/customer-metrics.md).
* **Creation**: Established the [Dataplex Playbook](/playbooks/dataplex.md).

## 2026-05-15
* **Initialization**: Created foundational directory structure.
* **Update**: Added progressive-disclosure guidelines to the root [index](/index.md).
```

## Format Rules

- Date headings MUST use ISO 8601 `YYYY-MM-DD` form.
- Log entries are prose; the leading bold word (`**Update**`, `**Creation**`,
  `**Deprecation**`, etc.) is a convention, not a requirement.
- For grep-friendly parseability, entries MAY use a consistent
  `**<operation>** | <subject>` prefix within each date group. This complements
  the spec format (spec takes precedence):
  `grep "^\* \*\*ingest\*\*" log.md` returns all ingest entries across all dates.

## Maintenance

- Use `log.md` for tracking major updates
- Append an entry on every ingest, query filed back, and lint pass
- Keep frontmatter extensions minimal
- Preserve unknown keys when round-tripping documents

<!-- vim: set ft=markdown -->
