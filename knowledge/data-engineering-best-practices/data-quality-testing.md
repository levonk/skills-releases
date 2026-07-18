---
type: Practice
title: Data Quality Testing — Schema, Freshness, and Pipeline Gates
description: Validate data before and after transformation with schema checks, freshness tests, uniqueness/referential integrity assertions, and Great Expectations or Soda as pipeline gates.
tags: [data-engineering, data-quality, testing, great-expectations, soda, schema, freshness]
timestamp: 2026-07-17T00:00:00Z
---

# Data Quality Testing

## Failure Mode

Bad data flows downstream because schema drift, null values, duplicate keys, and
stale sources are not detected until dashboards show wrong numbers.

## Symptoms

- A column is renamed in the source and downstream models fail at runtime.
- 30% of `order_id` values are suddenly null after a source load.
- A downstream report uses yesterday's data because the pipeline did not run.
- Dashboards show $10M revenue because a currency column was read as string and
  summed lexicographically.

## Practice

### Test Layers

| Layer | Tests |
|-------|-------|
| Source | Schema validation, row count deltas, freshness, null rates |
| Staging | Type casting, not-null, accepted values, uniqueness |
| Mart | Referential integrity, business rules, threshold checks |

### dbt Tests

- Generic: `not_null`, `unique`, `accepted_values`, `relationships`.
- Custom SQL tests for business rules.
- Source freshness: `freshness: { warn_after: { count: 1, period: hour } }`.

### Great Expectations / Soda

- Great Expectations: rich, documentation-backed expectations; good for data
  contracts and data docs.
- Soda: lightweight YAML checks; good for quick pipeline gates and CI.

### Pipeline Gates

- Fail the pipeline if critical checks fail.
- Use `warn` vs `error` severity.
- Send alerts to the data team Slack/Teams channel, not just email.

### Testcontainers

- For integration tests, use Testcontainers with Postgres/Mysql/Kafka to test
  pipeline code against real dependencies.

## Citations

[1] [dbt tests](https://docs.getdbt.com/docs/build/tests)
[2] [Great Expectations](https://greatexpectations.io/)
[3] [Soda](https://docs.soda.io/)
