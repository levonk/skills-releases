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

## Related Skills
- **base-ai-guidance** (template, base-framework) — Shared framework for creating all AI guidance types
- **container-image-build** (skill, complement) — Builds container images for services — cicd-upsert builds the CI environment image and the pipeline that uses it
- **container-service-deploy** (skill, complement) — Deploys services — cicd-upsert adds deployment validation steps to the pipeline
- **nixify** (skill, complement) — Adds Nix flake support — cicd-upsert ensures CI uses the same tool versions as devbox/Nix
- **project-detection** (skill, dependency) — Detects project type, build systems, and CI/CD platforms — cicd-upsert uses detection results to shape the pipeline

---

- **Full skill**: [`skills/software-dev/cicd-upsert/SKILL.md`](skills/software-dev/cicd-upsert/SKILL.md)
- **Install**: `pnpm dlx skills add levonk/skills-releases`
- **Generated**: 2026-08-21T01:09:20Z
