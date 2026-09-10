# treefmt Configuration

Add treefmt for automated Nix formatting.

**Add treefmt-nix input to `flake.nix`:**

```nix
inputs = {
  nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  flake-utils.url = "github:numtide/flake-utils";
  treefmt-nix.url = "github:numtide/treefmt-nix";
};
```

**Add formatter output:**

```nix
outputs = { self, nixpkgs, flake-utils, treefmt-nix }:
  flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = nixpkgs.legacyPackages.${system};
      treefmt = import ./nix/modules/treefmt.nix { inherit pkgs; };
    in
    {
      formatter = treefmt-nix.lib.mkWrapper pkgs treefmt;
    }
  );
```

**Usage:**

```bash
nix fmt          # Format all Nix files
nix fmt --check  # Check formatting without modifying
```

**Skip if:** The project has no Nix files beyond `flake.nix` or the team prefers other tools.
