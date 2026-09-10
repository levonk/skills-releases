---
type: Concept
title: Agent Plugins Specification
description: Cross-link to the agentplugins/agent-plugins-spec — an open, vendor-neutral standard for packaging reusable components (Agent Skills and MCP servers) into distributable plugins. Maps the spec's plugin package model, manifest, and component discovery onto the skills-src primitive system and identifies the gaps (no agent component type, divergent SKILL.md frontmatter, different distribution mechanism).
tags: [ai-primitives, cross-domain, agent-plugins, packaging, distribution, plugin, manifest, skills, mcp]
date:
  created: "2026-09-09"
  knowledge-basis: "2026-09-09"
  last-used: "2026-09-09"
sources:
  - id: agent-plugins-spec-1-0-0
    resource: "https://github.com/agentplugins/agent-plugins-spec/blob/main/spec/1.0.0.md"
    title: "Agent Plugins Specification 1.0.0"
  - id: agent-plugins-readme
    resource: "https://github.com/agentplugins/agent-plugins-spec"
    title: "agentplugins/agent-plugins-spec README"
  - id: agent-skills-specification
    resource: "https://agentskills.io/specification"
    title: "Agent Skills Specification (agentskills.io)"
  - id: agent-plugins-design-decisions
    resource: "https://github.com/agentplugins/agent-plugins-spec/blob/main/spec/1.0.0.md#design-decisions"
    title: "Agent Plugins Design Decisions (Why only Agent Skills and MCP in v1?)"
---

# Agent Plugins Specification

[agentplugins/agent-plugins-spec](https://github.com/agentplugins/agent-plugins-spec)
is an open, vendor-neutral standard for packaging reusable components that
extend AI agents into distributable plugins. Version 1.0.0 is the current
published release (1.1.0 is a working draft). The spec defines a portable
**on-disk package format** — a plugin is a directory with a `plugin.json`
manifest and component subdirectories that any conforming client can
discover and load.

This page maps the spec onto the skills-src primitive system and identifies
where the two align, where they diverge, and what skills-src would need to
do to emit agent-plugins-conformant packages.

## Why This Matters for ai-primitives

The skills-src primitive system defines skills, agents, MCP servers, and
composition chains abstractly, then builds and distributes them via the
vercel-labs/skills CLI. The agent-plugins spec is an **independent,
vendor-neutral packaging standard** that defines how skills and MCP servers
are packaged for cross-client portability (Copilot, Claude, etc.). Studying
the spec sharpens the local primitive definitions by forcing them to be
loadable by a foreign client that knows nothing about skills-src's build
system, frontmatter superset, or distribution repos.

The spec also makes a deliberate scope decision that directly affects the
agent primitive: **agents are excluded from v1** because they are "too
client-specific for a stable portable contract." This is a data point for
the ongoing question of how portable the agent primitive can be.

## The Plugin Package Model

A plugin is a directory rooted at a single filesystem location. The
standard layout:

```text
my-plugin/
├── plugin.json          # Required: manifest (closed schema)
├── skills/              # Component type 1: Agent Skills
│   └── summarize/
│       ├── SKILL.md
│       ├── scripts/
│       │   └── analyze.sh
│       └── references/
│           └── checklist.md
├── mcp.json            # Component type 2: MCP servers
├── com.example.client/ # Client extension directory (reverse-domain)
│   └── hooks/
├── LICENSE
└── CHANGELOG.md
```

### Manifest (`plugin.json`)

The manifest MUST be JSON at the plugin root. Its schema is **closed**: the
only permitted top-level fields are `$schema`, `name`, `version`,
`description`, `author`, `homepage`, `repository`, `license`, `keywords`,
and `extensions`. Unknown top-level fields are reported and ignored (the
client continues loading); any other schema violation is fatal.

Required fields: `$schema` (canonical schema identifier, e.g.
`https://agent-plugins.org/schemas/1.0.0/plugin.schema.json`) and `name`
(human-readable, 1-64 chars, lowercase `a-z`/`0-9`/`-`/`.`, alphanumeric
start/end, no `--` or `..`).

The `extensions` field holds client-specific manifest data keyed by
reverse-domain namespace (e.g. `com.example.client`). Client-specific files
go in a top-level directory of the same name. The spec assigns no portable
discovery or validation semantics to extension data — each client defines
its own namespace behavior.

### Component Discovery

Components are discovered from **fixed locations** — `plugin.json` cannot
override these or contain inline component configuration:

| Component type | Fixed location | Pattern |
|----------------|----------------|---------|
| Skills | `skills/` | Immediate child directories containing `SKILL.md` |
| MCP servers | `mcp.json` | JSON configuration at plugin root |

Clients MUST NOT recursively search deeper than immediate child directories
for skills. Missing locations are not errors; malformed locations make that
component type invalid but do not fail the plugin.

### Containment Rules

All plugin-relative paths MUST begin with `./`, resolve against the plugin
root, and remain within the filesystem-resolved plugin root after resolution.
Symlinks MAY resolve to targets within the plugin root, but paths that
escape are rejected. This is path containment for package-supplied files —
it does not sandbox a subprocess or restrict runtime-supplied paths.

When a path fails containment, the client applies the **narrowest applicable
failure boundary**: reject the plugin, invalidate the component type, skip
the skill, invalidate the server entry, or deny the specific path — in that
order of narrowness.

### MCP Servers (`mcp.json`)

MCP configuration is a JSON object at `mcp.json` with required `$schema` and
`mcpServers` fields (no other top-level fields). Each server entry has a
`type` field matching one of three closed variants:

- **stdio** — `command` (single executable token, bare name or `./`-relative
  path), `args`, `env`, `cwd`
- **streamable-http** — `url` (absolute HTTP/HTTPS, no userinfo/fragment),
  `headers`
- **sse** — deprecated HTTP+SSE transport, same fields as streamable-http

Clients that launch subprocesses MUST provide `PLUGIN_ROOT` (absolute path
to plugin root) and `PLUGIN_DATA` (absolute path to a client-managed
persistent data directory) in the subprocess environment, and MUST expand
`${PLUGIN_ROOT}` and `${PLUGIN_DATA}` in `args`, `env` values, and `cwd`.
Expansion is single-pass, non-recursive. Headers and `env` values are
"visible package data, not a portable secret mechanism" — plugins MUST NOT
embed credentials in them.

## The Agent Skills Format (agentskills.io)

The agent-plugins spec defers the `SKILL.md` format to the separate
[Agent Skills specification](https://agentskills.io/specification). That spec
defines:

### Required Frontmatter

| Field | Constraints |
|-------|-------------|
| `name` | Max 64 chars, lowercase `a-z`/`0-9`/`-`, no leading/trailing hyphen, no `--`, **must match parent directory name** |
| `description` | Max 1024 chars, non-empty, describes what the skill does and when to use it |

### Optional Frontmatter

| Field | Constraints |
|-------|-------------|
| `license` | License name or reference to bundled license file |
| `compatibility` | Max 500 chars, environment requirements (product, system packages, network) |
| `metadata` | Arbitrary string-to-string key-value map for additional properties |
| `allowed-tools` | Space-separated string of pre-approved tools (experimental) |

### Progressive Disclosure

The agentskills.io spec explicitly recommends progressive disclosure:
1. **Metadata** (~100 tokens): `name` + `description` loaded at startup for
   all skills
2. **Instructions** (<5000 tokens recommended, <500 lines): full `SKILL.md`
   body loaded on activation
3. **Resources** (as needed): `scripts/`, `references/`, `assets/` loaded on
   demand

This mirrors skills-src's progressive disclosure principle exactly.

## Mapping to the skills-src Primitive System

### What Aligns

| Agent Plugins / Agent Skills | skills-src |
|------------------------------|------------|
| `skills/<name>/SKILL.md` | `src/current/skills/<cat>/<name>/SKILL.md.tmpl` → built to `skills/<name>/SKILL.md` |
| `scripts/`, `references/`, `assets/` subdirectories | Identical directory structure |
| Progressive disclosure (metadata → body → resources) | Core design principle, same three tiers |
| `name` + `description` as required frontmatter | Same — `description` is the primary trigger |
| `mcp.json` for MCP servers | skills-src does not bundle MCP servers (out of scope) |
| Closed manifest schema with `extensions` for client data | skills-src has no manifest; distribution is via vercel-labs/skills CLI |
| Path containment (paths must stay within plugin root) | skills-src's `includeChezmoi`/`includeJinja` enforce similar containment (`vendor/dotfiles/`, `vendor/boilerplate/`) |

### What Diverges

#### 1. No `plugin.json` manifest

skills-src does not emit a `plugin.json`. Distribution uses the
vercel-labs/skills CLI (`pnpm dlx skills add`) against the `skills-releases`
/ `skills-private` repos. A consumer using an agent-plugins-conformant
client (e.g. Copilot) cannot load a skills-src distribution repo as-is —
there is no manifest to discover.

**Implication**: to target agent-plugins-conformant clients, skills-src
would need a build step that emits `plugin.json` per profile (or per
plugin group) with the required `$schema` and `name` fields.

#### 2. SKILL.md frontmatter is a rich superset

skills-src `SKILL.md` frontmatter includes `version`, `date` (created/
knowledge-basis/last-used), `tags`, `see-also`, `okf-supported-version`,
`user-invocable`, `disable-model-invocation`, `owner`, `status`,
`visibility`, and more. The agentskills.io spec recognizes only `name`,
`description`, `license`, `compatibility`, `metadata`, and `allowed-tools`.

The agentskills.io `metadata` field (string-to-string map) could
theoretically hold skills-src's extra fields, but they would need to be
stringified (e.g. `see-also` is a list of objects). Unknown top-level
fields in `SKILL.md` frontmatter are not addressed by the agent-plugins
spec (which only governs discovery, not skill format) — behavior depends
on the client's Agent Skills implementation. The agentskills.io spec does
not state whether unknown frontmatter fields are ignored or rejected;
the `metadata` map is the sanctioned escape hatch.

**Implication**: skills-src's rich frontmatter is not portable to
agent-plugins-conformant clients without either (a) mapping extras into
`metadata` as strings, or (b) confirming that target clients ignore
unknown frontmatter fields.

#### 3. `name` must match parent directory

The agentskills.io spec requires `name` to match the parent directory
name. skills-src uses `name` as the authoritative identifier and allows
it to differ from the directory (useful when a skill moves or is aliased).

**Implication**: skills-src skills that have a `name` differing from
their directory would need to be renamed or restructured to conform.

#### 4. No agent component type

The agent-plugins spec defines exactly two component types: **Skills** and
**MCP servers**. The Design Decisions section explicitly states:

> Other proposed component types — such as commands, hooks, agents,
> rules, and LSP servers — remain too client-specific for a stable
> portable contract and are outside the v1 format until their formats
> converge.

This is a significant divergence: skills-src has **agents** as a
first-class primitive (autonomous orchestrators with personality, I/O
schemas, workflows, guardrails, design-by-contract). The agent-plugins
spec considers agents too client-specific to standardize.

**Implication**: there is no portable representation for skills-src's
agent primitive in the agent-plugins format. An agent would have to be
encoded as a skill (losing personality, I/O schema, autonomy) or an MCP
server (losing the markdown guidance entirely). This is a fundamental
expressiveness gap.

#### 5. Distribution mechanism

| | agent-plugins | skills-src |
|---|---|---|
| Package unit | Plugin directory with `plugin.json` | Built skill directory (no manifest) |
| Discovery | Client scans `skills/` + `mcp.json` | Consumer runs `pnpm dlx skills add` |
| Registry | Not specified (client-defined) | GitHub repos (`skills-releases`, `skills-private`) |
| Versioning | `plugin.json` `version` field (semver recommended) | `SKILL.md` `version` frontmatter field |

The two distribution models are orthogonal: agent-plugins defines how a
package sits on disk for any client; skills-src defines how a package is
installed from a GitHub repo via a specific CLI. They could compose —
skills-src could emit agent-plugins-conformant packages that the skills
CLI installs — but they do not today.

## Design Lessons for skills-src

1. **Manifest as conformance floor** — the agent-plugins spec makes
   `plugin.json` the single guaranteed entry point that works across all
   clients. skills-src has no equivalent manifest; the `SKILL.md`
   frontmatter is the closest analog but is per-skill, not per-package.
   If cross-client portability becomes a goal, a per-package manifest
   (even a minimal one) is the conformance floor.

2. **Closed schema with extensions escape hatch** — the closed
   `plugin.json` schema with `extensions` for client-specific data is a
   clean separation of portable vs client-specific. skills-src's
   frontmatter has no such separation — all fields are skills-src-specific.
   The agentskills.io `metadata` map is the closest analog, but it is
   unstructured (string-to-string only).

3. **Fixed locations over manifest configuration** — the spec uses fixed
   locations (`skills/`, `mcp.json`) instead of letting the manifest
   declare component paths. This eliminates discovery indirection. skills-src
   already follows this convention (skills are in `skills/<cat>/<name>/`),
   but the build output flattens categories — built skills go to
   `build/current/skills/<name>/`, losing the category hierarchy. An
   agent-plugins-conformant layout would need `skills/<name>/SKILL.md`
   at the plugin root.

4. **Narrowest-failure-boundary** — when a path fails containment, the
   spec prescribes a graded response (reject plugin → invalidate
   component type → skip skill → invalidate server → deny path). This is
   a good resilience pattern that skills-src's build system could adopt
   more explicitly: a single malformed skill should not fail the entire
   build, only that skill.

5. **Agents are too client-specific for v1** — the spec's explicit
   exclusion of agents (and hooks, rules, commands) is a data point for
   the portability of the agent primitive. skills-src's agent definition
   (personality, voice parameters, model-level, runtime duration,
   design-by-contract) is deeply tied to a specific runtime model. The
   agent-plugins spec's authors concluded that this level of specificity
   cannot be standardized across clients yet. This does not mean
   skills-src's agent primitive is wrong — it means the portable surface
   for agents is currently just "a skill that orchestrates," not the full
   agent definition.

6. **Secrets are not portable** — the spec repeatedly states that `env`
   and `headers` are "visible package data, not a portable secret
   mechanism." Plugins MUST NOT embed credentials. This aligns with
   skills-src's `secrets-egress-security` knowledge bundle and the
   universal contract to never commit secrets.

## Cross-Bundle References

- [primitives/skills.md](../primitives/skills.md) — the skills primitive
  definition. The agent-plugins spec's skill component type maps onto this
  primitive, with the agentskills.io format as the portable surface.
- [primitives/agents.md](../primitives/agents.md) — the agent primitive
  definition. The agent-plugins spec explicitly excludes agents from v1
  as too client-specific; this page explains why.
- [cross-domain/eve-filesystem-agents.md](eve-filesystem-agents.md) —
  vercel/eve is a runtime framework that implements the agent primitive
  with filesystem conventions. Eve, agent-plugins, and skills-src are
  three independent approaches to the same problem space (see comparison
  below).
- [cross-domain/agent-integration-standards.md](agent-integration-standards.md)
  — the bridge contract for how an external CLI tool participates in the
  primitive system via skill emission (`--gen-skill`). The agent-plugins
  spec is the packaging layer that would carry such emitted skills to
  foreign clients.
- [agent-orchestration-practices/two-tier-skill-layout](https://github.com/levonk/skills-releases/blob/main/knowledge/agent-orchestration-practices/two-tier-skill-layout.md)
  — skills-src's profile system (current/private) is a two-tier layout.
  The agent-plugins spec has no notion of internal vs public plugins;
  all conformant plugins are distributable. The two-tier distinction
  would be enforced at the distribution layer (which repos are published),
  not in the plugin format.
- [secrets-egress-security](https://github.com/levonk/skills-releases/blob/main/knowledge/secrets-egress-security) — the
  agent-plugins spec's "env and headers are not a secret mechanism" rule
  aligns with this bundle's egress and vault storage patterns.

## Three Approaches to the Same Problem Space

| Aspect | agent-plugins spec | vercel/eve | skills-src |
|--------|-------------------|------------|------------|
| Layer | Packaging/distribution | Runtime framework | Authoring + build system |
| Goal | Portable plugin loadable by any conforming client | Durable, inspectable running agents | Portable, self-contained markdown skill modules |
| Composition timing | Static (manifest declares components) | Runtime (filesystem discovery at boot) | Build-time (`{{{ include }}}` inlining) |
| Naming | Manifest `name` field | Path-as-name (no duplicate field) | Frontmatter `name` (authoritative, can differ from dir) |
| Agent primitive | Not defined (only Skills + MCP servers) | First-class (`agent/` dir with instructions, tools, subagents) | First-class (own upsert skill, I/O schema, personality, contracts) |
| Skill format | Defers to agentskills.io (name + description + optional metadata) | TypeScript files in `agent/skills/` | Rich frontmatter superset (version, date, tags, see-also, evals) |
| Evals | Not specified | `evals/` peer directory | `evals/` inside each skill directory |
| Output | Plugin directory on disk | Running TypeScript agent | Built markdown consumed by any AI agent |
| Distribution | Client-defined (plugin directory) | eve runtime (Node.js 24+) | vercel-labs/skills CLI → GitHub repos |

All three are "convention over configuration" designs that agree on the
core primitives (skills are on-demand capabilities in directories, evals
are peer to the skill, progressive disclosure is the loading model). They
differ in what they standardize: agent-plugins standardizes the package
envelope, eve standardizes the runtime layout, skills-src standardizes the
authoring and build process.

## Producer Skill

This cross-domain reference was added by
[`ai-upsert`](../upsert-skills/ai-upsert.md) (Mode B: Ingest) using the
agent-plugins spec 1.0.0, the agentskills.io specification, and the spec's
Design Decisions section as sources.
