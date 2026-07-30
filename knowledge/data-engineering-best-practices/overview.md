---
type: Synthesis
title: Data Engineering Best Practices Overview
description: Synthesis of data engineering practices spanning ETL/ELT, Airflow orchestration, layered container images, Spark, dbt, warehouse design, streaming, data quality, orchestration tooling, CQRS, and ORM patterns.
tags: [data-engineering, airflow, spark, dbt, data-warehouse, streaming, data-quality, orchestration, cqrs, drizzle, overview, synthesis]
date:
  created: "2026-07-18"
  knowledge-basis: "2026-07-17"
  last-used: "2026-07-17"

sources:
  - id: infrahub-airflow-service-readme
    resource: "https://github.com/levonk/infrahub/blob/main/shared/active/03-container/services/airflow/README.md"
    title: "infrahub Airflow service README"
  - id: job-aide-airflow-layered-images-spec
    resource: "https://github.com/lrepo52/job-aide/blob/main/specs/005-airflow-layered-images-spec/spec.md"
    title: "job-aide Airflow layered images spec"
  - id: 2ndbrain-airflow-vs-argo-workflows-vs-tekton-pipelines
    resource: "https://github.com/levonk/2ndbrain"
    title: "2ndbrain: Airflow vs Argo Workflows vs Tekton Pipelines"
  - id: 2ndbrain-kueue-vs-airflow
    resource: "https://github.com/levonk/2ndbrain"
    title: "2ndbrain: Kueue vs Airflow"
  - id: job-aide-adr-20251106011-postgresql-as-primary-database
    resource: "https://github.com/lrepo52/job-aide/blob/main/internal-docs/adr/adr-20251106011-postgresql-for-database.md"
    title: "job-aide ADR-20251106011: PostgreSQL as Primary Database"
  - id: job-aide-drizzle-orm-config
    resource: "https://github.com/lrepo52/job-aide/blob/main/apps/active/politics/left-parody/web/typescript/drizzle.config.ts"
    title: "job-aide Drizzle ORM config"
---

---
description: STE100-inspired Simplified Technical English guidelines for technical prose output — active voice, short sentences, one-word-one-meaning, imperative for instructions
---

### Simplified Technical English (STE100-Inspired)

This artifact produces technical English (instructions, procedures, descriptions,
reference documentation). Apply these STE100-inspired guidelines to all technical
prose output so the result is unambiguous, translatable, and easy to read for
non-native speakers and for AI agents that must execute the steps precisely.

These are **STE-inspired guidelines**, not the full ASD-STE100 vocabulary
restriction. Domain terms (Dockerfile, pnpm, devbox, Nx, etc.) are permitted
when they are the correct technical term — STE100's 1000-word approved
vocabulary is too narrow for this domain. The goal is the *clarity discipline*
of STE100, not its word list.

For the full writing rules, before/after examples, and the approved-words
reference, see the
[Simplified Technical English](https://github.com/levonk/skills-releases/blob/main/knowledge/simplified-technical-english/simplified-technical-english.md)
and
[Detailed Guide](https://github.com/levonk/skills-releases/blob/main/knowledge/simplified-technical-english/detailed-guide.md)
concept pages in the `simplified-technical-english` knowledge bundle. The
bundle is the canonical, publicly-reachable home for these guidelines; this
include is the build-time gist that gets inlined into skills and other
bundles.

#### Core Principles

1. **One word, one meaning.** Pick one term for each concept and use it
   everywhere. Do not alternate between "image" and "container image" and
   "docker image" for the same thing. Pick one, define it once, reuse it.

2. **Short sentences.** Keep procedural sentences under 20 words. Keep
   descriptive sentences under 25 words. Split long sentences into two.

3. **Active voice.** Write "The build copies the file" not "The file is copied
   by the build." The actor does the action. Passive voice hides who does what
   and is the single largest source of ambiguity in technical prose.

4. **Imperative mood for instructions.** Write "Run the tests" not "You should
   run the tests" or "The tests should be run." Instructions tell the reader
   (or agent) what to do, directly.

5. **One topic per sentence.** One idea per sentence. Do not chain unrelated
   clauses with "and" or "while." If a sentence has two ideas, split it.

6. **Consistent verb forms.** Use the same verb for the same action across the
   document. If you "run" a script in section 1, do not "execute" it in
   section 2. Pick one verb per action and keep it.

7. **Approved modifiers only.** Avoid decorative adjectives and adverbs
   ("very", "extremely", "simply", "just"). Keep modifiers that carry
   information ("non-root", "read-only", "idempotent"). Drop modifiers that
   carry only emphasis.

8. **Define every acronym on first use.** Write "Continuous Integration (CI)"
   on first use, then "CI" thereafter. Never assume the reader knows the
   acronym.

#### What Counts as Technical English

Apply these guidelines to:

- Procedural instructions ("Run `just build`", "Add the user to the group")
- Descriptions of failure modes, symptoms, and practices
- Reference documentation and concept pages
- Checklists and review guidance
- Synthesis and overview prose in knowledge bundles

Do **not** apply these guidelines to:

- Code, commands, and file paths (those have their own syntax)
- Frontmatter and structured data (YAML, JSON)
- Diagrams and their source syntax (Mermaid, PlantUML)
- Business communication, marketing copy, or creative content
- Log entries and change logs (those are append-only records)

#### Quick Self-Check

Before finishing a piece of technical prose, run this checklist:

- [ ] Is every sentence under 25 words? (Procedural: under 20.)
- [ ] Is every sentence active voice? (Or is the passive voice intentional and
      necessary?)
- [ ] Are instructions in imperative mood?
- [ ] Does each technical term have one and only one form in this document?
- [ ] Is every acronym defined on first use?
- [ ] Are decorative modifiers removed?
- [ ] Does each sentence carry one topic?

If any answer is "no," revise before publishing.


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

- [container-best-practices](https://github.com/levonk/skills-releases/blob/main/knowledge/container-best-practices/overview.md) —
  container authoring, layered images, and runtime hardening used by Airflow
  and Spark deployments.
- [java-best-practices](https://github.com/levonk/skills-releases/blob/main/knowledge/java-best-practices/overview.md) — Spark and other
  JVM data processing tools build on Java packaging and JVM tuning practices.
- [typescript-monorepo-best-practices](https://github.com/levonk/skills-releases/blob/main/knowledge/typescript-monorepo-best-practices/overview.md)
  — TypeScript data access layers (Drizzle ORM, CQRS) and monorepo conventions
  used by data products.
- [devsecops-codeguard](https://github.com/levonk/skills-releases/blob/main/knowledge/devsecops-codeguard/overview.md) — pipeline
  security, credential handling, and container hardening for data platforms.

---

## Content Ordering

This artifact is optimized for machine consumption. Generic framework content
(shared includes, knowledge bundles) appears before the skill-specific body.
This ordering maximizes cross-skill prefix caching: skills that share the same
includes produce identical byte prefixes, so an LLM context cache warmed by one
skill serves all skills that share the same preamble.

This is sub-optimal for human reading — the skill-specific content starts deep
in the file, after the generic preamble. Human readers can jump to the
skill-specific body by searching for the first `# ` heading that follows the
generic sections. Each section is self-contained and documented with its own
heading hierarchy.

