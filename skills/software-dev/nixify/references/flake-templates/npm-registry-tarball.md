# npm Registry Tarball Flake

Use when the project is published to npm **and** the published tarball ships
compiled output (`dist/`, bundled `daemon/`/`ui/` trees, etc.) — so the flake
can wrap the artifact the maintainer already publishes instead of replicating
the project's build pipeline in a Nix derivation.

This is the third packaging source, sitting between the prebuilt GitHub
release tarball (preferred when binary assets exist — Step 4b) and a
from-source build. It exists because some projects' source builds require
reproducing an entire staging pipeline (monorepo workspace ordering, asset
copying, codegen, `node-gyp` native compiles) inside the derivation — the
registry tarball skips all of that because `dist/` is already built and
native deps arrive as N-API prebuilds. (Reference: mvschwarz/openrig#1089 —
field notes from a NixOS deployment packaging the published `@openrig/cli`
tarball: "Either works. The tarball route is much less to maintain.")

## When to use

All of the following must hold (detected by
`scripts/check-npm-registry.sh` at Step 5 — store the JSON output):

- **Published to npm** — `is_published=true` (`npm view <name> version`
  succeeds; `private: true` packages are not published).
- **Tarball ships the compiled artifact** — `bin_targets_exist=true`: every
  `bin` entry in `package.json` resolves to a file inside the published
  tarball. If the tarball only ships `src/` and the `bin`/`main` targets are
  build outputs that don't exist in it, this route cannot work — use a
  source build.
- **Nothing compiles in the Nix sandbox** — native deps ship prebuilt
  binaries inside their npm packages (N-API prebuilds, e.g. `better-sqlite3`
  >= 13 bundles `prebuilds/`), or there are no native deps at all. If a dep
  falls back to `node-gyp` compilation or a `prebuild-install` network fetch
  at install time, the sandboxed build fails — check `native_deps` from the
  script output and verify each one ships in-tarball prebuilds before
  choosing this route.
- **The source build is disproportionately complex** — `is_complex=true`
  from `classify-node-complexity.sh` (monorepo staging, custom build
  orchestration, postinstall complications), OR the derivation would have to
  replicate a multi-step build script (`build-package.sh`-style) to produce
  what the tarball already contains. This is where the registry tarball wins:
  identical runtime result, far less to maintain.

## When NOT to use

- **GitHub prebuilt release binaries exist** → use `prebuilt-tarball.md`
  (the Step 4b preferred path). A platform-native binary beats a wrapped
  Node.js app for startup cost and distribution clarity.
- **`is_complex=false`** (simple single-package project) → prefer
  `source-build/node.md`. It uses the same `buildNpmPackage` builder but with
  `src = cleanSource ./.`, which gives tag-pinning
  (`nix run github:owner/repo/vX.Y.Z` builds that exact tag) and needs no
  generated lockfile. The registry route trades those away for little gain
  when the source build is already trivial.
- **`force_source_build=true`** → source build. A maintainer's explicit
  request for a source-building flake overrides this route.
- **The package is not on npm**, or the tarball omits the compiled output →
  not eligible; route to the source-build templates.
- **Tag-pinning is a stated requirement** → source build. The registry
  tarball flake pins `version` + `hash` + `npmDepsHash` in `flake.nix` and is
  bumped *after* each release — tag-pinning does NOT work (same limitation
  as `prebuilt_tarball`).

## The trade-off, stated plainly for the PR body

The registry tarball needs a generated `package-lock.json` (npm tarballs
exclude lockfiles) and an `npmDepsHash`, both regenerated on every version
bump alongside `version` and the tarball `hash`. A from-source flake avoids
that per-release maintenance and can pin by git tag, but must replicate the
project's build pipeline. For a complex build the tarball route is much less
to maintain; for a trivial build the source route is simpler. The Step 16
hash-automation workflow (Registry Tarball Variant in
`references/advanced/hash-automation.md`) makes the per-release cost zero —
it regenerates the lockfile, recomputes `npmDepsHash`, and bumps `version` +
`hash` in one PR.

## Template

```nix
{
  description = "<project description>";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    # nixpkgs-unstable dropped x86_64-darwin in 26.11 — the legacy pin is the
    # only path to a current-version install for Intel Mac users.
    # See references/flake-templates/darwin-legacy-pin.md.
    nixpkgs-darwin-legacy.url = "github:NixOS/nixpkgs/nixpkgs-26.05-darwin";
  };

  outputs = { self, nixpkgs, nixpkgs-darwin-legacy }: let
    # Set to the latest npm release at generation time (`npm view <pkg>
    # version`). Bumped by the hash automation workflow after each release —
    # a stale version serves a superseded release until the bot's first run.
    version = "<version>";

    allSystems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
    forAllSystems = f: nixpkgs.lib.genAttrs allSystems (system: f system);

    projectFor = system: let
      pkgs =
        if system == "x86_64-darwin"
        then import nixpkgs-darwin-legacy { inherit system; }
        else nixpkgs.legacyPackages.${system};
    # finalAttrs-style mkDerivation requires nixpkgs >= 24.11 — the pinned
    # nixpkgs-unstable input satisfies this; do not backport the pattern to
    # an older stable pin.
    in pkgs.buildNpmPackage (finalAttrs: {
      pname = "<project-name>";
      inherit version;

      # The published npm tarball. Get the exact URL with
      # `npm view <pkg> dist.tarball`. For scoped packages the pattern is
      # https://registry.npmjs.org/@<scope>/<name>/-/<name>-<version>.tgz
      src = pkgs.fetchurl {
        url = "https://registry.npmjs.org/<npm-name>/-/<name>-${finalAttrs.version}.tgz";
        hash = "<sha256>";  # SRI hash of the registry tarball
      };

      # Match the upstream-supported Node major(s) — check package.json
      # `engines.node` (e.g. "22 || 24" -> nodejs_22 for the lower bound).
      nodejs = pkgs.nodejs_<node-major>;

      # npm tarballs exclude lockfiles. If the tarball ships
      # npm-shrinkwrap.json, delete this postPatch (the shrinkwrap is used
      # directly). Otherwise commit the generated package-lock.json beside
      # flake.nix (see "Lockfile" below).
      postPatch = ''
        cp ${./package-lock.json} package-lock.json
      '';

      npmDepsHash = "<sha256>";

      # dist/ is prebuilt in the tarball; `npm run build` would need the
      # full monorepo/dev toolchain that isn't in the published package.
      dontNpmBuild = true;

      nativeBuildInputs = [ pkgs.makeWrapper ];

      # Wrap every installed bin with the runtime PATH tools the CLI shells
      # out to (from Step 11 derivation inspection / Step 5 subagent
      # findings — e.g. tmux, git, ssh, rsync). User-supplied harness CLIs
      # stay unwrapped on the user's own PATH.
      postFixup = ''
        for b in <bin1> <bin2>; do
          wrapProgram $out/bin/$b --suffix PATH : ${pkgs.lib.makeBinPath [ <runtime-tools> ]}
        done
      '';

      meta = with pkgs.lib; {
        description = "<project description>";
        homepage = "https://github.com/<owner>/<repo>";
        license = licenses.<license>;
        mainProgram = "<binary-name>";
        platforms = allSystems;
      };
    });
  in {
    packages = forAllSystems (system: rec {
      <project> = projectFor system;
      default = <project>;
    });

    apps = forAllSystems (system: let
      # Keep the derivation in a `let` binding — a `rec` attrset member named
      # `<project>` would shadow it and interpolate a set, not a store path.
      <project>Pkg = projectFor system;
    in {
      <project> = {
        type = "app";
        program = "${<project>Pkg}/bin/<binary-name>";
      };
      default = {
        type = "app";
        program = "${<project>Pkg}/bin/<binary-name>";
      };
    });

    checks = forAllSystems (system: { default = projectFor system; });
  };
}
```

## Lockfile

`buildNpmPackage` (via `fetchNpmDeps`) needs a lockfile, and npm tarballs
exclude `package-lock.json`. Two cases:

1. **The tarball ships `npm-shrinkwrap.json`** (rare — only if the project
   runs `npm shrinkwrap` in `prepublishOnly`): delete the `postPatch` and
   point `npmDeps` at the shrinkwrap — `prefetch-npm-deps` reads it
   directly. No generated lockfile needed.
2. **No lockfile in the tarball** (the common case): generate one inside the
   unpacked tarball and commit it next to `flake.nix`:

   ```bash
   tmp=$(mktemp -d)
   curl -sL "$(npm view <pkg> dist.tarball)" | tar xz -C "$tmp"
   (cd "$tmp/package" && npm install --package-lock-only --ignore-scripts)
   cp "$tmp/package/package-lock.json" ./package-lock.json
   ```

   Mark it as generated for reviewers — e.g. a `package-lock.nix-generated.json`
   filename or a PR-body note — so nobody mistakes it for the project's own
   lockfile. Regenerate it on every version bump (the hash automation variant
   does this automatically).

## `npmDepsHash`

Compute it with the fake-hash loop (set `npmDepsHash = pkgs.lib.fakeHash;`,
run `nix build .#default`, copy the `sha256-...` from the error) or
`nix run nixpkgs#prefetch-npm-deps -- package-lock.json`.

**Per-platform caveat**: if the lockfile carries platform-gated optional
deps (`@esbuild/linux-x64`, `optionalDependencies` with native addons), a
single `npmDepsHash` is not valid across systems — the installed
`node_modules` differs per platform. Use per-platform FOD hashes as in
`source-build/bun.md` — Per-platform FOD hashes, gated per system.

## Runtime tool wrapping

The wrapped binary must find everything the CLI shells out to at runtime.
Enumerate the `bin` entries (there may be several — a CLI plus a TUI binary)
and wrap each with the runtime tools from Step 11's nixpkgs-derivation
inspection and Step 5's subagent findings. Do NOT wrap user-supplied harness
CLIs the project expects on the user's own PATH — only tools the project
itself requires (e.g. `tmux`, `git`, `ssh`, `rsync`).

## Key details

- `dontNpmBuild = true` is load-bearing — without it `npm run build` runs in
  the sandbox and fails (the build script needs the monorepo or dev deps the
  tarball doesn't ship).
- If the upstream build stamps build info via `git rev-parse` (fails without
  `.git`), the tarball's prebuilt `dist/` sidesteps it entirely — one less
  patch vs the source build. Only patch a stamp if the tarball's output
  actually re-runs it at install time (it usually doesn't).
- Tag-pinning does NOT work — `flake.nix` pins `version` + `hash` +
  `npmDepsHash` and is bumped after each release. Document
  `nix run github:owner/repo` only; no `/vX.Y.Z` refs.
- Outputs are `#default` + `#<project-name>` only. Do not add `#prebuilt` /
  `#source` labels — a `#source` output would reintroduce the complex build
  this route exists to avoid. If a reviewer later asks for a source option,
  add it then (it becomes a maintenance trade-off discussion, not a default).
- Platform scoping still applies: `allSystems` and `meta.platforms` follow
  `target_platforms` from Step 4a. The npm tarball is platform-independent —
  coverage is limited by the **runtime tools** in `makeBinPath`, the
  `nodejs` package, and any platform-gated optional deps, not the tarball.
  `x86_64-darwin` works via the `nixpkgs-darwin-legacy` pin — do not drop it.
- **x86_64-darwin cannot come from nixpkgs itself** (channels no longer build
  it). If the project is later upstreamed (Step 28b), the nixpkgs package
  covers the other three systems and the in-repo flake remains the Intel-Mac
  path.
- This flake is a **single build definition**, so it is extraction-eligible —
  see `references/flake-templates/package-extraction.md`. The
  `buildNpmPackage` derivation maps directly onto the `package.nix` shape
  nixpkgs expects for Step 28b.
