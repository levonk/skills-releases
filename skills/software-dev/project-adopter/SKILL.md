---
name: project-adopter
description: Adopt and establish best practices for projects by overwriting existing preferences with standardized developer UX flow. Use when onboarding a new project to standard tooling, setting up devbox/just/direnv, establishing CI/CD, or applying ADR-compliant project structure. Triggers on 'adopt project', 'set up dev environment', 'standardize project', 'apply best practices', or 'project adoption'.
version: 2.8.0
owner: "https://github.com/levonk"
status: "ready"
date:
  created: "2025-02-01"
  knowledge-basis: "2026-08-27"
  last-used: "2026-08-27"
tags: ["ai/skill", "software-development", "project-management", "best-practices", "development-experience", "project-adoption", "preference-overwrite"]
see-also:
  - skill: project-configuration
    relationship: "alternative-approach"
    description: "For adding compatible preferences without overwriting existing workflows"
  - skill: project-detection
    relationship: "dependency"
    description: "Required for analyzing current project state and tooling"
  - skill: surgical-config
    relationship: "dependency"
    description: "Required for safe configuration file modifications"
  - skill: repository-health-review
    relationship: "optional"
    description: "Optional for pre/post-adoption health assessment"
  - skill: ai-development-loop
    relationship: "optional"
    description: "Optional for systematic development workflow integration"
  - skill: git-repository-management
    relationship: "dependency"
    description: "Required for initializing new repos and committing the adoption changeset (init + collect + batch-commit + push)"
  - skill: ignorefile-manager
    relationship: "dependency"
    description: "Required for generating .gitignore, .dockerignore, .codeiumignore, .cursorignore, .aiexclude, .npmignore, VS Code excludes, and ripgrep config from modular concern sources"
  - skill: agent-file-upsert
    relationship: "dependency"
    description: "Required for creating or updating AGENTS.md (AI-facing entry point). Handles both greenfield (create from template) and brownfield (preserve accurate sections, update stale ones, delta analysis). Bundled via includeTree for offline availability."
  - skill: readme-upsert
    relationship: "dependency"
    description: "Required for creating or updating README.md (human-facing entry point). Handles both greenfield (create from template) and brownfield (preserve accurate sections, update stale ones). Runs the README↔AGENTS.md consistency checker after AGENTS.md is in place."
  - skill: dev-env-upsert
    relationship: dependency
    description: "Required for devbox.json package management, .envrc generation/update, and justfile prime_impl line additions. Owns the devbox+direnv+justfile coupled trio per the Standard Developer UX Flow."
  - skill: base-ai-guidance
    relationship: "base-framework"
    description: "Base AI guidance framework for all AI skills"
  - templates: boilerplates
    relationship: "preference-source"
    description: "Provides standardized project templates and preference definitions"
dependencies:
  - type: skill
    name: project-detection
    reason: "Required for comprehensive project analysis and tooling detection"
  - type: skill
    name: surgical-config
    reason: "Required for non-destructive configuration file editing"
  - type: skill
    name: git-repository-management
    reason: "Required for initializing new repos (git-repo-init.bash) and committing the adoption changeset (git-collect.sh + git-commit-batch.sh + git-push.sh)"
  - type: skill
    name: ignorefile-manager
    reason: "Required for all ignore file generation (.gitignore, .dockerignore, .codeiumignore, .cursorignore, .aiexclude, .npmignore, VS Code excludes, ripgrep config) from modular concern sources"
  - type: skill
    name: agent-file-upsert
    reason: "Required for creating or updating AGENTS.md — the AI-facing entry point. Bundled via includeTree for offline availability."
  - type: skill
    name: readme-upsert
    reason: "Required for creating or updating README.md — the human-facing entry point. Handles greenfield (template-based creation) and brownfield (preserve accurate sections, update stale ones). Runs verify_consistency.py to check README↔AGENTS.md agreement."
  - type: skill
    name: dev-env-upsert
    reason: "Required for devbox.json + .envrc + justfile trio management"
  - type: skill
    name: repository-health-review
    reason: "Optional for pre/post-adoption health assessment"
  - type: skill
    name: ai-development-loop
    reason: "Optional for systematic development workflow integration"
  - type: templates
    name: boilerplates
    url: https://github.com/levonk/levonk-base-boilerplate
    reason: "Source of preference templates and standard project structures"
  - type: nix
    name: devbox
    url: https://github.com/jetify-com/devbox
  - type: nix
    name: just
    url: https://github.com/casey/just
  - type: node
    name: direnv
    url: https://direnv.net/
  - type: nix
    name: zizmor
    url: https://github.com/woodruffw/zizmor
    reason: "Workflow security analyzer — catches unpinned actions, excessive permissions, OIDC token misuse. Run in the dedicated workflow-security CI job via nix run nixpkgs#zizmor."
  - type: nix
    name: actionlint
    url: https://github.com/rhysd/actionlint
    reason: "Workflow syntax/schema linter — catches syntax errors, schema violations, deprecated syntax. Run in the dedicated workflow-security CI job via nix run nixpkgs#actionlint."

---

---
description: Wrapper-level hub include for skill SKILL.md files — bundles self-update requirement and CLI tool discovery. Used by the wrapper pattern (SKILL.md is a thin wrapper that runs refresh.sh then reads INSTRUCTIONS.md).
---

---
description: Self-update requirement template for AI guidance files to track usage for maintenance and cleanup
---

### Self-Update Requirement

**CRITICAL**: When this guidance file is called, you MUST update the `last-used`
field in this file's front-matter to the current date (YYYY-MM-DD format).

**Ordering — wrapper-pattern skills**: If this skill uses the wrapper pattern
(has a `## Refresh` section that runs `scripts/refresh.sh`), you MUST run
`refresh.sh` FIRST, then update `last-used`. `refresh.sh` runs
`pnpm dlx skills update <skill-name>`, which overwrites the entire skill
directory — including `SKILL.md` and its frontmatter. If you update `last-used`
before running `refresh.sh`, the update overwrites your change and `last-used`
reverts to the published value. `refresh.sh` also sets `last-used` to today
deterministically after the update completes, so the field stays current even
when the AI forgets. The manual update here is a fallback for when
`refresh.sh` is skipped (`SKIP_SKILL_REFRESH=1`, inside `skills-src`, or
daily-cache hit).

**Ordering — non-wrapper artifacts** (workflows, rules, knowledge bundles, and
skills without `refresh.sh`): update `last-used` before proceeding with any
other work. There is no refresh step to overwrite the field.

After updating `last-used`, the `freshness-check` include (which follows this
one in `base-ai-guidance`) checks whether the artifact's 3rd-party technology
references are stale (>90 days since `date.knowledge-basis`). If stale, it
prompts a subagent validation pass and user-approved source update. See
`freshness-check.md` for the full protocol.


---
description: Shared CLI tool discovery — run cli-tool-discovery.sh to find and run tools through environment wrappers and standard PATH locations before giving up. Also resolves the canonical ad-hoc runner for an ecosystem (python/node/rust/go) via --runner.
---

### CLI Tool Discovery

Before concluding a CLI tool is unavailable, run `cli-tool-discovery.sh`. It
detects environment wrappers (devbox, mise, flox, direnv, nix), searches 30+
standard PATH locations, checks package managers (brew, mise, asdf), and
accounts for the project's tech stack — all in one pass. **Never give up on
the first `command -v` failure.**

For ad-hoc package execution (e.g. `uvx`, `pnpm dlx`, `cargo binstall`, `go
install`), use `--runner <ecosystem>` instead of resolving the binary and
hardcoding the invocation. The runner mode is the single source of truth for
"how do I invoke an ad-hoc command in ecosystem X?" — it pairs the binary
resolution with the canonical invocation pattern from the tech-stack table.

#### Get the script

```bash
# Skills: the script is materialized into scripts/cli-tool-discovery.sh at build time
bash scripts/cli-tool-discovery.sh <tool-name>

# Workflows, agents, and rules (no scripts/ directory): fetch from the public releases repo
curl -fsSL https://raw.githubusercontent.com/levonk/skills-releases/main/includes/cli-tool-discovery.sh -o /tmp/cli-tool-discovery.sh
bash /tmp/cli-tool-discovery.sh <tool-name>
```

#### Usage

```bash
# Resolve only — print where the tool is or how to run it
cli-tool-discovery.sh <tool-name>          # text output
cli-tool-discovery.sh <tool-name> --json   # JSON output (for scripts)

# Resolve and exec — runs the tool through the right wrapper/path, never returns
cli-tool-discovery.sh -- <tool-name> [args...]

# Resolve the ad-hoc runner for an ecosystem (JSON only)
cli-tool-discovery.sh --runner <python|node|rust|go>
```

#### Output (resolve mode)

| Output | Meaning | Action |
|--------|---------|--------|
| `FOUND: <path>` | Tool found at a specific path | Use that path directly |
| `WRAPPER: <wrapper-cmd>` | Tool is inside an environment wrapper | Run via the wrapper (e.g. `devbox run -- <tool>`) |
| `NOT_FOUND: <tool>` | Tool not found anywhere | Install it (ask user first) |

In exec mode (`--`), the script resolves the tool and replaces itself with
the tool process — stdout/stderr/exit code pass through directly. If the tool
is inside a wrapper, it execs through the wrapper. If not found, exits 127.

#### Output (runner mode)

`--runner <ecosystem>` emits JSON only:

```json
{
  "ecosystem": "python",
  "binary": "uv",
  "binary_status": "found",
  "binary_path": "/usr/local/bin/uv",
  "wrapper": "",
  "script": "uv run --script",
  "package": "uvx",
  "fallback": "pip install + python3",
  "fallback_runner": "python3",
  "recommendation": ""
}
```

| Field | Meaning |
|-------|---------|
| `binary` | The canonical binary for the ecosystem (`uv`, `pnpm`/`bun`, `cargo`, `go`) |
| `binary_status` | `found` (use `binary_path`), `wrapper` (use `wrapper`), `not_found` (use `fallback`/`recommendation`) |
| `script` | The runner for inline-metadata scripts (PEP 723). Empty for ecosystems without an equivalent. |
| `package` | The runner for ad-hoc package execution (`uvx`, `pnpm dlx`, `bunx`, `cargo binstall -y`, `go install`) |
| `fallback` | The fallback approach when the binary is not found (e.g. `pip install + python3`). Empty if no fallback exists. |
| `fallback_runner` | The command to use for the fallback. Empty if no fallback exists. |
| `recommendation` | When `binary_status` is `not_found`: either "add to devbox.json", "use fallback", or "install manually". Empty otherwise. |

Ecosystem mapping:

| Ecosystem | Binary | Script runner | Package runner | Fallback |
|-----------|--------|---------------|----------------|----------|
| `python` | `uv` | `uv run --script` | `uvx` | `pip install + python3` |
| `node` (host) | `pnpm` | — | `pnpm dlx` | none (install pnpm) |
| `node` (container) | `bun` | — | `bunx` | none |
| `rust` | `cargo` | — | `cargo binstall -y` | `cargo install` |
| `go` | `go` | — | `go install` | none |

Container detection for `node`: checks `/.dockerenv`, `$DOCKER_CONTAINER`, or
container markers in `/proc/1/cgroup`. This matches the tech-stack table's
"inside a container → bunx" rule.

The Python include (`cli-tool-discovery.py.tmpl`) provides `resolve_runner(ecosystem)`
returning the same dict shape, for use inside Python scripts that need to
discover the runner programmatically.

#### When to Use

- **Always**, before reporting a tool as "not found" or "not installed"
- When a build/test/lint command fails with "command not found"
- When a skill or workflow script needs a tool that isn't on PATH
- When the user reports a tool "should be installed" but `command -v` fails
- **For ad-hoc package execution**, use `--runner <ecosystem>` instead of
  hardcoding `uvx` / `pnpm dlx` / `cargo binstall` / `go install` — the
  runner mode keeps the binary resolution and the invocation pattern paired
  and consistent with the tech-stack table

#### Anti-Patterns

- **Giving up on first `command -v` failure** — run the script instead
- **Installing a tool without asking** — always confirm before adding packages
- **Ignoring environment wrappers** — if a `devbox.json` exists, the tool is
  likely inside devbox, not on the bare shell
- **Hardcoding `uvx` / `pnpm dlx` / `cargo binstall` / `go install`** — use
  `--runner <ecosystem>` instead so the binary and invocation stay paired
  and the policy lives in one place (the tech-stack table, mirrored by the
  runner mode)



# Project Adopter

## Refresh

Before doing anything else, ensure this skill is current:

1. Run `scripts/refresh.sh`. Its stdout is this skill's current body
   (`INSTRUCTIONS.md`). The script handles: finding pnpm via
   cli-tool-discovery, checking the daily-refresh cache, running
   `pnpm dlx skills update <skill-name>` (sandboxed via nono if available),
   and printing `INSTRUCTIONS.md`.

2. Read the script output. That file contains the actual outcome,
   guardrails, calibration, and current process. Do not proceed until
   you have read it.

If the update fails (no network, pnpm unavailable), the script prints
the on-disk version of `INSTRUCTIONS.md` — stale content is better
than no content.

## Pre-Commit Hooks

As part of the adoption flow (step 18a), `scripts/install-pre-commit-hooks.sh`
installs a composite pre-commit hook at `scripts/hooks/pre-commit` in the
target project and sets `git config core.hooksPath scripts/hooks`. The
composite hook calls individual check scripts in order:

1. **Worktree isolation** (`pre-commit-worktree-isolation.sh`) — blocks
   commits to `main`/`master` (or other protected branches) when not
   working inside a linked git worktree. This enforces the
   worktree-per-feature workflow.

   # Worktree Enforcement Bypass Table

The worktree-per-feature workflow is enforced by two machine gates. Both
have bypass mechanisms designed to be **asymmetric** — the user can
bypass but the agent can't:

| Gate | Bypass | How user bypasses | Why agent can't |
|------|--------|-------------------|-----------------|
| Pre-commit hook | `SKILL_ALLOW_MAIN_WRITE=1` | Set in your shell: `SKILL_ALLOW_MAIN_WRITE=1 git commit ...` | Visible in the exec tool call output — you see it |
| PreToolUse hook | `SKILL_BYPASS_GATE=1` | Set at session launch: `SKILL_BYPASS_GATE=1 devin` | Hook inherits session env, not command env — agent can't set session-level vars mid-session |
| Both | `git commit --no-verify` | Type it in your shell | Agent would have to pass `--no-verify` in its exec command — visible |
| Config file | `.agents/config/script-guards.toml` | Create with `[worktree-isolation] allow_main_write = true` | Agent can write files, but the change is visible in git diff and the file is version-controlled |

## Read-Only Profile Exemption (not a bypass — a correct non-application)

The PreToolUse hook inspects the `profile` field in the `run_subagent`
`tool_input`. `subagent_explore` dispatches are **allowed without a
gate-pass** — this is not a bypass, it is a correct non-application of the
gate. The gate exists to prevent mutation of the main working directory;
`subagent_explore` has profile-enforced read-only tool access (grep, glob,
read, web_search — no edit/write/exec) and cannot mutate anything. The
exemption is enforced at the tool layer, so an agent cannot escalate a
read-only dispatch to write capability by prompt content alone.

| Profile | Gate required? | Why |
|---------|----------------|-----|
| `subagent_explore` | No | Read-only tool access — cannot mutate the working directory |
| `subagent_general` | Yes | Full tool access (foreground) — can edit/write/exec |
| Custom write-capable | Yes | Has edit/write/exec access |
| Custom read-only | No | If the profile restricts tools to read-only set |
| Missing/empty profile | Yes | Fail-closed — treat as write-capable |

**Do not abandon subagent dispatch to avoid the gate.** If a write-capable
dispatch is blocked, run `execution-gate.sh` and re-dispatch. Dropping the
subagent to do the work inline is circumvention, not compliance (binding
contract rule 9).

The config file bypass is also available for repos that don't use the
worktree-per-feature workflow (e.g., single-maintainer repos where
worktrees add overhead without benefit):

```toml
# .agents/config/script-guards.toml
[worktree-isolation]
allow_main_write = true
protected_branches = ["main", "master"]  # optional override
```


2. **Submodule integrity** (`pre-commit-submodule-integrity.sh`) — detects
   the class of bug where a git submodule (mode `160000 commit`) is
   accidentally converted to a regular directory (mode `040000 tree`) in
   the parent repo's index. Reads ALL submodule paths from `.gitmodules`
   (no hardcoded paths) and skips silently at runtime if `.gitmodules`
   doesn't exist or is empty.

The installer is idempotent — safe to re-run. To add a new check, create a
`pre-commit-<name>.sh` script in `scripts/hooks/` and add a call to it in
the composite `pre-commit` entry point. The installer also scans
`.gitmodules` for `file://` submodule URLs and prints an advisory if found
(see step 19a for details).

---

## Content Ordering

This artifact is optimized for machine consumption. Generic framework content
(shared includes, knowledge bundles) appears before the skill-specific body.
This ordering maximizes cross-skill prefix caching: skills that share the same
includes produce identical byte prefixes, so an LLM context cache warmed by one
skill serves all skills that share the same preamble.

This is sub-optimal for human reading — the skill-specific content starts deep
in the file, after the generic preamble. Human readers can jump to the
skill-specific body by searching for the first `# ` heading that follows the
generic sections. Each section is self-contained and documented with its own
heading hierarchy.

