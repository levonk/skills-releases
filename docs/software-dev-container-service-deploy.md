<!-- Managed by skills-src build pipeline. Do not edit; changes will be overwritten. -->
<!-- Generated from SKILL.md frontmatter + body by `just catalog` -->

# Skills: the script is materialized into scripts/cli-tool-discovery.sh at build time

> Category: **software-dev** · Status:  · Version: 1.0.0

Deploy multi-container services using docker-compose (local/dev) or Ansible docker_container (production). Use when composing services, writing docker-compose.yml, creating Ansible roles for container deployment, or deciding between compose and Ansible for a deployment target. Covers service structure, networking, volumes, health checks, env var naming, and security hardening. Do NOT trigger on image building (use container-image-build), Kubernetes manifest authoring, or bare-metal service management.

## Metadata

| Field | Value |
|-------|-------|
| Name | `container-service-deploy` |
| Category | `software-dev` |
| Version | `1.0.0` |
| Status | `` |
| Owner |  |

## References

- `references/docker-compose.md` — Branch A: docker-compose for local/dev
- `references/ansible-deploy.md` — Branch B: Ansible docker_container for prod

## Related Skills
- **base-ai-guidance** (template, base-framework) — Shared framework for creating all AI guidance types
- **container-image-build** (skill, complement) — Builds the images this skill deploys

---

- **Full skill**: [`skills/software-dev/container-service-deploy/SKILL.md`](skills/software-dev/container-service-deploy/SKILL.md)
- **Install**: `npx skills add levonk/skills-releases`
- **Generated**: 2026-07-16T08:39:39Z
