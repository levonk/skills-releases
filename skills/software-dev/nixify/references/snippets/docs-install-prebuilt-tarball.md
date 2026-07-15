### Nix (Flakes)

For users who already have Nix with flakes enabled:

```bash
# Run without installing (prebuilt binary)
nix run github:$UPSTREAM_OWNER/$UPSTREAM_REPO

# Install into your profile
nix profile install github:$UPSTREAM_OWNER/$UPSTREAM_REPO

# Build from source instead
nix run github:$UPSTREAM_OWNER/$UPSTREAM_REPO#source
```

The flake tracks the default branch and is auto-bumped to the latest release
daily, so `github:$UPSTREAM_OWNER/$UPSTREAM_REPO` always serves the current
release. For reproducibility, pin to a specific commit SHA or use the nixpkgs
package.

**Updating:**

```bash
# For profile installs
nix profile upgrade <index-or-name>

# For flake-based installs (e.g., via flake inputs)
nix flake update <repo>
```
