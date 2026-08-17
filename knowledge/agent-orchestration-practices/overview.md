---
type: Synthesis
title: Agent Orchestration Practices Overview
description: Synthesis of agent orchestration practices — DAG workflow engines, output schema validation, session persistence, capability gating, router fallback chains, provider capability tiers, and MCP/hooks/skills integration for agentic runtimes.
tags: [agent-orchestration, overview, synthesis, workflow-engine, dag, session-persistence, capability-gating, router, provider-tiers, mcp, hooks]
date:
  created: "2026-08-10"
  knowledge-basis: "2026-08-10"
  last-used: "2026-08-10"
sources:
  - id: archon-workflow-engine
    resource: "https://github.com/coleam00/archon"
    title: "Archon — governed agentic automation engine (workflow engine, provider abstraction, MCP/hooks integration)"
---

---
description: STE100-inspired Simplified Technical English guidelines for technical prose output — active voice, short sentences, one-word-one-meaning, imperative for instructions
---

### Simplified Technical English (STE100-Inspired)

This artifact produces technical English (instructions, procedures, descriptions,
reference documentation). Apply these STE100-inspired guidelines to all technical
prose output so the result is unambiguous, translatable, and easy to read for
non-native speakers and for AI agents that must execute the steps precisely.

These are **STE-inspired guidelines**, not the full ASD-STE100 vocabulary
restriction. Domain terms (Dockerfile, pnpm, devbox, Nx, etc.) are permitted
when they are the correct technical term — STE100's 1000-word approved
vocabulary is too narrow for this domain. The goal is the *clarity discipline*
of STE100, not its word list.

For the full writing rules, before/after examples, and the approved-words
reference, see the
[Simplified Technical English](https://github.com/levonk/skills-releases/blob/main/knowledge/simplified-technical-english/simplified-technical-english.md)
and
[Detailed Guide](https://github.com/levonk/skills-releases/blob/main/knowledge/simplified-technical-english/detailed-guide.md)
concept pages in the `simplified-technical-english` knowledge bundle. The
bundle is the canonical, publicly-reachable home for these guidelines; this
include is the build-time gist that gets inlined into skills and other
bundles.

#### Core Principles

1. **One word, one meaning.** Pick one term for each concept and use it
   everywhere. Do not alternate between "image" and "container image" and
   "docker image" for the same thing. Pick one, define it once, reuse it.

2. **Short sentences.** Keep procedural sentences under 20 words. Keep
   descriptive sentences under 25 words. Split long sentences into two.

3. **Active voice.** Write "The build copies the file" not "The file is copied
   by the build." The actor does the action. Passive voice hides who does what
   and is the single largest source of ambiguity in technical prose.

4. **Imperative mood for instructions.** Write "Run the tests" not "You should
   run the tests" or "The tests should be run." Instructions tell the reader
   (or agent) what to do, directly.

5. **One topic per sentence.** One idea per sentence. Do not chain unrelated
   clauses with "and" or "while." If a sentence has two ideas, split it.

6. **Consistent verb forms.** Use the same verb for the same action across the
   document. If you "run" a script in section 1, do not "execute" it in
   section 2. Pick one verb per action and keep it.

7. **Approved modifiers only.** Avoid decorative adjectives and adverbs
   ("very", "extremely", "simply", "just"). Keep modifiers that carry
   information ("non-root", "read-only", "idempotent"). Drop modifiers that
   carry only emphasis.

8. **Define every acronym on first use.** Write "Continuous Integration (CI)"
   on first use, then "CI" thereafter. Never assume the reader knows the
   acronym.

#### What Counts as Technical English

Apply these guidelines to:

- Procedural instructions ("Run `just build`", "Add the user to the group")
- Descriptions of failure modes, symptoms, and practices
- Reference documentation and concept pages
- Checklists and review guidance
- Synthesis and overview prose in knowledge bundles

Do **not** apply these guidelines to:

- Code, commands, and file paths (those have their own syntax)
- Frontmatter and structured data (YAML, JSON)
- Diagrams and their source syntax (Mermaid, PlantUML)
- Business communication, marketing copy, or creative content
- Log entries and change logs (those are append-only records)

#### Quick Self-Check

Before finishing a piece of technical prose, run this checklist:

- [ ] Is every sentence under 25 words? (Procedural: under 20.)
- [ ] Is every sentence active voice? (Or is the passive voice intentional and
      necessary?)
- [ ] Are instructions in imperative mood?
- [ ] Does each technical term have one and only one form in this document?
- [ ] Is every acronym defined on first use?
- [ ] Are decorative modifiers removed?
- [ ] Does each sentence carry one topic?

If any answer is "no," revise before publishing.


# Agent Orchestration Practices Overview

This bundle documents practices for **agentic runtimes and workflow engines**
— the systems that coordinate multi-step execution mixing deterministic
steps (bash, scripts, commands) with AI agent calls, human approval gates,
and full audit trails. This is a distinct subject area from general software
architecture: the concerns here are specific to orchestrating agent
execution where the "compute" is a non-deterministic LLM call, the "state"
spans provider sessions and conversation scopes, and the "governance"
requires capability gating, structured output enforcement, and reversible
multi-step runs.

## Why This Bundle Exists Separately

No existing bundle covers the agentic-runtime/workflow-engine domain.
The closest neighbors are:

- **software-architecture-essentials** — covers structural architecture
  (modularity, data access, scalability, resilience). It addresses
  request-handler concurrency and downstream isolation, not agent-session
  lifecycle, DAG node typing, or provider capability negotiation.
- **cicd-testing-practices** — covers CI/CD pipelines and test runners. A
  workflow engine shares the DAG concept with CI, but agent orchestration
  adds human approval gates, provider session resume, structured output
  re-ask loops, and capability-gated invocation — none of which appear in
  CI/CD testing.
- **typescript-monorepo-best-practices** — covers language-specific tooling.
  Agent orchestration is stack-neutral; the same DAG, session, and
  capability patterns apply to TypeScript, Python, Go, and Rust agent
  runtimes.

The agentic-runtime domain is coherent: its concerns (node typing,
dependency ordering, output validation, session persistence, capability
gating, routing, provider negotiation, tool/skill/hook integration) form a
tight cluster that does not map cleanly onto any existing bundle's scope.
Splitting these across architecture or CI bundles would dilute both the
new content and the existing bundles. A dedicated bundle keeps the
orchestration practice set discoverable and compounding.

## The Orchestration Landscape

```
dag-workflow-engine → output-schema-validation → session-persistence
                                ↓
       capability-gating → router-fallback-chain → provider-capability-tiers
                                ↓
                  mcp-hooks-skills-integration
```

| Concern | Practice | Prevents |
|---------|----------|----------|
| Execution | [DAG Workflow Engine](dag-workflow-engine.md) | Unordered agent steps, missing dependency joins, no concurrent-layer control, ad-hoc step orchestration |
| Validation | [Output Schema Validation](output-schema-validation.md) | Silent malformed agent output, unbounded repair loops, schema drift between declaration and enforcement |
| State | [Session Persistence](session-persistence.md) | Lost conversation context on re-run, duplicate agent cold-starts, session identity collisions across scopes |
| Governance | [Capability Gating](capability-gating.md) | Incurred AI cost before discovering a missing integration, silent capability downgrades, partial runs with no rollback |
| Routing | [Router Fallback Chain](router-fallback-chain.md) | Hard failures on name typos, no catch-all for unmatched requests, ambiguous resolution with no disambiguation |
| Negotiation | [Provider Capability Tiers](provider-capability-tiers.md) | Assuming all providers support structured output, silent feature drops, no per-capability enforcement tier |
| Integration | [MCP Hooks Skills Integration](mcp-hooks-skills-integration.md) | Hardcoded tool lists, no lifecycle callbacks, skills/agents loaded ad-hoc instead of declaratively |

## Scope

This bundle covers **agent orchestration practices** — the runtime and
engine patterns for coordinating multi-step agent execution. It does
**not** cover:

- General software architecture (modularity, data access, scalability) —
  see [software-architecture-essentials](https://github.com/levonk/skills-releases/blob/main/knowledge/software-architecture-essentials/overview.md).
- CI/CD pipeline configuration and test runners — see
  [cicd-testing-practices](https://github.com/levonk/skills-releases/blob/main/knowledge/cicd-testing-practices/overview.md).
- Language-specific agent SDK usage — see the relevant stack bundle
  (e.g. [typescript-monorepo-best-practices](https://github.com/levonk/skills-releases/blob/main/knowledge/typescript-monorepo-best-practices/overview.md)).

## Compounding

New lessons from future agent orchestration work — new node types, routing
strategies, capability negotiation patterns, session lifecycle models —
should be filed as new concept pages. Append to `log.md` when adding.

## Related Knowledge Bundles

- [software-architecture-essentials](https://github.com/levonk/skills-releases/blob/main/knowledge/software-architecture-essentials/overview.md)
  — Structural architecture that the orchestration engine is built on
  (adapter-provider pattern, dependency injection, error classification).
- [cicd-testing-practices](https://github.com/levonk/skills-releases/blob/main/knowledge/cicd-testing-practices/overview.md) — CI/CD
  pipelines share the DAG concept; this bundle extends it with agent-specific
  governance.
- [typescript-monorepo-best-practices](https://github.com/levonk/skills-releases/blob/main/knowledge/typescript-monorepo-best-practices/overview.md)
  — Language-specific tooling for TypeScript agent runtimes.

## Sources

- [coleam00/archon](https://github.com/coleam00/archon) — governed agentic
  automation engine; workflow engine (10 DAG node types, output_format
  validation, persist_session, requires gate, 4-tier router fallback),
  provider abstraction (ProviderCapabilities with enforced/best-effort/false
  tiers), MCP/hooks/skills integration (loadMcpConfig, HookCallbackMatcher,
  settingSources). Ingested 2026-08-10 as one concrete instance of each
  pattern.

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

