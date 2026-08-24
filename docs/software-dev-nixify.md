<!-- Managed by skills-src build pipeline. Do not edit; changes will be overwritten. -->
<!-- Generated from SKILL.md frontmatter + body by `just catalog` -->

# Skills: the script is materialized into scripts/cli-tool-discovery.sh at build time

> Category: **software-dev** · Status:  · Version: 2.21.0

Add Nix flake support to a project so it can be installed via nix run github:... or nix profile add github:.... Use when the user wants to make a project installable via Nix flakes from a remote GitHub repository, add devbox.json for reproducible development environments, or package a project for Nix profile installation. Covers forking, cloning, architecture analysis, flake template selection, documentation updates, CI setup, PR creation, nixpkgs superset detection (expose #nixpkgs output when nixpkgs packaging is more complete), and nixpkgs upstream contribution (submit package.nix to NixOS/nixpkgs when the project is not yet packaged). Do NOT trigger on general Nix questions, NixOS configuration, or non-flake Nix usage.

## Metadata

| Field | Value |
|-------|-------|
| Name | `nixify` |
| Category | `software-dev` |
| Version | `2.21.0` |
| Status | `` |
| Owner |  |

## Related Skills
- **base-ai-guidance** (template, base-framework) — Shared framework for creating all AI guidance types
- **project-detection** (skill, complementary) — Run detect-build-systems.sh for comprehensive language/build-system detection before selecting a flake template

---

- **Full skill**: [`skills/software-dev/nixify/SKILL.md`](skills/software-dev/nixify/SKILL.md)
- **Install**: `pnpm dlx skills add levonk/skills-releases`
- **Generated**: 2026-08-24T20:08:44Z
