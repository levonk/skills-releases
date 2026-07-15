# Advanced Features

## Table of Contents

- [Home-Manager Module](#home-manager-module)
- [Modular Nix Structure](#modular-nix-structure)
- [Flake-Compat Shims (Legacy Nix)](#flake-compat-shims-legacy-nix)
- [treefmt Configuration](#treefmt-configuration)
- [GitHub Actions CI for Nix](#github-actions-ci-for-nix)
- [Release-Triggered Hash Automation](#release-triggered-hash-automation)
- [Cachix Integration (Binary Caching)](#cachix-integration-binary-caching)
- [Upstream Cache Consumption (nixConfig)](#upstream-cache-consumption-nixconfig)
- [Input Follows for nixpkgs Deduplication](#input-follows-for-nixpkgs-deduplication)
- [forAllSystems / perSystem Pattern (No flake-utils)](#forallsystems--persystem-pattern-no-flake-utils)

---

## Home-Manager Module

For projects that benefit from declarative user configuration, add a home-manager module.

**Create the module structure:**

```bash
mkdir -p nix/modules/hm
```

**Create `nix/modules/hm-module.nix`:**

```nix
{ pkgs, lib, config, ... }:

with lib;

let
  cfg = config.programs.<binary-name>;
in
{
  options.programs.<binary-name> = {
    enable = mkEnableOption "<project name>";

    package = mkOption {
      type = types.package;
      default = pkgs.<binary-name>;
      description = "Package to use for <project name>.";
    };

    settings = mkOption {
      type = types.attrs;
      default = { };
      description = "Configuration for <project name>.";
      example = {
        theme.name = "catppuccin";
        terminal.default_shell = "${pkgs.zsh}/bin/zsh";
      };
    };

    shellIntegration = mkOption {
      type = types.bool;
      default = true;
      description = "Enable shell integration.";
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ cfg.package ];

    xdg.configFile."<binary-name>/config.toml".source =
      pkgs.formats.toml {}.generate "config.toml" cfg.settings;

    programs.zsh.initExtra = mkIf cfg.shellIntegration ''
      # Add shell integration for zsh
    '';

    programs.bash.initExtra = mkIf cfg.shellIntegration ''
      # Add shell integration for bash
    '';

    programs.fish.interactiveShellInit = mkIf cfg.shellIntegration ''
      # Add shell integration for fish
    '';
  };
}
```

**Skip if:** The project is a library, not a CLI tool, or configuration is simple enough for manual management.

---

## Modular Nix Structure

For larger projects requiring complex Nix logic, use a modular structure instead of a monolithic `flake.nix`.

**Create `nix/modules/packages.nix`:**

```nix
{ pkgs, system, ... }:
{
  default = pkgs.<binary-name>;
}
```

**Create `nix/modules/overlays.nix`:**

```nix
final: prev: {
  <binary-name> = final.<binary-name>;
}
```

**Create `nix/modules/devshells.nix`:**

```nix
{ pkgs, ... }:
{
  default = pkgs.mkShell {
    buildInputs = with pkgs; [
      rustc
      cargo
      rust-analyzer
      pkg-config
      openssl
    ];
  };
}
```

**Create `nix/modules/treefmt.nix`:**

```nix
{ pkgs, ... }:
{
  projectRootFile = "flake.nix";
  settings.formatter.nixfmt = {
    command = "${pkgs.nixfmt}/bin/nixfmt";
    includes = [ "*.nix" ];
  };
}
```

**Update `flake.nix` to use modules:**

```nix
{
  description = "<Project description>";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    treefmt-nix.url = "github:numtide/treefmt-nix";
  };

  outputs = { self, nixpkgs, flake-utils, treefmt-nix }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        packages = import ./nix/modules/packages.nix { inherit pkgs system; };
        overlays = import ./nix/modules/overlays.nix;
        devshells = import ./nix/modules/devshells.nix { inherit pkgs; };
        treefmt = import ./nix/modules/treefmt.nix { inherit pkgs; };
      in
      {
        inherit packages overlays devshells;
        packages.default = packages.default;
        devShells.default = devshells.default;
        formatter = treefmt-nix.lib.mkWrapper pkgs treefmt;
      }
    );
}
```

**Skip if:** The project is simple and a monolithic `flake.nix` is sufficient.

---

## Flake-Compat Shims (Legacy Nix)

Create `default.nix` and `shell.nix` for users who don't have flakes enabled.

**`default.nix`:**

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

**`shell.nix`:**

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
}).shellNix
```

**Skip if:** The project only targets users with Nix flakes enabled.

---

## treefmt Configuration

Add treefmt for automated Nix formatting.

**Add treefmt-nix input to `flake.nix`:**

```nix
inputs = {
  nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  flake-utils.url = "github:numtide/flake-utils";
  treefmt-nix.url = "github:numtide/treefmt-nix";
};
```

**Add formatter output:**

```nix
outputs = { self, nixpkgs, flake-utils, treefmt-nix }:
  flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = nixpkgs.legacyPackages.${system};
      treefmt = import ./nix/modules/treefmt.nix { inherit pkgs; };
    in
    {
      formatter = treefmt-nix.lib.mkWrapper pkgs treefmt;
    }
  );
```

**Usage:**

```bash
nix fmt          # Format all Nix files
nix fmt --check  # Check formatting without modifying
```

**Skip if:** The project has no Nix files beyond `flake.nix` or the team prefers other tools.

---

## GitHub Actions CI for Nix

**Create `.github/workflows/nix.yml`:**

```yaml
name: Nix flake

# Validates the flake (flake.nix). For most nixify targets Nix is a side
# concern, so this job is path-filtered to the flake files — it fires only
# when they change, not on every source/docs commit.
#
# Steps, in order of what they catch:
#   1. nix flake check --all-systems  — every system's outputs evaluate
#      (including darwin on an ubuntu runner).
#   2. nix build .#default            — fetchurl + autoPatchelf + install
#      layout actually realises for the runner's system.
#   3. nix run .#default -- --version — the patched binary actually execs.
#      This is the only step that catches the `let ... in rec` shadowing
#      class of bug (passes flake check, fails nix run). Do NOT drop it.
#   4. nix build .#source (if #source output exists) — the from-source
#      build path realises for the runner's system. Skip if the flake
#      does not expose a #source output.

on:
  push:
    branches: [master]
    paths:
      - "flake.nix"
      - "flake.lock"
      - "**/*.nix"
      - ".github/workflows/nix.yml"
  pull_request:
    branches: [master]
    paths:
      - "flake.nix"
      - "flake.lock"
      - "**/*.nix"
      - ".github/workflows/nix.yml"

permissions:
  contents: read

concurrency:
  group: nix-{{{ printf "%s" "${{{ github.workflow }}}" }}}-{{{ printf "%s" "${{{ github.event.pull_request.number || github.ref }}}" }}}
  cancel-in-progress: true

jobs:
  check:
    name: nix flake check
    runs-on: ubuntu-latest
    timeout-minutes: 20
    steps:
      - name: Checkout
        uses: actions/checkout@v6
        with:
          persist-credentials: false

      - name: Install Nix
        # DeterminateSystems/nix-installer-action installs Nix natively on the
        # runner so `nix build` / `nix run` work directly (a Docker-container
        # approach can run `nix flake check` but is awkward for build+smoke).
        uses: DeterminateSystems/nix-installer-action@v16

      - name: nix flake check --all-systems
        # --no-build: evaluate every system's outputs (including darwin on
        # ubuntu) without realising them. Without --no-build, `nix flake
        # check` builds every derivation in `checks`, which fails for
        # non-native systems (darwin stdenv can't run on linux). The
        # build/run steps below handle realisation for the runner's system.
        run: nix flake check --all-systems --no-build

      - name: nix build .#default
        run: nix build .#default --print-build-logs

      - name: nix run .#default -- --version
        run: nix run .#default -- --version

      - name: nix build .#source (if exists)
        # Exercises the from-source build path. Skip if the flake does not
        # expose a #source output (source-build-only flakes use #default).
        run: |
          if nix flake show --json 2>/dev/null | jq -e 'has("source")' >/dev/null 2>&1; then
            nix build .#source --print-build-logs
          else
            echo "No #source output — skipping"
          fi
```

**Customization notes:**
- Adjust `branches: [master]` if the project uses a different default branch (e.g., `main`).
- The `paths:` filter (include) is preferred over `paths-ignore:` (exclude) for nixify targets — Nix is usually a side concern and should not run on every source/docs commit. Add more paths only if the project has non-`.nix` files the flake reads.
- Replace `--version` with the project's actual smoke command (e.g. `--help`, `--version`, or a no-op subcommand). The point is to exec the patched binary end-to-end.
- The `#source` build step uses `jq` to detect whether the output exists before building. If the project's runner doesn't have `jq`, install it first or replace the check with `nix build .#source 2>/dev/null || true` (less precise but functional).
- Pin `actions/checkout` and `nix-installer-action` to commit SHAs (with `# vX.Y.Z` comments) if the project's existing workflows do so — match the repo's convention.

**DO NOT add `DeterminateSystems/magic-nix-cache-action`.** Its hosted backend was sunset in February 2025 and the step now degrades to a silent no-op; it adds noise and a dead dependency for no benefit. If binary caching is actually needed, use Cachix (see [Cachix Integration](#cachix-integration-binary-caching)).

**Skip if:** The project does not use GitHub Actions for CI.

---

## Release-Triggered Hash Automation

For the **Prebuilt Tarball Flake** path, every release requires bumping `version` and refreshing the
per-platform `sha256` hashes in `flake.nix`. Doing this by hand is the #1 objection maintainers raise
to accepting a repo-owned flake ("I don't know Nix and this adds per-release maintenance"). Automation
removes that burden entirely: it prefetches the new release assets, rewrites `flake.nix`, and opens a
PR — zero Nix knowledge required from the maintainer.

**This is a required deliverable for release-based repos using the Prebuilt Tarball Flake, not an
optional extra.** Without it, the flake rots one release after merge.

### CRITICAL: the `GITHUB_TOKEN` trap (why `release: published` often does not work)

Before choosing a trigger, **inspect how the project creates its releases**. If the release workflow
uses `secrets.GITHUB_TOKEN` to run `gh release create` (common with cargo-dist, release-please, and
many autogenerated release pipelines), then a `release: published` workflow **will never fire**.
GitHub deliberately does not start new workflow runs from events created by `GITHUB_TOKEN` (to
prevent recursive loops). This is a documented limitation:
https://docs.github.com/en/actions/using-workflows/triggering-a-workflow#triggering-a-workflow-from-a-fork

**Decision tree:**
1. Inspect the project's release workflow (e.g. `.github/workflows/release.yml`). Find the
   `gh release create` step and check its `GH_TOKEN` / `GITHUB_TOKEN` env.
2. If it uses a **PAT or GitHub App token** -> `release: published` works. Use the
   `release: published` template below.
3. If it uses **`secrets.GITHUB_TOKEN`** (the common case, including all cargo-dist setups) ->
   `release: published` will NOT fire. Use the **scheduled lag-check** template below instead. It
   runs daily, compares `flake.nix`'s `version` to the latest GitHub release, and only acts when
   they differ. Fully decoupled from how releases are created; needs no PAT and no edits to the
   release pipeline.

### Template A: scheduled lag-check (recommended for `GITHUB_TOKEN`-created releases)

Runs daily (and on manual dispatch). When the latest GitHub release outpaces `flake.nix`'s pinned
`version`, prefetches new SRI hashes and opens a PR. No dependency on the release event, no PAT, no
edits to the release pipeline.

**Create `.github/workflows/nix-release.yml`:**

```yaml
name: Update Nix flake

# Checks whether flake.nix lags behind the latest GitHub release. If it does,
# prefetches the new release's per-platform SRI hashes, rewrites flake.nix,
# and opens a PR.
#
# Runs on a schedule instead of release: published because releases are created
# with GITHUB_TOKEN, which does not start new workflow runs. A daily lag-check
# is fully decoupled from how releases are created and needs no PAT.

on:
  schedule:
    - cron: "17 6 * * *"
  workflow_dispatch:

permissions:
  contents: write
  pull-requests: write

concurrency:
  group: nix-flake-release
  cancel-in-progress: true

jobs:
  update-flake:
    name: Bump flake version + hashes if lagging
    runs-on: ubuntu-latest
    if: github.repository == '<owner>/<repo>'
    steps:
      - name: Checkout
        uses: actions/checkout@v6
        with:
          persist-credentials: false

      - name: Install Nix
        uses: cachix/install-nix-action@v31

      - name: Check for lag and rewrite flake.nix
        env:
          # system|asset-substring — one per line. The substring must uniquely
          # match the release asset filename for that system (including the
          # .tar.gz suffix so it does not match the sibling .sha256 files).
          ASSET_MAP: |
            x86_64-linux|x86_64-unknown-linux-musl
            aarch64-linux|aarch64-unknown-linux-musl
            x86_64-darwin|x86_64-apple-darwin
            aarch64-darwin|aarch64-apple-darwin
        run: |
          set -euo pipefail
          tag=$(curl -fsSL -H "Accept: application/vnd.github+json" \
            "https://api.github.com/repos/${GITHUB_REPOSITORY}/releases/latest" \
            | python3 -c 'import json,sys; print(json.load(sys.stdin)["tag_name"])')
          latest="${tag#v}"
          current=$(python3 -c 'import re; s=open("flake.nix").read(); m=re.search(r"version = \"([^\"]*)\";", s); print(m.group(1))')
          echo "flake.nix version: $current  |  latest release: $latest (tag $tag)"
          if [ "$current" = "$latest" ]; then
            echo "flake.nix is up to date; nothing to do."
            echo "LAGGING=no" >> "$GITHUB_ENV"
            exit 0
          fi
          echo "LAGGING=yes" >> "$GITHUB_ENV"
          echo "VERSION=$latest" >> "$GITHUB_ENV"
          export TAG="$tag"
          python3 <<'PYEOF'
          import json, os, re, subprocess, urllib.request
          tag = os.environ["TAG"]
          version = tag.lstrip("v")
          repo = os.environ["GITHUB_REPOSITORY"]
          with urllib.request.urlopen(
              f"https://api.github.com/repos/{repo}/releases/latest") as r:
              release = json.load(r)
          # Drop sibling checksum files (.sha256) so a tarball substring does
          # not also match its "<tarball>.sha256" companion (cargo-dist etc.).
          names = {a["name"] for a in release["assets"]
                   if not a["name"].endswith(".sha256")}
          asset_map = {}
          for line in os.environ["ASSET_MAP"].splitlines():
              line = line.strip()
              if not line or line.startswith("#"):
                  continue
              sys_, sub = line.split("|", 1)
              asset_map[sys_.strip()] = sub.strip()
          src = open("flake.nix").read()
          src, n = re.subn(r'version = "[^"]*";', f'version = "{version}";', src, count=1)
          if n != 1:
              raise SystemExit('could not find version = "..." in flake.nix')
          for sys_, sub in asset_map.items():
              match = next((n for n in names if sub in n), None)
              if not match:
                  raise SystemExit(f"no asset for {sys_} ({sub}) in {tag}; have: {sorted(names)}")
              url = f"https://github.com/{repo}/releases/download/{tag}/{match}"
              out = json.loads(subprocess.check_output(
                  ["nix", "store", "prefetch-file", "--json", "--hash-type", "sha256", url]))
              sri = out["hash"]
              pat = re.compile(r'("' + re.escape(sys_) + r'" = \{[^}]*\})', re.S)
              def repl(m):
                  b = m.group(1)
                  b = re.sub(r'file = "[^"]*";', f'file = "{match}";', b, count=1)
                  b = re.sub(r'sha256 = "[^"]*";', f'sha256 = "{sri}";', b, count=1)
                  return b
              src, n = pat.subn(repl, src, count=1)
              if n != 1:
                  raise SystemExit(f"could not find assets block for {sys_} in flake.nix")
          open("flake.nix", "w").write(src)
          print(f"bumped flake.nix to {version}: {list(asset_map)}")
          PYEOF

      - name: Open PR
        if: env.LAGGING == 'yes'
        uses: peter-evans/create-pull-request@v7
        with:
          commit-message: "chore(nix): bump flake to v{{{ printf "%s" "${{{ env.VERSION }}}" }}}"
          title: "chore(nix): bump flake to v{{{ printf "%s" "${{{ env.VERSION }}}" }}}"
          branch: chore/nix-flake-v{{{ printf "%s" "${{{ env.VERSION }}}" }}}
          base: master
          body: |
            Auto-generated by the `Update Nix flake` workflow (daily lag-check).
            The latest GitHub release is v{{{ printf "%s" "${{{ env.VERSION }}}" }}} but `flake.nix` was
            pinned to an older version. This PR bumps `version` and refreshes the per-platform SRI
            hashes by prefetching the new release assets.

            Note: PRs opened by `GITHUB_TOKEN` do not trigger downstream workflow runs (e.g. CI),
            so this PR will show no checks. The diff is a 5-line hash bump with no source changes —
            safe to merge as-is.
```

### Template B: `release: published` (only if releases are created with a PAT/App token)

Use this only when Step 1 of the decision tree confirmed the release is created with a PAT or
GitHub App token (not `secrets.GITHUB_TOKEN`). Otherwise this workflow will silently never fire.

```yaml
name: Update Nix flake

on:
  release:
    types: [published]

permissions:
  contents: write
  pull-requests: write

concurrency:
  group: nix-flake-release
  cancel-in-progress: true

jobs:
  update-flake:
    name: Bump flake version + hashes
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v6
        with:
          persist-credentials: false

      - name: Install Nix
        uses: cachix/install-nix-action@v31

      - name: Rewrite flake.nix with new release
        env:
          ASSET_MAP: |
            x86_64-linux|x86_64-unknown-linux-musl
            aarch64-linux|aarch64-unknown-linux-musl
            x86_64-darwin|x86_64-apple-darwin
            aarch64-darwin|aarch64-apple-darwin
        run: |
          version="${GITHUB_REF_NAME#v}"
          echo "VERSION=$version" >> "$GITHUB_ENV"
          python3 <<'PYEOF'
          import json, os, re, subprocess
          tag = os.environ["GITHUB_REF_NAME"]
          version = tag.lstrip("v")
          event = json.load(open(os.environ["GITHUB_EVENT_PATH"]))
          asset_map = {}
          for line in os.environ["ASSET_MAP"].splitlines():
              line = line.strip()
              if not line or line.startswith("#"):
                  continue
              sys_, sub = line.split("|", 1)
              asset_map[sys_.strip()] = sub.strip()
          names = {a["name"] for a in event["release"]["assets"]
                   if not a["name"].endswith(".sha256")}
          repo = os.environ["GITHUB_REPOSITORY"]
          src = open("flake.nix").read()
          src, n = re.subn(r'version = "[^"]*";', f'version = "{version}";', src, count=1)
          if n != 1:
              raise SystemExit('could not find version = "..." in flake.nix')
          for sys_, sub in asset_map.items():
              match = next((n for n in names if sub in n), None)
              if not match:
                  raise SystemExit(f"no asset for {sys_} ({sub}) in {tag}; have: {sorted(names)}")
              url = f"https://github.com/{repo}/releases/download/{tag}/{match}"
              out = json.loads(subprocess.check_output(
                  ["nix", "store", "prefetch-file", "--json", "--hash-type", "sha256", url]))
              sri = out["hash"]
              pat = re.compile(r'("' + re.escape(sys_) + r'" = \{[^}]*\})', re.S)
              def repl(m):
                  b = m.group(1)
                  b = re.sub(r'file = "[^"]*";', f'file = "{match}";', b, count=1)
                  b = re.sub(r'sha256 = "[^"]*";', f'sha256 = "{sri}";', b, count=1)
                  return b
              src, n = pat.subn(repl, src, count=1)
              if n != 1:
                  raise SystemExit(f"could not find assets block for {sys_} in flake.nix")
          open("flake.nix", "w").write(src)
          print(f"bumped flake.nix to {version}: {list(asset_map)}")
          PYEOF

      - name: Open PR
        uses: peter-evans/create-pull-request@v7
        with:
          commit-message: "chore(nix): bump flake to v{{{ printf "%s" "${{{ env.VERSION }}}" }}}"
          title: "chore(nix): bump flake to v{{{ printf "%s" "${{{ env.VERSION }}}" }}}"
          branch: chore/nix-flake-v{{{ printf "%s" "${{{ env.VERSION }}}" }}}
          base: master
          body: |
            Auto-generated by the `Update Nix flake` workflow on release publication.
            Bumps `version` and refreshes per-platform SRI hashes in `flake.nix` by
            prefetching the new release assets. No manual editing required.
```

**Customization notes (both templates):**
- `ASSET_MAP`: one `system|substring` per line. The substring must uniquely match the release asset filename for that system (e.g. `x86_64-unknown-linux-musl`). Inspect the project's release assets to fill this in — it is the only project-specific input. Sibling checksum files ending in `.sha256` are filtered out automatically, so a `foo.tar.gz` substring will not also match its `foo.tar.gz.sha256` companion (common with cargo-dist releases).
- `base: master`: change to `main` if the project's default branch is `main`.
- `if: github.repository == '<owner>/<repo>'` (Template A): prevents the scheduled job from running on forks. Replace with the upstream owner/repo.
- The script targets the `assets = { "<system>" = { file = ...; sha256 = ...; }; }` shape from the Prebuilt Tarball Flake template. For other flake shapes, adapt the regex.
- Hashes are written in SRI form (`sha256-...=`), which modern Nix accepts in the `sha256` field.
- `nix store prefetch-file` requires Nix >= 2.20; `cachix/install-nix-action@v31` installs a recent release.
- PRs opened by `GITHUB_TOKEN` (both templates) do not trigger downstream CI workflows. The diff is a 5-line hash bump with no source changes — safe to merge without checks. If CI on the bump PR is required, use a PAT for `peter-evans/create-pull-request` (but that reintroduces secret-management burden).
- To make it fully hands-off, add a final `gh pr merge --merge --auto` step (with `env: GH_TOKEN: ${{{ "{{" }}} secrets.GITHUB_TOKEN {{{ "}}" }}}`) or enable auto-merge on the branch via repository settings.
- Pin actions to commit SHAs (with `# vX.Y.Z` comments) if the project's existing workflows do so — match the repo's convention.

**How it addresses maintainer objections:** the maintainer cuts a release exactly as they do today; the workflow opens a PR with the bumped `flake.nix`. Reviewing a 5-line diff (version + 4 hashes) needs no Nix knowledge. Merge -> `nix run github:<owner>/<repo>` serves the new release. The scheduled variant (Template A) adds no PAT, no release-pipeline edits, and no per-release manual step of any kind.

**Verification (do this before opening the PR):** the automation workflow itself is not exercised by the PR's CI (it mutates `main` post-publish and runs on a schedule, not on push). Confirm it evaluates by triggering it manually on the PR branch:

```bash
# From the PR branch, after pushing:
gh workflow run "Update Nix flake" --ref <pr-branch-name>
# Then watch the run — it should report "flake.nix is up to date; nothing to do."
# (because the flake version already matches the latest release on the PR branch).
gh run watch
```

A clean "up to date, nothing to do" run proves the workflow's Nix install, GitHub API call, version comparison, and `ASSET_MAP` parsing all work. The actual hash-rewrite path is only exercised when a real new release outpaces the flake, but the manual run catches config/parse errors before merge. (This is the "can't be exercised by this PR's CI" gap that led nubjs/nub#169 to defer automation — the manual `workflow_dispatch` run closes it.)

**Skip if:** the project does not publish release tarballs (use a source-build flake instead), or already automates flake updates via another mechanism (e.g. `update-flake-lock` action).

---

## Cachix Integration (Binary Caching)

1. **Create a Cachix cache:** Visit https://cachix.org and create a new cache.

2. **Add Cachix input to `flake.nix`:**

```nix
inputs = {
  nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  flake-utils.url = "github:numtide/flake-utils";
  cachix = {
    url = "github:cachix/cachix";
    inputs.nixpkgs.follows = "nixpkgs";
  };
};
```

3. **Add CI workflow to push to Cachix** (`.github/workflows/cachix.yml`):

```yaml
name: Cachix

on:
  push:
    branches: [ master ]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: cachix/install-nix-action@v22
        with:
          nix_path: nixpkgs=channel:nixos-unstable
      - uses: cachix/cachix-action@v12
        with:
          name: <your-cache-name>
          authToken: '${{{ "{{" }}} secrets.CACHIX_AUTH_TOKEN {{{ "}}" }}}'
```

4. **Add `CACHIX_AUTH_TOKEN` secret** to GitHub repository from https://cachix.org/api/token

**Skip if:** The project is small and build times are acceptable, or uses a different caching solution.

---

## Upstream Cache Consumption (nixConfig)

When a flake depends on other flakes (e.g., `bun2nix`, `rust-overlay`, `naersk`), those dependencies may have pre-built binaries in their own Cachix caches. Declare the upstream caches directly in `flake.nix` via `nixConfig` so that anyone using the flake automatically fetches pre-built artifacts instead of compiling downstream dependencies locally.

**Add `nixConfig` to `flake.nix`:**

```nix
{
  description = "<project description>";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    bun2nix.url = "github:nix-community/bun2nix";
    bun2nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  nixConfig = {
    extra-substituters = [
      "https://nix-community.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  outputs = { self, nixpkgs, ... }: {
    # ...
  };
}
```

Key details:
- Uses `extra-substituters` (additive) not `substituters` (replacement) so user-configured caches are preserved
- `extra-trusted-public-keys` must match the substituter URLs — get keys from the upstream project's documentation or `cachix.org/<cache-name>`
- Requires the user to have `trusted-users` or `trusted-substituters` configured in their Nix settings, or to accept the flake's nix config on first use
- This is complementary to the Cachix Integration section above — that section covers pushing YOUR builds to a cache; this section covers consuming OTHERS' caches

**When to use:**
- The flake has inputs that publish to Cachix (e.g., `nix-community`, `rust-overlay`, `nixpkgs-wayland`)
- Build times are slow because downstream dependencies compile from source
- You want users to have a fast `nix run` / `nix build` experience without manual cache configuration

**Skip if:** The flake has no external flake inputs, or all inputs are already in the official `cache.nixos.org`.

---

## Input Follows for nixpkgs Deduplication

When a flake has multiple inputs that each depend on nixpkgs, each input will pin its own copy of nixpkgs by default. This causes:
- Duplicate nixpkgs evaluations (slower builds, more memory)
- Potential version mismatches between inputs
- Larger `flake.lock` files

Use `follows` to make all inputs use the same nixpkgs revision:

```nix
inputs = {
  nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  # These inputs will use the same nixpkgs as the main flake
  bun2nix = {
    url = "github:nix-community/bun2nix";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  rust-overlay = {
    url = "github:oxalica/rust-overlay";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  naersk = {
    url = "github:nix-community/naersk";
    inputs.nixpkgs.follows = "nixpkgs";
  };
};
```

**When to use:** Always, when inputs have a `nixpkgs` input. This is a best practice for all flakes with multiple inputs.

**Skip if:** An input deliberately pins a different nixpkgs version (rare — usually for compatibility testing).

---

## forAllSystems / perSystem Pattern (No flake-utils)

Instead of depending on `flake-utils` for multi-system support, use a lightweight `forAllSystems` / `perSystem` pattern. This eliminates an external dependency and gives full control over which systems are supported.

```nix
{
  description = "<project description>";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs, ... }: let
    lib = nixpkgs.lib;
    supportedSystems = [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];
    forAllSystems = lib.genAttrs supportedSystems;
    perSystem = forAllSystems (
      system: let
        pkgs = import nixpkgs { inherit system; };
        <pname> = pkgs.callPackage ./nix/package.nix { };
      in {
        packages = {
          inherit <pname>;
          default = <pname>;
        };
        devShells.default = pkgs.callPackage ./nix/devShell.nix { };
      }
    );
    systemOutput = name: lib.mapAttrs (_: value: value.${name}) perSystem;
  in {
    packages = systemOutput "packages";
    devShells = systemOutput "devShells";
  };
}
```

Key details:
- `supportedSystems` is explicit — only build for systems you actually support, not every possible system
- `perSystem` defines all per-system outputs in one block (packages, devShells, apps, checks)
- `systemOutput` extracts a named key from each system's attribute set into the top-level flake output
- `pkgs.callPackage` for devShell and package definitions enables clean separation into `./nix/` files
- No `flake-utils` input means one fewer entry in `flake.lock` and no dependency on an external maintainer

**When to use:**
- You want to minimize external flake inputs
- You need explicit control over supported systems (not all systems via `eachDefaultSystem`)
- The project has a modular `./nix/` directory structure

**Skip if:** The project already uses `flake-utils` and migration would add complexity, or `eachDefaultSystem` behavior (all systems) is desired.
