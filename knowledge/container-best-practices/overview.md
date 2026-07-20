---
type: Synthesis
title: Container Best Practices Overview
description: Synthesis of container best practices extracted from real failure modes — base image selection, layer caching, build context, multi-stage builds, process supervision, supply-chain pinning, linting, compose dependency ordering, runtime hardening, registry cache strategy, build-time secret hygiene, Node.js production hardening, and Dockerfile package cleanup.
tags: [docker, containers, dockerfile, docker-compose, buildkit, security, nodejs, best-practices, overview, synthesis]
timestamp: 2026-07-17T18:30:00Z
---

# Container Best Practices Overview

This bundle documents practices for authoring and running containers that are
small, fast to build, reproducible, secure, and operationally sound. Each
concept was extracted from a specific failure mode — a Dockerfile that was
slow, bloated, broken, or unreproducible; a compose stack that raced on
startup; a container that leaked privileges or secrets — and the practice
that prevents it.

## The Container Lifecycle

```
base-image → layer-order → context-hygiene → multi-stage → process-model → pin-digest → lint
                                                                                          ↓
                            secrets → registry-cache → compose-ordering → runtime-hardening
```

Each phase has practices that prevent specific failure modes:

| Phase | Practice | Prevents |
|-------|----------|----------|
| Base image | [Base Image Selection](base-image-selection.md) | musl libc breakage, 15× build-time penalty, missing native deps |
| Layering | [Layer Cache Order](layer-cache-order.md) | Cold rebuild on every code edit; dependency install re-runs needlessly |
| Context | [Build Context Hygiene](build-context-hygiene.md) | Shipping node_modules/.git/logs to daemon; mile-long COPY commands |
| Build | [Multi-Stage Builds](multi-stage-builds.md) | 272 MB images for a static binary; toolchain in runtime image |
| Process | [Single-Container Multi-Process](single-container-multi-process.md) | Over-engineering two containers for a small app that needs Nginx+backend |
| Supply chain | [Pin Image Digests](pin-image-digests.md) | Reproducible builds breaking when tags move; internal image mistakes |
| Quality | [Dockerfile Linting](dockerfile-linting.md) | Manual review missing the patterns above; CI not enforcing them |
| Secrets | [BuildKit Secret Mounts](buildkit-secrets.md) | Credentials baked into layers, leaked via `docker history`, exposed in CI logs |
| Cache | [Registry Cache Strategy](registry-cache-strategy.md) | CI cold-rebuilding every layer; registry bandwidth costs; Docker Hub rate limits |
| Compose | [Compose Service Dependency Ordering](compose-service-dependency-ordering.md) | App containers crashing on startup because DB isn't accepting connections yet |
| Runtime | [Container Runtime Hardening](container-runtime-hardening.md) | Container escape, privilege escalation, resource exhaustion attacks, docker.sock exposure, unscanned images |
| Node.js | [Node.js in Containers](nodejs-in-containers.md) | Dev deps in prod, root-owned processes, zombie processes from missing init, SIGTERM not reaching Node.js |
| Dockerfile | [Dockerfile Best Practices](dockerfile-best-practices.md) | Bloated layers, package cache retention, missing healthchecks, root-by-default images |
| Build strategy | [Container Runtime Essentials](container-runtime-essentials.md) | Rebuilding from source when a pre-built image exists; single-arch :latest for mixed fleets; QEMU segfaults on Rust/C++ builds; missing --push for multi-platform |

## Scope

This bundle covers **container authoring, build, runtime, and language-specific
hardening** — Dockerfiles, build context, multi-stage patterns, the runtime
process model, build-time secret hygiene, registry cache strategy, compose
dependency ordering, runtime hardening (including docker.sock and TCP daemon
prohibitions, image scanning), Node.js production container hardening,
Dockerfile package cleanup patterns, and the build-strategy decision tree
(pre-built vs Dockerfile vs Nix, multi-arch mandates, QEMU avoidance, sidecar
usage, entrypoint/healthcheck file naming). It does **not** cover:

- Container orchestration (Kubernetes, Nomad) — separate bundle.
- Container runtime daemon configuration (Docker daemon, containerd, podman
  config files) — future concept pages can be ingested here.
- Container registry administration (push policies, garbage collection,
  signing) — future concept pages can be ingested here.
- Project-specific security ADRs — see job-aide ADR-20251218001 and the
  `secure-docker` workflow; this bundle's [Container Runtime Hardening](container-runtime-hardening.md)
  provides the generalizable knowledge behind those standards.

## Relationship to Existing Project Standards

The job-aide `docker-standards.md` workflow prescribes project-specific
container standards (file structure, base image preferences for infra
services, OrbStack/podman tooling). This bundle provides the **generalizable
knowledge** behind those standards — the "why" that explains when the
project standard applies and when it doesn't.

The most important interaction: `docker-standards.md` says "prefer alpine if
possible" for infrastructure services. [Base Image Selection](base-image-selection.md)
explains why this is correct for infra (you control the toolchain) but wrong
for application Dockerfiles (musl breaks upstream glibc wheels). The two are
not contradictory — they are context-dependent.

## Sources

The initial 7 concepts were extracted from the DevOps Toolbox video
"Give me 15 minutes and I'll Fix Your Dockerfiles Forever" (2026-07-17), which
distilled five corrections plus two bonus practices from years of container
building experience.

The 2ndbrain note capturing the full video transcript with timecoded
backlinks lives at:
`2ndbrain/Default/Literature/Internet/Video/Give me 15 minutes and I'll Fix Your Dockerfiles Forever.md`

The subsequent 4 concepts (compose dependency ordering, runtime hardening,
registry cache strategy, buildkit secrets) were researched from Docker
documentation, the CIS Docker Benchmark, NIST SP 800-190, and practitioner
blog posts — see each concept's `# Citations` section for the specific
sources.

The 2 language-specific concepts (Node.js in Containers, Dockerfile Best
Practices) were migrated from the devsecops-codeguard bundle, where they
were originally sourced from job-aide `.devin/rules/codeguard-0-devops-ci-cd-containers.md`
and `.devin/rules/dockerfile-best-practices.md`. The runtime hardening concept
was extended with docker.sock, TCP daemon, image scanning, and implementation
checklist content from the same codeguard rules.

## Compounding

New lessons from future container work — videos, articles, real production
failures, or new tooling — should be filed as new concept pages. The trigger
for adding a concept is: a build failure, a production incident, or a
debugging session that revealed a practice the bundle doesn't yet cover.
Append to `log.md` when adding.

Future concept candidates (not yet in the bundle):

- `container-networking-patterns.md` — bridge vs. host vs. macvlan; internal
  networks; DNS-based service discovery
- `container-logging-strategy.md` — JSON-file vs. journald vs. fluentd
  drivers; log rotation; structured logging from containers
- `container-resource-governance.md` — cgroups v2; CPU/memory/IO limits vs.
  reservations; OOM-kill behavior
- `image-vulnerability-scanning.md` — Trivy, Grype, Snyk; when to scan; how
  to handle CVEs in base images you can't upgrade
- `container-update-strategy.md` — Watchtower, Renovate, manual rebuilds;
  balancing freshness vs. stability

## Related Knowledge Bundles

- [devsecops-codeguard](https://github.com/levonk/skills-releases/blob/main/knowledge/devsecops-codeguard/overview.md) — code-level security
  rules (credential detection, crypto governance, certificate validation, SSH
  hardening) that complement this bundle's runtime and build-time guidance.
  Container-specific concepts formerly in devsecops-codeguard have been
  consolidated here.
- [java-best-practices](https://github.com/levonk/skills-releases/blob/main/knowledge/java-best-practices/overview.md) — Java/JVM
  container packaging, JRE vs JDK, and Alpine compatibility for Java
  applications.
- [data-engineering-best-practices](https://github.com/levonk/skills-releases/blob/main/knowledge/data-engineering-best-practices/overview.md)
  — Airflow layered images and Kubernetes deployment patterns that build on
  the container practices here.
- [typescript-monorepo-best-practices](https://github.com/levonk/skills-releases/blob/main/knowledge/typescript-monorepo-best-practices/overview.md)
  — Node.js containerization and package conventions that intersect with
  Dockerfile best practices.

## Citations

[1] [Give me 15 minutes and I'll Fix Your Dockerfiles Forever](https://www.youtube.com/watch?v=aZ_y2M2OuEA) — DevOps Toolbox, 2026-07-17
[2] [docker-standards.md workflow](https://github.com/levonk/skills-releases/blob/main/workflows/software-dev/devops/containers/docker-standards.md) — existing project standard
[3] [container-image-build skill](https://github.com/levonk/skills-releases/blob/main/skills/software-dev/container-image-build/SKILL.md) — image build automation
[4] [container-service-deploy skill](https://github.com/levonk/skills-releases/blob/main/skills/software-dev/container-service-deploy/SKILL.md) — compose/Ansible deployment
