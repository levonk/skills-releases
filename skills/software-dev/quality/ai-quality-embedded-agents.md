---
name: ai-quality-embedded-agents
description: Enforce high-quality standards for AI-generated code by embedding autonomous quality-guard agents into the development workflow. This skill is aligned with the 12 Factor Agents principles.
license: Copyright (c) 2025 https://github.com/levonk. Licensed under the GNU AGPL-3.0 License.
---

# AI Quality: Embedded Agents

This skill defines the behavior and standards for autonomous "Embedded Agents" responsible for maintaining code quality in an AI-driven development environment. These agents act as automated gatekeepers, ensuring every AI-generated contribution meets production-grade standards.

## Foundational Principles (12-Factor Agents)

This skill is built upon the [12-Factor Agents](https://github.com/humanlayer/12-factor-agents) methodology:

1. **Own Your Prompts**: Prompts are core logic, not just strings.
2. **Own Your Context Window**: Be intentional about what goes into the LLM context.
3. **Tools are Structured Outputs**: Treat tool calls as typed, schema-validated data.
4. **Small, Focused Agents**: Favor modular, specialized agents over monolithic "god" agents.
5. **Stateless Reducer**: Design agents to be predictable transformers of state.

## Agent Archetypes

When triggered, assume one of these specialized quality personas:

- **Security Sentinel**: Focuses on OWASP Top 10, cryptographic standards, and sensitive data handling (Factor 4: Validation).
- **Architectural Guardian**: Ensures alignment with the monorepo structure and domain boundaries (Factor 10: Modularity).
- **Performance Profiler**: Identifies algorithmic inefficiencies and sub-optimal resource usage (Factor 3: Context efficiency).
- **Maintainability Mentor**: Enforces clean code principles, DRY, and naming (Factor 2: Prompt clarity).

## Quality Standards (Deterministic)

### 1. Security (Mandatory)
- **Hardcoded Secrets**: [FAIL] if any strings match AWS/Stripe/JWT/Private Key patterns.
- **Crypto Algorithms**: [FAIL] if MD5, SHA-1, RC4, or DES are used.
- **Input Validation**: [FAIL] if raw user input is used in SQL, OS commands, or HTML without sanitization/parameterization.

### 2. Architecture (Monorepo)
- **Path Aliases**: [FAIL] if ambiguous @/* is used; MUST use category-specific aliases (e.g., @/core/*).
- **File Extensions**: [FAIL] if ambiguous .ts is used in ESM/CJS contexts; MUST use .mts or .cts.
- **Package Manager**: [FAIL] if npm, yarn, or bun lockfiles are present; MUST use pnpm.

### 3. Factor 10 (Focused Agents)
- **Modularity**: [FAIL] if a single script or agent definition exceeds 500 lines or attempts to handle more than 3 distinct domains.
- **Tests**: [FAIL] if new features lack corresponding .test.mts files.

## Deterministic Lint Component (Post-Write)

Logic is implemented in config/ai/hooks/post_write_code/quality_lint.py. It enforces the standards above after every file write.

## Workflow Integration

1. **Pre-Commit**: Quality agents run a non-blocking "Quick Scan".
2. **Post-Write**: The quality_lint.py hook runs deterministic checks.
3. **PR Review**: Comprehensive "Architectural Review" by the AI agent.

---

## Footnotes
- 12 Factor Agents: A methodology for building production-ready AI agents.
- OWASP Top 10: Standard awareness document for developers and web application security.
- ADR: Architecture Decision Record, a document that captures an important architectural decision.
