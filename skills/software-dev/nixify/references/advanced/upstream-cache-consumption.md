## Upstream Cache Consumption (nixConfig)

When a flake depends on other flakes (e.g., `bun2nix`, `rust-overlay`, `naersk`), those dependencies may have pre-built binaries in their own Cachix caches. Declare the upstream caches directly in `flake.nix` via `nixConfig` so that anyone using the flake automatically fetches pre-built artifacts instead of compiling downstream dependencies locally.

**Add `nixConfig` to `flake.nix`:**

```nix
{
  description = "<project description>";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    bun2nix.url = "github:nix-community/bun2nix";
    bun2nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  nixConfig = {
    extra-substituters = [
      "https://nix-community.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  outputs = { self, nixpkgs, ... }: {
    # ...
  };
}
```

Key details:
- Uses `extra-substituters` (additive) not `substituters` (replacement) so user-configured caches are preserved
- `extra-trusted-public-keys` must match the substituter URLs — get keys from the upstream project's documentation or `cachix.org/<cache-name>`
- Requires the user to have `trusted-users` or `trusted-substituters` configured in their Nix settings, or to accept the flake's nix config on first use
- This is complementary to the Cachix Integration section above — that section covers pushing YOUR builds to a cache; this section covers consuming OTHERS' caches

**When to use:**
- The flake has inputs that publish to Cachix (e.g., `nix-community`, `rust-overlay`, `nixpkgs-wayland`)
- Build times are slow because downstream dependencies compile from source
- You want users to have a fast `nix run` / `nix build` experience without manual cache configuration

**Skip if:** The flake has no external flake inputs, or all inputs are already in the official `cache.nixos.org`.
