## Devenv vs mkShell

[devenv](https://devenv.sh) is a popular Nix-based dev environment tool built on
top of flakes. It provides managed services, language ecosystems, and a CLI
workflow (`devenv shell`, `devenv up`, `devenv test`). For most nixify targets,
plain `mkShell` in the flake's `devShells.default` is the right choice — devenv
adds a heavy flake input and complexity that is overkill for simple projects.
This section documents when each is appropriate.

### Use plain mkShell when

This is the **common case** for C/C++/Rust/Go projects with standard build
systems. The project just needs build tools from nixpkgs — compilers, CMake,
Ninja, pkg-config, Qt, OpenSSL, etc. — and nothing more.

```nix
devShells.default = pkgs.mkShell {
  buildInputs = with pkgs; [
    cmake
    ninja
    pkg-config
    openssl
    qt6.qtbase
  ];
};
```

Characteristics:
- No managed services (no databases, redis, message queues to start/stop)
- No special language ecosystem management (no `devenv.languages.rust.enable`
  style features needed)
- No devcontainer parity requirement
- The `devShells.default` output is sufficient — `nix develop` works

### Use devenv when

The project needs capabilities that exceed what a plain `mkShell` provides:

- **Managed services**: databases (PostgreSQL, MySQL), Redis, message queues
  (RabbitMQ), search engines (Elasticsearch, Meilisearch) that should start/stop
  with the dev environment (`devenv services.postgres.enable = true`). With
  `mkShell` you would have to manage these manually or via a separate
  `docker-compose.yml`.
- **Multi-language ecosystems with complex setup**: projects that combine
  multiple language toolchains where devenv's `languages` module provides
  value beyond what listing packages in `mkShell` does (e.g. integrated
  Python venv + Node.js + PostgreSQL with automatic wiring).
- **Devcontainer parity**: the project already uses devcontainers and wants
  a Nix-native equivalent that provides the same services and tooling.
- **Established devenv CLI workflow**: the project or team already uses
  `devenv shell` / `devenv up` / `devenv test` and the flake should support
  that workflow rather than introducing `nix develop`.

A minimal devenv shell (`devenv.nix`):

```nix
{ pkgs, ... }:

{
  languages.rust.enable = true;

  services.postgres = {
    enable = true;
    listen_addresses = "127.0.0.1";
    initialDatabases = [{ name = "myapp"; }];
  };
}
```

### Trade-offs

devenv is not free — it adds real cost to the flake:

- **Heavy flake input**: `cachix/devenv` is a large input with its own
  dependency tree. It increases `flake.lock` size, evaluation time, and
  the Nix store footprint for every consumer of the flake — not just those
  who use the dev shell.
- **`nixConfig` block**: devenv requires a `nixConfig` block in `flake.nix`
  pointing at the devenv Cachix cache (`devenv.cachix.org`). This is the
  same `nixConfig` mechanism documented in
  [Upstream Cache Consumption (nixConfig)](upstream-cache-consumption.md)
  — it forces every user of the flake to trust an additional substituter
  and public key. For a project that only needs `cmake` and `openssl` in
  its dev shell, this is unjustified complexity.
- **More moving parts**: devenv introduces `devenv.nix`, `devenv.yaml`,
  the `devenv` CLI, and its own module system on top of the flake. This is
  more surface area to maintain, review, and explain to contributors who
  just want `nix develop`.

```nix
# The nixConfig block devenv requires — added to every flake that uses it
nixConfig = {
  extra-substituters = [ "https://devenv.cachix.org" ];
  extra-trusted-public-keys = [
    "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
  ];
};
```

### Decision summary

| Need | Recommendation |
|------|----------------|
| Build tools only (compilers, CMake, Qt, OpenSSL) | `mkShell` |
| Managed services (databases, redis, queues) | devenv |
| Multi-language ecosystem with automatic wiring | devenv |
| Devcontainer parity | devenv |
| Established `devenv` CLI workflow | devenv |
| Simple C/C++/Rust/Go project, standard build system | `mkShell` |

**Default to `mkShell`.** Only reach for devenv when the project has a concrete
need that `mkShell` cannot meet — managed services, complex multi-language
wiring, or an established devenv workflow. Adding devenv to a project that
only needs `cmake` and `ninja` in its dev shell is overkill and increases
maintenance burden for no benefit.

**Skip devenv if:** the project only needs build tools from nixpkgs, has no
managed services, and has no established devenv workflow. Use `mkShell` in
`devShells.default` instead.
