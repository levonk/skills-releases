---
type: Practice
title: Nix Flake Structure
description: flake.nix with inputs, outputs, devShells per system, packages, and flake.lock for reproducibility. Standard structure for all Nix-based projects.
tags: [nix, flakes, flake-nix, flake-lock, devshells, reproducible]
timestamp: 2026-07-17T00:00:00Z
---

# Nix Flake Structure

## Failure Mode

Missing or incomplete flake.nix files prevent reproducible development shells.
Missing flake.lock allows dependency drift across machines. Unclear output
structure makes it difficult to find devShells and packages.

## Practice

Every Nix-based project must have a standard `flake.nix` structure.

### Required Structure

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            go
            just
            jq
            git
          ];
        };

        packages.default = pkgs.buildGoModule {
          # ... package definition
        };
      });
}
```

### Key Elements

- **inputs**: Pinned to specific nixpkgs channel (e.g., `nixos-25.11`)
- **outputs**: Per-system devShells and packages
- **flake.lock**: Committed for reproducibility
- **devShells.default**: The standard development shell

### Superseded by Devbox

Raw Nix flakes were the original approach (ADR-20251219001). Devbox now provides
a simpler JSON-based abstraction over Nix (ADR-20251226001). Projects using
devbox still benefit from understanding the underlying Nix flake structure.

## Related Concepts

- [Devbox as Nix Abstraction](devbox-as-nix-abstraction.md) — Simpler alternative
- [Reproducible Builds](reproducible-builds.md) — flake.lock enables this

## Citations

[1] `internal-docs/adr/adr-20251219001-nix-direnv-dev-environment.md` — levonk-base-boilerplate
