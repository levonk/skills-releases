# Directory Update Log

## 2026-07-17

* **Initialization**: Created the `nix-build-practices` knowledge bundle to consolidate Nix build and development practices from two ADRs in levonk-base-boilerplate and project conventions.
* **Creation**: Authored 4 concept pages covering the Nix build stack.
  - [nix-flake-structure.md](nix-flake-structure.md) — flake.nix with inputs, outputs, devShells, packages
  - [devbox-as-nix-abstraction.md](devbox-as-nix-abstraction.md) — devbox.json as simpler JSON alternative to raw Nix
  - [package-verification.md](package-verification.md) — Always verify via search.nixos.org before adding packages
  - [reproducible-builds.md](reproducible-builds.md) — flake.lock and devbox.lock for deterministic builds
* **Creation**: Established [overview.md](overview.md) synthesis and [index.md](index.md) directory listing.
* **Note**: Concepts extracted from ADR-20251219001 (Nix flake, 66 lines) and ADR-20251226001 (devbox, 65 lines) in levonk-base-boilerplate, plus project conventions for package verification.
