---
okf_version: "0.2"
---

# Dev Environment Practices

A compounding knowledge base documenting practices for reproducible developer
environments — the toolchain, workflow patterns, and configuration that make
"works on my machine" a thing of the past. Each concept captures a specific
failure mode and the practice that prevents it, sourced from real ADRs and
project migrations.

## Concepts

* [Overview](overview.md) - Synthesis of the full dev environment practice set and how the pieces fit together
* [Nix Flake Dev Shells](nix-flake-dev-shells.md) - Per-project reproducible tooling via flake.nix; superseded by devbox but documents the foundation
* [Devbox Over Raw Nix](devbox-over-raw-nix.md) - Why devbox.json replaces flake.nix for developer UX; simpler config, familiar CLI, Nix under the hood
* [direnv Auto-Activation](direnv-auto-activation.md) - Automatic environment loading on cd; watch_file for config changes; use_devbox pattern
* [Standard Developer UX Flow](standard-developer-ux-flow.md) - direnv → devbox → just (auto-detecting) → [build tool]; three flows for agents, novices, and power users
* [Just Over Makefiles](just-over-makefiles.md) - No .PHONY, simple syntax, better errors, command-runner focus; why just replaced Make
* [Auto-Detecting Devbox Targets](internal-vs-normal-targets.md) - Single-target auto-detection via DEVBOX_SHELL_ENABLED; _devbox helper + _impl targets; no more -internal thinking overhead
* [Async Prime Internal](async-prime-internal.md) - prime_impl kicks off cache-warming jobs (downloads, build, list, API docs) in parallel as fire-and-forget; verification gates stay synchronous
* [Devbox Script Generation Bug](devbox-script-generation-bug.md) - Known v0.14.x regression; auto-detection pattern makes it largely irrelevant; workarounds still documented
* [Devbox Broken Override](devbox-broken-override.md) - When devbox cannot build the environment at all (nixpkgs pin missing a package on a platform), override devbox-wrapped commands with direct package-manager equivalents rather than blocking
* [Mandatory Testing Workflow](mandatory-testing-workflow.md) - TDD, regression tests for bug fixes, quality gates before completion; enforced via pre-commit and CI
* [Shell Scripting Best Practices](shell-scripting-best-practices.md) - Strict mode, PATH guards, git gates, dry-runs, logging, and shellcheck/shfmt/bats verification for safe shell scripts
