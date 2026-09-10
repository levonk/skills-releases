# Source Build Flake: CMake (C/C++)

Use when the project does not have published binary releases and uses CMake
(`CMakeLists.txt`). Covers C and C++ projects with a CMake-based build system.

## Key challenge: version derivation

Unlike Rust (reads `version` from `Cargo.toml`) or Node (reads `version` from
`package.json`), C/C++ projects typically have **no language manifest with a
version field**. CMake projects often derive the version from git tags at build
time via `git describe` in `CMakeLists.txt`. The Nix `version` attribute should
track the git revision too — do NOT hardcode a `version = "<x.y.z>"` that goes
stale the moment the source moves past that tag.

Use the git-revision version pattern:

```nix
version = "unstable-${self.shortRev or "dirty"}";
```

This produces a version like `unstable-a1b2c3d` for committed builds, and
`unstable-dirty` for uncommitted/dirty working trees. See
`references/advanced/version-from-git.md` for the full
rationale, the `self.shortRev` / `self.dirtyRev` / `self.lastModifiedDate`
flake attributes, and when to use vs. avoid this pattern.

**CMake's `git describe` and Nix's `self.shortRev` are complementary:**
- CMake reads git tags at build time to embed a version string into the binary
  (the binary's internal `--version` output).
- Nix's `self.shortRev` sets the package `version` attribute (Nix package
  metadata, what `nix run` / `nix profile list` shows).

Both track the git commit, so they stay in sync. Do not try to make Nix read
the CMake-derived version — that would require running CMake's configure step
during Nix evaluation, which is not possible.

## Template

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
        <pname> = pkgs.stdenv.mkDerivation {
          pname = "<binary-name>";
          # Derive version from the flake's git revision instead of
          # hardcoding a stale number. C/C++ projects have no language
          # manifest (Cargo.toml, package.json) to read the version from,
          # and CMake projects commonly use `git describe` at build time —
          # so the Nix version should track the git revision too.
          # See references/advanced/version-from-git.md.
          version = "unstable-${self.shortRev or "dirty"}";
          # cleanSource filters build artifacts, .git, .devbox, etc., so
          # trivial local changes do not invalidate the Nix build cache.
          src = pkgs.lib.cleanSource ./.;
          nativeBuildInputs = [
            pkgs.cmake
            pkgs.ninja
            pkgs.pkg-config
          ];
          buildInputs =
            [
              # Common C++ dependencies — replace with the project's actual
              # deps. Inspect CMakeLists.txt find_package() calls.
              pkgs.openssl
              pkgs.pugixml
              # Qt example (uncomment if the project uses Qt):
              # pkgs.qt6.qtbase
            ]
            ++ pkgs.lib.optionals pkgs.stdenv.isDarwin [
              # macOS frameworks the project links against. Inspect
              # CMakeLists.txt for find_library() / target_link_libraries()
              # calls referencing macOS frameworks.
              pkgs.darwin.apple_sdk.frameworks.Cocoa
              pkgs.darwin.apple_sdk.frameworks.Security
              pkgs.darwin.apple_sdk.frameworks.SystemConfiguration
            ];
          cmakeFlags = [
            # Common options — adjust per project. Skip the prefix
            # (Nix sets it). Disable tests if they need host paths or
            # network (see doCheck below).
            "-DCMAKE_BUILD_TYPE=Release"
            # Pass the git revision to CMake so the binary's embedded
            # version string matches the Nix package version. This
            # complements (does not replace) CMake's `git describe` —
            # the Nix sandbox has no .git, so CMake's `git describe`
            # fallback would produce a garbage version without this.
            "-DGIT_REV=${self.shortRev or "dirty"}"
            # Disable tests in the Nix build if they require host paths,
            # network, or behavior unavailable in the sandbox.
            "-DBUILD_TESTING=OFF"
          ];
          # If the project's tests pass in the Nix sandbox, set
          # BUILD_TESTING=ON above and doCheck = true here. Common
          # reasons tests fail in the sandbox: tests modify HOME or
          # TMPDIR, spawn subprocesses needing host tools, need network
          # access, or depend on absolute paths from the dev environment.
          doCheck = false;
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
          nativeBuildInputs = [ pkgs.cmake pkgs.ninja pkgs.pkg-config ];
          buildInputs =
            [ pkgs.openssl pkgs.pugixml ]
            ++ pkgs.lib.optionals pkgs.stdenv.isDarwin [
              pkgs.darwin.apple_sdk.frameworks.Cocoa
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

C/C++ projects usually only need build tools, so `mkShell` is the default. If the project needs managed services (databases, Redis, etc.) or devcontainer parity, see `references/advanced/devenv-vs-mkshell.md` — Devenv vs mkShell.

**Platform scope narrowing**: When Step 4a's `detect-platform-scope.sh` reports
`platform_scope=darwin_only` or `linux_only`, replace
`flake-utils.lib.eachDefaultSystem` with `flake-utils.lib.eachSystem target_platforms`
where `target_platforms` is the JSON array from Step 4a converted to a Nix list.
See `references/architecture-analysis.md` — Inherent Platform Scope.

## Darwin considerations (macOS)

C++ projects on macOS often need extra care:

- **macOS SDK frameworks**: Add the frameworks the project links against to
  `buildInputs` under a `pkgs.stdenv.isDarwin` conditional. Inspect
  `CMakeLists.txt` for `find_library()` or `target_link_libraries()` calls
  referencing macOS frameworks (`Cocoa`, `Foundation`, `Security`,
  `SystemConfiguration`, `CoreFoundation`, etc.). Map each to
  `pkgs.darwin.apple_sdk.frameworks.<Name>`.
- **`macdeployqt`**: If the project produces a Qt `.app` bundle, the CMake
  build may call `macdeployqt` to fix up framework paths. Add `pkgs.qt6.qttools`
  (which provides `macdeployqt`) to `nativeBuildInputs` on Darwin:
  ```nix
  ++ pkgs.lib.optionals pkgs.stdenv.isDarwin [
    pkgs.qt6.qttools
  ];
  ```
- **x86_64-darwin legacy pin**: The `nixpkgs-darwin-legacy` input (already in
  the template above) ensures builds work on Intel Macs. See
  `references/flake-templates/darwin-legacy-pin.md` for the rationale and EOL
  timeline. Skip only if the project explicitly targets `aarch64-darwin` only.

## Common CMake flags

| Flag | Purpose |
|------|---------|
| `-DCMAKE_BUILD_TYPE=Release` | Optimized build (default in the template) |
| `-DBUILD_TESTING=OFF` | Disable tests (sandbox incompatibility) |
| `-DBUILD_SHARED_LIBS=ON` | Build shared libraries instead of static |
| `-DCMAKE_INSTALL_PREFIX=...` | Skip — Nix sets this automatically |

Do NOT set `CMAKE_INSTALL_PREFIX` — Nix sets it to the output path. Setting
it manually breaks the install layout.

## Disabling tests (`doCheck = false` / `BUILD_TESTING=OFF`)

Set `BUILD_TESTING=OFF` (and `doCheck = false`) when the project's test suite
does not work in the Nix sandbox. Common reasons:

- Tests modify `HOME`, `TMPDIR`, or `XDG_CONFIG_HOME` (sandbox restricts these)
- Tests spawn subprocesses that need specific host tools
- Tests require network access (denied in the sandbox)
- Tests depend on absolute paths from the development environment

The template ships with `BUILD_TESTING=OFF` by default. If the project's tests
are sandbox-compatible, set `BUILD_TESTING=ON` and `doCheck = true`. When in
doubt, start with tests off and let the project's own CI handle test validation
— the Nix CI workflow (`nix.yml`) validates the **build**, not the test suite.
