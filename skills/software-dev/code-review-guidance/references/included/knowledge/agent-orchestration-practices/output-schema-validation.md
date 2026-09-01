---
type: Practice
title: Output Schema Validation
description: Declare a JSON schema for agent output, validate post-parse against it, and re-ask the model with schema errors on failure — with bounded retries and tier-aware enforcement. The schema is the contract between the agent and the downstream consumer.
tags: [agent-orchestration, structured-output, schema-validation, re-ask, output-format, json-schema, provider-tiers]
date:
  created: "2026-08-10"
  knowledge-basis: "2026-08-10"
  last-used: "2026-08-10"
sources:
  - id: archon-output-format
    resource: "https://github.com/coleam00/archon"
    title: "Archon — output_format schema validation with enforced/best-effort tiers and bounded re-ask"
---

# Output Schema Validation

## The General Rule

When an agent node must produce structured output for a downstream
consumer, the workflow engine enforces a **three-phase contract**:

1. **Declare** — the node specifies a JSON schema for its expected output.
2. **Validate post-parse** — after the agent response is parsed, the
   engine validates it against the schema before passing it downstream.
3. **Re-ask on failure** — if validation fails, the engine re-runs the
   agent with the schema errors appended to the prompt, up to a bounded
   number of retries.

The schema is the contract. Downstream nodes reference
`$nodeId.output.field` — they trust the schema, not the raw prose. Without
post-parse validation, a downstream node receives unvalidated text that may
be missing required fields, have wrong types, or contain a refusal instead
of the expected data.

### Tier-Aware Enforcement

Not all providers can enforce structured output equally. The engine
classifies each provider into one of three tiers:

- **Enforced** — the provider's backend grammar-constrains decoding so the
  output is guaranteed to match the schema. The engine still validates
  post-parse as a net for edge cases (refusals, max-tokens truncation).
  No re-ask is needed on validation failure — a failure here is a genuine
  edge case, not a repairable mistake.
- **Best-effort** — the provider augments the prompt with the schema but
  has no backend grammar. The engine validates post-parse and re-asks with
  errors on failure, up to a bounded retry count (typically 3). Each
  re-ask starts a fresh session so the prior invalid turn is not carried
  forward.
- **False** — the provider cannot produce structured output at all. The
  engine rejects the node at dispatch time rather than silently
  downgrading.

### Bounded Re-Ask Loop

The re-ask loop is bounded — it is not an infinite repair cycle. Each
attempt:

1. Appends a correction block to the prompt listing the specific schema
   errors.
2. Starts a fresh agent session (no context pollution from the failed
   turn).
3. Validates the new response.
4. On exhaustion (max retries exceeded), the node fails with a clear error
   naming the schema violations.

The engine logs every re-ask and notifies the user on the first attempt so
auto-correction is not invisible.

### Cost Accumulation

Re-asks incur cost. The engine accumulates cost across all attempts and
reports the total on the node's final outcome (success or failure). A
best-effort provider that requires 3 re-asks costs 3× a single-pass
enforced provider — this is visible in the run's cost accounting.

## Concrete Instances

### Archon (Bun + TypeScript)

Archon's `output_format` field on DAG nodes accepts a free-form JSON
Schema object. The dag-executor resolves the provider's
`structuredOutput` capability tier: `enforced` providers (Claude, Codex)
get 0 re-asks (validation failure is a genuine edge case); `best-effort`
providers (Pi, Copilot) get up to 3 re-asks with a correction block;
`false` providers are rejected at dispatch. The re-ask prompt is
`${originalPrompt}\n\n--- CORRECTION ---\nYour previous response did not
satisfy the required JSON schema: ${errors}. Respond again with ONLY a
JSON object matching the schema.` Each re-ask starts a fresh session pass.
Cost is accumulated across all passes and reported on the node's final
outcome.

### OpenAI Structured Outputs

OpenAI's Structured Outputs API provides backend grammar-constrained
decoding via `response_format: { type: "json_schema", json_schema: {...} }`.
This is the `enforced` tier — the output is guaranteed to match the
schema. The OpenAI SDK still recommends post-parse validation for edge
cases (the model may produce a valid-JSON-but-semantically-wrong response).
No re-ask loop is needed for schema compliance, though semantic validation
may still warrant one.

### LangChain

LangChain's structured output support (`with_structured_output()`) wraps
the schema declaration and post-parse validation. For providers with
native structured output (OpenAI, Anthropic), it uses the enforced path.
For providers without it, it falls back to prompt augmentation + output
parsing + retry. The retry count is configurable. LangChain's
`OutputParserException` is the validation failure signal that triggers the
re-ask path.

## Anti-Patterns

- **No post-parse validation on enforced providers** — assuming the
  backend grammar is infallible. Refusals, max-tokens truncation, and
  provider bugs can still produce invalid output. Always validate
  post-parse.
- **Unbounded re-ask** — re-asking indefinitely until the model gets it
  right. This can loop forever on a schema the model cannot satisfy and
  accumulates unbounded cost. Cap the retries.
- **Re-ask with same session** — carrying the failed turn's context into
  the re-ask. The model may anchor on its prior invalid output. Start a
  fresh session per re-ask.
- **Silent best-effort downgrade** — a node declares a schema, the
  provider is best-effort, and the engine silently drops the schema
  instead of validating. The downstream consumer receives unvalidated
  text. Always validate post-parse regardless of tier.

## See Also

- [DAG Workflow Engine](dag-workflow-engine.md) — the engine that
  executes nodes with output schemas.
- [Provider Capability Tiers](provider-capability-tiers.md) — how the
  engine negotiates capabilities including structured output support.
