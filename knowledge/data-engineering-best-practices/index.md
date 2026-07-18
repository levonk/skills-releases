---
okf_version: "0.1"
---

# Data Engineering Best Practices

A compounding knowledge base documenting hard-won lessons from building data
platforms, pipelines, and orchestration systems. Each concept captures a
specific practice grounded in real infrastructure — Airflow deployments on
Kubernetes, layered container images, warehouse modeling, streaming semantics,
and ORM/data-access patterns observed in production codebases.

## Concepts

* [Overview](overview.md) - Synthesis of the full practice set and how the pieces fit together
* [ETL vs ELT](etl-vs-elt.md) - ETL transforms before load; ELT loads then transforms in-warehouse with dbt — choose by warehouse compute cost and transformation maturity
* [Airflow DAG Patterns](airflow-dag-patterns.md) - Idempotent tasks, clear task boundaries, XCom for small data only, deterministic retries
* [Airflow Layered Images](airflow-layered-images.md) - Split Airflow runtime into base-common → base-python → core → platform → py layers for cache reuse and task-image separation
* [Airflow on Kubernetes](airflow-on-kubernetes.md) - KubernetesExecutor, Helm chart deployment, Postgres metadata DB, non-root read-only security hardening
* [Spark Best Practices](spark-best-practices.md) - Partitioning, broadcast joins, caching strategy, memory tuning, and shuffle reduction
* [dbt Transformation Patterns](dbt-transformation-patterns.md) - Models, tests, snapshots, materializations, and incremental models for in-warehouse transformations
* [Data Warehouse Design](data-warehouse-design.md) - Star schema vs snowflake, slowly changing dimensions (SCD1/SCD2), fact and dimension table modeling
* [Streaming Data Patterns](streaming-data-patterns.md) - Kafka/Kinesis patterns, exactly-once semantics, watermarking, and windowing strategies
* [Data Quality Testing](data-quality-testing.md) - Great Expectations and Soda for schema validation, freshness checks, and pipeline gate assertions
* [Orchestration Comparison](orchestration-comparison.md) - Airflow vs Argo Workflows vs Tekton vs Kueue — pick by what your tasks look like and where they run
* [CQRS and Caching](cqrs-and-caching.md) - CQRS with delayed reads for cache-first data retrieval, separating write models from read models
* [Drizzle ORM Patterns](drizzle-orm-patterns.md) - Drizzle ORM configuration, schema definition, and migrations for PostgreSQL with TypeScript
