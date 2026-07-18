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

## Quick Start

Before each bash tool call, run the wrapper script to get the wrapped command,
then execute the wrapped command:

```bash
# 1. Get the wrapped form (resolve mode — prints the command to run)
bash scripts/wrap_command.sh git status
# → devbox run -- rtk git status

# 2. Execute what it printed
devbox run -- rtk git status
```

Or use exec mode to resolve and run in one shot:

```bash
bash scripts/wrap_command.sh -- git status
# runs: devbox run -- rtk git status
```

## Instructions

### Step 1: Detect the environment wrapper

Before any bash tool call, determine whether an environment wrapper (devbox,
mise, flox, direnv, or nix) applies to the current directory. The wrapper
script calls `cli-tool-discovery.sh` with a nonexistent tool name to probe for
wrapper detection — the discovery script checks PATH first, then wrappers; a
nonexistent tool skips PATH and falls through to the wrapper check. See
`references/wrapper-detection.md` for the full algorithm, all five supported
wrappers, and the already-inside-shell detection for each.

### Step 2: Check rtk support

Determine whether rtk is available (resolved via `cli-tool-discovery.sh` —
finds it even in non-standard locations) and whether the command is one rtk
optimizes. Coverage is determined by `rtk rewrite` — the single source of
truth that rtk's own hooks use. It knows which commands are supported, which
are excluded (vim, top, tmux, etc.), and the user's rtk config. No hardcoded
list is maintained in the wrapper script. See `references/rtk-coverage.md` for
a reference summary of rtk's coverage. If rtk is not found, skip the rtk
layer — do not install rtk without asking.

### Step 3: Wrap and execute

Compose the prefix in this order (each layer is conditional):

1. If an environment wrapper is detected and we're not already inside that
   wrapper's shell → prefix with the wrapper command (e.g. `devbox run --`)
2. If rtk is available AND the command is rtk-supported → insert `rtk` after
   the wrapper prefix
3. The original command follows unchanged

Final forms:

| wrapper? | rtk? | rtk-supported? | Wrapped command |
|----------|------|----------------|-----------------|
| no | no | — | `<cmd>` |
| no | yes | no | `<cmd>` |
| no | yes | yes | `rtk <cmd>` |
| yes | no | — | `<wrapper> <cmd>` |
| yes | yes | no | `<wrapper> <cmd>` |
| yes | yes | yes | `<wrapper> rtk <cmd>` |

Run `scripts/wrap_command.sh <cmd>` (resolve mode) to get the wrapped form, or
`scripts/wrap_command.sh -- <cmd> [args...]` (exec mode) to resolve and execute
in one call. The script exits non-zero only if the underlying command fails —
resolve mode exits 0 with the wrapped command on stdout.

### Step 4: Handle edge cases

- **Chained commands** (`&&`, `||`, `|`, `;`, `&`): the wrapper script detects
  shell operators and wraps the entire command as `<wrapper> bash -c '<cmd>'`
  so the operators are interpreted inside the wrapper environment. `rtk
  rewrite` handles inserting `rtk ` before each supported command in the chain
  — including pipe-aware behavior (only the first command in a pipe is
  rewritten, per rtk's design). For example, `git fetch && git status` becomes
  `devbox run -- bash -c 'rtk git fetch && rtk git status'`. Excluded commands
  (vim, top, etc.) in the chain are not prefixed with rtk — `rtk rewrite`
  handles this automatically.
- **Interactive TUI commands** (vim, top, htop, tmux, less, more, man, fzf):
  rtk filters stdout, which breaks TUIs. `rtk rewrite` knows these exclusions
  — even in a chain, `vim file && ls` becomes `bash -c 'vim file && rtk ls'`.
- **Already inside a wrapper shell**: if the wrapper's environment variables
  are set (`DEVBOX_SHELL`, `IN_DEVBOX_SHELL`, `MISE_SHELL`, `FLOX_ACTIVE`,
  `DIRENV_DIR`, `IN_NIX_SHELL`), skip the wrapper prefix (we're already in the
  environment).
- **rtk not found**: skip the rtk layer silently. Do not install rtk
  without user confirmation.
- **User explicitly asks for raw output**: honor it. Run the command without
  rtk. The wrapper script has a `--raw` flag for this.
- **cli-tool-discovery.sh missing**: the wrapper script falls back to
  `command -v rtk` for rtk detection and skips wrapper detection. This
  shouldn't happen in normal operation (the script is materialized at build
  time), but the fallback ensures the script degrades gracefully.

## References

- [`references/wrapper-detection.md`](references/wrapper-detection.md) — All
  five supported environment wrappers (devbox, mise, flox, direnv, nix), the
  cli-tool-discovery.sh probe algorithm, already-inside-shell detection for
  each wrapper, and the fallback behavior.
- [`references/rtk-coverage.md`](references/rtk-coverage.md) — A reference
  summary of rtk's command coverage, passthrough behavior, and exclusions.
  The authoritative source is `rtk rewrite` (or `rtk --help`), not this file.

## Related Skills
- **base-ai-guidance** (template, base-framework) — Shared framework for creating all AI guidance types
- **cli-tool-discovery** (template, dependency) — Shared CLI tool discovery script — shell-wrapper uses it to resolve the environment wrapper and rtk. Materialized into scripts/ at build time per script-materialization best practice
- **use-devbox** (skill, complement) — Devbox environment detection and usage — shell-wrapper automates the devbox run prefix that use-devbox teaches manually, and generalizes to mise/flox/direnv/nix via cli-tool-discovery
- **cli-tool-upsert** (skill, complement) — Creates agent-facing CLI scripts — shell-wrapper wraps those scripts (and any shell command) for token efficiency
- **project-detection** (skill, complement) — Detects build systems, package managers, and environment configs (devbox, nix, mise, Swift, Maven, Gradle, etc.) — git-collect.sh in git-repository-management uses this to know which lint/test/build commands to run before and after commits. shell-wrapper wraps those commands with devbox + rtk when they're executed
- **git-repository-management** (skill, complement) — git-collect.sh detects the environment (devbox/mise/nix) and runs quality checks (eslint, npm test, cargo test, pytest) — shell-wrapper can wrap those check commands with rtk for token-compressed output

---

- **Full skill**: [`skills/software-dev/shell-wrapper/SKILL.md`](skills/software-dev/shell-wrapper/SKILL.md)
- **Install**: `npx skills add levonk/skills-releases`
- **Generated**: 2026-07-18T08:27:30Z
