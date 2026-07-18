---
type: Synthesis
title: Data Engineering Best Practices Overview
description: Synthesis of data engineering practices spanning ETL/ELT, Airflow orchestration, layered container images, Spark, dbt, warehouse design, streaming, data quality, orchestration tooling, CQRS, and ORM patterns.
tags: [data-engineering, airflow, spark, dbt, data-warehouse, streaming, data-quality, orchestration, cqrs, drizzle, overview, synthesis]
timestamp: 2026-07-17T00:00:00Z
---

# Data Engineering Best Practices Overview

This bundle documents practices for building and operating data platforms —
from pipeline authoring and orchestration to warehouse modeling, streaming
semantics, data quality, and application-level data access. Each concept was
extracted from real infrastructure: an Airflow-on-Kubernetes deployment with
layered container images, a spec-driven image build pipeline, comparison
matrices of orchestration tools, and TypeScript application data-access
patterns using Drizzle ORM and CQRS-style read models.

## The Data Engineering Lifecycle

```
ingest → transform → orchestrate → store → quality → serve
           ↑            ↑          ↑        ↑        ↑
       etl-vs-elt   airflow-*   warehouse  data-   cqrs /
       dbt          spark       design     quality  drizzle
                     ↑
              orchestration-comparison
```

Each phase has practices that prevent specific failure modes:

| Phase | Practice | Prevents |
|-------|----------|----------|
| Ingest/Transform | [ETL vs ELT](etl-vs-elt.md) | Transforming in the wrong place; warehouse compute waste; brittle pre-load transforms |
| Orchestration | [Airflow DAG Patterns](airflow-dag-patterns.md) | Non-idempotent reruns, XCom bloat, tangled task boundaries |
| Orchestration | [Airflow Layered Images](airflow-layered-images.md) | Rebuilding Airflow from scratch on every change; task images bloated with scheduler code |
| Orchestration | [Airflow on Kubernetes](airflow-on-kubernetes.md) | Privileged containers, shared metadata DB corruption, executor misconfiguration |
| Processing | [Spark Best Practices](spark-best-practices.md) | Shuffle storms, OOM kills, broadcast-join blowups, wasted caching |
| Transform | [dbt Transformation Patterns](dbt-transformation-patterns.md) | Untested models, full-refresh explosions, lost history without snapshots |
| Storage | [Data Warehouse Design](data-warehouse-design.md) | Snowflake-schema join complexity, lost dimension history, fact table grain confusion |
| Streaming | [Streaming Data Patterns](streaming-data-patterns.md) | At-least-once duplicates, late events dropping, windowing misalignment |
| Quality | [Data Quality Testing](data-quality-testing.md) | Silent schema drift, stale data flowing downstream, unmonitored freshness |
| Tooling | [Orchestration Comparison](orchestration-comparison.md) | Picking Airflow for CI/CD, Tekton for ETL, or ignoring Kueue quota needs |
| Serving | [CQRS and Caching](cqrs-and-caching.md) | Read/write model coupling, cache staleness, thundering herd on cache miss |
| Serving | [Drizzle ORM Patterns](drizzle-orm-patterns.md) | Unmanaged migrations, raw SQL drift, missing schema type safety |

## Scope

This bundle covers **data pipeline authoring, orchestration, transformation,
warehouse modeling, streaming, data quality, and application data access**. It
does **not** cover:

- General Kubernetes operations — see the container-best-practices bundle.
- Container image build mechanics — see [airflow-layered-images](airflow-layered-images.md)
  for the Airflow-specific layered strategy and the container bundle for
  general Dockerfile practices.
- Frontend data fetching and UI state management — this bundle's
  [cqrs-and-caching](cqrs-and-caching.md) covers the backend read/write split
  only.

## Relationship to Real Infrastructure

The Airflow concepts are grounded in the infrahub Airflow service at
`shared/active/03-container/services/airflow/` and the job-aide spec
`specs/005-airflow-layered-images-spec/`. The layered image strategy
(airflow-base-common → base-python → airflow-core → airflow-platform →
airflow-py) is a real, deployed pattern using Airflow 3.1.2, Python 3.14
(Debian) / 3.13 (Alpine fallback), KubernetesExecutor, and Postgres metadata
DB.

The orchestration comparison synthesizes 2ndbrain feature-matrix notes that
compare Airflow, Argo Workflows, Tekton Pipelines, and Kueue across licensing,
Kubernetes nativeness, scheduling, and workload fit.

The Drizzle and CQRS concepts reference the job-aide `left-parody` application's
Drizzle ORM configuration and the architecture gaps analysis that identifies
CQRS/read models as a planned capability.

## Sources

The initial 12 concepts were extracted from three real sources on 2026-07-17:

1. **infrahub** — Airflow service README and layered image directory structure.
2. **job-aide** — `005-airflow-layered-images-spec` (spec, plan, research,
   quickstart), Drizzle ORM config, PostgreSQL ADR, and architecture gaps
   analysis.
3. **2ndbrain** — Orchestration comparison notes (Airflow vs Argo vs Tekton,
   Kueue vs Airflow, open-source workflow tools comparison).

See each concept's `# Citations` section for the specific file paths and URLs.

## Compounding

New lessons from future data engineering work — production incidents, new
tooling evaluations, warehouse migrations, streaming redesigns — should be
filed as new concept pages. The trigger for adding a concept is: a pipeline
failure, a data quality incident, a tooling comparison that resolved a
decision, or a debugging session that revealed a practice the bundle doesn't
yet cover. Append to `log.md` when adding.

Future concept candidates (not yet in the bundle):

- `data-lineage.md` — OpenLineage integration, Marquez, lineage-driven
  impact analysis
- `data-contracts.md` — Schema contracts between producing and consuming
  teams, contract testing
- `feature-store-patterns.md` — Online/offline feature parity, Feast, Tecton
- `lakehouse-architecture.md` — Iceberg/Delta/Hudi table formats, time travel,
  ACID on object storage
- `reverse-etl.md` — Hightouch, Census, pushing warehouse data back to
  operational systems

## Related Knowledge Bundles

- [container-best-practices](../container-best-practices/overview.md) —
  container authoring, layered images, and runtime hardening used by Airflow
  and Spark deployments.
- [java-best-practices](../java-best-practices/overview.md) — Spark and other
  JVM data processing tools build on Java packaging and JVM tuning practices.
- [typescript-monorepo-best-practices](../typescript-monorepo-best-practices/overview.md)
  — TypeScript data access layers (Drizzle ORM, CQRS) and monorepo conventions
  used by data products.
- [devsecops-codeguard](../devsecops-codeguard/overview.md) — pipeline
  security, credential handling, and container hardening for data platforms.

## Citations

[1] [infrahub Airflow service README](https://github.com/levonk/infrahub/blob/main/shared/active/03-container/services/airflow/README.md) — `shared/active/03-container/services/airflow/README.md`
[2] [job-aide Airflow layered images spec](https://github.com/lrepo52/job-aide/blob/main/specs/005-airflow-layered-images-spec/spec.md) — `specs/005-airflow-layered-images-spec/`
[3] [2ndbrain: Airflow vs Argo Workflows vs Tekton Pipelines](https://github.com/levonk/2ndbrain) — `Default/Technologies/Computer/Data/Airflow vs Argo Workflows vs Tekton Pipelines.md`
[4] [2ndbrain: Kueue vs Airflow](https://github.com/levonk/2ndbrain) — `Default/Technologies/Computer/Data/Kueue vs Airflow.md`
[5] [job-aide ADR-20251106011: PostgreSQL as Primary Database](https://github.com/lrepo52/job-aide/blob/main/internal-docs/adr/adr-20251106011-postgresql-for-database.md)
[6] [job-aide Drizzle ORM config](https://github.com/lrepo52/job-aide/blob/main/apps/active/politics/left-parody/web/typescript/drizzle.config.ts) — `apps/active/politics/left-parody/web/typescript/drizzle.config.ts`
