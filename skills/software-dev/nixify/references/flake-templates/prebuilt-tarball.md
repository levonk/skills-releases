# Prebuilt Tarball Flake

Use when the project publishes prebuilt release tarballs. Preserves exact layout and avoids complex builds. Exposes prebuilt as `#default` and from-source as `#source` so users get the fast path by default and the reproducible-from-source path on demand.

```nix
{
  description = "<project description>";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs = { self, nixpkgs }: let
    version = "<version>";

    assets = {
      "x86_64-linux" = {
        file = "<project>-linux-x64.tar.gz";
        sha256 = "<sha256>";
      };
      "aarch64-linux" = {
        file = "<project>-linux-arm64.tar.gz";
        sha256 = "<sha256>";
      };
      "x86_64-darwin" = {
        file = "<project>-darwin-x64.tar.gz";
        sha256 = "<sha256>";
      };
      "aarch64-darwin" = {
        file = "<project>-darwin-arm64.tar.gz";
        sha256 = "<sha256>";
      };
    };

    systems = builtins.attrNames assets;
    forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f system);

    # Prebuilt binary from release tarball
    projectFor = system: let
      pkgs = nixpkgs.legacyPackages.${system};
      asset = assets.${system};
    in pkgs.stdenv.mkDerivation {
      pname = "<project-name>";
      inherit version;

      src = pkgs.fetchurl {
        url = "https://github.com/<owner>/<repo>/releases/download/v${version}/${asset.file}";
        sha256 = asset.sha256;
      };

      sourceRoot = ".";

      nativeBuildInputs = pkgs.lib.optionals pkgs.stdenv.isLinux [ pkgs.autoPatchelfHook ];
      buildInputs = pkgs.lib.optionals pkgs.stdenv.isLinux [ pkgs.stdenv.cc.cc.lib ];

      dontConfigure = true;
      dontBuild = true;

      installPhase = ''
        runHook preInstall
        mkdir -p "$out"
        cp -r bin "$out/bin"
        cp -r runtime "$out/runtime"
        chmod +x "$out/bin/<binary-name>"
        runHook postInstall
      '';

      meta = with pkgs.lib; {
        description = "<project description>";
        homepage = "https://github.com/<owner>/<repo>";
        downloadPage = "https://github.com/<owner>/<repo>/releases";
        license = licenses.<license>;
        mainProgram = "<binary-name>";
        platforms = systems;
        sourceProvenance = [ sourceTypes.binaryNativeCode ];
      };
    };

    # From-source build — fill in using the appropriate language-specific
    # template from references/flake-templates/source-build-*.md (Rust, Bun,
    # Node, Go, Python). The source build gives users a reproducible-from-source
    # path via `nix run .#source` / `nix build .#source` alongside the prebuilt
    # default. If the project cannot be built from source in Nix (e.g. complex
    # native addon setup with no nixpkgs support), remove the `source` outputs
    # from packages/apps below and document why in the PR body.
    sourceFor = system: let
      pkgs = nixpkgs.legacyPackages.${system};
    in
      # === REPLACE THIS BLOCK with the language-specific source build ===
      # Example for Bun (see references/flake-templates/source-build-bun.md):
      #   pkgs.stdenv.mkDerivation { ... bun build --compile ... }
      # Example for Rust (see references/flake-templates/source-build-rust.md):
      #   pkgs.rustPlatform.buildRustPackage { ... }
      # Example for Go (see references/flake-templates/source-build-go.md):
      #   pkgs.buildGoModule { ... }
      throw "sourceFor not implemented — fill in from source-build-<lang>.md";
  in {
    packages = forAllSystems (system: rec {
      <project> = projectFor system;
      default = <project>;
      source = sourceFor system;
    });

    apps = forAllSystems (system: let
      # WARNING: do NOT replace this `let` binding with `rec` referencing the
      # `packages` attrset above. A `rec { default = { program = "${<project>}/bin/..."; }; }`
      # that names the binding `<project>` shadows the `let`-bound derivation, so
      # `${<project>}` interpolates the app attrset (a set, not a store path) and
      # throws "cannot coerce a set to a string" at `nix run` / `nix flake check`.
      # The separate `let <project>Pkg = projectFor system;` binding keeps the
      # derivation in scope as a store path. (Reference: nubjs/nub#169 fix commit.)
      <project>Pkg = projectFor system;
      sourcePkg = sourceFor system;
    in {
      <project> = {
        type = "app";
        program = "${<project>Pkg}/bin/<binary-name>";
      };
      default = {
        type = "app";
        program = "${<project>Pkg}/bin/<binary-name>";
      };
      source = {
        type = "app";
        program = "${sourcePkg}/bin/<binary-name>";
      };
    });

    checks = forAllSystems (system: {
      # CI exercises both the prebuilt and source outputs
      prebuilt = projectFor system;
      source = sourceFor system;
    });
  };
}
```

Key details:
- Explicit SHA256 hashes per platform for reproducibility
- Preserves exact layout (bin/ + runtime/ as-is from tarball)
- Uses `autoPatchelfHook` for Linux glibc linking
- No wrapper scripts — binary is real file with runtime/ as sibling
- Uses `nixpkgs-unstable` for broader platform support
- **Target set is the 4 glibc+darwin systems** (`x86_64`/`aarch64` × `linux`/`darwin`). Exclude win32 (not a Nix target) and musl tarballs (the glibc tarballs already cover Linux Nix systems). See `references/flake-templates/darwin-framework-note.md` for darwin-specific caveats.
- **`#source` output**: The prebuilt binary is `#default` (fast, no compilation). The from-source build is `#source` (reproducible from source, auditable). Fill in `sourceFor` using the appropriate language-specific template from `references/flake-templates/source-build-*.md`. The `checks` attrset exercises both so CI catches breakage in either path.
- **If source build is not feasible** (e.g. complex native addon setup with no nixpkgs support), remove the `source` outputs from `packages`, `apps`, and `checks`, and document why in the PR body. The prebuilt-only flake is still acceptable when accompanied by hash automation + CI.
