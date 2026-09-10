# Advanced Features — Index

This file is an index. The advanced features documentation has been split
into topic-specific files under `references/advanced/`. Each file covers one
concern with its own templates, customization notes, and skip conditions.

| File | Topic |
|------|-------|
| [`advanced/github-actions-nix.md`](advanced/github-actions-nix.md) | GitHub Actions CI for Nix (nix.yml template, lockfile path-filter, cross-platform matrix, magic-nix-cache-action, self-pruning on runner decommission) |
| [`advanced/hash-automation.md`](advanced/hash-automation.md) | Release-Triggered Hash Automation (Template A scheduled lag-check, Template B release: published, overrideAttrs variant, nix-update alternative) |
| [`advanced/garnix.md`](advanced/garnix.md) | Garnix CI (Hosted Alternative) — maintainer-opt-in hosted Nix CI, garnix.yaml configuration, FOD checks |
| [`advanced/nixos-service.md`](advanced/nixos-service.md) | NixOS Service Module — systemd service, user/group, auto-configured runtime deps, .env-strict projects |
| [`advanced/home-manager.md`](advanced/home-manager.md) | Home-Manager Module — declarative user configuration for CLI tools |
| [`advanced/flake-patterns.md`](advanced/flake-patterns.md) | Flake patterns: modular Nix structure, flake-compat shims, forAllSystems/perSystem (no flake-utils) |
| [`advanced/treefmt.md`](advanced/treefmt.md) | treefmt configuration for automated Nix formatting |
| [`advanced/cachix-integration.md`](advanced/cachix-integration.md) | Cachix Integration (Binary Caching) — push your builds to a Cachix cache |
| [`advanced/upstream-cache-consumption.md`](advanced/upstream-cache-consumption.md) | Upstream Cache Consumption (nixConfig) — pull others' pre-built deps |
| [`advanced/input-follows.md`](advanced/input-follows.md) | Input Follows for nixpkgs Deduplication across flake inputs |
| [`advanced/devenv-vs-mkshell.md`](advanced/devenv-vs-mkshell.md) | Devenv vs mkShell — when to use devenv (managed services, devcontainer parity) vs plain mkShell |
| [`advanced/version-from-git.md`](advanced/version-from-git.md) | Version from Git Revision — derive `version` from `self.shortRev` for projects with no language manifest |
