## Cachix Integration (Binary Caching)

1. **Create a Cachix cache:** Visit https://cachix.org and create a new cache.

2. **Add Cachix input to `flake.nix`:**

```nix
inputs = {
  nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  flake-utils.url = "github:numtide/flake-utils";
  cachix = {
    url = "github:cachix/cachix";
    inputs.nixpkgs.follows = "nixpkgs";
  };
};
```

3. **Add CI workflow to push to Cachix** (`.github/workflows/cachix.yml`):

```yaml
name: Cachix

on:
  push:
    branches: [ master ]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@<checkout-sha> # v<N>
      - uses: cachix/install-nix-action@<install-nix-sha> # v<N>
        with:
          nix_path: nixpkgs=channel:nixos-unstable
      - uses: cachix/cachix-action@<cachix-action-sha> # v<N>
        with:
          name: <your-cache-name>
          authToken: '${{{ "{{" }}} secrets.CACHIX_AUTH_TOKEN {{{ "}}" }}}'
```

4. **Add `CACHIX_AUTH_TOKEN` secret** to GitHub repository from https://cachix.org/api/token

**Skip if:** The project is small and build times are acceptable, or uses a different caching solution.
