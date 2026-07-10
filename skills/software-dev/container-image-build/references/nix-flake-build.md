# Branch C — Nix Flake

> Use when the service genuinely needs a Nix store at runtime: serves nixpkgs
> to Nix clients, needs the `nix` CLI inside the container, or needs
> `nix-store` running.

## When to Use

- The container must serve nixpkgs packages to Nix clients (e.g., a binary
  cache server).
- The container needs the `nix` CLI or `nix-store` daemon running inside.
- The service is tightly coupled to Nix store paths at runtime.

If the service is just a binary (Rust, Go, C/C++, Python) that reads a mounted
`/nix/store` volume but doesn't need `nix-store` inside, use Branch B instead.
Nix flake container builds couple the image to the build host's system — avoid
this coupling unless the runtime genuinely requires it.

## Basic Structure

Use `dockerTools.buildLayeredImage` in `flake.nix`:

```nix
{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in {
      packages.${system}.default = pkgs.dockerTools.buildLayeredImage {
        name = "my-nix-service";
        tag = "latest";
        contents = [
          pkgs.nix
          pkgs.cacert
          # your service package
        ];
        config = {
          Cmd = [ "${pkgs.nix}/bin/nix-store" "--init" ];
          Env = [ "NIX_REMOTE=daemon" ];
        };
      };
    };
}
```

Build and load:

```bash
nix build .#default
docker load < result
```

## Multi-Arch

### Option 1: flake-utils (legacy, still works)

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachSystem ["x86_64-linux" "aarch64-linux"] (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in {
        packages.default = pkgs.dockerTools.buildLayeredImage {
          name = "my-nix-service";
          # ...
        };
      });
}
```

> **Note:** `flake-utils` is deprecated. Prefer Flake Parts for new projects.

### Option 2: Flake Parts (preferred for new projects)

Per the 2026 NixOS Wiki, Flake Parts is the recommended flake composition
library for new projects:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = inputs@{ self, nixpkgs, flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = ["x86_64-linux" "aarch64-linux"];
      perSystem = { config, pkgs, system, ... }: {
        packages.default = pkgs.dockerTools.buildLayeredImage {
          name = "my-nix-service";
          # ...
        };
      };
    };
}
```

## Cross-Compilation with pkgsCross

When the build host is one arch but the target is another, use `pkgsCross`:

```nix
let
  pkgs = import nixpkgs { system = "x86_64-linux"; };
  aarch64Pkgs = import nixpkgs {
    system = "x86_64-linux";
    crossSystem = { config = "aarch64-unknown-linux-gnu"; };
  };
in {
  packages.aarch64-image = aarch64Pkgs.dockerTools.buildLayeredImage {
    name = "my-nix-service";
    # ...
  };
}
```

## Build Platform Coupling Warning

- **Nix flake builds are coupled to the build host's system.** The build host
  must be **Linux**, not Darwin. Cross-compilation from Darwin to Linux is
  limited and often fails for complex derivations.
- Document which build hosts can produce which architectures in the task or
  PRD. If no available Linux host can produce the required arch, block the task
  until the feasibility issue is resolved (see `container-build-principles.md`).
- **Cross-compilation is NOT cached on the NixOS binary cache.** `pkgsCross`
  builds compile from source and can take hours for large dependency trees.
  Plan build time accordingly.

## Related Skills & Workflows

- **`nixify` skill** — flake authoring patterns, architecture analysis, flake
  templates. Reference it for flake structure conventions.
- **`nix-standards` workflow** — flake standards (formatting, inputs pinning,
  evaluation). Follow it for flake hygiene.

## Example

A service that needs `nix-store` inside the container to serve the local Nix
store to clients. The container runs `nix-store --serve` on a mounted
`/nix/store` volume. This genuinely requires Nix at runtime — Branch C is
correct. Build on a Linux host with Flake Parts, targeting
`["x86_64-linux" "aarch64-linux"]`, and push the resulting images to the
registry.
