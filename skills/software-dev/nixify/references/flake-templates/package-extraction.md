# Package Extraction: `package.nix` + `default.nix` + `flake.nix`

Extract the package definition from `flake.nix` into a standalone `package.nix`
(callPackage-style) and a `default.nix` wrapper. This makes the flake's
system-specific wiring clearer, enables non-flake `nix-build` / `callPackage`
workflows, and produces a `package.nix` already in the shape nixpkgs expects for
upstream contribution.

## When to Use

Use this pattern when ALL of the following are true:

1. `flake_type` is `source_build` (the package is built from source, not a
   prebuilt tarball or nixpkgs wrapper)
2. `check-nixpkgs.sh` (Step 10) reported `project_in_nixpkgs: false` — the
   project is a nixpkgs upstreaming candidate (Step 28b)
3. The project has a single build definition (no multi-output `#prebuilt` /
   `#source` split — those stay inline in `flake.nix` because the prebuilt
   and source outputs have different derivations)

Do NOT use this pattern when:
- `flake_type` is `prebuilt_tarball` — the `assets` attrset and per-platform
  hash automation target the inline `flake.nix` structure; extracting them
  complicates the hash automation workflow (Step 16)
- `flake_type` is `nixpkgs_wrapper` or `nixpkgs_override_attrs` — the package
  is already in nixpkgs; extraction adds no upstreaming value
- The flake has a hybrid fallback (`hybrid_fallback=true`) — the `#default`
  output conditionally falls back to source on some platforms, which requires
  inline logic that does not extract cleanly

## Three-File Structure

### `package.nix` — the callPackage-style package definition

This is the core derivation. It takes dependencies as function arguments
(auto-filled by `callPackage`) and a `version` parameter with a release-please
marker. The builder function (`buildGoModule`, `buildRustPackage`, etc.) comes
from the language-specific source-build template — the only change is the
function signature and `src = lib.cleanSource ./.` instead of
`src = pkgs.lib.cleanSource ./.`.

```nix
{
  lib,
  buildGoModule,
  git,
  python3,
  version ? "2.3.0" # x-release-please-version
}:

buildGoModule {
  pname = "<project-name>";
  inherit version;

  src = lib.cleanSource ./.;
  vendorHash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";

  ldflags = [
    "-X main.version=v${version}"
  ];

  # Nix-specific check inputs (not runtime deps) go here.
  # See the language-specific source-build template for what to include.
  nativeCheckInputs = [
    git
    python3
  ];

  # Disable the Nix sandbox check when the project's own CI covers it.
  # See the language-specific source-build template for the rationale.
  doCheck = false;

  meta = {
    description = "<one-line description>";
    homepage = "https://github.com/$UPSTREAM_OWNER/$UPSTREAM_REPO";
    license = lib.licenses.<license>;
    mainProgram = "<project-name>";
    platforms = [
      "aarch64-darwin"
      "x86_64-darwin"
      "aarch64-linux"
      "x86_64-linux"
    ];
  };
}
```

**Language-specific builder**: Replace `buildGoModule` with the correct
builder for the project's language — see the source-build template
(`source-build/go.md`, `source-build/rust.md`, etc.) for the builder function,
dependency names, and hash fields. The function arguments change from
`pkgs.<dep>` to bare `<dep>` because `callPackage` injects them from the
package set.

**Darwin legacy pin**: The `nixpkgs-darwin-legacy` input stays in
`flake.nix` (it selects which `pkgs` to pass). The `package.nix` itself is
pin-agnostic — it receives `buildGoModule` (or equivalent) as an argument,
and the flake passes the right one per system. See
`references/flake-templates/darwin-legacy-pin.md`.

**Release-please marker**: The `# x-release-please-version` comment on the
`version` default lets release-please update the version in `package.nix`
automatically. Add `package.nix` to the `extra-files` list in
`release-please-config.json` so the version bump propagates. Without the
marker, the default stays at the initial version after a release and
standalone `nix-build` / `callPackage` builds report a stale version.

### `default.nix` — the non-flake entry point

Enables `nix-build` without a flake by bridging to the flake's locked
nixpkgs via [flake-compat](https://github.com/edolstra/flake-compat). This
requires adding `flake-compat` as a flake input (see `flake.nix` below):

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

Users can now build without flakes:

```bash
nix-build                # uses the flake's locked nixpkgs and version
nix-build default.nix    # explicit
```

**CRITICAL — never use `import <nixpkgs> {}` in `default.nix`**: The
ambient `<nixpkgs>` channel is outside the flake's control and may lack
the toolchain version the flake deliberately pins (e.g., Go 1.25.5
requires nixpkgs-unstable; stable branches only ship Go 1.22.x/1.23.x).
It may also have dropped platforms the flake supports — nixpkgs 26.11+
removes `x86_64-darwin` entirely, so a user on a current stable channel
gets a silent build failure instead of the darwin-legacy pin the flake
configured. The flake-compat shim reads the locked nixpkgs from
`flake.lock`, guaranteeing the traditional `nix-build` path uses the
same toolchain and platform support as the flake — including the
darwin-legacy pin for `x86_64-darwin`. See
[`advanced/flake-patterns.md`](../advanced/flake-patterns.md) →
"Flake-Compat Shims (Legacy Nix)" for the full shim pattern.

**Version propagation**: The `default.nix` shim does not carry a
`version` parameter or `# x-release-please-version` marker — the version
comes from the flake's `let version = ...` binding (which has the
marker). Release-please updates the flake's version line, and the shim
picks up the new value on the next `nix-build`. Add `default.nix` to
`release-please-config.json` `extra-files` only if it carries its own
version marker; with the flake-compat shim it does not, so `extra-files`
needs only `flake.nix` and `package.nix`.

### `flake.nix` — system wiring only

The flake calls `package.nix` directly via `callPackage`, keeping the
system-specific wiring (legacy pin, `forAllSystems`, `apps`) separate
from the package definition. The `flake-compat` input enables the
`default.nix` shim for non-flake `nix-build`:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixpkgs-darwin-legacy.url = "github:NixOS/nixpkgs/nixpkgs-26.05-darwin";
    flake-compat.url = "github:edolstra/flake-compat";
    flake-compat.flake = false;
  };

  outputs =
    { self
    , nixpkgs
    , nixpkgs-darwin-legacy
    , ...
    }:
    let
      version = "2.3.0"; # x-release-please-version
      systems = [
        "aarch64-darwin"
        "x86_64-darwin"
        "aarch64-linux"
        "x86_64-linux"
      ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
    in
    {
      packages = forAllSystems (
        system:
        let
          pkgs =
            if system == "x86_64-darwin" then
              import nixpkgs-darwin-legacy { inherit system; }
            else
              nixpkgs.legacyPackages.${system};
          treehouse = pkgs.callPackage ./package.nix { inherit version; };
        in
        {
          default = treehouse;
          inherit treehouse;
        }
      );

      apps = forAllSystems (
        system:
        {
          default = {
            type = "app";
            program = "${self.packages.${system}.default}/bin/${self.packages.${system}.default.meta.mainProgram}";
            meta = self.packages.${system}.default.meta;
          };
          treehouse = {
            type = "app";
            program = "${self.packages.${system}.treehouse}/bin/${self.packages.${system}.treehouse.meta.mainProgram}";
            meta = self.packages.${system}.treehouse.meta;
          };
        }
      );
    };
}
```

**Why `callPackage ./package.nix` instead of `import ./default.nix`**: The
flake already has the correct per-system `pkgs` (including the
darwin-legacy selection for `x86_64-darwin`). Routing through
`default.nix` is unnecessary coupling — `default.nix` exists for
non-flake users, not for the flake to call. Calling `package.nix`
directly via `callPackage` also avoids a circular dependency: if
`default.nix` uses flake-compat to import the flake, the flake cannot
also import `default.nix`.

## Release-Please Configuration

Add `package.nix` to `release-please-config.json` `extra-files` so the
version bump propagates. Both `flake.nix` and `package.nix` carry the
`# x-release-please-version` marker. The `default.nix` flake-compat shim
does not carry a version parameter (it inherits the version from the
flake), so it does not need to be in `extra-files`:

```json
{
  "extra-files": [
    "flake.nix",
    "package.nix"
  ]
}
```

If the project keeps `default.nix` in `extra-files` (e.g., for
release-please to track it as a changed file), release-please will
still update it — but since it has no `# x-release-please-version`
marker, no version string is changed. This is harmless but unnecessary.

## Workflow Updates

When using this pattern, the following workflow files must target the
extracted files instead of (or in addition to) `flake.nix`:

- **Vendor hash automation** (Step 16): if the hash automation workflow
  updates `vendorHash` / `cargoHash` / etc., it must target `package.nix`
  (where the hash now lives), not `flake.nix`
- **CI nix workflow** (`.github/workflows/nix.yml`): `nix build .#default`
  and `nix run .#default` still work (the flake wires them), but add
  `nix-build default.nix` to validate the non-flake path
- **Release-please path filters**: include `package.nix` and `default.nix`
  in the paths that trigger the release workflow
- **Flake lock update**: after adding the `flake-compat` input, run
  `nix flake lock` to populate `flake.lock` with the `flake-compat` node.
  The `default.nix` shim reads `lock.nodes.flake-compat.locked.rev` and
  `narHash` from `flake.lock` — without the lock entry, `nix-build
  default.nix` fails with a missing-node error.

## Connection to nixpkgs Upstreaming (Step 28b)

The extracted `package.nix` is already in the shape nixpkgs expects for
`pkgs/by-name`. The only changes needed for the nixpkgs PR are:

1. Replace `src = lib.cleanSource ./.` with `fetchFromGitHub { ... }` pointing
   at the upstream release tag
2. Replace the `version` default with the pinned release version
3. Add `meta.maintainers` (the nixpkgs PR requires a maintainer entry)

See `references/nixpkgs-contribution.md` — Reusing the In-Repo `package.nix`
for the full transformation checklist.
