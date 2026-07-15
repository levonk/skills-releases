<!-- Managed by skills-src build pipeline. Do not edit; changes will be overwritten. -->
<!-- Generated from SKILL.md frontmatter + body by `just catalog` -->

# Skills: the script is materialized into scripts/cli-tool-discovery.sh at build time

> Category: **software-dev** · Status:  · Version: 1.0.0

Build container images for mixed-architecture fleets (x86_64 + aarch64). Three branches: wrap pre-built upstream images, Dockerfile + docker buildx, or Nix flake. Use when building, wrapping, or sourcing container images for any service — especially when the deployment target spans multiple CPU architectures. Enforces "check pre-built first" and "multi-arch mandatory" principles. Do NOT trigger on Kubernetes manifest authoring, docker-compose service orchestration, or Ansible playbook writing — those are deployment concerns, not image build concerns.

## Metadata

| Field | Value |
|-------|-------|
| Name | `container-image-build` |
| Category | `software-dev` |
| Version | `1.0.0` |
| Status | `` |
| Owner |  |

## References

- `references/wrap-prebuilt.md` — Branch A: wrapping pre-built upstream images
- `references/dockerfile-buildx.md` — Branch B: multi-stage Dockerfile + buildx
- `references/nix-flake-build.md` — Branch C: Nix flake container builds
- `references/multi-arch.md` — Multi-arch manifest management, tagging, verification

## Related Skills
- **base-ai-guidance** (template, base-framework) — Shared framework for creating all AI guidance types
- **container-service-deploy** (skill, complement) — Deploys the images this skill builds — compose for dev, Ansible for prod
- **nixify** (skill, complement) — Nix flake authoring patterns for Branch C (Nix flake builds)

---

- **Full skill**: [`skills/software-dev/container-image-build/SKILL.md`](skills/software-dev/container-image-build/SKILL.md)
- **Install**: `npx skills add levonk/skills-releases`
- **Generated**: 2026-07-15T22:13:34Z
