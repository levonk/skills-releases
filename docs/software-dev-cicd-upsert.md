<!-- Managed by skills-src build pipeline. Do not edit; changes will be overwritten. -->
<!-- Generated from SKILL.md frontmatter + body by `just catalog` -->

# Skills: the script is materialized into scripts/cli-tool-discovery.sh at build time

> Category: **software-dev** · Status:  · Version: 1.0.0

Create, audit, and improve CI/CD pipelines with incremental builds, pre-built CI images, security scans, guardrails, versioning, provenance, and deployment validation. CI-provider-agnostic (GitHub Actions default, also GitLab CI, Jenkins, CircleCI, Buildkite, Azure Pipelines). Use when setting up CI/CD from scratch, optimizing slow CI, adding security gates, implementing filtered/incremental builds, publishing pre-built CI container images, adding provenance/SBOM to builds, improving git tagging/versioning hygiene, or aligning devbox/Justfile/CI/deployment tooling versions. Do NOT trigger on general DevOps questions, Kubernetes manifest authoring, Dockerfile writing (use container-image-build), or Ansible playbook writing (use container-service-deploy) — this skill is for the CI/CD pipeline itself, not the things the pipeline deploys.

## Metadata

| Field | Value |
|-------|-------|
| Name | `cicd-upsert` |
| Category | `software-dev` |
| Version | `1.0.0` |
| Status | `` |
| Owner |  |

## Overview

### What This Skill Does

1. **Creates CI/CD pipelines from scratch** — detects the project's build
   system, test framework, and deployment target, then generates a pipeline
   with incremental builds, security scans, and guardrails.
2. **Audits and improves existing pipelines** — identifies slow steps, missing
   security, missing provenance, tooling misalignment, and proposes fixes.
3. **Sets up pre-built CI images** — publishes a container image with all build
   tools pre-installed to a registry (GHCR, etc.), rebuilds only when the
   environment definition changes.
4. **Aligns tooling versions** — ensures devbox.json, Justfile, CI, Dockerfile,
   and deployment tools all reference the same versions from a single source.

### Core Principles

- **Incremental builds first** — detect what changed, build only that. Profile
  filtering, not workflow-level path triggers (avoids required-checks deadlock).
- **Pre-built CI images** — bake the toolchain into a container once, reuse
  everywhere. Rebuild only when the environment definition changes.
- **No secrets in images** — multi-stage builds, BuildKit secrets, `.dockerignore`
  as a mandatory security gate (not an optimization). Scan images before publishing.
- **Security as gates, not afterthoughts** — secret scanning early, SAST,
  dependency scanning, container scanning. Gate on critical/high, report on
  medium/low.
- **Provenance/lineage** — sign artifacts, generate SBOMs, embed git SHA/tag/
  branch in deployed packages. Verify signatures before deployment.
- **DRY CI files** — reusable workflows, composite actions, job matrices. No
  copy-pasted workflow definitions.
- **Tooling alignment** — single source of truth for tool versions (devbox.json
  or equivalent). CI, Dockerfile, Justfile all read from it. Task runner recipes
  must work with or without `devbox run` wrappers (two-layer unwrapping).
- **CI hygiene** — `concurrency: cancel-in-progress` to cancel redundant runs,
  `timeout-minutes` on every job, least-privilege `permissions:` scoping,
  `shell: bash -l {0}` when running inside containers (GitHub Actions uses
  `--noprofile --norc` by default, silently ignoring PATH setup).
- **Local testability** — pipelines must be testable locally with `act` before
  pushing. Handle secret format differences (act uses single-line base64, real
  CI uses multi-line PEM). Handle container file ownership mismatches.
- **Interactive vs automatic** — optimizations and quality improvements are
  automatic. Build process changes that affect the project's existing workflow
  are proposed interactively with user confirmation.

## References

- `references/incremental-builds.md` — Path filters, git-diff patterns, dependency-aware filtering, required-checks deadlock avoidance
- `references/prebuilt-images.md` — When to use pre-built CI images, rebuild triggers, GHCR publishing, caching strategies
- `references/container-hygiene.md` — Multi-stage builds, BuildKit secrets, .dockerignore, pre-publish scanning
- `references/security-scans.md` — Scanning pipeline order, tool selection, SARIF integration, gating configuration
- `references/guardrails-gates.md` — Branch protection, required checks, merge queues, blocking vs quality gates
- `references/versioning-tagging.md` — Semantic versioning, conventional commits, automated changelogs, git tag hygiene
- `references/provenance-lineage.md` — SLSA provenance, SBOM generation, cosign signing, OCI labels, verification
- `references/deployment-validation.md` — Smoke tests, health checks, canary/blue-green, when each is appropriate vs overkill
- `references/testing-strategies.md` — Test pyramid, parallel execution, test splitting, flaky management, coverage gates
- `references/modular-parallel.md` — Reusable workflows, composite actions, job matrices, DRY CI file organization
- `references/tooling-alignment.md` — Single source of truth for tool versions, devbox/Justfile/CI/Dockerfile alignment
- `references/interactive-vs-automatic.md` — Decision framework for automatic vs interactive CI changes
- `references/audit-checklist.md` — Full audit checklist for existing CI/CD pipelines

## Related Skills
- **base-ai-guidance** (template, base-framework) — Shared framework for creating all AI guidance types
- **container-image-build** (skill, complement) — Builds container images for services — cicd-upsert builds the CI environment image and the pipeline that uses it
- **container-service-deploy** (skill, complement) — Deploys services — cicd-upsert adds deployment validation steps to the pipeline
- **nixify** (skill, complement) — Adds Nix flake support — cicd-upsert ensures CI uses the same tool versions as devbox/Nix
- **project-detection** (skill, dependency) — Detects project type, build systems, and CI/CD platforms — cicd-upsert uses detection results to shape the pipeline

---

- **Full skill**: [`skills/software-dev/cicd-upsert/SKILL.md`](skills/software-dev/cicd-upsert/SKILL.md)
- **Install**: `pnpm dlx skills add levonk/skills-releases`
- **Generated**: 2026-07-20T22:00:35Z
