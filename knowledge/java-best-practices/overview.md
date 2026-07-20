---
type: Synthesis
title: Java Best Practices Overview
description: Synthesis of Java/JVM best practices covering JVM tuning, container packaging, build tooling, testing, security, Alpine compatibility, sidecar architecture, and library pitfalls.
tags: [java, jvm, best-practices, overview, synthesis, containers, maven, gradle]
timestamp: 2026-07-17T00:00:00Z
---

# Java Best Practices Overview

This bundle documents practices for building, running, and debugging Java/JVM
applications that are fast, reproducible, secure, and operationally sound. Each
concept was extracted from a specific finding — a container sidecar that needed
JRE-only runtime, a build tool that needed cache volumes, a library pitfall
that caused silent bugs — and the practice that addresses it.

## The Java Application Lifecycle

```
jvm-tuning → container-packaging → build-tool → testing → security
     ↑              ↑                  ↑          ↑         ↑
     └── alpine-compatibility ── sidecar-pattern ── library-pitfalls
```

Each phase has practices that prevent specific failure modes:

| Phase | Practice | Prevents |
|-------|----------|----------|
| Runtime | [JVM Tuning](jvm-tuning.md) | OOM kills in containers, wrong GC for workload, ignored cgroup limits |
| Packaging | [Java in Containers](java-in-containers.md) | Shipping full JDK in runtime image, bloated images, missing JRE |
| Build (Maven) | [Maven Best Practices](maven-best-practices.md) | Non-reproducible builds, dependency conflicts, cold cache rebuilds |
| Build (Gradle) | [Gradle Best Practices](gradle-best-practices.md) | Unpinned Gradle versions, no configuration cache, missing wrapper |
| Testing | [Java Testing](java-testing.md) | Unit/integration test mixing, no containerized integration tests |
| Security | [Java Security](java-security.md) | Known CVEs in dependencies, injected vulnerabilities, deprecated security APIs |
| Build speed | [Java Build Optimization](java-build-optimization.md) | Slow incremental builds, no parallelism, daemon misconfiguration |
| Compatibility | [Java Alpine Compatibility](java-alpine-compatibility.md) | JNI crashes on musl, missing native libs, iconv failures |
| Architecture | [Java Sidecar Pattern](java-sidecar-pattern.md) | Redundant JDK downloads, no shared cache, slow dev container startup |
| Libraries | [BigDecimal Pitfalls](bigdecimal-pitfalls.md) | Silent inequality bugs from equals() comparing scale not value |

## Scope

This bundle covers **Java/JVM application building, packaging, and runtime** —
JVM tuning, container packaging, Maven and Gradle build tooling, testing
strategy, security scanning, build optimization, Alpine compatibility, the
sidecar development pattern, and library-level pitfalls. It does **not** cover:

- Java framework-specific patterns (Spring Boot, Quarkus, Micronaut) — separate
  bundles can be ingested here.
- Kotlin-specific practices — see the `configure-kotlin.sh` script in the
  project-adopter skill for Kotlin project setup.
- Java application server administration (Tomcat, Jetty, WildFly tuning) —
  future concept pages can be ingested here.
- JVM internals (classloading, bytecode manipulation, JIT profiling) — future
  concept pages can be ingested here.

## Relationship to Existing Project Assets

The skills-src repository contains several assets that interact with Java
projects but lacked a dedicated knowledge bundle — this bundle fills that gap:

- **project-adopter skill**: `scripts/configure-java.sh` handles Maven `pom.xml`
  and Gradle `build.gradle` configuration, Checkstyle, and testing setup. This
  bundle provides the **generalizable knowledge** behind what that script
  configures.
- **project-detection skill**: Detects Maven and Gradle build systems (see
  `references/detection-capabilities.md`). This bundle explains the practices
  that should follow detection.
- **infrahub sidecars**: The `java-sidecar` and `gradle-sidecar` containers
  (see [Java Sidecar Pattern](java-sidecar-pattern.md)) are real
  implementations of the container packaging and caching practices documented
  here.

## Sources

The concepts in this bundle were sourced from real findings across four
repositories:

1. **infrahub** — Java and Gradle sidecar Dockerfiles, health check scripts,
   and cache volume definitions in `docker-compose.*.yml`.
2. **job-aide** — `docker-compose.include.yml` referencing `gradle-cache` and
   `java-m2-cache` volumes; planned Java CLI boilerplate (ADR-20251210001).
3. **2ndbrain** — A single article on BigDecimal comparison pitfalls captured
   from Igor's Techno Club (2024-06-19).
4. **skills-src** — `configure-java.sh` and `configure-kotlin.sh` scripts in
   the project-adopter skill; Maven/Gradle detection in project-detection.

See each concept's `# Citations` section for the specific sources.

## Compounding

New lessons from future Java work — production incidents, library upgrades,
new JVM features, framework migrations — should be filed as new concept pages.
The trigger for adding a concept is: a build failure, a production incident, a
debugging session, or a library pitfall that revealed a practice the bundle
doesn't yet cover. Append to `log.md` when adding.

Future concept candidates (not yet in the bundle):

- `java-logging.md` — structured logging (SLF4J/Logback), log levels, JSON
  output for container environments
- `java-concurrency.md` — virtual threads (JEP 444), structured concurrency,
  executor service patterns
- `java-modules.md` — JPMS module system, `module-info.java`, automatic modules
- `spring-boot-best-practices.md` — auto-configuration, profiles, actuator
  health checks, layered jars
- `java-records-sealed.md` — records (JEP 395), sealed classes (JEP 409),
  pattern matching

## Related Knowledge Bundles

- [container-best-practices](https://github.com/levonk/skills-releases/blob/main/knowledge/container-best-practices/overview.md) —
  multi-stage builds, base image selection, and runtime hardening for Java
  container packaging.
- [data-engineering-best-practices](https://github.com/levonk/skills-releases/blob/main/knowledge/data-engineering-best-practices/overview.md)
  — data pipeline tooling that often runs on the JVM (Spark) or uses Java-based
  orchestration patterns.
- [devsecops-codeguard](https://github.com/levonk/skills-releases/blob/main/knowledge/devsecops-codeguard/overview.md) — dependency
  scanning, SAST, and secure coding practices that apply to Java applications.

## Citations

[1] [infrahub java-sidecar Dockerfile](https://github.com/levonk/infrahub/blob/main/shared/active/03-container/services/artifact/java-sidecar/Dockerfile.java-sidecar) — real OpenJDK 17 Alpine sidecar
[2] [infrahub gradle-sidecar Dockerfile](https://github.com/levonk/infrahub/blob/main/shared/active/03-container/services/artifact/gradle-sidecar/Dockerfile.gradle-sidecar) — real multi-stage Gradle build
[3] [project-adopter skill configure-java.sh](https://github.com/levonk/skills-releases/blob/main/skills/software-dev/project-adopter/scripts/configure-java.sh) — Java project configuration automation
[4] [project-detection skill](https://github.com/levonk/skills-releases/blob/main/skills/software-dev/project-detection/references/detection-capabilities.md) — Maven/Gradle build system detection
[5] [2ndbrain BigDecimal article](https://igorstechnoclub.com/java-bigdecimal/) — Igor's Techno Club, 2024-06-19
