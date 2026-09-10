# Example Concepts

## Resource-bound concept

```markdown
---
type: BigQuery Table
title: Customer Orders
description: One row per completed customer order across all channels.
resource: https://console.cloud.google.com/bigquery?p=acme&d=sales&t=orders
tags: [sales, orders, revenue]
timestamp: 2026-05-28T14:30:00Z
---

# Schema

| Column        | Type      | Description                              |
|---------------|-----------|------------------------------------------|
| `order_id`    | STRING    | Globally unique order identifier.        |
| `customer_id` | STRING    | Foreign key into [customers](/tables/customers.md). |
| `total_usd`   | NUMERIC   | Order total in US dollars.               |
| `placed_at`   | TIMESTAMP | When the customer submitted the order.   |

# Joins

Joined with [customers](/tables/customers.md) on `customer_id`.

# Citations

[1] [BigQuery table schema](https://console.cloud.google.com/bigquery?p=acme&d=sales&t=orders)
```

## Citation Format

When a concept's body makes claims sourced from external material, those sources
SHOULD be listed under a `# Citations` heading at the bottom of the document,
numbered:

```markdown
# Citations

[1] [BigQuery public dataset announcement](https://cloud.google.com/blog/products/data-analytics/...)
[2] [Internal data quality runbook](https://wiki.acme.internal/data/quality)
```

Citation links MAY be absolute URLs, bundle-relative paths, or paths into a
`references/` subdirectory that mirrors external material as first-class OKF
concepts.

## Abstract concept

```markdown
---
type: Playbook
title: Incident response — data freshness alert
description: Steps to triage a freshness alert on the orders pipeline.
tags: [oncall, incident]
timestamp: 2026-04-12T09:00:00Z
---

# Trigger

A freshness alert fires when `orders` lags more than 30 minutes behind its expected SLA. See the [orders table](/tables/orders.md).

# Steps

1. Check the [ingestion job dashboard](https://example.com/dash).
2. Verify data source availability
3. Check pipeline logs for errors
4. Escalate if unresolved in 15 minutes
```

## References

- Knowledge bundle scaffold: `config/ai/templates/meta/knowledge-bundle-template.md`
- Concept templates: `config/ai/templates/ai/knowledge-bundle/references/concept-template-resource-bound.md`, `concept-template-abstract.md`
- Index/log templates: `config/ai/templates/ai/knowledge-bundle/references/index-log-templates.md`

<!-- vim: set ft=markdown -->
