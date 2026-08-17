<!-- Managed by skills-src build pipeline. Do not edit; changes will be overwritten. -->
<!-- Generated from SKILL.md frontmatter + body by `just catalog` -->

# Skills: the script is materialized into scripts/cli-tool-discovery.sh at build time

> Category: **software-dev** · Status:  · Version: 0.1.0

Wrap bash tool calls with an environment wrapper (devbox, mise, flox, direnv, or nix) and rtk before execution. Auto-triggers whenever the bash/shell tool is about to be invoked. Uses cli-tool-discovery.sh to detect the environment wrapper (walks up from cwd looking for devbox.json, .mise.toml, flox.nix, .envrc, flake.nix/shell.nix) and resolve rtk (searches PATH, wrappers, 30+ standard locations, package managers). If a wrapper is detected, prefix the command with the wrapper (e.g. `devbox run --`) so it runs inside the project's environment. Then, if rtk is available and the command is one rtk can optimize (git, gh, ls, read, find, grep, diff, jest, vitest, playwright, pytest, go test, cargo test, rake, rspec, lint, tsc, next build, prettier, cargo build, cargo clippy, ruff, golangci-lint, rubocop, pnpm, pip, bundle, prisma, aws, docker, kubectl, json, deps, env, log, curl, wget, summary, proxy, gain, discover, session, smart, err, test), prefix it with rtk to get token-compressed output (60-90% savings). Even basic shell operations (ls, find, grep, cat, diff) should use rtk when it helps. Use this skill on EVERY bash tool call — the wrapping is cheap and the savings compound. Do NOT trigger on non-bash tools (Read, Grep, Glob, Edit, Write — those bypass the shell), on commands the user explicitly asked to run raw, or on interactive TUI commands (vim, top, htop, tmux, less, more, man) that rtk would break.

## Metadata

| Field | Value |
|-------|-------|
| Name | `shell-wrapper` |
| Category | `software-dev` |
| Version | `0.1.0` |
| Status | `` |
| Owner |  |

## Related Skills
- **base-ai-guidance** (template, base-framework) — Shared framework for creating all AI guidance types
- **cli-tool-discovery** (template, dependency) — Shared CLI tool discovery script — shell-wrapper uses it to resolve the environment wrapper and rtk. Materialized into scripts/ at build time per script-materialization best practice
- **use-devbox** (skill, complement) — Devbox environment detection and usage — shell-wrapper automates the devbox run prefix that use-devbox teaches manually, and generalizes to mise/flox/direnv/nix via cli-tool-discovery
- **cli-tool-upsert** (skill, complement) — Creates agent-facing CLI scripts — shell-wrapper wraps those scripts (and any shell command) for token efficiency
- **project-detection** (skill, complement) — Detects build systems, package managers, and environment configs (devbox, nix, mise, Swift, Maven, Gradle, etc.) — git-collect.sh in git-repository-management uses this to know which lint/test/build commands to run before and after commits. shell-wrapper wraps those commands with devbox + rtk when they're executed
- **git-repository-management** (skill, complement) — git-collect.sh detects the environment (devbox/mise/nix) and runs quality checks (eslint, npm test, cargo test, pytest) — shell-wrapper can wrap those check commands with rtk for token-compressed output

---

- **Full skill**: [`skills/software-dev/shell-wrapper/SKILL.md`](skills/software-dev/shell-wrapper/SKILL.md)
- **Install**: `pnpm dlx skills add levonk/skills-releases`
- **Generated**: 2026-08-17T03:55:48Z
