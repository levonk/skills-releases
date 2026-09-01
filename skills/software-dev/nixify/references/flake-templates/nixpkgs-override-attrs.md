# Nixpkgs overrideAttrs Flake (Reuse Upstream Packaging)

Use when the project is already packaged in nixpkgs with complex fixup logic
(patchelf, wrapGApps, desktop-file-fixup, icon symlinks, `OutdatedBuildDetector`
disables, etc.) AND the project publishes prebuilt release binaries that nixpkgs
fetches. This template reuses nixpkgs' packaging via `overrideAttrs` — swapping
in the upstream version + per-platform SRI hashes — so the repo only maintains
`version` + 4 hashes while nixpkgs maintains the ~150 lines of fixup logic.

This is the pattern used for browsers, Electron apps, and other projects where
nixpkgs already has mature packaging but lags behind upstream releases by days
or weeks. A repo-owned flake using `overrideAttrs` lets `nix run github:...`
track upstream releases directly while inheriting all of nixpkgs' fixup work.

## When to Use

ALL of the following must be true:

1. `check-nixpkgs.sh` (Step 10) reported `project_in_nixpkgs: true`
2. `inspect-nixpkgs-derivation.sh` (Step 11) confirmed the nixpkgs derivation
   has complex fixup logic (patchelf, wrapGApps, desktop-file-fixup, icon
   symlinks, build patches, etc.) — not a trivial wrapper
3. `check-nixpkgs-superset.sh` (Step 11b) reported `is_superset: true` — the
   nixpkgs packaging is a superset of what a naive from-source flake would
   produce
4. The project publishes prebuilt release binaries (`.deb`, `.zip`, `.tar.gz`)
   that nixpkgs' derivation fetches — the `overrideAttrs` swaps the version
   and hashes to point at upstream releases instead of nixpkgs' pinned version
5. The nixpkgs version lags behind upstream (`version_current: false` from
   Step 11b) OR the maintainer wants the flake to track upstream releases
   faster than nixpkgs updates

## When NOT to Use

- The project is NOT in nixpkgs → use a source-build or prebuilt-tarball template
- The nixpkgs packaging is trivial (no patches, no hooks, no wrappers) → use
  `nixpkgs-packages.md` (wrap `pkgs.<pkg>` as-is) or a prebuilt-tarball template
- The project does not publish prebuilt release binaries → use a source-build
  template (there's nothing to `overrideAttrs` the fetchurl hashes toward)
- The nixpkgs version is current AND the maintainer is happy with nixpkgs'
  cadence → use `nixpkgs-packages.md` (wrap as-is, no version override needed)
- You need a `#source` (from-source build) output → `overrideAttrs` only wraps
  the prebuilt binary; combine with a source-build template if both are needed

## Template

```nix
{
  description = "<project description>";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    # Pin x86_64-darwin to a stable release branch for older macOS Intel
    # compatibility. The -darwin branches receive security updates without
    # the breaking churn of nixpkgs-unstable. See darwin-legacy-pin.md.
    nixpkgs-darwin-legacy.url = "github:NixOS/nixpkgs/nixpkgs-24.05-darwin";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, nixpkgs-darwin-legacy, flake-utils, ... }:
    flake-utils.lib.eachSystem [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ] (system:
      let
        pkgs =
          if system == "x86_64-darwin"
          then nixpkgs-darwin-legacy.legacyPackages.${system}
          else nixpkgs.legacyPackages.${system};

        version = "<version>";

        # Per-platform SRI hashes for the prebuilt release artifacts.
        # These are the only values the repo maintains — nixpkgs maintains
        # the ~150 lines of patchelf/wrapGApps/desktop-fixup logic via
        # pkgs.<project-name>.overrideAttrs below.
        # Keys MUST be quoted — Nix attribute names cannot contain hyphens
        # unquoted (unlike the `assets` attrset in prebuilt-tarball.md which
        # also quotes them).
        hashes = {
          "x86_64-linux" = "<sha256-x86_64-linux>";
          "aarch64-linux" = "<sha256-aarch64-linux>";
          "x86_64-darwin" = "<sha256-x86_64-darwin>";
          "aarch64-darwin" = "<sha256-aarch64-darwin>";
        };

        # Reuse nixpkgs' packaging — swap in upstream version + per-platform
        # SRI hashes. This inherits all of nixpkgs' fixup logic (patchelf,
        # wrapGApps, desktop-file-fixup, icon symlinks, etc.) without
        # vendoring ~150 lines of derivation code.
        <project-name> = pkgs.<project-name>.overrideAttrs (old: {
          inherit version;
          src = pkgs.fetchurl {
            url = "https://github.com/<owner>/<repo>/releases/download/v${version}/<asset-filename-for-${system}>";
            hash = hashes.${system};
          };
          # Disable the OutdatedBuildDetector or similar version-check logic
          # that nixpkgs' packaging may include — it compares the built
          # version against nixpkgs' pinned version and warns/fails if they
          # differ. Since we're intentionally overriding to a newer upstream
          # version, this check is a false positive.
          #
          # === REPLACE THE MARKER BELOW ===
          # Inspect the nixpkgs derivation (Step 11) to find the exact check
          # name and disable mechanism. Common patterns:
          #   substituteInPlace $src/build.rs --replace "OutdatedBuildDetector" ""
          #   or remove the check call from postPatch.
          postPatch = (old.postPatch or "") + ''
            # <disable-outdated-build-detector>
            # Inspect the nixpkgs derivation from Step 11 and add the
            # appropriate substituteInPlace or removal here. Without this,
            # the build may warn or fail on a version mismatch because
            # overrideAttrs intentionally tracks upstream, not nixpkgs' pin.
          '';
        });
      in
      {
        packages = {
          <project-name> = <project-name>;
          default = <project-name>;
        };

        apps = {
          <project-name> = {
            type = "app";
            program = "${<project-name>}/bin/<binary-name>";
          };
          default = {
            type = "app";
            program = "${<project-name>}/bin/<binary-name>";
          };
        };

        checks = {
          build = <project-name>;
        };
      });
}
```

## Key Details

- **`overrideAttrs` reuses nixpkgs' fixup logic** — the flake does NOT vendor
  `make-brave.nix` or equivalent. nixpkgs maintains the patchelf/wrapGApps/
  desktop-file-fixup/icon-symlink/`OutdatedBuildDetector`-disable logic; the
  repo only maintains `version` + 4 SRI hashes.
- **Per-platform SRI hashes** — the `hashes` attrset has one entry per target
  system. The hash automation workflow (Step 16) bumps these on each release.
  See `references/advanced-features.md` — Release-Triggered Hash Automation —
  overrideAttrs Variant for the adapted regex.
- **`OutdatedBuildDetector` disable** — nixpkgs packaging for browsers and
  some Electron apps includes a build-time check that compares the built
  version against the expected version and warns or fails if they differ.
  Since `overrideAttrs` intentionally overrides to a newer upstream version,
  this check is a false positive and must be disabled in `postPatch`. Inspect
  the nixpkgs derivation (Step 11) to find the exact check name and disable
  mechanism.
- **Darwin legacy pin** — the `nixpkgs-darwin-legacy` input is MANDATORY for
  `x86_64-darwin` support. nixpkgs-unstable periodically drops support for
  older macOS versions; the legacy pin ensures Intel Macs continue to build.
  See `references/flake-templates/darwin-legacy-pin.md`. Skip only if the
  project explicitly targets `aarch64-darwin` only.
- **Platform scoping** — when `platform_scope` is `darwin_only` or
  `linux_only` (Step 4a), replace the `eachSystem` list with
  `target_platforms` and remove the `hashes` entries for excluded platforms.
  Do NOT add outputs for platforms the project doesn't support.
- **No `#source` output** — this template only wraps the prebuilt binary via
  nixpkgs' packaging. If a from-source build is also needed, combine this
  template with a source-build template (add a `sourceFor` function from
  `references/flake-templates/source-build/<lang>.md` and expose `#source`).
- **No `#nixpkgs` output** — this template IS the nixpkgs-packaged version,
  just at a newer version than nixpkgs ships. There is no separate `#nixpkgs`
  output to add (unlike the `nixpkgs-output.md` pattern which adds `#nixpkgs`
  alongside `#prebuilt`/`#source`).

## Relationship to Other Templates

| Template | Source | When to Use |
|----------|--------|-------------|
| `nixpkgs-packages.md` | `pkgs.<pkg>` as-is | Project in nixpkgs, version is current, packaging is trivial or sufficient |
| `nixpkgs-override-attrs.md` (this) | `pkgs.<pkg>.overrideAttrs` | Project in nixpkgs with complex fixup, prebuilt binaries exist, track upstream faster than nixpkgs |
| `nixpkgs-output.md` | `#nixpkgs` output alongside `#prebuilt`/`#source` | Add nixpkgs version as an option when the in-repo flake uses a different build approach |
| `prebuilt-tarball.md` | `fetchurl` + `stdenv.mkDerivation` | Project not in nixpkgs, or nixpkgs packaging is not reusable |

The `overrideAttrs` pattern is the middle ground between `nixpkgs-packages.md`
(wrap as-is, no version control) and `prebuilt-tarball.md` (vendor all fixup
logic). It gives the repo control over the version cadence while inheriting
nixpkgs' packaging maturity.

## Hash Automation

The hash automation workflow (Step 16) for this template targets the `hashes`
attrset shape (`hashes = { "<system>" = "<sri>"; };`), not the `assets`
attrset shape from `prebuilt-tarball.md` (`assets = { "<system>" = { file =
...; sha256 = ...; }; }`). The regex in the workflow script must be adapted
to match `hashes.${system} = "..."` instead of the `assets` block. See
`references/advanced-features.md` — Release-Triggered Hash Automation —
overrideAttrs Variant for the adapted workflow template.

The reverse-check guard and `.sha256` sibling cross-check from the standard
hash automation both apply to this variant — they catch omitted platforms and
corrupted artifacts before pinning hashes.

## nix-update Alternative

For projects that use a nixpkgs-style single-derivation `package.nix` shape
(one `src = fetchurl { ... }` with a single hash, not per-platform hashes),
[`nixpkgs#nix-update`](https://github.com/Mic92/nix-update) can replace the
custom hash automation script:

```bash
nix run 'nixpkgs#nix-update' -- <project-name> --build \
  --override-filename package.nix --use-github-releases \
  --github-releases-limit 50
```

**When nix-update is sufficient:**
- The flake uses a single-derivation shape (one `src`, one hash) — not the
  per-platform `hashes` attrset from this template
- The project ships a single universal binary, or the flake only targets one
  platform
- The reverse-check guard and `.sha256` cross-check are not needed (single
  platform, no omission risk)

**When to prefer the custom script over nix-update:**
- The flake uses per-platform hashes (the `hashes` attrset) — `nix-update`
  targets single-derivation `src`, not multi-platform hash attrsets
- The reverse-check guard is needed (multi-platform releases where omitting
  a platform from the hash map causes a hash mismatch that CI cannot catch)
- The `.sha256` sibling cross-check is needed (releases publish checksum
  files that should be verified before pinning)
- The workflow needs to open a PR automatically (`nix-update` updates the
  file in-place but does not open a PR — a wrapper step is needed)

For the `overrideAttrs` template with per-platform hashes, the custom script
is the recommended approach. `nix-update` is mentioned for completeness and
for the single-derivation edge case.
