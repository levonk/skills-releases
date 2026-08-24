# Source Build Flake: Tauri (Rust + JS frontend + optional Bun sidecar)

Use when the project does not have published binary releases and is a Tauri 2.x
desktop app — a Rust backend compiled with the Tauri CLI, plus a JS frontend
(Svelte, React, Vue, etc.) built with a JS package manager (pnpm/npm/yarn), and
optionally a Bun-compiled sidecar. These projects combine multiple toolchains in
a specific build order and exceed the single-language templates
(`source-build/rust.md`, `source-build/node-complex.md`, `source-build/bun.md`).

## Key challenge: multi-toolchain build orchestration

A Tauri app build has 3-4 phases that must run in order:

1. **Build SDK / shared packages** (if the project has a workspace with shared
   packages consumed by the frontend — e.g. `<workspace-sdk-package>`)
2. **Build Bun sidecar** (if the project has a Bun-compiled sidecar staged by
   `build.rs` into `resources/` — e.g. `<ext-builder-dir>/dist/sidecar.js`)
3. **Build frontend** (`vite build` / `svelte-kit build` via the JS package
   manager — produces `frontendDist` directory configured in `tauri.conf.json`)
4. **Build Rust + bundle** (`cargo build` via the Tauri CLI — `build.rs` stages
   the frontend dist, sidecar, and other resources into the binary bundle)

The Nix derivation must reproduce this order. `cargo-tauri.hook` (available in
nixpkgs 24.11+) handles the Tauri bundling, but the frontend and sidecar must
be built in `preBuild` before the hook runs `cargo build`.

## Key challenge: git cargo dependencies

Tauri projects often have git cargo dependencies (e.g. `tauri-nspanel`,
`monitor` from `ahkohd/tauri-toolkit`). These need explicit hashes in
`cargoLock.outputHashes` — set a fake hash, run `nix build`, copy the correct
hash from the error output, replace, rebuild. See the Troubleshooting table in
INSTRUCTIONS.md for the exact procedure.

## Key challenge: code signing + updater artifacts

`tauri.conf.json` may have `"createUpdaterArtifacts": true` and signing identity
configured. Nix builds cannot sign (no keychain) and should not produce updater
artifacts (no signing keys). Disable both via a config override in `prePatch` or
`preBuild`. The `--local` build flag in some projects does this already — check
`scripts/build.mjs` for the pattern.

## Template

```nix
{
  description = "<Project description>";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    # Pin x86_64-darwin to a stable release branch for older macOS Intel
    # compatibility. See references/flake-templates/darwin-legacy-pin.md.
    nixpkgs-darwin-legacy.url = "github:NixOS/nixpkgs/nixpkgs-24.05-darwin";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, nixpkgs-darwin-legacy, flake-utils, ... }@inputs:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs =
          if system == "x86_64-darwin"
          then nixpkgs-darwin-legacy.legacyPackages.${system}
          else nixpkgs.legacyPackages.${system};

        # ── Frontend deps (pnpm workspace-aware) ──────────────────────────
        # Use pnpm.fetchDeps with pnpmWorkspaces for monorepo support.
        # For npm, use fetchNpmDeps instead. For yarn, use fetchYarnDeps.
        # The hash is discovered by setting a fake hash, running nix build,
        # and copying the correct hash from the error output.
        frontendDeps = pkgs.pnpm.fetchDeps {
          pname = "<binary-name>-frontend";
          version = "<x.y.z>";
          src = pkgs.lib.cleanSource ./.;
          # List all workspace packages that have their own package.json
          pnpmWorkspaces = [ "<workspace-package-1>" "<workspace-package-2>" ];
          hash = "sha256-AAAA..."; # REPLACE after first build attempt
        };

        # ── Bun sidecar deps (if the project has a Bun sidecar) ───────────
        # Only include if Step 5's detect-multi-toolchain.sh reported bun
        # in the toolchains array AND the subagent confirmed bun is a hard
        # requirement. If bun is not needed, remove this block entirely.
        # bunSidecarDeps = pkgs.bun.fetchDeps {
        #   pname = "<binary-name>-sidecar";
        #   version = "<x.y.z>";
        #   src = pkgs.lib.cleanSource ./<ext-builder-dir>;
        #   hash = "sha256-AAAA..."; # REPLACE after first build attempt
        # };

        <pname> = pkgs.rustPlatform.buildRustPackage (finalAttrs: {
          pname = "<binary-name>";
          version = "<x.y.z>";
          # cleanSource filters build artifacts, .git, .devbox, etc., so
          # trivial local changes do not invalidate the Nix build cache.
          src = pkgs.lib.cleanSource ./.;

          # cargoLock with outputHashes for git dependencies.
          # Discover each hash: set "sha256-AAA..." (fake), run nix build,
          # copy the correct hash from the error output, replace, rebuild.
          cargoLock = {
            lockFile = ./<src-tauri-dir>/Cargo.lock;
            outputHashes = {
              "tauri-nspanel" = "sha256-AAAA..."; # REPLACE
              "monitor" = "sha256-AAAA..."; # REPLACE
              # Add one entry per git cargo dependency
            };
          };

          # ── Tauri CLI + frontend toolchain ──────────────────────────────
          nativeBuildInputs = with pkgs; [
            cargo-tauri.hook
            nodejs_20        # or nodejs_22 — match the project's engines.node
            pnpm             # or npm/yarn — match detect-package-manager.sh output
            pkg-config
            makeWrapper
          ]
          # Add bun only if the project requires it for sidecar building
          ++ pkgs.lib.optionals (true /* set to false if no bun sidecar */) [
            pkgs.bun
          ];

          # ── Platform system libraries ───────────────────────────────────
          buildInputs =
            # Linux: Tauri needs WebKitGTK 4.1 + GTK3 + platform libs
            (pkgs.lib.optionals pkgs.stdenv.isLinux (with pkgs; [
              webkitgtk_4_1
              gtk3
              glib-networking
              libayatana-appindicator
              librsvg
              xdg-utils
              openssl
            ]))
            # macOS: frameworks via apple_sdk (objc2/AppKit/CoreFoundation
            # are pulled in by cargo automatically; these are for linking)
            ++ pkgs.lib.optionals pkgs.stdenv.isDarwin (with pkgs; [
              libiconv
              darwin.apple_sdk.frameworks.Security
              darwin.apple_sdk.frameworks.SystemConfiguration
              darwin.apple_sdk.frameworks.AppKit
              darwin.apple_sdk.frameworks.CoreFoundation
              darwin.apple_sdk.frameworks.Cocoa
            ]);

          # ── Disable code signing + updater artifacts ────────────────────
          # tauri.conf.json may have createUpdaterArtifacts: true and a
          # signing identity. Nix builds cannot sign and should not produce
          # updater artifacts. Override via a config patch.
          prePatch = ''
            # Disable updater artifacts for Nix builds (no signing keys)
            substituteInPlace <src-tauri-dir>/tauri.conf.json \
              --replace '"createUpdaterArtifacts": true' '"createUpdaterArtifacts": false'
          '';

          # ── Build frontend + sidecar before cargo build ─────────────────
          # cargo-tauri.hook runs `cargo build` which triggers build.rs.
          # build.rs may stage resources from sibling directories (frontend
          # dist, sidecar JS, capability specs). Build them first.
          preBuild = ''
            # Set HOME to sandbox temp — prevents postinstall scripts from
            # writing to ~/.<project>/ (keytar, node-gyp, etc.)
            export HOME=$TMPDIR

            # 1. Install frontend deps from prefetched cache, offline
            export npm_config_cache=${frontendDeps}
            export npm_config_offline=true
            pnpm install --frozen-lockfile --ignore-scripts
            patchShebangs node_modules

            # 2. Build SDK / shared workspace packages (if the project has
            #    a build:all script in a shared package)
            pnpm --filter <workspace-package-1> run build:all || true

            # 3. Build Bun sidecar (if the project requires bun)
            #    Only include if detect-multi-toolchain.sh detected bun AND
            #    the subagent confirmed it is a hard requirement.
            # (cd <ext-builder-dir> && bun install && bun run build:js)

            # 4. Build frontend (vite build / svelte-kit build)
            #    The prebuild script may run code generators (gen:all) first.
            pnpm --filter <frontend-package> run gen:all || true
            pnpm --filter <frontend-package> run build
          '';

          # ── Install the Tauri binary ────────────────────────────────────
          # cargo-tauri.hook produces the binary in target/release/.
          # The hook handles installation to $out/bin/ automatically.
          # If the hook does not install, add an explicit installPhase:
          # installPhase = ''
          #   runHook preInstall
          #   mkdir -p $out/bin
          #   cp target/release/<binary-name> $out/bin/
          #   runHook postInstall
          # '';

          # ── Tauri config ────────────────────────────────────────────────
          # Point cargo-tauri.hook at the src-tauri directory
          cargoRoot = "<src-tauri-dir>";
          buildAndTestSubdir = finalAttrs.cargoRoot;

          meta = {
            description = "<Project description>";
            homepage = "https://github.com/$UPSTREAM_OWNER/$UPSTREAM_REPO";
            license = pkgs.lib.licenses.<spdx>;
            mainProgram = "<binary-name>";
            # Tauri desktop apps need a display — not headless servers.
            # platforms is scoped to target_platforms from Step 4a.
            platforms = [
              "x86_64-linux" "aarch64-linux"
              "x86_64-darwin" "aarch64-darwin"
            ];
          };
        });
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
          nativeBuildInputs = with pkgs; [
            pkg-config
            cargo-tauri.hook
            rustc
            cargo
            clippy
            rustfmt
            nodejs_20
            pnpm
          ]
          ++ pkgs.lib.optionals (true /* set to false if no bun */) [ bun ];

          buildInputs =
            (pkgs.lib.optionals pkgs.stdenv.isLinux (with pkgs; [
              webkitgtk_4_1
              gtk3
              glib-networking
              libayatana-appindicator
              librsvg
              openssl
            ]))
            ++ pkgs.lib.optionals pkgs.stdenv.isDarwin (with pkgs; [
              libiconv
              darwin.apple_sdk.frameworks.Security
              darwin.apple_sdk.frameworks.SystemConfiguration
              darwin.apple_sdk.frameworks.AppKit
              darwin.apple_sdk.frameworks.CoreFoundation
              darwin.apple_sdk.frameworks.Cocoa
            ])
            # Add runtime service deps detected by:
            #   scripts/detect-runtime-deps.sh <project-dir>
            ++ [ <runtime-deps> ];
        };
      }
    );
}
```

## Platform scope narrowing

When Step 4a's `detect-platform-scope.sh` reports `platform_scope=darwin_only`
or `linux_only`, replace `flake-utils.lib.eachDefaultSystem` with
`flake-utils.lib.eachSystem target_platforms` where `target_platforms` is the
JSON array from Step 4a converted to a Nix list. Also update `meta.platforms`
to match. See `references/flake-templates/source-build/rust.md` — Platform
scope narrowing for the example.

## Build order discovery (MANDATORY subagent validation)

Before filling in the template, the subagent validation from Step 5 must have
confirmed:

1. **Exact build order** — read `scripts/build.mjs` (or equivalent) and list
   the phases in order. The `preBuild` section must reproduce this order.
2. **Bun requirement** — is bun a hard requirement (build script exits if bun
   is missing) or optional? If optional, remove the bun blocks. If required,
   uncomment the bun sidecar deps and bun install/build lines.
3. **Frontend build command** — is it `vite build`, `svelte-kit build`,
   `next build`, or something else? The `preBuild` must run the correct command.
4. **Code generators** — does `prebuild` run code generators (`gen:all`,
   `svelte-kit sync`)? These must run before the frontend build in `preBuild`.
5. **Git cargo dep hashes** — list each git dependency and its repo URL so the
   agent can discover the `outputHashes` via the fake-hash → build → copy-hash
   → rebuild cycle.

## FOD hash discovery

The `frontendDeps` hash and `bunSidecarDeps` hash (if present) are
fixed-output derivation hashes. Discover each:

1. Set `hash = "sha256-AAAA..."` (fake)
2. Run `nix build .#<pname>`
3. The build fails with a hash mismatch error showing the correct hash
4. Copy the correct hash from the error output
5. Replace the fake hash in `flake.nix`
6. Rebuild — the FOD now passes

For `cargoLock.outputHashes`, the same cycle applies per git dependency.

## Toolchain version pinning

The Node, pnpm, and Rust versions must match the project's CI and `engines`
declarations:

- **Node**: if `package.json#engines.node` declares `>=20`, use `nodejs_20`.
  If `>=22`, use `nodejs_22`. Match the major version.
- **pnpm**: if `package.json#packageManager` declares `pnpm@10.26.0`, pin pnpm
  to that version or use the nixpkgs pnpm that matches the major.
- **Rust**: if `rust-toolchain.toml` declares `channel = "1.97.0"`, the nixpkgs
  rustc must be >= 1.97. Check with `nix run nixpkgs#rustc -- --version`.
- **Bun**: if the project pins bun in `package.json` or `<ext-builder-dir>`,
  pin the nixpkgs bun to the same major.minor.

A version mismatch means the flake and CI validate against different
toolchains — the flake can pass while CI fails, or vice versa.

## Vendored crates

If `Cargo.toml` has a `[patch.crates-io]` section pointing at a `vendor/`
directory (e.g. `mac-notification-sys = { path = "vendor/mac-notification-sys" }`),
the vendored crate is part of the source tree and `cargoLock` handles it
automatically — no special Nix configuration needed. The `cleanSource` will
include the `vendor/` directory. Verify the vendored crate builds in the Nix
sandbox (it may have its own system dependencies).

## When to use this template vs source-build/rust.md

| Signal | Use |
|--------|-----|
| `tauri.conf.json` exists | **tauri.md** |
| `Cargo.toml` has `tauri` dep + no `tauri.conf.json` | rust.md (library, not app) |
| `Cargo.toml` has no `tauri` dep + JS frontend exists | node-complex.md |
| No Rust, no Tauri, just Bun | bun.md |

The `detect-multi-toolchain.sh` script makes this determination
deterministically — do not pick this template by gut feel.
