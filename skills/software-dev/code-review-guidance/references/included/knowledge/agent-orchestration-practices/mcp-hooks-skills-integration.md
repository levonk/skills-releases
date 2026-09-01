---
type: Practice
title: MCP Hooks Skills Integration
description: Load external tool configs (MCP servers), register lifecycle callbacks (hooks), and preload skills/agents declaratively per node — so the agent enters its turn with the right tools, the right event handlers, and the right context already wired. Integration is config-driven, not code-driven.
tags: [agent-orchestration, mcp, hooks, skills, agents, lifecycle-callbacks, config-driven, preload, setting-sources]
date:
  created: "2026-08-10"
  knowledge-basis: "2026-08-10"
  last-used: "2026-08-10"
sources:
  - id: archon-mcp-hooks-skills
    resource: "https://github.com/coleam00/archon"
    title: "Archon — loadMcpConfig, HookCallbackMatcher, settingSources, AgentDefinition, buildArchonMcpServer"
---

# MCP Hooks Skills Integration

## The General Rule

An agent node in a workflow engine needs three categories of external
integration wired before its turn starts:

1. **Tools** — MCP (Model Context Protocol) servers that provide
   external tools the agent can call.
2. **Lifecycle callbacks** — hooks that fire on specific events
   (PreToolUse, PostToolUse, SessionStart, Stop, etc.) and inject
   responses or side effects.
3. **Context** — skills, agents, and setting sources that preload
   instructions, sub-agent definitions, and filesystem configuration
   into the agent's turn.

All three are **config-driven, not code-driven**. The workflow definition
declares which configs to load, which hooks to register, and which
skills/agents to preload. The engine resolves and wires them before the
agent's first turn. The agent does not discover its tools at runtime — it
enters its turn with everything already in place.

### MCP Config Loading

The engine loads MCP server configurations from a JSON file specified per
node. The loader:

1. Resolves the config path (absolute or relative to the node's working
   directory).
2. Reads and parses the JSON (throws on missing file, invalid JSON, or
   wrong shape — must be a JSON object, not an array or scalar).
3. Normalizes the server configurations (validates each server entry).
4. Expands environment variables in server configs (e.g. `${API_KEY}` →
   the value from the environment). Missing env vars are reported.
5. Returns the server map and server names to the provider, which
   registers them before the agent's turn.

The loader is **shared across providers** — the same config format works
for Claude, Codex, Copilot, and community providers. Each provider
translates the normalized server map into its own SDK's expected format.

### Hook Registration

Hooks are declarative event callbacks. The workflow definition specifies,
per node, a map of event name → array of matchers. Each matcher has:

- A **matcher pattern** (regex for tool names or event subtypes).
- A **response** (the static response to return when the hook fires).
- An optional **timeout** (default: the SDK's default, typically 60s).

The engine converts the declarative hook definitions into the provider
SDK's callback format. If the node declares hooks and the provider also
has existing hooks for the same event, the engine merges them (node hooks
are appended to existing hooks, not replacing them).

Hook events cover the full agent lifecycle: PreToolUse, PostToolUse,
PostToolUseFailure, Notification, UserPromptSubmit, SessionStart,
SessionEnd, Stop, SubagentStart, SubagentStop, PreCompact,
PermissionRequest, Setup, and more. Each event fires at a specific point
in the agent's turn, letting the workflow inject behavior without
modifying the agent's prompt.

### Skills, Agents, and Setting Sources

Beyond tools and hooks, the engine preloads:

- **Skills** — named capability packages that the agent can invoke. The
  node declares a non-empty array of skill names to load.
- **Agents** — inline sub-agent definitions keyed by agent ID. The node
  declares a map of agent IDs to agent definitions (model, prompt, tools).
  These sub-agents are available to the agent via its task/delegation
  tool.
- **Setting sources** — which filesystem sources the agent loads
  (project-level `.claude/`, user-level `~/.claude/`). A node can scope
  to project-only (for CI or shared environments) or include user-level
  (for personal context). This is a per-provider capability — not all
  providers support setting source control.

All three are declared in the node's YAML, not hardcoded in the engine.
The engine reads the declarations and passes them to the provider's SDK
before the agent's turn.

### Capability Gating for Integration

Each integration category is gated by a provider capability flag:

- `mcp: true` — the provider supports MCP server registration.
- `hooks: true` — the provider supports lifecycle hook callbacks.
- `skills: true` — the provider supports skill preloading.
- `agents: true` — the provider supports inline sub-agent definitions.
- `settingSources: true` — the provider supports setting source control.

A node that declares an integration feature on a provider that does not
support it produces a loud warning (the feature is ignored) or a hard
block (for critical features). The engine never silently drops an
integration declaration.

## Concrete Instances

### Archon (Bun + TypeScript)

Archon's `loadMcpConfig()` reads and validates MCP server configs from
JSON, expands environment variables, and returns the normalized server
map. The Claude provider converts declarative YAML hooks into the SDK's
`HookCallbackMatcher` arrays, merging with existing hooks. The
`settingSources` field controls which filesystem sources Claude loads
(`['project', 'user']` by default; `['project']` for CI-scoped nodes).
`AgentDefinition` objects wrap inline sub-agents with model, prompt, and
tool configuration. `buildArchonMcpServer()` registers in-process native
tools as an MCP server for the agent's turn. The Codex and Copilot
providers reuse the shared `loadMcpConfig()` helper, each translating the
server map into their SDK's format.

### Claude Code SDK

The Claude Code SDK accepts `mcpServers` (MCP server configs), `hooks`
(event callback matchers), `settingSources` (filesystem source control),
`agents` (inline sub-agent definitions), and `allowedTools`/`disallowedTools`
(tool permission control) as options to `query()`. The SDK loads all of
these before the agent's first turn. This is the native integration
surface that Archon's Claude provider wraps — the SDK is the direct
consumer of the declarative integration config.

### OpenAI Agents SDK

OpenAI's Agents SDK (formerly Swarm) supports tool registration
(functions decorated as tools), handoffs (sub-agent delegation), and
guardrails (pre/post hooks). Tools are registered as Python functions
with typed signatures; handoffs are declared as agent-to-agent routing
rules; guardrails are callbacks that run before or after the agent's
turn. This is the same pattern (tools, lifecycle callbacks, sub-agents)
with a different config surface (Python code instead of YAML). The
integration is code-driven rather than config-driven, but the categories
are identical.

## Anti-Patterns

- **Runtime tool discovery** — the agent searches for tools at runtime
  instead of receiving them pre-wired. This is slow, non-deterministic,
  and breaks audit trails (the set of tools varies per run). Load all
  tools before the agent's turn.
- **Hardcoded hook logic** — hooks are implemented in engine code rather
  than declared in the workflow YAML. Changing a hook response requires
  an engine code change. Keep hooks declarative.
- **Ignoring env var expansion** — MCP configs reference environment
  variables (`${API_KEY}`) but the loader does not expand them. The
  server starts with a literal `${API_KEY}` string and fails at runtime.
  Expand env vars at load time and report missing vars.
- **Silent feature drop** — a node declares hooks on a provider that does
  not support them, and the engine silently ignores the declaration. Warn
  loudly so the user knows the hooks will not fire.
- **Per-provider config format** — each provider has its own MCP config
  format, so a workflow that switches providers must rewrite all tool
  configs. Use a shared config format and let each provider translate it.

## See Also

- [DAG Workflow Engine](dag-workflow-engine.md) — the engine that wires
  integrations before node execution.
- [Provider Capability Tiers](provider-capability-tiers.md) — the
  capability flags (`mcp`, `hooks`, `skills`, `agents`, `settingSources`)
  that gate integration features per provider.
- [Capability Gating](capability-gating.md) — the pre-flight gate pattern
  applied to external integrations.
