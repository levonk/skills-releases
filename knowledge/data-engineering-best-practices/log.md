# Directory Update Log

## 2026-07-17

* **Update**: Completed missing concept pages that were referenced in [index.md](index.md) and [overview.md](overview.md) but not yet written to disk.
  - [airflow-layered-images.md](airflow-layered-images.md) — Airflow layered image strategy
  - [airflow-on-kubernetes.md](airflow-on-kubernetes.md) — KubernetesExecutor, Helm, security hardening
  - [spark-best-practices.md](spark-best-practices.md) — Spark partitioning, caching, memory tuning
  - [dbt-transformation-patterns.md](dbt-transformation-patterns.md) — dbt models, tests, snapshots, incremental models
  - [data-warehouse-design.md](data-warehouse-design.md) — star schema, SCD, fact/dimension tables
  - [streaming-data-patterns.md](streaming-data-patterns.md) — Kafka/Kinesis, exactly-once, watermarking
  - [data-quality-testing.md](data-quality-testing.md) — schema validation, freshness, pipeline gates
  - [orchestration-comparison.md](orchestration-comparison.md) — Airflow vs Argo vs Tekton vs Kueue
  - [cqrs-and-caching.md](cqrs-and-caching.md) — CQRS with delayed reads
  - [drizzle-orm-patterns.md](drizzle-orm-patterns.md) — Drizzle ORM schema, migrations, PostgreSQL

## 2026-07-17

* **Initialization**: Created the `data-engineering-best-practices` knowledge bundle as an OKF v0.1 knowledge base, seeded from real findings across infrahub, job-aide, and 2ndbrain.
* **Creation**: Initialized [index.md](index.md) directory listing and [overview.md](overview.md) synthesis covering the full data engineering practice set.
* **Creation**: Added 12 concept pages sourced from real infrastructure, specs, and comparison notes.
  - [etl-vs-elt.md](etl-vs-elt.md) — ETL vs ELT patterns, modern ELT with dbt
  - [airflow-dag-patterns.md](airflow-dag-patterns.md) — DAG authoring, idempotency, XCom boundaries
  - [airflow-layered-images.md](airflow-layered-images.md) — layered image strategy (airflow-base-common → base-python → airflow-core → airflow-platform → airflow-py)
  - [airflow-on-kubernetes.md](airflow-on-kubernetes.md) — KubernetesExecutor, Helm, Postgres metadata DB, security hardening
  - [spark-best-practices.md](spark-best-practices.md) — partitioning, broadcast joins, caching, memory tuning
  - [dbt-transformation-patterns.md](dbt-transformation-patterns.md) — models, tests, snapshots, materializations, incremental models
  - [data-warehouse-design.md](data-warehouse-design.md) — star schema, SCD1/SCD2, fact/dimension tables
  - [streaming-data-patterns.md](streaming-data-patterns.md) — Kafka/Kinesis, exactly-once, watermarking, windowing
  - [data-quality-testing.md](data-quality-testing.md) — Great Expectations, Soda, schema validation, freshness checks
  - [orchestration-comparison.md](orchestration-comparison.md) — Airflow vs Argo vs Tekton vs Kueue
  - [cqrs-and-caching.md](cqrs-and-caching.md) — CQRS with delayed reads for cache-first retrieval
  - [drizzle-orm-patterns.md](drizzle-orm-patterns.md) — Drizzle ORM config, schema, migrations for PostgreSQL
* **Note**: Airflow layered image concepts derived from the infrahub Airflow service README (155 lines) and the job-aide `005-airflow-layered-images-spec` (spec, plan, quickstart, research). Orchestration comparison sourced from 2ndbrain feature-matrix notes. Drizzle and CQRS patterns sourced from job-aide `left-parody` app and ADR-20251106011.
