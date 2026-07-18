---
okf_version: "0.1"
---

# Nix Build Practices

A compounding knowledge base documenting practices for Nix-based build and
development environments — flake structure, devbox as Nix abstraction, package
verification, and reproducible builds. Each concept captures specific practices
sourced from ADRs and project conventions.

## Concepts

* [Overview](overview.md) - Synthesis of the full Nix build practice set
* [nix-flake-structure](nix-flake-structure.md) - flake.nix with inputs, outputs, devShells, packages; flake.lock for reproducibility
* [devbox-as-nix-abstraction](devbox-as-nix-abstraction.md) - devbox.json as simpler alternative to raw Nix flakes, Nix-compatible packages
* [package-verification](package-verification.md) - Always verify Nix packages exist, check versions, confirm attribute names via search.nixos.org
* [reproducible-builds](reproducible-builds.md) - flake.lock pinning, devbox.lock, deterministic builds across machines
