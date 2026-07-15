## Nix

The project provides optional Nix flake outputs for users who already use Nix. The flake wraps the prebuilt release binary as `#default` and also builds from source as `#source`.

```bash
# Run without installing (prebuilt binary)
nix run github:$UPSTREAM_OWNER/$UPSTREAM_REPO

# Install into your profile
nix profile install github:$UPSTREAM_OWNER/$UPSTREAM_REPO

# Build from source instead
nix run github:$UPSTREAM_OWNER/$UPSTREAM_REPO#source
```

The flake tracks the default branch and is auto-bumped to the latest release by a
daily [workflow](.github/workflows/nix-release.yml), so `github:$UPSTREAM_OWNER/$UPSTREAM_REPO`
always serves the current release. (Release tags are cut before the bump lands,
so `github:$UPSTREAM_OWNER/$UPSTREAM_REPO/vX.Y.Z` is not a valid pin — use the
nixpkgs package or a specific commit SHA if you need reproducibility.)
