# Model Card Brief

The model prompting brief tells the doctor phase how to phrase requests
for the selected model. It is normally produced by the
`model-card-review` workflow (`workflows/ai/model-card-review` in the
same distribution). This file is the fallback when that workflow is not
installed — follow it to produce the same artifact by hand.

## When the workflow is installed

Run `model-card-review` with the model ID (+ provider when ambiguous).
It writes `internal-docs/models/model-brief-<model-id>-YYYYMMDD.md` and
prints the brief inline. Carry the brief forward to Stage C.

## Fallback procedure

1. Confirm the exact model ID and provider — version and date suffix
   matter; a card for a sibling version does not apply.
2. Locate the primary source, in order: model card / system card →
   provider prompting guide → API docs (context window, output caps,
   tool calling, structured output) → release notes → independent evals
   (corroboration only).
3. If the card cannot be found, write the brief with every unverified
   field marked `unknown` — never fill gaps from memory of a different
   model or version.
4. Extract the prompting-relevant facts (the subset of the
   [model-assessment](../../knowledge/ai-primitives/comparison/model-assessment.md)
   framework that changes request phrasing): context window and output
   caps, preferred prompt structure, reasoning mode and effort levels,
   tool-calling format, structured-output support, instruction-following
   style, known failure modes, knowledge cutoff.
5. Write the brief to
   `internal-docs/models/model-brief-<model-id>-YYYYMMDD.md` using the
   schema below — one page, every claim cites its source.

## Brief schema

```markdown
# Model Brief: <model-id> (<provider>)

**Reviewed**: YYYY-MM-DD | **Sources**: <URLs actually read>

## How to Ask
- Prompt structure: <XML/markdown/plain; system prompt placement>
- Request sizing: <max practical input per call; chunking strategy>
- Reasoning mode: <defaults; when to raise/lower effort>
- Output expectations: <length caps; structured-output mechanism>

## Constraints That Change Requests
- <concrete rule, e.g. "split audit reports by cluster — max output 8k">

## Known Failure Modes / Gotchas
- <cited>

## Confidence
- Verified: <fields confirmed by >=1 primary source>
- Unverified: <fields no source states — do not assume>
```

## How the brief changes the doctor phase

- **Request structure** — wrap file lists, rules, and output schemas in
  the model's preferred delimiters.
- **Sizing** — split the sweep into sub-requests under the practical
  input cap; split the report under the output cap.
- **Reasoning** — raise effort for cross-file consistency analysis;
  lower it for mechanical sweeps.
- **Structured output** — when reliable, ask for findings JSON directly;
  otherwise markdown + convert.
- **Gotchas** — work around documented failure modes (e.g. over-refusal
  on security findings → phrase as defensive-hardening audit).
