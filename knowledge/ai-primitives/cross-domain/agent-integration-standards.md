---
type: Concept
title: Agent Integration Standards
description: Cross-domain standards for how a CLI tool integrates with AI coding agents — skill emission via --gen-skill, coding-agent hook wiring with per-agent config.toml preferences, and non-user-identifiable telemetry. Cross-link to the canonical CLI standards ADR.
tags: [ai-primitives, cross-domain, cli, agent-integration, skill-emission, hooks, telemetry, axi]
date:
  created: "2026-07-29"
  knowledge-basis: "2026-07-29"
  last-used: "2026-07-29"
sources:
  - id: levonk-base-boilerplate-adr-20260607001
    resource: "https://github.com/levonk/levonk-base-boilerplate/blob/main/internal-docs/adr/adr-20260607001-cli-tool-standards.md"
    title: "ADR-20260607001 CLI Tool Standards (v5.0.0)"
  - id: axi-spec
    resource: "https://github.com/kunchenguid/axi/blob/main/.agents/skills/axi/SKILL.md"
    title: "Agent eXperience Interface (AXI) Specification"
  - id: agent-skills-registry
    resource: "https://agentskills.io"
    title: "Agent Skills Registry"
---

# Agent Integration Standards

A CLI tool that wants AI coding agents (Claude Code, Codex, OpenCode, Devin,
Cursor, Continue, Aider) to use it correctly must do three things: emit an
installable skill prompt, wire itself into the agent's session hooks, and
collect only non-identifiable telemetry. These are cross-domain concerns —
they apply to any CLI in any language, not just Rust. The canonical home is
[ADR-20260607001 §46–§48](https://github.com/levonk/levonk-base-boilerplate/blob/main/internal-docs/adr/adr-20260607001-cli-tool-standards.md)
(v5.0.0); the Rust-specific gist lives in the
[rust-development-practices](https://github.com/levonk/skills-releases/blob/main/knowledge/rust-development-practices/cli-tool-standards.md)
bundle. This page is the AI-primitives view: how these standards map onto the
primitive system (skills, hooks, memory, rules).

## Why This Matters for ai-primitives

The skills-src primitive system defines skills, hooks, and memory
abstractly. The agent-integration standards are the **bridge contract** that
lets an external CLI tool participate in that primitive system from outside:
the tool emits a skill (primitive), wires session hooks (primitive), and
respects privacy/telemetry boundaries (rules). Studying this bridge sharpens
the local primitive definitions by forcing them to be installable from a
foreign binary, not just authored in-tree.

## The Three Standards

### 1. Skill Emission (`--gen-skill`)

The tool prints a complete, installable [Agent Skill](https://agentskills.io)
prompt to stdout. The skill is the distributable companion to the session
hook — it lets an agent install the tool's guidance without a global binary
install.

- **Recommendation order**: the emitted skill must recommend integration
  paths in this order: (1) hooks (lowest per-session token cost, ambient
  context), (2) CLI use (explicit invocation), (3) MCP server if the tool
  exposes one. State the trade-off for each.
- **Single source of truth**: generate the skill body from the same content
  the no-args home view prints, so the skill never drifts. `--gen-skill
  --check` exits non-zero if the committed skill is stale (for CI).
- **Strip live state**: a skill is static; omit dynamic data only the hook can
  show.
- **Non-interactive commands**: rewrite command examples to forms runnable
  without a global install (`npx -y`, `uvx`, `pnpm dlx`).
- **Idempotent**: re-running `--gen-skill` with no CLI changes produces
  byte-identical output so CI can diff cleanly.

**Primitive mapping**: the emitted artifact is a **Skill** (primitive) —
trigger-shaped frontmatter, on-demand loading, no per-session token cost. The
`--gen-skill` flag is the producer; the agent's skill loader is the consumer.

### 2. Coding-Agent Hook Wiring with Per-Agent Config

The tool ships `--install-agent-hooks` / `--uninstall-agent-hooks` that wire
it into the user's chosen coding agents. This extends §42 session
integrations (Claude Code, Codex, OpenCode) to the broader ecosystem (Devin,
Cursor, Continue, Aider — opt-in).

- **Per-agent config**: read preferences from
  `${XDG_CONFIG_HOME:-$HOME/.config}/{app-name}/config.toml`. An
  `[agent-hooks]` table (or per-agent sub-tables like
  `[agent-hooks.claude-code]`, `[agent-hooks.devin]`) sets: which agents to
  wire (`enabled = ["claude-code", "codex"]`), the hook event
  (`session-start`, `pre-tool`, `post-tool`), and the recommendation order
  (`recommend = ["hooks", "cli", "mcp"]`).
- **Defaults**: `enabled = ["claude-code", "codex", "opencode"]`,
  `recommend = ["hooks", "cli"]`.
- **Explicit opt-in**: register hooks only from the user-invoked install
  command, never from ordinary CLI commands. Re-running with the same config
  is an idempotent no-op.
- **Portable commands**: hook commands use a PATH-verified binary name when
  it resolves to the current executable, falling back to the full absolute
  path.
- **Path repair**: the install command checks existing hooks and updates the
  executable path if it has changed (e.g., after reinstall or relocation).
- **Discovery**: the install command detects which agents are present and
  reports which were wired, which were skipped (not installed), and which
  were disabled by config.
- **Uninstall counterpart**: `--uninstall-agent-hooks` removes only the hooks
  the tool registered, never touching hooks from other tools.

**Primitive mapping**: the registered artifacts are **Hooks** (primitive) —
event-driven, JSON-via-stdin, exit-code-driven. The per-agent config is
**Memory** (primitive) — context files that persist user preferences. The
recommendation order is a **Rule** (primitive) — a binding constraint on
agent behavior.

### 3. Non-User-Identifiable Telemetry

The tool may collect anonymous usage telemetry (how it is called, which
subcommands run, exit codes, rough timing buckets) to inform development —
but never user-identifiable information, file paths, package names, project
names, environment variables, or any data that could identify the user or
their work.

- **No identifiers**: never log or transmit user names, host names, account
  names, email addresses, API keys, tokens, or hashes derived from them.
- **No file paths**: never log or transmit absolute or relative file paths,
  directory paths, repository URLs, or remote names. Log only integer
  counts, never path lists.
- **No content**: never log or transmit command arguments, package names,
  dependency names, code snippets, error message text, or any user-supplied
  input. Log only the subcommand verb and a coarse exit-code category.
- **Coarse buckets**: timing is logged as a bucket (`<100ms`, `100ms-1s`,
  `1s-10s`, `>10s`), never a precise duration.
- **Toggle precedence** (highest to lowest):
  1. Universal opt-out env vars — `DO_NOT_TRACK=1` (the cross-tool standard
     inspired by the HTTP Do Not Track header) and `DISABLE_TELEMETRY=1` (the
     widely-used generic opt-out). If **either** is set to a truthy value (`1`,
     `true`, `TRUE`, `yes`), telemetry is disabled regardless of any other
     setting. These are honored first so a single env var disables telemetry
     across every conforming tool on the system.
  2. Tool-specific env var — `MYTOOL_TELEMETRY=off|on` (overrides config but
     not the universal opt-outs).
  3. Config file — `[telemetry] enabled = true|false` in config.toml.
  4. Hardcoded default — `off` (opt-in) unless the user explicitly enables
     telemetry.
  A first-run prompt may ask the user, but only in human mode — never block
  agent mode. The universal opt-outs must be documented in `--help` so users
  discover them without reading the source.
- **No network without consent**: no network call to transmit telemetry
  unless telemetry is enabled AND a network endpoint is configured. If no
  endpoint is configured, telemetry is collected locally to the audit log
  but not transmitted.
- **Disclosure**: `--version` and `--help` state whether telemetry is
  enabled and where the data goes (endpoint URL or "local only"). The
  config file's `[telemetry]` section is commented out by default with an
  explanation of what is and is not collected.
- **Testability**: `--telemetry-dry-run` prints the exact payload without
  transmitting it, so users and CI can verify no identifying data leaks.

**Primitive mapping**: the telemetry toggle is a **Rule** (primitive) — a
binding constraint. The collected data is **Memory** (primitive) — context
the tool keeps about its own operation. The privacy boundary (no file
paths, no identifiers) is a **Rule** that overrides any data-collection
intent.

## Cross-Bundle References

- [rust-development-practices/cli-tool-standards.md](https://github.com/levonk/skills-releases/blob/main/knowledge/rust-development-practices/cli-tool-standards.md)
  — Rust-specific gist of the same three standards, sourced from the same
  ADR. Read this for Rust implementation guidance (crate choices, idioms).
- [ADR-20260607001 §46–§48](https://github.com/levonk/levonk-base-boilerplate/blob/main/internal-docs/adr/adr-20260607001-cli-tool-standards.md)
  — the canonical, authoritative source. The ADR is the single source of
  truth; this page and the Rust gist are derivations.
- [primitives/hooks.md](../primitives/hooks.md) — the hooks primitive
  definition. The hook-wiring standard is the external-tool bridge onto this
  primitive.
- [primitives/skills.md](../primitives/skills.md) — the skills primitive
  definition. The `--gen-skill` emission is the external-tool bridge onto
  this primitive.
- [primitives/memory.md](../primitives/memory.md) — the memory primitive
  definition. Per-agent config and telemetry state are memory.
- [primitives/rules.md](../primitives/rules.md) — the rules primitive
  definition. The telemetry privacy boundary and recommendation order are
  rules.

## Real-World Reference: apmw

[apmw](https://github.com/levonk/apmw) (All Package Manager Wrapper) is the
first tool expected to implement these three standards end-to-end. Its PRD
([feat-202607290558-apmw.md](https://github.com/levonk/apmw/blob/main/internal-docs/feature/2026/07/apmw/feat-202607290558-apmw.md))
calls for `--gen-skill`, `--install-agent-hooks`, and non-identifiable
telemetry as first-class CLI surface. apmw is the canonical reference
implementation; future tools should mirror its structure.
