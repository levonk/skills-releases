---
type: Synthesis
title: Dev Environment Practices Overview
description: Synthesis of dev environment practices — Nix foundations, devbox migration, direnv auto-activation, just task runner, standard UX flow, script generation bugs, and mandatory testing workflow.
tags: [dev-environment, nix, devbox, direnv, just, developer-experience, overview, synthesis]
timestamp: 2026-07-17T00:00:00Z
---

# Dev Environment Practices Overview

This bundle documents practices for creating reproducible, low-friction developer
environments. Each concept was extracted from real ADRs and project migrations —
the evolution from raw Nix flakes to devbox, the standardization on just over
Makefiles, the three-flow developer UX pattern, and the mandatory testing
workflow that gates all changes.

## The Dev Environment Evolution

```
nix-flake → devbox → direnv → just → standard-ux-flow → testing-gates
```

Each phase has practices that prevent specific failure modes:

| Phase | Practice | Prevents |
|-------|----------|----------|
| Foundation | [Nix Flake Dev Shells](nix-flake-dev-shells.md) | Missing tools, inconsistent local setups, "works on my machine" |
| Migration | [Devbox Over Raw Nix](devbox-over-raw-nix.md) | Steep Nix learning curve, verbose flake.nix, poor developer UX |
| Activation | [direnv Auto-Activation](direnv-auto-activation.md) | Manual environment sourcing, forgotten activation, stale shells |
| Task Runner | [Just Over Makefiles](just-over-makefiles.md) | .PHONY confusion, file-name collisions, complex variable syntax |
| Workflow | [Standard Developer UX Flow](standard-developer-ux-flow.md) | Inconsistent commands across projects, AI agent environment drift |
| Targets | [Internal vs Normal Targets](internal-vs-normal-targets.md) | Double-wrapping devbox run, unclear target responsibilities |
| Reliability | [Devbox Script Generation Bug](devbox-script-generation-bug.md) | Silent script failures, "command not found" in CI |
| Quality | [Mandatory Testing Workflow](mandatory-testing-workflow.md) | Untested changes, regressions, missing quality gates |
| Scripts | [Shell Scripting Best Practices](shell-scripting-best-practices.md) | Unsafe shell scripts, missing dry-runs, untested scripts, dirty repo state |

## Scope

This bundle covers **developer environment management and workflow patterns** —
the tools, configuration, and processes that ensure every developer and AI agent
works in the same reproducible environment. It does **not** cover:

- Build system orchestration (Nx, Turborepo) — see
  [typescript-monorepo-best-practices](../typescript-monorepo-best-practices/overview.md).
- Container build environments — see
  [container-best-practices](../container-best-practices/overview.md).
- CI/CD pipeline configuration — separate bundle.
- IDE-specific configuration (editor settings, extensions) — separate bundle.

## Relationship to ADRs

The concepts in this bundle were extracted from three ADRs in the
levonk-base-boilerplate repository:

- ADR-20251219001: Nix flake + direnv (superseded)
- ADR-20251226001: Devbox + direnv (accepted, supersedes 20251219001)
- ADR-20260131001: Standard Developer UX Flow (proposed, latest)

The ADRs document the decision-making process; this bundle extracts the
**generalizable practices** that can be applied to any project.

## Sources

- `internal-docs/adr/adr-20251219001-nix-direnv-dev-environment.md` — boilerplate
- `internal-docs/adr/adr-20251226001-devbox-direnv-dev-environment.md` — boilerplate
- `internal-docs/adr/adr-20260131001-standard-developer-ux-flow.md` — boilerplate

## Compounding

New lessons from future environment work — new tool integrations, performance
tuning, cross-platform issues, devbox version regressions — should be filed as
new concept pages. Append to `log.md` when adding.

Future concept candidates (not yet in the bundle):

- `remote-dev-environments.md` — devcontainer, GitHub Codespaces, remote Nix
- `multi-language-devbox.md` — managing Python + Rust + Node in one devbox
- `devbox-caching.md` — Nix store caching, binary cache configuration
- `shell-startup-performance.md` — measuring and optimizing direnv activation time

The shell scripting practices — strict mode, PATH guards, git cleanliness gates,
dry-run patterns, and shellcheck/shfmt/bats verification — are captured in
[Shell Scripting Best Practices](shell-scripting-best-practices.md), migrated
from the platform shell rules.

## Related Knowledge Bundles

- [typescript-monorepo-best-practices](../typescript-monorepo-best-practices/overview.md)
  — Monorepo build orchestration that runs inside the dev environment.
- [container-best-practices](../container-best-practices/overview.md) — Container
  build environments that complement local dev environments.
- [upstream-contribution-practices](../upstream-contribution-practices/overview.md)
  — Contribution workflow that depends on consistent local environments.

## Citations

[1] `internal-docs/adr/adr-20251219001-nix-direnv-dev-environment.md` — levonk-base-boilerplate
[2] `internal-docs/adr/adr-20251226001-devbox-direnv-dev-environment.md` — levonk-base-boilerplate
[3] `internal-docs/adr/adr-20260131001-standard-developer-ux-flow.md` — levonk-base-boilerplate
