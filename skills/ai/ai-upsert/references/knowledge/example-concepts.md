# Example Concepts

## Resource-bound concept (minimal v0.1-style — still conformant under v0.2)

```markdown
---
type: BigQuery Table
title: Customer Orders
description: One row per completed customer order across all channels.
resource: https://console.cloud.google.com/bigquery?p=acme&d=sales&t=orders
tags: [sales, orders, revenue]
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
```

> **Note:** This minimal form (just `type` + recommended fields) is fully
> conformant under OKF v0.2. The v0.1 `# Citations` body list and `timestamp`
> field are superseded by `sources` frontmatter and `generated` respectively,
> but consumers MAY still parse them for legacy documents.

## Abstract concept (minimal v0.1-style — still conformant under v0.2)

```markdown
---
type: Playbook
title: Incident response — data freshness alert
description: Steps to triage a freshness alert on the orders pipeline.
tags: [oncall, incident]
---

# Trigger

A freshness alert fires when `orders` lags more than 30 minutes behind its expected SLA. See the [orders table](/tables/orders.md).

# Steps

1. Check the [ingestion job dashboard](https://example.com/dash).
2. Verify data source availability
3. Check pipeline logs for errors
4. Escalate if unresolved in 15 minutes
```

## v0.2 example: concept with `sources` + footnote attribution

```markdown
---
type: BigQuery Table
title: GA4 Events
description: Daily-sharded GA4 event export table.
resource: https://console.cloud.google.com/bigquery?p=acme&d=analytics&t=events
tags: [analytics, ga4, events]
status: stable
generated: { by: reference_agent/gemini-2.5-pro, at: 2026-06-20T22:53:05Z }
verified: { by: human:ahormati, at: 2026-06-25T09:00:00Z }
sources:
  - id: ga4-schema
    resource: https://developers.google.com/analytics/bigquery/export-schema
    title: GA4 BigQuery Export schema
    author: team:ga4-docs
    usage_count: 5000
    last_modified: 2026-05-30
usage_window: { from: 2026-06-01, to: 2026-06-30 }
---

# Schema

| Column        | Type      | Description                              |
|---------------|-----------|------------------------------------------|
| `event_date`  | DATE      | The date of the event (partition key).   |
| `event_name`  | STRING    | The name of the event.                   |
| `user_pseudo_id` | STRING | Anonymous user identifier.              |

The `events_` table is sharded daily as `events_YYYYMMDD`.[^ga4-schema]

[^ga4-schema]: GA4 BigQuery Export schema
```

## v0.2 example: Attested Computation concept

```markdown
---
type: Attested Computation
title: Revenue for fiscal year
description: Recognized revenue for a fiscal year, per Finance's definition.
tags: [finance, revenue]
status: stable
runtime: bigquery
parameters:
  - { name: year, type: integer, required: true }
executor:
  resource: references/skills/run-on-bq.md
  receipt: [job_id, executed_sql, result]
attester:
  resource: references/attesters/revenue.py
generated: { by: reference_agent/gemini-2.5-pro, at: 2026-06-20T22:53:05Z }
verified: { by: human:ahormati, at: 2026-06-25T09:00:00Z }
stale_after: 2026-12-31
sources:
  - id: rev-policy
    resource: https://wiki.acme/finance/revenue-recognition
    title: Revenue recognition policy
---

# Computation

    SELECT SUM(amount) AS revenue
    FROM finance.recognized_revenue
    WHERE fiscal_year = @year

Recognized revenue per the recognition policy.[^rev-policy]

[^rev-policy]: Revenue recognition policy
```

A concept that uses this computation links to it with a normal markdown link:

```markdown
---
type: Metric
title: Revenue
description: Recognized revenue for a fiscal year.
tags: [finance, revenue]
status: stable
generated: { by: reference_agent/gemini-2.5-pro, at: 2026-06-20T22:53:05Z }
---

# Definition

Recognized revenue sums `amount` over rows booked to the fiscal year,
computed by [the revenue computation](../computations/revenue.md).
```

## References

- OKF v0.2 spec (worked example, Appendix A): <https://github.com/GoogleCloudPlatform/knowledge-catalog/blob/main/okf/SPEC.md>
- See `okf-spec.md` for the full frontmatter family reference

<!-- vim: set ft=markdown -->
