## Input Follows for nixpkgs Deduplication

When a flake has multiple inputs that each depend on nixpkgs, each input will pin its own copy of nixpkgs by default. This causes:
- Duplicate nixpkgs evaluations (slower builds, more memory)
- Potential version mismatches between inputs
- Larger `flake.lock` files

Use `follows` to make all inputs use the same nixpkgs revision:

```nix
inputs = {
  nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  # These inputs will use the same nixpkgs as the main flake
  bun2nix = {
    url = "github:nix-community/bun2nix";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  rust-overlay = {
    url = "github:oxalica/rust-overlay";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  naersk = {
    url = "github:nix-community/naersk";
    inputs.nixpkgs.follows = "nixpkgs";
  };
};
```

**When to use:** Always, when inputs have a `nixpkgs` input. This is a best practice for all flakes with multiple inputs.

**Skip if:** An input deliberately pins a different nixpkgs version (rare — usually for compatibility testing).
