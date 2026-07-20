# Directory Update Log

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
