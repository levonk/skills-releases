<!-- Managed by skills-src build pipeline. Do not edit; changes will be overwritten. -->
<!-- Generated from SKILL.md frontmatter + body by `just catalog` -->

# Skills: the script is materialized into scripts/cli-tool-discovery.sh at build time

> Category: **software-dev** · Status:  · Version: 1.0.0

Create new Java applications, update and improve existing Java projects, and convert between Maven and Gradle build systems. Covers project scaffolding, build configuration (pom.xml, build.gradle.kts), dependency management with BOMs and version catalogs, testing setup (JUnit 5, Mockito, Testcontainers, AssertJ), containerization (multi-stage Dockerfiles, JRE vs JDK, JVM container flags, Spring Boot layered jars), and JVM tuning (heap sizing, GC selection, JFR profiling, class data sharing). Use when users want to scaffold a new Java application from scratch, audit or modernize an existing Java project's build or test setup, convert a Maven project to Gradle or vice versa, configure Spring Boot for container deployment, set up Java testing infrastructure, tune JVM garbage collection or heap settings, or package a Java app as a container image. Trigger on mentions of pom.xml, build.gradle, build.gradle.kts, settings.gradle, Gradle wrapper, Maven shade/assembly/surefire/failsafe plugins, Spring Boot layered jars, JRE vs JDK in containers, MaxRAMPercentage, UseContainerSupport, G1GC, ZGC, JFR, JMC, class data sharing, or version catalogs. Do NOT trigger on general Java bug fixes, Java language syntax questions, Android application development (uses Gradle but different plugin ecosystem), Kotlin-only projects (use a Kotlin skill), or pure Scala projects — this skill is for Java application lifecycle, build system, and runtime configuration, not general Java coding.

## Metadata

| Field | Value |
|-------|-------|
| Name | `java-app-upsert` |
| Category | `software-dev` |
| Version | `1.0.0` |
| Status | `` |
| Owner |  |

## References

- `references/maven-project-setup.md` — pom.xml structure, dependency
  management, profiles, plugins (surefire, failsafe, shade, assembly), BOMs,
  reproducible builds
- `references/gradle-project-setup.md` — build.gradle.kts, Gradle wrapper,
  version catalogs, configuration cache, multi-project builds, Kotlin DSL
- `references/java-testing.md` — JUnit 5, Mockito, Testcontainers, AssertJ,
  surefire/failsafe split, integration tests
- `references/java-containerization.md` — JRE vs JDK in containers,
  multi-stage builds, Alpine openjdk17 vs Debian JDK, JVM container flags,
  Spring Boot layered jars
- `references/jvm-tuning.md` — heap sizing, GC selection (G1/ZGC/Parallel),
  container-aware flags, JFR/JMC profiling, class data sharing

## Related Skills
- **base-ai-guidance** (template, base-framework) — Shared framework for creating all AI guidance types
- **base-frontmatter** (template, structure-standard) — Standard frontmatter template for AI guidance files
- **ai-skill-upsert** (skill, sibling) — Same upsert family — handles AI skill creation and updates
- **container-image-build** (skill, complement) — Build container images for Java applications
- **cicd-upsert** (skill, complement) — CI/CD pipelines for Java application deployment
- **project-adopter** (skill, complement) — Adopt existing Java projects to standard tooling
- **data-pipeline-upsert** (skill, complement) — Create and update data pipelines that may include Java/Spark components

---

- **Full skill**: [`skills/software-dev/java-app-upsert/SKILL.md`](skills/software-dev/java-app-upsert/SKILL.md)
- **Install**: `pnpm dlx skills add levonk/skills-releases`
- **Generated**: 2026-07-20T22:00:35Z
