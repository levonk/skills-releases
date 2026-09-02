<!-- Managed by skills-src build pipeline. Do not edit; changes will be overwritten. -->
<!-- Generated from SKILL.md frontmatter + body by `just catalog` -->

# Skills: the script is materialized into scripts/cli-tool-discovery.sh at build time

> Category: **software-dev** · Status:  · Version: 1.0.0

Create, update, and convert data pipelines across Apache Airflow (DAG authoring), Apache Spark (job development), and dbt (model development). Three modes — create a new pipeline from scratch, audit and improve an existing pipeline, or convert between pipeline types (e.g., cron job to Airflow DAG). Use when users want to build an ETL/ELT pipeline, author an Airflow DAG, write a Spark job, create dbt models, set up data ingestion, build a data transformation pipeline, add idempotency or retries to an existing pipeline, migrate a cron job to Airflow, convert a Spark job to dbt, or audit a data pipeline for reliability and data quality. Make sure to use this skill whenever the user mentions data pipelines, ETL, ELT, DAGs, Airflow, Spark, dbt, data ingestion, data transformation, batch processing, pipeline idempotency, pipeline retries, data quality testing, or wants to orchestrate data workflows, even if they don't explicitly ask for a "data pipeline creator." Do NOT trigger on general Python coding questions, web API development, database schema migrations (use a migration tool), real-time streaming (Kafka/Flink unless it's part of a batch pipeline), or general DevOps/Kubernetes deployment — this skill is for data pipeline authoring and orchestration, not general infrastructure.

## Metadata

| Field | Value |
|-------|-------|
| Name | `data-pipeline-upsert` |
| Category | `software-dev` |
| Version | `1.0.0` |
| Status | `` |
| Owner |  |

## Related Skills
- **base-ai-guidance** (template, base-framework) — Shared framework for creating all AI guidance types
- **base-frontmatter** (template, structure-standard) — Standard frontmatter template for AI guidance files
- **ai-upsert** (skill, sibling) — Same upsert family — handles AI skill creation and updates
- **container-image-build** (skill, complement) — Build container images for data pipeline services
- **cicd-upsert** (skill, complement) — CI/CD pipelines for data pipeline deployment
- **java-app-upsert** (skill, complement) — Create and update Java applications that may serve as data pipeline components

---

- **Full skill**: [`skills/software-dev/data-pipeline-upsert/SKILL.md`](skills/software-dev/data-pipeline-upsert/SKILL.md)
- **Install**: `pnpm dlx skills add levonk/skills-releases`
- **Generated**: 2026-09-02T09:52:56Z
