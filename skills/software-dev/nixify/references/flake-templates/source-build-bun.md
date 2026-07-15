# Source Build Flake: Bun

Use when the project does not have published binary releases and uses Bun with `bun build --compile` to produce a standalone binary. The compiled binary is self-contained — no Node runtime or `node_modules` needed at install time.

## Key challenge: dependency fetching in the Nix sandbox

Nix builds run in a sandbox without network access. `bun install` needs to fetch packages from the npm registry. There are two approaches:

1. **`buildBunPackage`** (preferred if available in your nixpkgs revision) — nixpkgs' native Bun builder that handles dependency fetching via a fixed-output derivation keyed on `bun.lock` hash, similar to `buildNpmPackage`'s `npmDepsHash`.
2. **Manual `stdenv.mkDerivation` with a deps FOD** — a fixed-output derivation that runs `bun install` and produces a `node_modules` store path, then the main derivation copies it in before `bun build --compile`.

## Template: `stdenv.mkDerivation` with deps FOD

```nix
{
  description = "<Project description>";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }@inputs:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        # Bun target triple mapping for cross-compilation
        bunTarget = {
          x86_64-linux = "bun-linux-x64";
          aarch64-linux = "bun-linux-arm64";
          x86_64-darwin = "bun-darwin-x64";
          aarch64-darwin = "bun-darwin-arm64";
        }.${system} or (throw "Unsupported platform: ${system}");

        # Fixed-output derivation: runs `bun install` with network access,
        # produces a node_modules store path. The hash is computed from
        # bun.lock — run `nix hash to-sri --type sha256 $(nix store prefetch --json --hash-type sha256 file:///dev/null 2>/dev/null || echo "REPLACE_WITH_HASH")` after first build attempt.
        # ponytail: FOD hash must be updated when bun.lock changes; no automation yet.
        deps = pkgs.stdenv.mkDerivation {
          pname = "<binary-name>-deps";
          version = "<x.y.z>";
          src = ./.;

          nativeBuildInputs = [ pkgs.bun ];

          impureEnvVars = [ "HOME" "XDG_CACHE_HOME" ];
          BUN_INSTALL_CACHE_DIR = "$TMPDIR/bun-cache";

          dontBuild = true;
          dontConfigure = true;

          installPhase = ''
            runHook preInstall
            bun install --frozen-lockfile
            mkdir -p $out
            cp -r node_modules $out/node_modules
            runHook postInstall
          '';

          outputHashMode = "recursive";
          outputHashAlgo = "sha256";
          outputHash = "<REPLACE_WITH_FOD_HASH>";
        };

        <pname> = pkgs.stdenv.mkDerivation {
          pname = "<binary-name>";
          version = "<x.y.z>";
          src = ./.;

          nativeBuildInputs = [ pkgs.bun ];

          BUN_INSTALL_CACHE_DIR = "$TMPDIR/bun-cache";

          dontConfigure = true;

          buildPhase = ''
            runHook preBuild

            # Use pre-fetched node_modules from the deps FOD
            cp -r ${deps}/node_modules ./node_modules

            # Run any pre-build code generation the project requires
            # (e.g. bundled defaults, build-time constants). Inspect the
            # project's build script (scripts/build-binaries.sh or similar)
            # and replicate the necessary steps here.
            # Example: bun run scripts/generate-bundled-defaults.ts

            # Build standalone binary via bun build --compile
            # Adjust entry point to match the project's actual CLI entry
            bun build --compile --target ${bunTarget} \
              --outfile <binary-name> \
              <entry-point.ts>

            runHook postBuild
          '';

          installPhase = ''
            runHook preInstall
            install -Dm755 <binary-name> $out/bin/<binary-name>
            runHook postInstall
          '';

          meta = {
            description = "<Project description>";
            homepage = "https://github.com/$UPSTREAM_OWNER/$UPSTREAM_REPO";
            license = pkgs.lib.licenses.<spdx>;
            mainProgram = "<binary-name>";
            platforms = builtins.attrNames bunTarget;
          };
        };
      in
      {
        packages = {
          <pname> = <pname>;
          default = <pname>;
          source = <pname>;
        };

        apps = {
          <pname> = {
            type = "app";
            program = "${<pname>}/bin/<binary-name>";
          };
          default = {
            type = "app";
            program = "${<pname>}/bin/<binary-name>";
          };
        };

        checks = {
          build = <pname>;
        };
      }
    );
}
```

## Adapting to the project's build script

Most Bun projects that use `bun build --compile` have a build script (e.g. `scripts/build-binaries.sh`) that does more than just `bun build --compile`. Common extra steps:

- **Code generation**: `bun run scripts/generate-bundled-defaults.ts` or similar — replicate these in the `buildPhase` before the `bun build --compile` call.
- **Build-time constants**: rewriting a source file with version/commit info before compiling. In Nix, set these via environment variables or substitute the file in `preBuild`.
- **Multiple targets**: the build script may loop over targets. In the flake, each system handles its own target via the `bunTarget` mapping, so no loop is needed.

Read the project's build script carefully and replicate every step that affects the compiled binary. Steps that only affect packaging (checksums, uploading) are not needed.

## Getting the FOD hash

The `outputHash` for the deps derivation must be computed empirically:

1. Set `outputHash = pkgs.lib.fakeSha256` as a placeholder.
2. Run `nix build .#<pname>` — it will fail with a hash mismatch error showing the correct hash.
3. Replace the placeholder with the correct SRI hash.
4. Re-run to confirm.

This hash changes whenever `bun.lock` changes. For release-based repos, the hash automation workflow (see `references/advanced-features.md` — Release-Triggered Hash Automation) should be adapted to also bump the FOD hash.
