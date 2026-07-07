# Architecture Analysis

## Table of Contents

- [Check for Prebuilt Release Tarballs](#check-for-prebuilt-release-tarballs)
- [Complex Distribution Requirements](#complex-distribution-requirements)
- [Success and Failure Patterns](#success-and-failure-patterns)
- [Make Build Scripts Nix-Aware](#make-build-scripts-nix-aware)
- [Ensure Lockfiles in npm Tarballs](#ensure-lockfiles-in-npm-tarballs)
- [Inspecting Existing nixpkgs Derivations](#inspecting-existing-nixpkgs-derivations)

---

## Check for Prebuilt Release Tarballs

**CRITICAL**: Before proceeding with a source build, check if the project publishes prebuilt release tarballs. This is the preferred approach as it preserves exact layout and avoids complex builds.

```bash
curl -s "https://api.github.com/repos/<owner>/<repo>/releases/latest" | jq -r '.assets[].name'
curl -s "https://api.github.com/repos/<owner>/<repo>/releases" | jq -r '.[].assets[].name' | grep -E "(linux|darwin|windows|musl)"
```

**If prebuilt release tarballs exist:**
- Use fetchurl approach (see `references/flake-templates.md` — Prebuilt Tarball Flake)
- Extract and preserve exact layout (bin/ + runtime/ as siblings)
- Add explicit SHA256 hashes for each platform's tarball

**If no prebuilt tarballs exist:**
- Fall back to build from source or defer as tracked follow-up

**CRITICAL — prebuilt is MANDATORY, not just "preferred", when the binary resolves runtime assets beside itself.** Even if the project *also* builds cleanly from source, a from-source flake is broken (not merely suboptimal) when any of these hold:
- The binary walks up from `current_exe()` to find a sibling `runtime/`, `assets/`, or `resources/` directory (e.g. nub resolves `runtime/preload.mjs` beside its binary).
- The release tarball carries a vendored `node_modules/`, a N-API addon (`.node`), or other native artifacts produced by a separate build step the flake does not reproduce.
- A bare `cargo build` / `go build` / `npm run build` produces a binary that passes `--version` but fails real workloads because the runtime tree is absent.

A from-source `buildRustPackage` for such a project produces a binary that passes `nix run . -- --version` in CI but is non-functional for real use. Prefer the prebuilt tarball even when source builds are possible. (Reference: nubjs/nub#169 — prebuilt chosen precisely because from-source omits the vendored `runtime/` tree.)

---

## Complex Distribution Requirements

Only if no prebuilt tarballs exist (AND the project does not ship runtime assets beside the binary — see the CRITICAL rule above), analyze the project's architecture to determine if a simple flake.nix is sufficient or if complex packaging is required.

**Check for multi-component distribution:**

```bash
find . -type d -name "runtime" -o -name "assets" -o -name "resources" 2>/dev/null | head -10
find . -name "*.node" -o -name "*.so" -o -name "*.dylib" -o -name "*.dll" 2>/dev/null | head -10
grep -r "exclude" Cargo.toml package.json 2>/dev/null | head -10
find . -name "Makefile" -o -name "*.sh" -o -name "build.js" -o -name "packaging*" 2>/dev/null | head -10
grep -r "postinstall" package.json 2>/dev/null | head -5
```

**Key architectural patterns that require complex packaging:**

1. **Runtime asset dependencies**: Binary expects sibling directories (e.g., `runtime/`, `assets/`) to function
2. **Native addons**: Separate compiled libraries (N-API addons, .node files) built independently
3. **Workspace exclusions**: Components deliberately excluded from main build but required for functionality
4. **Multi-stage builds**: Separate build processes for different components
5. **Asset copying scripts**: Build processes that copy files to specific locations
6. **Postinstall hooks**: Installation scripts that set up runtime environment

**Decision tree:**

- **If prebuilt tarballs exist AND the binary resolves runtime assets beside itself** (vendored `runtime/`, `node_modules`, N-API `.node`, etc.): Use fetchurl approach — MANDATORY. A from-source flake is broken for this class of project, not merely suboptimal.
- **If prebuilt tarballs exist AND the binary is self-contained**: Use fetchurl approach (PREFERRED).
- **If no prebuilt tarballs AND simple single-binary project**: Continue with standard flake.nix approach.
- **If complex multi-component distribution with no prebuilt tarballs**:
  - STOP and document the architectural requirements
  - Do NOT create a minimal flake that produces non-functional software
  - Either implement full multi-component packaging OR defer as tracked follow-up
  - If deferring, still create issue but mark as requiring complex packaging work

**Why this matters:**
- A flake that builds only the binary but omits required assets produces non-functional software
- `nix flake check` validates derivation structure, not runtime behavior
- Users will install a broken tool if the README advertises a non-functional installation method

---

## Success and Failure Patterns

**Example success pattern (from nubjs/nub#169):**
- Project publishes prebuilt per-platform tarballs on GitHub releases
- Flake uses fetchurl to download tarball with explicit SHA256 hash
- Extracts bin/ + runtime/ preserving exact layout
- Linux binaries use autoPatchelfHook to fix glibc linking
- No wrapper scripts — binary is real file with runtime/ as sibling
- Result: Fully functional tool with all runtime assets

**Example failure pattern (from nubjs/nub#168):**
- Project has `runtime/` directory with preload scripts
- Native addon (`nub-native.node`) built separately from main workspace
- Binary walks up from its location looking for sibling `runtime/` directory
- Simple flake builds only binary -> installed tool cannot transpile TypeScript
- Core functionality silently disabled due to missing assets

---

## Make Build Scripts Nix-Aware

For projects with custom build scripts (e.g., `build.rs` in Rust, custom Makefiles), make them support environment variable overrides for toolchain paths.

**Check for custom build scripts:**
- Rust: `build.rs` in project root
- Python: `setup.py`, `pyproject.toml` with custom build backend
- Go: `Makefile` or build scripts
- Node: Custom build scripts in `scripts/` or root

**Example for Rust build.rs:**

```rust
let zig = env::var("ZIG").unwrap_or_else(|_| "zig".into());
let mut command = Command::new(zig);

if let Ok(system_dir) = env::var("LIBGHOSTTY_VT_ZIG_SYSTEM_DIR") {
    command.arg("--system").arg(system_dir);
}

println!("cargo:rerun-if-changed=vendor/libghostty-vt/include");
println!("cargo:rerun-if-changed=vendor/libghostty-vt/pkg");
println!("cargo:rerun-if-changed=vendor/libghostty-vt/src");
```

**Key patterns:**
- Use `env::var()` to allow environment variable overrides for tool paths
- Add directory-level `cargo:rerun-if-changed` for vendored dependencies
- Support system directory paths for cross-compilation

**Skip this step if:**
- The project uses standard build tools without custom build scripts
- The build system already supports environment variable overrides

---

## Ensure Lockfiles in npm Tarballs

If the project is a Node.js package published to npm and you intend to package it with Nix's `buildNpmPackage`, ensure a lockfile is present in the published tarball.

**The problem:**
- `package-lock.json` is excluded from npm tarballs by default
- Nix's `buildNpmPackage` requires a lockfile to compute `npmDepsHash`

**The fix:**

Add `npm shrinkwrap` to the `prepublishOnly` hook in `package.json`:

```diff
- "prepublishOnly": "npm run clean && npm run build"
+ "prepublishOnly": "npm run clean && npm run build && npm shrinkwrap"
```

Unlike `package-lock.json`, `npm-shrinkwrap.json` is included in npm tarballs by default.

**Verification:**

```bash
npm pack --dry-run 2>&1 | grep shrinkwrap
```

**Workspace caveat:**
If the project uses npm workspaces, `npm shrinkwrap` cannot be run from within a workspace package. It must be run from the workspace root. For workspace packages published individually, consider building from git (`src = ./.`) where `package-lock.json` is already present.

**Skip this step if:**
- The project is not a Node.js package published to npm
- You are building from a git checkout (where `package-lock.json` exists)

---

## Inspecting Existing nixpkgs Derivations

Before writing `flake.nix` from scratch, check whether the project (or a close analog) is already packaged in nixpkgs. The existing derivation is a battle-tested reference for what it takes to deploy the project — dependencies, patches, postInstall setup, wrapper scripts, and runtime fixes that aren't obvious from the project's own build instructions. Skipping this is the most common cause of "builds but doesn't work" flakes.

**How to inspect**: Run `scripts/inspect-nixpkgs-derivation.sh <package-name>`. The script uses `nix eval nixpkgs#<pkg>.meta.position` to locate the derivation source file, fetches it from GitHub, and also resolves the dependency lists (`buildInputs`, `nativeBuildInputs`, `propagatedBuildInputs`, `runtimeDependencies`). Read the full derivation source — the dependency lists are a convenience summary, but the source file is where patches, hooks, and wrapper logic live.

**Checklist — catalog every one of these from the nixpkgs derivation and cross-check against your planned flake.nix:**

1. **`buildInputs`** — libraries and runtime dependencies the binary links against. Missing one produces a binary that crashes on startup or at first use.
2. **`nativeBuildInputs`** — build-time tools (pkg-config, cmake, autoPatchelfHook, makeWrapper). Missing one causes the build to fail or produce an unpatched binary.
3. **`propagatedBuildInputs`** — dependencies that consumers of this package also need. If your flake exposes a library or SDK, these must be propagated.
4. **`runtimeDependencies`** — packages that must be on `PATH` at runtime but aren't linked libraries (e.g. a CLI that shells out to `git` or `curl`). Missing these produces "command not found" errors during real use.
5. **`patches`** — source patches nixpkgs applies. These fix Nix-specific issues (hardcoded `/usr` paths, FHS assumptions) or upstream bugs. If nixpkgs patches the source, your from-source flake likely needs the same patches.
6. **`postInstall` / `preInstall` hooks** — install-time setup: wrapping binaries with `makeWrapper`, setting `GSETTINGS_SCHEMAS_DIR`, installing desktop entries, icons, man pages, or completion scripts. These are the most commonly missed items.
7. **`makeWrapper` args** — `--prefix PATH : ${pkgs.something}/bin`, `--set GSETTINGS_SCHEMA_DIR ...`, `--set-default ...`. These set up the runtime environment the binary expects. A bare `installPhase` that copies the binary without wrapping will produce a tool that can't find its helpers.
8. **`configureFlags` / `cmakeFlags` / `cargoBuildFlags` / `buildFlags`** — build-time feature toggles. nixpkgs may disable default features or enable ones the project's defaults don't.
9. **`dontConfigure` / `dontBuild` / `dontUnpack`** — flags that skip standard phases. If nixpkgs sets these, there's a reason (usually the build system conflicts with stdenv's defaults).
10. **`meta.platforms`** — which platforms nixpkgs builds for. If nixpkgs only supports `x86_64-linux`, trying to build on `aarch64-darwin` may fail for reasons nixpkgs already discovered.
11. **`passthru`** — optional outputs, update scripts, or tests. `passthru.updateScript` shows how nixpkgs auto-updates the version (useful for designing your own hash-bump workflow).
12. **Overlay / `callPackage` patterns** — if the derivation uses `callPackage` with overridden dependencies, those overrides may be required for the build to succeed (e.g. a pinned Rust toolchain, a patched LLVM).

**When the project isn't in nixpkgs but a similar project is:**

Run the script with the analog's name. For example, if packaging a new Chromium-based browser, inspect `brave`'s derivation — it shows the Chromium sandbox setup, the wrapper script for the sandbox helper, the `--no-sandbox` flag handling, and the icon/desktop-entry installation that all Chromium-based browsers need. Extract the patterns that apply to your project.

**Example — `brave` (nixpkgs#brave):**

The `brave` derivation in nixpkgs wraps the binary with `makeWrapper` to set up `LD_LIBRARY_DIR` for the sandbox, installs desktop entries and icons via `postInstall`, and depends on `nss`, `nspr`, `atk`, `at-spi2-atk`, `cups`, `dbus`, `expat`, `libdrm`, `mesa`, `xorg` libraries — none of which are obvious from brave-browser's own build instructions. A from-source flake that omits these produces a browser that launches but can't render pages or access the network. This is exactly the class of failure Step 11 prevents.

**Decision after inspection:**

- If the nixpkgs derivation is simple (few inputs, no patches, no postInstall) — your flake can follow the same pattern with confidence.
- If the nixpkgs derivation has patches, wrapper scripts, or many runtime deps — either replicate them in your flake, or prefer the `nixpkgs_wrapper` approach (Step 12 — `flake_type=nixpkgs_wrapper`) and let nixpkgs handle the complexity.
- If the nixpkgs derivation uses `fetchurl` on a prebuilt binary — confirms the Prebuilt Tarball Flake path (Step 12 — `flake_type=prebuilt_tarball`) and shows you the exact `buildInputs` and `installPhase` layout to replicate.
