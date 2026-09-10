# NixOS Service Module

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

## Create the module structure

```bash
mkdir -p nix/modules/nixos
```

## Create `nix/modules/nixos/default.nix`

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

## Expose the module as a flake output

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

## Consuming `detect-runtime-deps.sh` output

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

## `.env`-strict projects

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

## Skip if

- The project is a CLI tool, not a long-running service (use the
  Home-Manager Module instead)
- The project is a library (no service to run)
- The project only runs in a container and has no native service mode
  (document the container deployment in the orientation issue instead)
