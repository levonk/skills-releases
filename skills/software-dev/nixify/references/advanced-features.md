# Advanced Features

## Table of Contents

- [Home-Manager Module](#home-manager-module)
- [NixOS Service Module](#nixos-service-module)
- [Modular Nix Structure](#modular-nix-structure)
- [Flake-Compat Shims (Legacy Nix)](#flake-compat-shims-legacy-nix)
- [treefmt Configuration](#treefmt-configuration)
- [GitHub Actions CI for Nix](#github-actions-ci-for-nix)
- [Garnix CI (Hosted Alternative)](#garnix-ci-hosted-alternative)
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

## NixOS Service Module

For projects that run as a long-running service (web server, API, daemon,
bot), add a NixOS module so users can deploy the service declaratively on
NixOS via `services.<project-name>.enable = true`. This is the gap between
"installable via `nix run`" (the flake's `packages` output) and "deployable
as a native NixOS service" (a `nixosModules` output with systemd service,
user/group, data dirs, and auto-configured dependencies). See OmniRoute
issue #3738 — a user requested "nix native packages and nix service
configuration options" after the dev-environment-only PR #2806 landed.

**Canonical examples** (referenced by issue #3738):
- [authentik-nix](https://github.com/nix-community/authentik-nix) — NixOS
  module for authentik with systemd service, redis, and postgresql
  auto-configuration
- [hermes-agent nix](https://github.com/NousResearch/hermes-agent/tree/main/nix)
  — NixOS module for a long-running AI agent service

### Create the module structure

```bash
mkdir -p nix/modules/nixos
```

### Create `nix/modules/nixos/default.nix`

```nix
{ pkgs, lib, config, options, ... }:

with lib;

let
  cfg = config.services.<project-name>;
  pkg = self.packages.${pkgs.system}.default;
in
{
  options.services.<project-name> = {
    enable = mkEnableOption "<project-name> service";

    package = mkOption {
      type = types.package;
      default = pkg;
      description = "Package to use for <project-name>.";
    };

    user = mkOption {
      type = types.str;
      default = "<project-name>";
      description = "User to run <project-name> as.";
    };

    group = mkOption {
      type = types.str;
      default = "<project-name>";
      description = "Group to run <project-name> as.";
    };

    dataDir = mkOption {
      type = types.path;
      default = "/var/lib/<project-name>";
      description = "Data directory for <project-name>.";
    };

    environmentFile = mkOption {
      type = with types; nullOr path;
      default = null;
      description = ''
        Path to an environment file loaded by the systemd service.
        Useful for projects that strictly read `.env` files (see
        `.env`-strict projects below). The file should contain
        KEY=value lines; it is passed to systemd via EnvironmentFile=.
      '';
    };

    # ── Auto-configured runtime service dependencies ───────────────────
    # These options are generated from detect-runtime-deps.sh output.
    # Each detected runtime dep (redis, postgresql, mongodb, etc.) gets
    # an `enable<Dep>` option that defaults to true, so the service
    # auto-configures its dependencies when enabled — like Nextcloud.
    enableRedis = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to auto-configure Redis for <project-name>.";
    };

    enablePostgresql = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to auto-configure PostgreSQL for <project-name>.";
    };

    # Add more enable<Dep> options as detected by detect-runtime-deps.sh.
    # Common ones: enableMongodb, enableRabbitmq, enableElasticsearch,
    # enableMeilisearch, enableClickhouse.
  };

  config = mkIf cfg.enable {
    # ── User and group ─────────────────────────────────────────────────
    users.users.${cfg.user} = {
      isSystemUser = true;
      group = cfg.group;
      home = cfg.dataDir;
      createHome = true;
    };
    users.groups.${cfg.group} = {};

    # ── Auto-configured runtime dependencies ───────────────────────────
    # Each enable<Dep> option maps to the corresponding NixOS service.
    # This is the "auto configure redis service just like Nextcloud"
    # pattern from issue #3738.
    services.redis = mkIf cfg.enableRedis {
      enable = true;
      # Bind to a unix socket or localhost for security
      bind = "127.0.0.1";
      port = 6379;
    };

    services.postgresql = mkIf cfg.enablePostgresql {
      enable = true;
      ensureDatabases = [ "<project-name>" ];
      ensureUsers = [
        {
          name = cfg.user;
          ensurePermissions = { "DATABASE \"<project-name>\"" = "ALL PRIVILEGES"; };
        }
      ];
    };

    # Add more service auto-configurations as detected:
    # services.mongodb = mkIf cfg.enableMongodb { enable = true; };
    # services.rabbitmq = mkIf cfg.enableRabbitmq { enable = true; };
    # services.elasticsearch = mkIf cfg.enableElasticsearch { enable = true; };

    # ── Systemd service ────────────────────────────────────────────────
    systemd.services.<project-name> = {
      description = "<project-name> service";
      wantedBy = [ "multi-user.target" ];
      after = [
        "network.target"
      ] ++ optionals cfg.enableRedis [ "redis.service" ]
        ++ optionals cfg.enablePostgresql [ "postgresql.service" ];

      environment = {
        # Pass config via environment variables. For projects that read
        # environment variables directly (not strictly .env files), this
        # is sufficient. See ".env-strict projects" below for the
        # EnvironmentFile pattern.
        NODE_ENV = "production";
        # Add project-specific env vars here:
        # DATABASE_URL = "postgresql:///project-name?host=/run/postgresql";
        # REDIS_URL = "redis://127.0.0.1:6379";
      };

      # For .env-strict projects: load the env file via systemd
      serviceConfig = {
        ExecStart = "${cfg.package}/bin/<binary-name>";
        User = cfg.user;
        Group = cfg.group;
        WorkingDirectory = cfg.dataDir;
        StateDirectory = "<project-name>";
        Restart = "on-failure";
        RestartSec = "5s";
        # Security hardening
        NoNewPrivileges = true;
        PrivateTmp = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        ReadWritePaths = [ cfg.dataDir ];
      } // (optionalAttrs (cfg.environmentFile != null) {
        EnvironmentFile = cfg.environmentFile;
      });
    };
  };
}
```

### Expose the module as a flake output

Add `nixosModules.<project-name>` to `flake.nix` alongside the existing
`packages` and `devShells` outputs:

```nix
nixosModules.<project-name> = import ./nix/modules/nixos;
nixosModules.default = self.nixosModules.<project-name>;
```

Users deploy the service in their NixOS configuration (`configuration.nix`
or a flake):

```nix
{
  inputs.<project-name>.url = "github:<owner>/<repo>";
  outputs = { self, <project-name>, ... }: {
    nixosConfigurations.myhost = nixpkgs.lib.nixosSystem {
      modules = [
        <project-name>.nixosModules.<project-name>
        {
          services.<project-name>.enable = true;
          # Redis and PostgreSQL are auto-configured by default.
          # Override if you manage them separately:
          # services.<project-name>.enableRedis = false;
        }
      ];
    };
  };
}
```

### Consuming `detect-runtime-deps.sh` output

Before generating the module, run
`scripts/detect-runtime-deps.sh <project-dir>` (Step 12b). The script
outputs `devbox_packages` and `devshell_packages` arrays — map each
detected service to a `mkIf`-guarded NixOS service block:

| Detected package | NixOS service option | NixOS service block |
|------------------|---------------------|---------------------|
| `redis` | `enableRedis` | `services.redis = mkIf cfg.enableRedis { ... }` |
| `postgresql` | `enablePostgresql` | `services.postgresql = mkIf cfg.enablePostgresql { ... }` |
| `mongodb` | `enableMongodb` | `services.mongodb = mkIf cfg.enableMongodb { ... }` |
| `rabbitmq` | `enableRabbitmq` | `services.rabbitmq = mkIf cfg.enableRabbitmq { ... }` |
| `elasticsearch` | `enableElasticsearch` | `services.elasticsearch = mkIf cfg.enableElasticsearch { ... }` |
| `meilisearch` | `enableMeilisearch` | `services.meilisearch = mkIf cfg.enableMeilisearch { ... }` |
| `clickhouse` | `enableClickhouse` | `services.clickhouse = mkIf cfg.enableClickhouse { ... }` |

Only add `enable<Dep>` options for services that
`detect-runtime-deps.sh` actually detected — do not add all possible
options speculatively. Each option defaults to `true` so the service
auto-configures its dependencies when enabled, matching the Nextcloud
pattern requested in issue #3738.

### `.env`-strict projects

Some projects strictly read configuration from a `.env` file at startup
and do not honor environment variables set in the process environment
(e.g. they use `dotenv/config` which only reads from the file, not the
environment). This is a common pattern in Node.js projects. For NixOS
deployment, there are two approaches:

1. **`EnvironmentFile` (preferred, no source changes)**: Pass the env
   file path via the `environmentFile` option (shown in the template
   above). The systemd service loads it via `EnvironmentFile=`. The user
   creates the file at the specified path (e.g.
   `/var/lib/<project-name>/.env`) with the required `KEY=value` lines.
   This works without any source code changes — the project reads its
   `.env` file as usual, and systemd provides the file.

2. **Source patch (if the project cannot use a file)**: If the project
   reads `.env` from a hardcoded relative path that cannot be overridden,
   a `postPatch` in the Nix derivation can patch the path to read from
   `$HOME/.env` or an absolute path. This is a source change in the Nix
   derivation only — do NOT modify the upstream source code in a
   Nix-only PR (see Step 8). Document the patch in the orientation issue
   so a follow-up PR can address the root cause (making the project read
   from the environment directly, as requested in issue #3738).

**When the user requests environment-variable reading instead of `.env`
files**: This is a source code change (e.g. replacing `dotenv/config`
with direct `process.env` reads, or adding `dotenv` with
`override: true`). It is out of scope for a nixify PR — the nixify PR
packages and deploys the project as-is. Document the request in the
orientation issue as a follow-up suggestion for the upstream project.

### Skip if

- The project is a CLI tool, not a long-running service (use the
  Home-Manager Module instead)
- The project is a library (no service to run)
- The project only runs in a container and has no native service mode
  (document the container deployment in the orientation issue instead)

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
# concern and the full build can take 10+ minutes, so this workflow runs
# only on manual dispatch or when a release is published — not on every
# push or PR. If the project wants per-PR validation, add a `pull_request`
# trigger with `paths:` filtered to flake files (see customization notes).
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
  # Manual trigger — run before cutting a release or after significant
  # flake changes.
  workflow_dispatch: {}
  # Auto-run on published releases only.
  release:
    types: [published]

permissions:
  contents: read
  # id-token: write is required by magic-nix-cache-action for the GitHub
  # Actions cache v2 API (OIDC token exchange for cache auth).
  id-token: write

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

      - name: Enable Nix binary cache (GitHub Actions cache)
        # magic-nix-cache-action uses GitHub Actions' built-in cache to share
        # Nix build outputs between workflow runs — free, zero-config, no
        # secrets. Saves 30-50% CI time on repeated builds. Was temporarily
        # broken Feb-Jun 2025 (GitHub cache API v2 migration), revived in
        # v13 (July 2025). Requires permissions: id-token: write above.
        uses: DeterminateSystems/magic-nix-cache-action@v13

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
          if nix flake show --json 2>/dev/null | jq -e 'any(.packages[]?; has("source"))' >/dev/null 2>&1; then
            nix build .#source --print-build-logs
          else
            echo "No #source output — skipping"
          fi
```

**Customization notes:**
- **Trigger policy**: The default is `workflow_dispatch` + `release: published` only — Nix is usually a side concern and the full build takes 10+ minutes. If the project wants per-PR validation, add a `pull_request` trigger with `paths:` filtered to flake files:
  ```yaml
  pull_request:
    branches: [main]
    paths:
      - "flake.nix"
      - "flake.lock"
      - "**/*.nix"
      - ".github/workflows/nix.yml"
  ```
  Adjust `branches: [main]` to match the project's default branch.
- **Lockfile path-filter (source-build flakes — MANDATORY)**: When the flake exposes a `#source` output that builds from source via a fixed-output derivation (FOD) keyed on a lockfile hash, **the lockfile MUST be in the `paths:` filter**. A lockfile change invalidates the FOD's `outputHash`, but if the lockfile isn't in the path filter, the Nix CI never runs on dependency bumps and the breakage reaches users instead of being caught in CI. Add the project's lockfile(s) to the `paths:` list:
  - Bun: `bun.lock`
  - npm: `package-lock.json`
  - pnpm: `pnpm-lock.yaml`
  - Cargo: `Cargo.lock`
  - Go: `go.sum`
  - Python (uv): `uv.lock`
  - Python (pip): `requirements.txt`
  - Maven: `pom.xml`
  Example with Bun:
  ```yaml
  pull_request:
    branches: [main]
    paths:
      - "flake.nix"
      - "flake.lock"
      - "**/*.nix"
      - ".github/workflows/nix.yml"
      - "bun.lock"
  ```
  This was a declining reason on Archon PR #2131: `bun.lock` changed 16 times in 60 days but was not in the nix.yml path filter, so dependency bumps never triggered Nix CI and the `#source` FOD hash rot reached users silently.
- **Cross-platform matrix (recommended for prebuilt tarball flakes)**: The default workflow runs on `ubuntu-latest` only. `nix flake check --all-systems --no-build` evaluates every system's outputs without realising fetchurl derivations, so a fetch-hash mismatch on `x86_64-darwin` or `aarch64-darwin` is invisible. To catch cross-platform hash mismatches and Darwin-specific build failures, add a matrix that builds on multiple runners:
  ```yaml
  strategy:
    matrix:
      runner: [ubuntu-latest, macos-26, macos-26-intel]
  runs-on: ${{ matrix.runner }}
  ```
  `macos-26` is ARM (aarch64-darwin), `macos-26-intel` is Intel (x86_64-darwin). This is the only way CI can catch the class of hash mismatch that the Archon PR #2131 ASSET_MAP omission caused. When GitHub Actions decommissions `macos-26-intel` (estimated ~Nov 2028 per [actions/runner-images#13739](https://github.com/actions/runner-images/issues/13739)), the `self-prune` job in the single-file workflow (see [Self-Pruning on Runner Decommission](#self-pruning-on-runner-decommission) below) comments out the Intel entry and swaps `x86_64-darwin` source-build FOD hashes to `lib.fakeHash` automatically.
- Replace `--version` with the project's actual smoke command (e.g. `--help`, `--version`, or a no-op subcommand). The point is to exec the patched binary end-to-end.
- The `#source` build step uses `jq` to detect whether the output exists before building. If the project's runner doesn't have `jq`, install it first or replace the check with `nix build .#source 2>/dev/null || true` (less precise but functional).
- Pin `actions/checkout` and `nix-installer-action` to commit SHAs (with `# vX.Y.Z` comments) if the project's existing workflows do so — match the repo's convention.
- **Add `DeterminateSystems/magic-nix-cache-action@v13` after the Nix install step** (see the updated template above). It uses GitHub Actions' built-in cache to share Nix build outputs between workflow runs — free, zero-config, no secrets needed (works on forks and PRs). Saves 30-50% CI time on repeated builds. The action was temporarily broken in Feb 2025 when GitHub deprecated the legacy Actions cache API, but was revived in June 2025 ([PR #139](https://github.com/DeterminateSystems/magic-nix-cache/pull/139)) against the new cache v2 API and is actively maintained (v13, July 2025). It requires `permissions: id-token: write` for the new cache API. The cache is per-workflow-per-repo (not a shared binary cache) — use [Cachix](#cachix-integration-binary-caching) or [FlakeHub Cache](https://flakehub.com/cache) if you need cross-machine or cross-team caching.

**Skip if:** The project does not use GitHub Actions for CI.

---

## Garnix CI (Hosted Alternative)

[Garnix](https://garnix.io) is a hosted CI service for Nix flake repos. After
installing the Garnix GitHub App on a repository, every push automatically
builds all flake outputs (`packages`, `checks`, `devShells`,
`nixosConfigurations`, `darwinConfigurations`, `homeConfigurations`) and
reports results back as GitHub commit/PR checks. Build outputs are cached on
Garnix's side, so subsequent builds and local `nix run` fetches are fast.

### Relationship to the required `.github/workflows/nix.yml`

Garnix is a **complement**, not a replacement, for the required GitHub Actions
workflow (see [GitHub Actions CI for Nix](#github-actions-ci-for-nix)):

- **`nix.yml`** is the **contributor-controlled** CI. The nixify PR adds it,
  and it works immediately on any repo — no maintainer action needed. It is
  the only CI the contributor can guarantee.
- **Garnix** is the **maintainer-opt-in** CI. The contributor cannot install
  the Garnix GitHub App on a repo they don't own. Adding a `garnix.yaml` to
  the PR makes the repo Garnix-ready the moment the maintainer enables the
  app, but it does nothing until then.

Keep `nix.yml` in every PR. Add `garnix.yaml` as an optional artifact when the
maintainer has expressed interest in hosted Nix CI, or when the project's
cross-platform coverage needs exceed what a single-runner GitHub Actions
workflow provides.

### The maintainer-opt-in constraint

nixify PRs go to **upstream third-party repos**. The contributor does not have
permission to install the Garnix GitHub App on the target repo — that requires
the repo owner to visit [app.garnix.io](https://app.garnix.io), install the
app, and authorize it for the repository. Therefore:

1. **`garnix.yaml` in the PR** configures build scope *if* the maintainer later
   enables the app. It is inert until the app is installed — no side effects,
   no broken checks.
2. **The PR body** should mention Garnix as an optional complement, not as
   something the PR activates. Phrase it as: "A `garnix.yaml` is included so
   the repo is ready for [Garnix CI](https://garnix.io) if the maintainer
   chooses to enable it."
3. **Do not** add Garnix badges to the README unless the maintainer has already
   enabled the app — a badge that links to a non-existent Garnix project page
   is worse than no badge.

### `garnix.yaml` configuration

Garnix's **default** build scope is **linux-only**:
`*.x86_64-linux.*`, `defaultPackage.x86_64-linux`, `devShell.x86_64-linux`,
plus all `homeConfigurations.*`, `darwinConfigurations.*`, and
`nixosConfigurations.*`. Mac (`aarch64-darwin`, `x86_64-darwin`) and ARM-linux
(`aarch64-linux`) builds are **opt-in** via the `builds.include` list.

This is the exact cross-platform gap the nixify skill cares about — the
`target_platforms` from Step 4a determines which systems to include. Run
`scripts/detect-garnix-scope.sh` to generate the correct `garnix.yaml` from
the Step 4a output.

**For `platform_scope=all` (all 4 systems):**

```yaml
builds:
  exclude: []
  include:
    - '*.x86_64-linux.*'
    - '*.aarch64-linux.*'
    - '*.x86_64-darwin.*'
    - '*.aarch64-darwin.*'
```

**For `platform_scope=darwin_only`:**

```yaml
builds:
  exclude: []
  include:
    - '*.x86_64-darwin.*'
    - '*.aarch64-darwin.*'
```

**For `platform_scope=linux_only`:**

```yaml
builds:
  exclude: []
  include:
    - '*.x86_64-linux.*'
    - '*.aarch64-linux.*'
```

### FOD checks (hash-rot detection)

For source-build flakes, enable FOD (fixed-output derivation) checks to catch
hash rot — the exact failure mode the lockfile path-filter section documents
(Archon PR #2131: `bun.lock` changed but Nix CI never ran, so the FOD hash rot
reached users silently):

```yaml
fodChecks: true
```

Garnix's FOD checks verify that all fixed-output derivations in the flake
produce the expected hashes. When a lockfile bump invalidates a FOD hash,
Garnix catches it on the next push — before it reaches users. This is
complementary to the `nix.yml` lockfile path-filter: the path-filter ensures
`nix.yml` *runs* on lockfile changes; Garnix's `fodChecks` provides an
independent hosted verification layer.

Enable `fodChecks: true` for `flake_type=source_build` and
`flake_type=prebuilt_tarball` (the `#source` output in prebuilt tarball flakes
also uses FODs). Skip if the flake has no FOD outputs (rare — most source
builds use `fetchurl`/`fetchFromGitHub`/`fetchNpmDeps`/`bun2nix` which are
FODs).

### Full `garnix.yaml` example (all 4 systems, FOD checks on)

```yaml
builds:
  exclude: []
  include:
    - '*.x86_64-linux.*'
    - '*.aarch64-linux.*'
    - '*.x86_64-darwin.*'
    - '*.aarch64-darwin.*'
fodChecks: true
```

### When to add `garnix.yaml` to the PR

- **Add it** when the maintainer has expressed interest in hosted Nix CI, or
  when the project would benefit from cross-platform build coverage that
  exceeds the single-runner `nix.yml` (e.g., the project has darwin-specific
  outputs that `nix.yml` only evaluates via `--no-build`).
- **Skip it** when the project already has a robust GitHub Actions matrix
  (ubuntu + macos-26 + macos-26-intel) and the maintainer hasn't mentioned Garnix.
  Adding an inert config file the maintainer didn't ask for is presumptuous.
- **Never** add it without the `nix.yml` — `nix.yml` is the contributor's
  guarantee; `garnix.yaml` is a bonus that only activates on maintainer opt-in.

### GitHub Actions integration

Garnix is not a GitHub Action (it avoids consuming GitHub Actions minutes).
If the project has existing GitHub Actions workflows that need to gate on
Garnix checks, use the `check_suite` event:

```yaml
on:
  check_suite:
    types: [completed]
```

This fires once per non-GitHub-Actions check-suite completion (i.e., when
Garnix finishes all builds for a commit). See the
[Garnix GitHub Actions Integration docs](https://garnix.io/docs/ci/gh-actions)
for details.

**Skip if:** The maintainer has not expressed interest in hosted Nix CI, or
the project already has a robust cross-platform GitHub Actions matrix.

---

## Release-Triggered Hash Automation

For the **Prebuilt Tarball Flake** path, every release requires bumping `version` and refreshing the
per-platform `sha256` hashes in `flake.nix`. Doing this by hand is the #1 objection maintainers raise
to accepting a repo-owned flake ("I don't know Nix and this adds per-release maintenance"). Automation
removes that burden entirely: it bumps the version, refreshes hashes, and opens a PR — zero Nix
knowledge required from the maintainer.

**This is a required deliverable for release-based repos using the Prebuilt Tarball Flake, not an
optional extra.** Without it, the flake rots one release after merge.

### Tooling: nix-update + nix-update-action

This skill uses [nix-update](https://github.com/Mic92/nix-update) (by Mic92) for hash generation —
the standard, maintained tool that handles version detection and FOD hash updates for all languages
the skill supports (Rust `cargoHash`, Go `vendorHash`, npm `npmDepsHash`, pnpm, Yarn, PHP, Maven,
.NET, Elixir, Zig, and custom dependency hashes via `--custom-dep`). It also handles prebuilt
tarball `fetchurl`/`fetchzip` hashes via `nix store prefetch-file` under the hood.

The GitHub Action wrapper [winapps-org/nix-update-action](https://github.com/winapps-org/nix-update-action)
(maintained fork of `selfuryon/nix-update-action`) runs nix-update on a schedule and opens a PR
automatically. This replaces the custom Python prefetch scripts this skill previously shipped —
nix-update covers more FOD types, is actively maintained, and doesn't require the contributor to
hand-write a hash-rewrite script per project.

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
   `release: published` trigger below.
3. If it uses **`secrets.GITHUB_TOKEN`** (the common case, including all cargo-dist setups) ->
   `release: published` will NOT fire. Use the **scheduled** trigger below instead. It runs daily,
   compares `flake.nix`'s `version` to the latest GitHub release, and only acts when they differ.
   Fully decoupled from how releases are created; needs no PAT and no edits to the release pipeline.

### Template A: scheduled lag-check (recommended for `GITHUB_TOKEN`-created releases)

Runs daily (and on manual dispatch). When the latest GitHub release outpaces `flake.nix`'s pinned
`version`, nix-update bumps the version and refreshes hashes, then opens a PR. No dependency on the
release event, no PAT, no edits to the release pipeline.

**Create `.github/workflows/nix-release.yml`:**

```yaml
name: Update Nix flake

# Checks whether flake.nix lags behind the latest GitHub release. If it does,
# nix-update bumps the version and refreshes per-platform FOD hashes, then
# opens a PR.
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
  # id-token: write is required by magic-nix-cache-action for the GitHub
  # Actions cache v2 API (OIDC token exchange for cache auth).
  id-token: write

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

      - name: Enable Nix binary cache (GitHub Actions cache)
        # Caches nix-update's --build verification output between daily runs.
        # Without this, each daily lag-check rebuilds the package from scratch
        # to verify the hash — wasted cycles when nothing changed.
        uses: DeterminateSystems/magic-nix-cache-action@v13

      - name: Update flake via nix-update
        uses: winapps-org/nix-update-action@v1.3.0
        with:
          # The flake attribute to bump (e.g. "default", "prebuilt", or the
          # project name). nix-update detects the latest version from GitHub
          # releases and updates the version + all FOD hashes (fetchurl,
          # cargoHash, npmDepsHash, vendorHash, etc.) in one pass.
          packages: default
          # Run nix-update --flake so it operates on the flake output, not a
          # nixpkgs package path.
          extra-args: --flake --build
          # Author/committer identity for the PR commit.
          git-author-name: 'github-actions[bot]'
          git-author-email: 'github-actions[bot]@users.noreply.github.com'
          git-committer-name: 'github-actions[bot]'
          git-committer-email: 'github-actions[bot]@users.noreply.github.com'
```

### Template B: `release: published` (only if releases are created with a PAT/App token)

Use this only when the decision tree above confirmed the release is created with a PAT or
GitHub App token (not `secrets.GITHUB_TOKEN`). Otherwise this workflow will silently never fire.

```yaml
name: Update Nix flake

on:
  release:
    types: [published]

permissions:
  contents: write
  pull-requests: write
  id-token: write

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

      - name: Enable Nix binary cache (GitHub Actions cache)
        uses: DeterminateSystems/magic-nix-cache-action@v13

      - name: Update flake via nix-update
        uses: winapps-org/nix-update-action@v1.3.0
        with:
          packages: default
          extra-args: --flake --build
          git-author-name: 'github-actions[bot]'
          git-author-email: 'github-actions[bot]@users.noreply.github.com'
          git-committer-name: 'github-actions[bot]'
          git-committer-email: 'github-actions[bot]@users.noreply.github.com'
```

**Customization notes (both templates):**
- `packages`: the flake attribute to bump. Use `default` for the standard `#default` output, or the project name for `#<project-name>`. For prebuilt tarball flakes with separate `#prebuilt` and `#source` outputs, bump `default` (which aliases `#prebuilt`).
- `extra-args: --flake --build`: `--flake` tells nix-update to operate on the flake output (not a nixpkgs package path). `--build` verifies the update by building the package after bumping — catches hash mismatches before the PR is opened. Drop `--build` if the build takes too long for a scheduled job.
- `if: github.repository == '<owner>/<repo>'` (Template A): prevents the scheduled job from running on forks. Replace with the upstream owner/repo.
- **What nix-update handles automatically**: version detection from GitHub releases (also GitLab, crates.io, npm, PyPI, etc.), `fetchurl`/`fetchzip` hash refresh, and all language-specific FOD hashes (Rust `cargoHash`, Go `vendorHash`, npm `npmDepsHash`, pnpm, Yarn, PHP, Maven, .NET, Elixir, Zig, custom via `--custom-dep`). This replaces the custom Python prefetch scripts this skill previously shipped.
- **Platform-gated FOD hashes (npm/Bun with native addons)**: nix-update on ubuntu computes platform-independent FOD hashes (Rust, Go, prebuilt tarballs) correctly. For platform-gated FODs (npm `npmDepsHash` with `@esbuild/*`-style optional deps), the hash differs per platform and nix-update on ubuntu can only compute the linux hash. The `x86_64-darwin` and `aarch64-darwin` hashes for platform-gated FODs are computed by the validate job in `nix.yml` (see [Self-Pruning on Runner Decommission](#self-pruning-on-runner-decommission) below) which runs `nix build .#source` on the target platform and captures the "got" hash from the fakehash error.
- PRs opened by `GITHUB_TOKEN` (both templates) do not trigger downstream CI workflows. The diff is a version bump plus per-platform hash refresh with no source changes. **Review the diff before merging** — do not self-declare "safe to merge as-is" in the PR body. If CI on the bump PR is required, use a PAT for the action (but that reintroduces secret-management burden).
- To make it fully hands-off, add a final `gh pr merge --merge --auto` step (with `env: GH_TOKEN: ${{{ "{{" }}} secrets.GITHUB_TOKEN {{{ "}}" }}}`) or enable auto-merge on the branch via repository settings. **Only do this if the project explicitly accepts auto-merged hash bumps** — some maintainers consider unreviewed merges a security concern (Archon PR #2131 feedback cited the `contents: write` + `pull-requests: write` self-declared unreviewed-merge path as a declining reason).
- Pin `winapps-org/nix-update-action` to a commit SHA (with `# v1.3.0` comment) if the project's existing workflows pin actions — match the repo's convention.

**Hybrid fallback interaction (partial platform coverage):** When the flake uses the Hybrid Fallback Variant from `references/flake-templates/prebuilt-tarball.md` (`hybrid_fallback=true` from Step 12), nix-update bumps the version and prebuilt tarball hashes for platforms that have release assets. The `#source` output on fallback platforms (platforms without a prebuilt binary) is NOT hash-automated by nix-update: it builds from source at the git tag, so it tracks the commit, not release assets. This is correct and requires no special handling. The `#source` outputs on fallback platforms are validated by the Nix CI workflow (`nix build .#source`), not by the hash automation. If a project later adds a prebuilt binary for a previously-missing platform, the next nix-update run will populate its hash automatically.

**CI blind spot — cross-platform hash validation:** `nix flake check --all-systems --no-build` evaluates every system's outputs without realising fetchurl derivations, so a fetch-hash mismatch is invisible at evaluation time. `nix build .#default` only runs on the runner's own system (typically `ubuntu-latest`), so it cannot catch a hash mismatch on `x86_64-darwin` or `aarch64-darwin`. nix-update's `--build` flag catches hash mismatches for the runner's own platform (linux), but not for darwin. For projects that need stronger cross-platform validation, add a matrix build to `nix.yml` that runs `nix build .#default` on `macos-26` (ARM) and `macos-26-intel` (Intel) in addition to `ubuntu-latest`. This catches hash mismatches and Darwin-specific build failures that `--all-systems --no-build` and nix-update's `--build` cannot see.

**How it addresses maintainer objections:** the maintainer cuts a release exactly as they do today; nix-update-action opens a PR with the bumped `flake.nix`. Reviewing a small diff (version + hashes) needs no Nix knowledge. Merge -> `nix run github:<owner>/<repo>` serves the new release. The scheduled variant (Template A) adds no PAT, no release-pipeline edits, and no per-release manual step of any kind.

**Verification (do this before opening the PR):** the automation workflow itself is not exercised by the PR's CI (it mutates `main` post-publish and runs on a schedule, not on push). Confirm it evaluates by triggering it manually on the PR branch:

```bash
# From the PR branch, after pushing:
gh workflow run "Update Nix flake" --ref <pr-branch-name>
# Then watch the run — it should report "flake.nix is up to date; nothing to do."
# (because the flake version already matches the latest release on the PR branch).
gh run watch
```

A clean "up to date, nothing to do" run proves the workflow's Nix install, nix-update-action invocation, and GitHub API access all work. The actual hash-rewrite path is only exercised when a real new release outpaces the flake, but the manual run catches config/parse errors before merge. (This is the "can't be exercised by this PR's CI" gap that led nubjs/nub#169 to defer automation — the manual `workflow_dispatch` run closes it.)

**Skip if:** the project does not publish release tarballs (use a source-build flake instead), or already automates flake updates via another mechanism (e.g. `update-flake-lock` action).

---

## Self-Pruning on Runner Decommission

When GitHub Actions decommissions the Intel macOS runner (`macos-26-intel`, estimated ~Nov 2028 per
[actions/runner-images#13739](https://github.com/actions/runner-images/issues/13739)), the
`validate-x86-darwin` job in `nix.yml` fails with "no runner available." The `self-prune` job
detects this failure and opens a PR to handle the transition — either updating to a newer runner
label (if GitHub ships one) or commenting out the dead job and swapping `x86_64-darwin` source-build
FOD hashes to `lib.fakeHash`.

### Design

The `self-prune` job runs on `ubuntu-latest`, triggered by `validate-x86-darwin` failure. It does
NOT use a date gate — it fires purely on runner-failure detection, so it works correctly regardless
of when GitHub actually decommissions the runner (the estimated Nov 2028 date may shift).

**Decision flow:**

1. Query the GitHub API for `actions/runner-images` directory listing under `images/macos/`.
2. Filter directory names matching `macos-*-intel`.
3. Compare the newest matching label against the current label (`macos-26-intel`).
4. **If a newer label exists** (e.g. `macos-27-intel`): open a PR that updates `runs-on: macos-26-intel`
   to the newer label in `nix.yml`. PR body explains: "macos-26-intel was decommissioned; updated to
   macos-27-intel (the current Intel macOS runner label). No other changes needed."
5. **If no newer label exists**: open a PR that (a) comments out the `validate-x86-darwin` job with
   re-enablement instructions, (b) adds a warning job that emits a `::warning::` annotation, and
   (c) swaps `x86_64-darwin` source-build FOD hashes to `lib.fakeHash` in `flake.nix`. PR body
   explains the decommission + re-enablement path + links to the GitHub announcement.

### Template: self-prune job (add to `.github/workflows/nix.yml`)

```yaml
  self-prune:
    name: Self-prune dead Intel macOS runner
    runs-on: ubuntu-latest
    if: always() && needs.validate-x86-darwin.result == 'failure'
    needs: [validate-x86-darwin]
    permissions:
      contents: write
      pull-requests: write

    steps:
      - name: Checkout
        uses: actions/checkout@v6
        with:
          persist-credentials: false

      - name: Check for newer Intel macOS runner label
        id: check-label
        run: |
          set -euo pipefail
          CURRENT="macos-26-intel"
          # Query the actions/runner-images repo for available macOS runner directories.
          # The directory structure is the closest public signal for runner label availability.
          LABELS=$(curl -fsSL \
            "https://api.github.com/repos/actions/runner-images/contents/images/macos" \
            | python3 -c '
          import json, sys
          entries = json.load(sys.stdin)
          intel = [e["name"] for e in entries
                   if e["type"] == "dir" and e["name"].endswith("-intel")]
          print("\n".join(sorted(intel)))
          ')
          NEWEST=$(echo "$LABELS" | tail -1)
          echo "current=$CURRENT" >> "$GITHUB_OUTPUT"
          echo "newest=$NEWEST" >> "$GITHUB_OUTPUT"
          if [ -n "$NEWEST" ] && [ "$NEWEST" != "$CURRENT" ]; then
            echo "newer=true" >> "$GITHUB_OUTPUT"
            echo "Found newer Intel macOS runner label: $NEWEST (current: $CURRENT)"
          else
            echo "newer=false" >> "$GITHUB_OUTPUT"
            echo "No newer Intel macOS runner label available (current: $CURRENT)"
          fi

      - name: Open PR to update runner label
        if: steps.check-label.outputs.newer == 'true'
        uses: peter-evans/create-pull-request@v7
        with:
          commit-message: "chore(ci): update Intel macOS runner from ${{{ steps.check-label.outputs.current }}} to ${{{ steps.check-label.outputs.newest }}}"
          title: "chore(ci): update Intel macOS runner label"
          branch: chore/ci-update-intel-runner
          body: |
            The `macos-26-intel` GitHub Actions runner was decommissioned and the
            `validate-x86-darwin` job failed with "no runner available."

            A newer Intel macOS runner label is available:
            `${{{{ steps.check-label.outputs.newest }}}}`.

            This PR updates `runs-on:` in the `validate-x86-darwin` job to the
            newer label. No other changes are needed.

            Source: https://github.com/actions/runner-images/issues/13739

      - name: Open PR to comment out dead job + swap to fakeHash
        if: steps.check-label.outputs.newer == 'false'
        run: |
          # Comment out the validate-x86-darwin job in nix.yml and add a warning
          # job + swap x86_64-darwin FOD hashes to lib.fakeHash in flake.nix.
          # This is a text transformation — see the commented-out job block below
          # for the exact replacement text.
          python3 <<'PYEOF'
          import re
          # 1. Comment out validate-x86-darwin job in .github/workflows/nix.yml
          wf = open(".github/workflows/nix.yml").read()
          # The job block is replaced with a commented-out version + warning job.
          # See the template below for the exact replacement.
          # 2. Swap x86_64-darwin FOD hashes to lib.fakeHash in flake.nix
          flake = open("flake.nix").read()
          # Replace real SRI hashes for x86_64-darwin with lib.fakeHash
          # Pattern: "x86_64-darwin" = { ... sha256 = "sha256-..."; ... }
          flake = re.sub(
              r'("x86_64-darwin" = \{[^}]*sha256 = ")[^"]*(";)',
              r'\1lib.fakeHash\2',
              flake, flags=re.S)
          open("flake.nix", "w").write(flake)
          print("Swapped x86_64-darwin FOD hashes to lib.fakeHash")
          PYEOF

      - name: Open PR for fakeHash swap
        if: steps.check-label.outputs.newer == 'false'
        uses: peter-evans/create-pull-request@v7
        with:
          commit-message: "chore(ci): decommission macos-26-intel — comment out validate-x86-darwin, swap to lib.fakeHash"
          title: "chore(ci): handle macos-26-intel decommission"
          branch: chore/ci-decommission-intel-runner
          body: |
            The `macos-26-intel` GitHub Actions runner was decommissioned and the
            `validate-x86-darwin` job failed with "no runner available." No newer
            Intel macOS runner label is currently available.

            This PR:
            1. Comments out the `validate-x86-darwin` job with re-enablement
               instructions (see the commented block in `.github/workflows/nix.yml`)
            2. Adds a warning job that emits a `::warning::` annotation on every
               CI run so the gap is visible, not buried in git history
            3. Swaps `x86_64-darwin` source-build FOD hashes to `lib.fakeHash`
               in `flake.nix` — an honest "unverified" signal

            To re-enable x86_64-darwin validation in the future:
            1. Check for a newer Intel macOS runner label:
               https://github.com/actions/runner-images/tree/main/images/macos
               (look for any `macos-*-intel` directory newer than `macos-26-intel`)
            2. If a newer label exists, uncomment `validate-x86-darwin` and update
               `runs-on:` to the new label
            3. If using a self-hosted Intel Mac runner, uncomment and set
               `runs-on:` to your self-hosted label
               (https://docs.github.com/en/actions/hosting-your-own-runners/managing-self-hosted-runners-with-github-actions)
            4. After re-enabling, run `nix build .#source --system x86_64-darwin`
               to compute the real FOD hash, replace `lib.fakeHash`, and open a PR

            Source: https://github.com/actions/runner-images/issues/13739
```

### Commented-out job block (what the self-prune PR produces)

When the self-prune PR comments out `validate-x86-darwin`, it replaces the job with this block so
the re-enablement path is visible in the file itself:

```yaml
# DECOMMISSIONED: macos-26-intel was scheduled for decommission by GitHub
# Actions (~Nov 2028 per https://github.com/actions/runner-images/issues/13739).
# This job is commented out to prevent CI failures from "no runner available."
#
# To re-enable:
# 1. Check for a newer Intel macOS runner label:
#    https://github.com/actions/runner-images/tree/main/images/macos
#    (look for any macos-*-intel directory newer than macos-26-intel)
# 2. If a newer label exists, uncomment this job and update runs-on below
# 3. If using a self-hosted Intel Mac runner, uncomment and set runs-on to
#    your self-hosted label
# 4. If no Intel macOS runner is available, x86_64-darwin source-build FOD
#    hashes are set to lib.fakeHash in flake.nix — a community user with an
#    Intel Mac can compute the real hash via `nix build .#source` and open a PR
# validate-x86-darwin:
#   runs-on: macos-26-intel  # ← update to newer label if available
#   needs: detect-platforms
#   steps:
#     - uses: actions/checkout@v6
#     - uses: cachix/install-nix-action@v31
#     - uses: DeterminateSystems/magic-nix-cache-action@v13
#     - run: nix build .#source --system x86_64-darwin
#     - run: nix run .#default --system x86_64-darwin -- --version

validate-x86-darwin-warning:
  runs-on: ubuntu-latest
  if: ${{ false }}  # re-enable when an Intel macOS runner is available
  # NOTE: This job replaces validate-x86-darwin after macos-26-intel was
  # decommissioned. It emits a warning so the gap is visible in every CI
  # run, not buried in git history. Uncomment validate-x86-darwin above
  # and delete this job when an Intel macOS runner is available again.
  steps:
    - name: x86_64-darwin validation unavailable
      run: |
        echo "::warning::x86_64-darwin validation is disabled — macos-26-intel runner was decommissioned by GitHub Actions. x86_64-darwin source-build FOD hashes are set to lib.fakeHash. See commented validate-x86-darwin job above for re-enablement instructions."
```

### Honest limitations

- **The API check looks at the runner-images repo's directory structure**, not GitHub's actual runner availability. There can be a lag between a directory appearing and the label being usable in workflows. The PR body includes the direct link so a human can verify before uncommenting.
- **The `self-prune` job fires on any `validate-x86-darwin` failure**, not just runner decommission. A transient outage or a real build failure would also trigger it. The PR body makes the assumption explicit ("failed with 'no runner available'") — a human reviewing the PR can distinguish "runner gone" from "build broke" and close the PR if it's the latter. This is a deliberate tradeoff: a date gate would prevent false positives but would also delay the self-prune if GitHub decommissions the runner earlier than estimated.
- **The `lib.fakeHash` swap is a regex replacement** that targets the `assets = { "x86_64-darwin" = { ... sha256 = "..."; ... }; }` shape from the Prebuilt Tarball Flake template. For other flake shapes (source-build with per-platform FOD hashes), adapt the regex in the Python script.

### Context-aware error messages

The flake itself provides context-aware error messages so users in different situations see the right message:

| Context | What happens | Error message |
|----------|-------------|---------------|
| CI: Intel macOS runner decommissioned | `validate-x86-darwin` fails with "no runner available" | Self-prune PR explains the runner retirement + what was changed |
| User: tries `nix build` on unsupported platform (e.g. Linux user, Mac-only project) | Nix error from `meta.platforms` | "This project is Mac-only (uses macOS UI frameworks). It doesn't expose Linux targets. To build from source on macOS, see <link>." |
| User: tries `nix build .#source` on x86_64-darwin after runner death (hash is `lib.fakeHash`) | Nix error from fakehash mismatch | "The x86_64-darwin source-build hash is unverified (set to lib.fakeHash after GitHub's Intel macOS runner was decommissioned). Run `nix build .#source` on an Intel Mac to compute the real hash, then open a PR with the updated hash." |

These three errors never overlap — each context gets exactly one message. The error messages are
implemented via a shared snippet in `references/snippets/unsupported-platform-throw.md` that all
flake templates include. See that file for the Nix `throw` implementation.

---

## Cachix Integration (Binary Caching)

**When to use Cachix vs Magic Nix Cache:**

| Need | Use |
|------|-----|
| Speed up repeated CI runs in one repo (free, zero-config) | `DeterminateSystems/magic-nix-cache-action@v13` (already in the `nix.yml` template above) |
| Share Nix build outputs across machines, teammates, or multiple repos | Cachix (this section) |
| Both | Add Magic Nix Cache to the workflow for per-run caching, and Cachix for the shared cache that users outside CI can also pull from |

Magic Nix Cache is free and zero-config but its cache is scoped to a single workflow in a single
repository — a developer running `nix build` on their laptop cannot pull from it. Cachix provides a
proper Nix binary cache that any Nix user can configure as a substituter, including developers
outside CI. The two are complementary, not mutually exclusive.

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
