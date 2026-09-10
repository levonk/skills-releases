# Flake Patterns: Modular Structure, Compat Shims, forAllSystems

This file covers three related flake structure patterns:
- [Modular Nix Structure](#modular-nix-structure) — split a monolithic `flake.nix` into `nix/modules/`
- [Flake-Compat Shims (Legacy Nix)](#flake-compat-shims-legacy-nix) — `default.nix`/`shell.nix` for non-flake users
- [forAllSystems / perSystem Pattern (No flake-utils)](#forallsystems--persystem-pattern-no-flake-utils) — lightweight multi-system support

---

## Modular Nix Structure

For larger projects requiring complex Nix logic, use a modular structure instead of a monolithic `flake.nix`.

**Create `nix/modules/packages.nix`:**

```nix
{ pkgs, system, ... }:
{
  default = pkgs.<binary-name>;
}
```

**Create `nix/modules/overlays.nix`:**

```nix
final: prev: {
  <binary-name> = final.<binary-name>;
}
```

**Create `nix/modules/devshells.nix`:**

```nix
{ pkgs, ... }:
{
  default = pkgs.mkShell {
    buildInputs = with pkgs; [
      rustc
      cargo
      rust-analyzer
      pkg-config
      openssl
    ];
  };
}
```

**Create `nix/modules/treefmt.nix`:**

```nix
{ pkgs, ... }:
{
  projectRootFile = "flake.nix";
  settings.formatter.nixfmt = {
    command = "${pkgs.nixfmt}/bin/nixfmt";
    includes = [ "*.nix" ];
  };
}
```

**Update `flake.nix` to use modules:**

```nix
{
  description = "<Project description>";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    treefmt-nix.url = "github:numtide/treefmt-nix";
  };

  outputs = { self, nixpkgs, flake-utils, treefmt-nix }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        packages = import ./nix/modules/packages.nix { inherit pkgs system; };
        overlays = import ./nix/modules/overlays.nix;
        devshells = import ./nix/modules/devshells.nix { inherit pkgs; };
        treefmt = import ./nix/modules/treefmt.nix { inherit pkgs; };
      in
      {
        inherit packages overlays devshells;
        packages.default = packages.default;
        devShells.default = devshells.default;
        formatter = treefmt-nix.lib.mkWrapper pkgs treefmt;
      }
    );
}
```

**Skip if:** The project is simple and a monolithic `flake.nix` is sufficient.

---

## Flake-Compat Shims (Legacy Nix)

Create `default.nix` and `shell.nix` for users who don't have flakes enabled.

**`default.nix`:**

```nix
(import (
  let
    lock = builtins.fromJSON (builtins.readFile ./flake.lock);
  in
  fetchTarball {
    url = "https://github.com/edolstra/flake-compat/archive/${lock.nodes.flake-compat.locked.rev}.tar.gz";
    sha256 = lock.nodes.flake-compat.locked.narHash;
  }
) {
  src = ./.;
}).defaultNix
```

**`shell.nix`:**

```nix
(import (
  let
    lock = builtins.fromJSON (builtins.readFile ./flake.lock);
  in
  fetchTarball {
    url = "https://github.com/edolstra/flake-compat/archive/${lock.nodes.flake-compat.locked.rev}.tar.gz";
    sha256 = lock.nodes.flake-compat.locked.narHash;
  }
) {
  src = ./.;
}).shellNix
```

**Skip if:** The project only targets users with Nix flakes enabled.

---

## forAllSystems / perSystem Pattern (No flake-utils)

Instead of depending on `flake-utils` for multi-system support, use a lightweight `forAllSystems` / `perSystem` pattern. This eliminates an external dependency and gives full control over which systems are supported.

```nix
{
  description = "<project description>";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs, ... }: let
    lib = nixpkgs.lib;
    supportedSystems = [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];
    forAllSystems = lib.genAttrs supportedSystems;
    perSystem = forAllSystems (
      system: let
        pkgs = import nixpkgs { inherit system; };
        <pname> = pkgs.callPackage ./nix/package.nix { };
      in {
        packages = {
          inherit <pname>;
          default = <pname>;
        };
        devShells.default = pkgs.callPackage ./nix/devShell.nix { };
      }
    );
    systemOutput = name: lib.mapAttrs (_: value: value.${name}) perSystem;
  in {
    packages = systemOutput "packages";
    devShells = systemOutput "devShells";
  };
}
```

Key details:
- `supportedSystems` is explicit — only build for systems you actually support, not every possible system
- `perSystem` defines all per-system outputs in one block (packages, devShells, apps, checks)
- `systemOutput` extracts a named key from each system's attribute set into the top-level flake output
- `pkgs.callPackage` for devShell and package definitions enables clean separation into `./nix/` files
- No `flake-utils` input means one fewer entry in `flake.lock` and no dependency on an external maintainer

**When to use:**
- You want to minimize external flake inputs
- You need explicit control over supported systems (not all systems via `eachDefaultSystem`)
- The project has a modular `./nix/` directory structure

**Skip if:** The project already uses `flake-utils` and migration would add complexity, or `eachDefaultSystem` behavior (all systems) is desired.
