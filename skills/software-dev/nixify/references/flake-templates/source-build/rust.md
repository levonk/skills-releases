# Source Build Flake: Rust (Cargo)

Use when the project does not have published binary releases and uses Cargo.

```nix
{
  description = "<Project description>";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    # Pin x86_64-darwin to a stable release branch for older macOS Intel
    # compatibility. See references/flake-templates/darwin-legacy-pin.md.
    nixpkgs-darwin-legacy.url = "github:NixOS/nixpkgs/nixpkgs-26.05-darwin";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, nixpkgs-darwin-legacy, flake-utils, ... }@inputs:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs =
          if system == "x86_64-darwin"
          then nixpkgs-darwin-legacy.legacyPackages.${system}
          else nixpkgs.legacyPackages.${system};
        <pname> = pkgs.rustPlatform.buildRustPackage {
          pname = "<binary-name>";
          # Read version from Cargo.toml instead of hardcoding — avoids
          # stale version on every release. For single-crate projects, read
          # the root Cargo.toml. For Cargo workspace projects where the
          # binary is in a subcrate (e.g. crates/<cli>/Cargo.toml), read
          # that subcrate's Cargo.toml — the root workspace Cargo.toml
          # typically has no version field.
          version = (builtins.fromTOML (builtins.readFile ./Cargo.toml)).version;
          # For workspace projects, point at the subcrate:
          # version = (builtins.fromTOML (builtins.readFile ./crates/<cli>/Cargo.toml)).version;
          # cleanSource filters build artifacts, .git, .devbox, etc., so
          # trivial local changes do not invalidate the Nix build cache.
          src = pkgs.lib.cleanSource ./.;
          cargoLock.lockFile = ./Cargo.lock;
          nativeBuildInputs = [ pkgs.pkg-config ];
          buildInputs =
            [ pkgs.openssl ]
            ++ pkgs.lib.optionals pkgs.stdenv.isDarwin [
              pkgs.libiconv
              pkgs.darwin.apple_sdk.frameworks.Security
              pkgs.darwin.apple_sdk.frameworks.SystemConfiguration
            ];
          # Disable cargo tests if they require host paths, network, or
          # behavior unavailable in the Nix sandbox. Common cases:
          # - Tests that modify HOME, TMPDIR, or XDG_CONFIG_HOME
          # - Tests that spawn subprocesses or need specific host tools
          # - Tests that need network access
          # - Tests that depend on absolute paths from the dev environment
          # If the project's tests pass in `cargo test` locally but fail
          # in `nix build`, set doCheck = false with a comment explaining
          # why. The Nix CI workflow (nix.yml) validates the build, not the
          # test suite — that's the project's own CI's job.
          doCheck = false; # <set to true if tests work in the Nix sandbox>
          meta = {
            description = "<Project description>";
            homepage = "https://github.com/$UPSTREAM_OWNER/$UPSTREAM_REPO";
            license = pkgs.lib.licenses.<spdx>;
            mainProgram = "<binary-name>";
          };
        };
      in
      {
        packages = {
          # Users naturally try .#<pname>, so expose it alongside default.
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

        overlays.default = final: prev: {
          <pname> = <pname>;
        };

        checks = {
          build = <pname>;
        };

        devShells.default = pkgs.mkShell {
          nativeBuildInputs = [ pkgs.pkg-config ];
          buildInputs =
            [ pkgs.openssl pkgs.rustc pkgs.cargo ]
            ++ pkgs.lib.optionals pkgs.stdenv.isDarwin [
              pkgs.libiconv
              pkgs.darwin.apple_sdk.frameworks.Security
              pkgs.darwin.apple_sdk.frameworks.SystemConfiguration
            ]
            # Add runtime service deps detected by:
            #   scripts/detect-runtime-deps.sh <project-dir>
            # Common examples: pkgs.surrealdb, pkgs.postgresql, pkgs.redis
            ++ [ <runtime-deps> ];
        };
      }
    );
}
```

**Platform scope narrowing**: When Step 4a's `detect-platform-scope.sh` reports
`platform_scope=darwin_only` or `linux_only`, replace
`flake-utils.lib.eachDefaultSystem` with `flake-utils.lib.eachSystem target_platforms`
where `target_platforms` is the JSON array from Step 4a converted to a Nix list.
For example, a darwin-only project:

```nix
  outputs = { self, nixpkgs, nixpkgs-darwin-legacy, flake-utils, ... }@inputs:
    flake-utils.lib.eachSystem [ "x86_64-darwin" "aarch64-darwin" ] (system:
      ...
```

This ensures the flake only instantiates outputs for platforms the project
actually supports. Do NOT attempt cross-compilation to the excluded family.
See `references/architecture-analysis.md` — Inherent Platform Scope.

## Cargo Workspace Projects

When the project is a Cargo workspace (root `Cargo.toml` has a `[workspace]`
section and the binary is in a subcrate like `crates/<cli>/`):

- **Version**: Read from the subcrate's `Cargo.toml`, not the root. The root
  workspace `Cargo.toml` typically has no `version` field:
  ```nix
  version = (builtins.fromTOML (builtins.readFile ./crates/<cli>/Cargo.toml)).version;
  ```
- **`src`**: `pkgs.lib.cleanSource ./.` still works — it includes the entire
  workspace, which `buildRustPackage` needs to resolve workspace dependencies.
  Do NOT narrow `src` to just the subcrate directory.
- **`cargoLock.lockFile`**: Points at the root `./Cargo.lock` (workspaces
  share a single lockfile).
- **`pname`**: Use the binary name from the subcrate that produces the CLI
  binary, not the workspace root package name.
- **Selecting the binary crate**: If the workspace has multiple binary
  crates, use `cargoBuildFlags = [ "-p" "<cli-crate-name>" ]` to build
  only the CLI binary. Without this, `buildRustPackage` builds all
  workspace members, which may fail or produce unexpected outputs.
- **Workspace-inherited versions**: If the subcrate uses
  `version.workspace = true`, the version is defined in the root
  `Cargo.toml` under `[workspace.package]`. Read it from there:
  ```nix
  version = (builtins.fromTOML (builtins.readFile ./Cargo.toml)).workspace.package.version;
  ```

## Disabling Tests (`doCheck = false`)

Set `doCheck = false` when the project's `cargo test` suite does not work
in the Nix sandbox. Common reasons:

- Tests modify `HOME`, `TMPDIR`, or `XDG_CONFIG_HOME` (Nix sandbox restricts
  these)
- Tests spawn subprocesses that need specific host tools not in `nativeBuildInputs`
- Tests require network access (denied in the sandbox)
- Tests depend on absolute paths from the development environment
- Tests use `#[ignore]` flags that expect specific host state

The template above ships with `doCheck = false` by default. If the project's
tests are sandbox-compatible (no host paths, no network, no subprocess
spawning), set `doCheck = true` to run them during the Nix build. When in
doubt, start with `doCheck = false` and let the project's own CI handle
test validation — the Nix CI workflow (`nix.yml`) validates the **build**,
not the test suite.
