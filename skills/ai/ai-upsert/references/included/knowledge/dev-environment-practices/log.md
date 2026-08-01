# Directory Update Log

## 2026-07-30

* **Ingest**: Created [devbox-broken-override.md](devbox-broken-override.md) —
  documents the practice for when devbox cannot build the environment at all
  (nixpkgs pin missing a package on a specific platform, e.g., the `jujitsu`
  package missing on Intel Macs). Distinct from the script generation bug
  (which is a v0.14.x regression where `devbox run <script>` fails but
  `devbox run -- <cmd>` works). The override practice: replace
  devbox-wrapped commands with direct package-manager equivalents
  (`pnpm exec vitest run` instead of `devbox run -- just test-internal`), and
  document the override in the project's execution workflow file so subagents
  use the direct form without re-discovering the breakage on every story.
  Sourced from the seodata-execute workflow (commit 2c23734). Added to
  [index.md](index.md) and [overview.md](overview.md.tmpl) table.

## 2026-07-28

* **Update**: Renamed `internal-vs-normal-targets.md` concept to "Auto-Detecting Devbox Targets" — replaced the two-tier `just build` / `just build-internal` / `devbox run build` pattern with a single-target auto-detection pattern using a DRY `_devbox` helper recipe. Implementation targets renamed from `*-internal` to `*_impl` (underscore-prefixed to hide from `just --list`). `doctor` is special-cased to run directly (it's the fallback when devbox is missing).
* **Update**: Updated [standard-developer-ux-flow.md](standard-developer-ux-flow.md) — all three flows now use `just build` (auto-detecting). No more `devbox run -- just build-internal` in Flow 1. Added `_devbox` helper documentation.
* **Update**: Updated [devbox-script-generation-bug.md](devbox-script-generation-bug.md) — added section explaining why auto-detection makes the script generation bug largely irrelevant (`just build` uses `devbox run --` raw form, not `devbox run <script>`).
* **Update**: Updated [async-prime-internal.md](async-prime-internal.md) — renamed `prime-internal` → `prime_impl`, `build-internal` → `build_impl`, `bootstrap-internal` → `bootstrap_impl` throughout. Updated `.envrc` trigger and three-entry-paths section.
* **Update**: Updated [just-over-makefiles.md](just-over-makefiles.md), [mandatory-testing-workflow.md](mandatory-testing-workflow.md), [devbox-over-raw-nix.md](devbox-over-raw-nix.md) — updated code examples to use `*_impl` targets and `just _devbox` pattern.

## 2026-07-26
* **Migration**: Migrated `## Citations` body sections to `sources` frontmatter with stable `id` attributes per OKF v0.2 §13.1.
* **Migration**: Migrated bundle from OKF v0.1 to OKF v0.2 — bumped `okf_version` in index.md. No `# Citations` sections or `timestamp` fields to migrate.

## 2026-07-20

* **Creation**: Authored [async-prime-internal.md](async-prime-internal.md) — documents the two-phase prime pattern: Phase 1 (sync) git checkpoint commit (no push, follows pre-task-commit-checkpoint protocol from git-repository-management skill, skippable via PRIME_SKIP_CHECKPOINT=1); Phase 2 (async, fire-and-forget) cache-warming jobs (package downloads, build, recipe list, API doc generation) in parallel. Verification gates (typecheck/test/validate) stay synchronous and blocking. Includes the `.envrc` async trigger (gated by direnv allow + `DEVBOX_SHELL_ENABLED` check) and the sync/async split rule.
* **Update**: Updated [standard-developer-ux-flow.md](standard-developer-ux-flow.md) — added Prime Flow section documenting the two-phase pattern (sync checkpoint + async warmup) and the rule that verification gates stay synchronous.
* **Update**: Updated [internal-vs-normal-targets.md](internal-vs-normal-targets.md) — clarified `prime`/`prime-internal` as sync checkpoint + async warmup (not just "code indexing") with cross-link to async-prime-internal.md.

## 2026-07-17

* **Initialization**: Created the `dev-environment-practices` knowledge bundle to consolidate developer environment practices from three ADRs in levonk-base-boilerplate.
* **Creation**: Authored 8 concept pages covering the dev environment evolution from Nix flakes to devbox to the standard UX flow.
  - [nix-flake-dev-shells.md](nix-flake-dev-shells.md) — original Nix flake approach (superseded)
  - [devbox-over-raw-nix.md](devbox-over-raw-nix.md) — devbox migration from raw Nix
  - [direnv-auto-activation.md](direnv-auto-activation.md) — automatic environment activation
  - [standard-developer-ux-flow.md](standard-developer-ux-flow.md) — three-flow pattern for agents, novices, power users
  - [just-over-makefiles.md](just-over-makefiles.md) — just as task runner replacement for Make
  - [internal-vs-normal-targets.md](internal-vs-normal-targets.md) — *-internal naming convention
  - [devbox-script-generation-bug.md](devbox-script-generation-bug.md) — known v0.14.x regression and workarounds
  - [mandatory-testing-workflow.md](mandatory-testing-workflow.md) — TDD, regression tests, quality gates
* **Creation**: Established [overview.md](overview.md) synthesis and [index.md](index.md) directory listing.
* **Note**: Concepts extracted from ADR-20251219001 (Nix flake, superseded), ADR-20251226001 (devbox+direnv, accepted), and ADR-20260131001 (standard UX flow, proposed) in levonk-base-boilerplate.
