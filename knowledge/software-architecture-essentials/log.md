# Directory Update Log

## 2026-07-18

* **Initialization**: Created the `software-architecture-essentials` knowledge bundle to consolidate architectural practices from the `src/current/rules/software-dev/general/architecture/` rule files.
* **Creation**: Authored 10 concept pages covering philosophy, project structure, data access, configuration, distribution, theming, terminal state, tool detection, extensibility, and auth/environment.
  - [philosophy.md](philosophy.md) — domain-based modular architecture
  - [project-structure.md](project-structure.md) — domain-first hierarchical package structure
  - [data-access-layer.md](data-access-layer.md) — centralized data access with security checkpoint
  - [configuration-system.md](configuration-system.md) — layered config precedence with validation
  - [distribution.md](distribution.md) — single-binary/minimal-runtime distributions
  - [theme-system.md](theme-system.md) — single source of truth for palettes/variants
  - [terminal-state.md](terminal-state.md) — minimal terminal control sequences
  - [tool-detection.md](tool-detection.md) — PATH-first detection with caching
  - [adding-tools.md](adding-tools.md) — consistent procedure for wiring new tools
  - [auth-env.md](auth-env.md) — CI/SSH/Docker/Codespaces detection and headless auth
* **Creation**: Established [overview.md](overview.md) synthesis and [index.md](index.md) directory listing.
* **Note**: Concepts migrated from `src/current/rules/software-dev/general/architecture/*.md` (10 files).
