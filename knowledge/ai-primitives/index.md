---
okf_version: "0.1"
---

# AI Primitives Knowledge Bundle

A compounding knowledge base documenting the AI primitives that compose the
skills-src system: committees, agents, skills, workflows (commands), templates,
prompts, memory, rules, hooks, and the upsert skills that produce them.

## Primitives

* [Overview](overview.md) - Synthesis of the entire primitive system and how the pieces fit together
* [Composition Chain](composition/composition-chain.md) - How primitives compose: templates → prompts → workflows → skills → agents → committees
* [Comparison Matrix](comparison/primitive-comparison.md) - Full comparison across all dimensions (role, scope, autonomy, loading, reusability, personality, reasoning, and more)

### Primitive Types

* [Committees](primitives/committees.md) - Groups of agents that deliberate and synthesize
* [Agents](primitives/agents.md) - Autonomous orchestrators that channel domain expertise
* [Skills](primitives/skills.md) - Capabilities loaded on demand for focused tasks
* [Workflows](primitives/workflows.md) - Multi-step repeatable processes (aka commands)
* [Templates](primitives/templates.md) - Reusable structures with variable schemas
* [Prompts](primitives/prompts.md) - Precision-crafted instruction sets
* [Memory](primitives/memory.md) - Context files: identity, soul, tools, user preferences
* [Rules](primitives/rules.md) - Always-on binding constraints for AI agents
* [Hooks](primitives/hooks.md) - Event-driven scripts that fire on tool calls
* [Snippets](primitives/snippets.md) - Small reusable content fragments

### Upsert Skills (Producers)

* [Upsert Skills Family](upsert-skills/upsert-family.md) - Overview of the skill family that creates and maintains all primitives
* [ai-skill-upsert](upsert-skills/ai-skill-upsert.md) - Creates, updates, converts, and benchmarks skills
* [ai-workflow-upsert](upsert-skills/ai-workflow-upsert.md) - Creates, updates, and converts workflows
* [agent-upsert](upsert-skills/agent-upsert.md) - Creates, updates, and audits agent definitions
* [agent-file-upsert](upsert-skills/agent-file-upsert.md) - Generates AGENTS.md hierarchy documentation
* [prompt-upsert](upsert-skills/prompt-upsert.md) - Creates and improves AI prompts
* [template-upsert](upsert-skills/template-upsert.md) - Creates and audits reusable templates
* [knowledge-bundle-upsert](upsert-skills/knowledge-bundle-upsert.md) - Creates and maintains OKF knowledge bundles
* [rule-upsert](upsert-skills/rule-upsert.md) - Creates and maintains AI agent rules
* [readme-upsert](upsert-skills/readme-upsert.md) - Generates and updates README documentation
* [ai-guidance-improver](upsert-skills/ai-guidance-improver.md) - Audits and improves existing AI guidance
* [handoff](upsert-skills/handoff.md) - Transfers context between agent sessions

### Build System

* [Templater](build-system/templater.md) - Go text/template renderer with custom delimiters
* [Build-Time vs Runtime Dependencies](build-system/dependencies.md) - What gets inlined vs what consumers must install
