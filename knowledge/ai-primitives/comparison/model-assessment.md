---
type: Comparison
title: LLM Model Assessment — Selection Criteria and Verification Checklist
description: Twelve-criterion framework for assessing an LLM before adoption. Covers benchmark methodology disclosure, open-weights vs open-model verification, active vs total parameter counts for MoE, on-disk model size, license and weights-availability verification, per-million-token pricing, independent third-party evaluations, language and tool support, modality coverage, knowledge cutoff, and Hugging Face adoption signals. Each criterion pairs the question to ask with the verification step and the failure mode it catches.
tags: [ai-primitives, comparison, model-assessment, llm, evaluation, open-weights, licensing, pricing, benchmarks, huggingface, moe]
date:
  created: "2026-08-03"
  knowledge-basis: "2026-08-03"
  last-used: "2026-08-03"
sources:
  - id: helm-crfm
    resource: https://crfm.stanford.edu/helm/latest/
    title: "Stanford CRFM — Holistic Evaluation of Language Models (HELM)"
  - id: lmarena
    resource: https://lmarena.ai
    title: "LMArena — crowd-sourced blind pairwise model preference leaderboard"
  - id: artificial-analysis
    resource: https://artificialanalysis.ai
    title: "Artificial Analysis — independent performance, price, and speed aggregator"
  - id: open-weight-license-landscape-2026
    resource: https://presenc.ai/research/open-weight-license-landscape-2026
    title: "Presenc AI — Open-Weight License Landscape 2026"
  - id: ml-model-license-guide
    resource: https://lockml.com/research/ml-model-license-guide.html
    title: "LockML — ML Model License Guide (commercial use, fine-tuning, redistribution by license)"
  - id: osi-open-source-ai-definition
    resource: https://opensource.org/ai
    title: "Open Source Initiative — Open Source AI Definition (OSAID) 1.0"
  - id: open-weights-claim-60s
    resource: https://dev.to/dublecc/how-to-check-an-open-weights-claim-in-60-seconds-and-the-three-ways-the-check-fools-you-fg1
    title: "How to check an open-weights claim in 60 seconds — Hugging Face API verification, decoy repos"
  - id: deepseek-v3-report
    resource: https://arxiv.org/pdf/2412.19437
    title: "DeepSeek-V3 Technical Report — 671B total / 37B active MoE parameter reporting convention"
  - id: moe-sparse-routing
    resource: https://www.youngju.dev/blog/ai-papers/2026-03-06-ai-papers-moe-sparse-mixture-experts-architecture.en
    title: "Sparse Mixture of Experts architecture — total vs active parameter counts across Mixtral, DeepSeek-V3, Qwen3-235B"
  - id: openai-pricing
    resource: https://developers.openai.com/api/docs/pricing
    title: "OpenAI API pricing — per-1M-token input, cached input, cache write, output tiers"
  - id: anthropic-pricing
    resource: https://platform.claude.com/docs/en/about-claude/pricing
    title: "Anthropic Claude pricing — per-1M-token input, output, 5M/1H cache writes, cache hits"
  - id: tldl-llm-pricing
    resource: https://www.tldl.io/resources/llm-api-pricing
    title: "TLDL — LLM API pricing aggregator with source verification (July 2026)"
  - id: hf-model-hub-economies
    resource: https://arxiv.org/html/2512.03073v1
    title: "Economies of Open Intelligence — Hugging Face Model Hub download/likes dataset and concentration analysis"
  - id: llm-runtime-selection
    resource: ../llm-runtime-selection.md
    title: "LLM Runtime Selection — companion concept page (runtime choice after model choice)"
---

# LLM Model Assessment — Selection Criteria and Verification Checklist

A twelve-criterion framework for assessing an LLM before adoption. Each
criterion pairs the question to ask with the verification step and the failure
mode it catches. Use this before committing a model to a production path;
pair with [LLM Runtime Selection](llm-runtime-selection.md) for the serving
decision after the model decision.

The criteria split into four groups: **evidence** (does the claim have a
verifiable source), **cost** (what does it actually cost to run), **fit**
(does it do what the workload needs), and **adoption** (is anyone else
running it). Verify evidence and cost first — they are the criteria most
often lied about by omission.

## Criterion Map

| # | Criterion | Group | Question | One-line verification |
|---|-----------|-------|----------|----------------------|
| 1 | Benchmark methodology | Evidence | Are benchmarks published **with** the methodology, not just the scores? | Look for scenario definitions, metrics, prompt format, few-shot config, and raw outputs |
| 2 | Open weights vs open model | Evidence | Is this open weights, open model (OSAID-aligned), or neither? | Check the license text against OSAID; do not trust the marketing label |
| 3 | Active vs total parameters (MoE) | Evidence | For MoE, what is the **active** parameter count, not just the total? | Read the technical report; total alone overstates compute cost |
| 4 | Model total size | Cost | What is the on-disk size of the weights at the chosen quantization? | Sum the `safetensors` shard sizes from the HF repo |
| 5 | License and weights availability | Evidence | Does the repo have an actual license, and are the weights actually downloadable? | `curl` the HF API; check `gated`, `siblings`, and shard count |
| 6 | Per-million-token pricing | Cost | Is there a published per-1M-token price for input, cached input, and output? | Check the provider pricing page; treat "contact sales" as a red flag |
| 7 | Independent evaluations | Evidence | Are there third-party evals from an org with no stake in the model? | Check HELM, LMArena, Artificial Analysis; vendor blogs do not count |
| 8 | Languages supported | Fit | Which languages does the model support, and at what quality tier? | Check the model card and the HELM multilingual scenarios |
| 9 | Tools supported | Fit | Does the model support tool/function calling, and which schemas? | Check the model card for tool-calling format and verified integrations |
| 10 | Modalities (image, text, audio, video) | Fit | Which input and output modalities does the model handle? | Check the model card; distinguish "accepts" from "generates" |
| 11 | Knowledge cutoff | Fit | What is the latest date the training data covers? | Check the model card; do not confuse release date with cutoff |
| 12 | Hugging Face stats | Adoption | What are the download counts, likes, and derivative-model counts? | `curl` the HF API for `downloads`, `likes`, and search for derivatives |

## The Twelve Criteria

### 1. Benchmark Table Published WITH the Methodology

**Ask**: Are the benchmark scores published together with the methodology
that produced them — scenario definitions, metrics, prompt format, few-shot
configuration, and raw model outputs?

**Verify**:
- The model card or technical report contains a benchmark table **and** a
  methodology section, not just the table.
- The methodology names the benchmark suite (MMLU-Pro, GPQA, IFEval,
  WildBench, HELM, HELMET, etc.) and the version.
- Raw prompts and completions are released publicly (HELM does this; vendor
  blog posts rarely do).
- The few-shot count and prompt template are stated. A 5-shot MMLU score is
  not comparable to a 0-shot MMLU score.

**Failure mode caught**: A vendor publishes a benchmark table with no
methodology. The scores are cherry-picked from the best prompt format and
few-shot count, and are not reproducible by a third party. Without the
methodology, the table is marketing, not evidence.

**Red flag**: "We achieve X on MMLU" with no shot count, no prompt template,
and no link to the raw outputs.

### 2. Open Weights, Open Model, or Neither

**Ask**: Is the release open weights, open model (OSAID-aligned), or neither?
The three are not the same.

**Verify**:
- **Open weights** = the trained parameters are downloadable. The training
  code and data information may be withheld.
- **Open model** (OSAID 1.0) = open weights **plus** the code and data
  information needed to make meaningful changes, under a license that grants
  use, study, modify, and share freedoms.
- **Neither** = weights are gated, behind a click-through, or under a
  license that restricts commercial use, competitive use, or scale (e.g.,
  700M MAU thresholds).

Check the license text against the
[OSAID 1.0](https://opensource.org/ai) and the
[ML Model License Guide](https://lockml.com/research/ml-model-license-guide.html).
Common 2026 license postures:

| License | Commercial use | Restrictions | Honest label |
|---------|:--------------:|-------------|--------------|
| Apache 2.0 | Yes | None | Open weights, permissive |
| MIT | Yes | None | Open weights, permissive |
| Llama Community | Conditional | 700M MAU threshold, attribution | Open weights, restricted |
| Tongyi Qianwen | Conditional | 100M MAU threshold, competitive-use restriction | Open weights, restricted |
| Gemma Terms | Conditional | Prohibited-use policy | Open weights, restricted |
| CC-BY-NC | No | Non-commercial only | Open weights, non-commercial |
| Mistral Research | No | Research only | Weights-only, not open |

**Failure mode caught**: A vendor labels a release "open source" when it is
only open weights under a restricted license. Procurement and downstream
redistribution rights are silently different.

**Red flag**: The model card says "open source" but the license file is
Llama Community, Gemma Terms, or a custom license with a MAU threshold.

### 3. Active Parameter Count for Mixture-of-Experts Models

**Ask**: For an MoE model, what is the **active** parameter count per token,
in addition to the total parameter count?

**Verify**:
- The technical report states both numbers. The convention is
  `<total>-A<active>` (e.g., `DeepSeek-V3 671B-A37B`, `Qwen3-235B-A22B`,
  `GLM-5.2 744B-A40B`).
- The active count is what determines per-token FLOPs and inference cost. The
  total count is what determines GPU memory footprint (all experts must be
  resident).
- For dense models, active = total. State this explicitly so the reader does
  not have to infer it.

Reference points (2026):

| Model | Total params | Active params | Activation ratio | Experts / Top-K |
|-------|:------------:|:-------------:|:----------------:|:---------------:|
| Mixtral 8x7B | 47B | 13B | ~28% | 8 / Top-2 |
| DeepSeek-V3 / R1 | 671B | 37B | ~5.5% | 256 / Top-8 |
| Qwen3-235B-A22B | 235B | 22B | ~9.4% | 128 / Top-8 |
| GLM-5.2 | 744B | 40B | ~5.4% | — |

**Failure mode caught**: A vendor quotes only the total parameter count for
an MoE model. The reader overestimates inference cost (active is much smaller
than total) or underestimates memory footprint (total must be resident).

**Red flag**: A model is announced as "671B" with no mention that only 37B
activates per token — or, the reverse, a model is announced as "37B" with no
mention that 671B must be loaded into memory.

### 4. Model Total Size

**Ask**: What is the on-disk size of the model weights at the quantization
you will actually serve?

**Verify**:
- Sum the `safetensors` shard sizes from the Hugging Face repo (or the GGUF
  file size for llama.cpp).
- State the quantization explicitly. The same model at FP8 is roughly 2x the
  size of NVFP4 or AWQ-4bit.
- For MoE, the on-disk size tracks the **total** parameter count, not the
  active count. A 671B MoE at FP8 is ~1.3 TB on disk regardless of the 37B
  active count.
- Include the Multi-Token Prediction (MTP) module if present. DeepSeek-V3's
  HF repo is 685B = 671B main model + 14B MTP module.

**Failure mode caught**: An operator plans disk and VRAM for the active
parameter count and is surprised when the full expert set does not fit.

**Red flag**: A model card quotes a parameter count but no on-disk size, or
quotes the size at a quantization the operator does not intend to use.

### 5. Repository With an Actual License, and Weights Actually Available

**Ask**: Does the repository have an actual license file, and are the weights
actually downloadable — not just claimed to be?

**Verify** with the Hugging Face API (60-second check):

```bash
curl -s "https://huggingface.co/api/models/$REPO" \
  | jq '{gated, downloads,
         shards: ([(.siblings // [])[].rfilename
                   | select(endswith(".safetensors"))] | length),
         has_license: ([(.siblings // [])[].rfilename
                   | select(test("(?i)license"))] | length)}'
```

- `gated: false` + `shards > 0` + `has_license: 1` = real release.
- `gated: true` = weights exist but require approval. Approval may be
  automatic or may take weeks; check the gating policy.
- `shards: 0` = no weights. The repo is a name, a paper, or a derivative
  wearing the model's name. Likes and downloads do **not** prove weights
  exist — a repo with 82 likes and 0 shards has been observed.
- `has_license: 0` = no license file. Without a license, the default is "all
  rights reserved" — the weights are not usable in production even if
  downloadable.

**Failure mode caught**: A repo is announced as "open weights" but contains
no weight files (a decoy), contains weights for a different model (a
derivative wearing the name), or contains weights with no license (download
is legal, use is not).

**Red flag**: High like count, zero shards. Likes are a social signal, not a
storage signal.

### 6. Published Per-Million-Token Pricing

**Ask**: Is there a published per-1M-token price for input, cached input,
cache writes, and output?

**Verify**:
- Check the provider's pricing page. The standard 2026 format is a table with
  columns for input, cached input, cache writes, and output, all per 1M
  tokens.
- Distinguish short-context from long-context pricing. Most providers charge
  more per token above a context threshold (e.g., 200K for Anthropic, 1M for
  OpenAI).
- Distinguish standard from batch and flex tiers. Batch is typically 50% off;
  flex (formerly "priority") is variable.
- Treat "contact sales" as a red flag. It means the price is not published,
  which means it is not comparable, which means the criterion fails.

Reference price tiers (August 2026, per 1M tokens, USD):

| Tier | Input | Output | Examples |
|------|:-----:|:------:|---------|
| Frontier | $3–30 | $10–180 | GPT-5.5 Pro, Claude Opus 4.7, Gemini 3.1 Pro |
| Workhorse | $1–5 | $5–30 | Claude Sonnet 5, GPT-5.6 Terra, Gemini 3.0 |
| Small | $0.10–1 | $0.25–4 | Claude Haiku, GPT-5.4 mini, Gemini Flash |
| Nano / Open Flash | <$0.20 | <$0.50 | GPT-5.4 nano, DeepSeek V4 Flash |

**Failure mode caught**: An operator picks a model on capability, deploys
it, and discovers the realized cost is 10x the headline number because
prompt caching was not enabled, long-context pricing kicked in, or the
"contact sales" tier turned out to be frontier-priced.

**Red flag**: No published price, or a price quoted only as "starting from
$X" with no output-token price.

### 7. Independent Evaluations From a Third Party With No Stakes

**Ask**: Are there evaluations from an organization that has no financial or
reputational stake in the model's success?

**Verify**:
- Check at least one of the three independent sources:
  - **HELM** (Stanford CRFM) — open framework, reproducible, releases raw
    prompts and completions. Best for standardized scenario/metric
    comparison.
  - **LMArena** — crowd-sourced blind pairwise preference. Best for
    aggregate human taste; not a full benchmark suite.
  - **Artificial Analysis** — aggregates performance, price, and speed
    across providers. Best for price/performance decisions.
- Vendor blogs and model cards do **not** count as independent, even when
  they cite independent benchmarks. Go to the primary source.
- A vendor that benchmarks only against weaker competitors is selecting the
  comparison set, not running an independent eval.

**Failure mode caught**: A vendor reports state-of-the-art on a benchmark
suite it chose, against competitors it selected, with a methodology it did
not release. Independent evals on the same suite show the model in the
middle of the pack.

**Red flag**: The only evals cited are on the vendor's own blog, or the
vendor cites LMArena but only the week its model was at the top.

### 8. Languages Supported

**Ask**: Which languages does the model support, and at what quality tier?

**Verify**:
- Check the model card for a stated language list. Distinguish "trained on"
  (the model saw the language in pretraining) from "evaluated on" (the model
  was benchmarked in the language).
- Check HELM's multilingual scenarios for independent verification of
  non-English quality.
- For production use in a non-English language, require an independent eval
  in that language. A model that "supports" 100 languages may be
  English-frontier and everything-else-mediocre.

**Failure mode caught**: A model is deployed for a multilingual workload
based on a "100 languages supported" claim, and quality collapses for the
languages that were not in the eval set.

**Red flag**: The model card lists supported languages but cites no
non-English benchmark scores.

### 9. Tools Supported

**Ask**: Does the model support tool/function calling, and which schemas
(OpenAI function calling, Anthropic tool use, Hermes-style, custom)?

**Verify**:
- Check the model card for the tool-calling format and any verified
  integrations (e.g., "tested with LangChain, LlamaIndex").
- Distinguish "trained for tool use" from "prompted into tool use". The
  former has a dedicated tool-calling format and post-training; the latter
  is a base model with a tool prompt and is less reliable.
- For agentic workloads, check whether the model supports parallel tool
  calls, multi-step tool chains, and structured output (JSON mode).

**Failure mode caught**: A model is deployed for an agentic workload based
on a "supports tools" claim, but the support is a prompt template, not a
trained capability. Tool-call reliability is low and the agent loop fails
silently.

**Red flag**: The model card says "tool-capable" but names no tool-calling
format and no verified integration.

### 10. Image, Text, Audio, Video — Supported?

**Ask**: Which input and output modalities does the model handle?

**Verify**:
- Check the model card. Distinguish **accepts** (the model can take the
  modality as input) from **generates** (the model can produce the
  modality as output). Many "multimodal" models accept images but generate
  only text.
- For audio and video, check whether the modality is native or routed through
  a separate encoder/decoder. Native is lower latency; routed is more
  flexible but adds a hop.
- For production use, check the modality-specific pricing. Audio and video
  tokens are typically priced differently from text tokens (e.g., per-minute
  for audio).

**Failure mode caught**: A model is deployed for a multimodal workload based
on a "multimodal" label, but the model only accepts images and generates
text. The video-generation requirement was never going to be met.

**Red flag**: The model card says "multimodal" without a per-modality
capability matrix.

### 11. Max Knowledge Basis Date

**Ask**: What is the latest date the training data covers (the knowledge
cutoff)?

**Verify**:
- Check the model card for a stated knowledge cutoff. Do not confuse the
  **release date** with the **knowledge cutoff** — a model released in
  August 2026 may have a cutoff of January 2026.
- For time-sensitive workloads (news, finance, regulations), require a
  cutoff recent enough that the workload's facts are in the training data, or
  plan for retrieval-augmented generation (RAG).
- Internet-connected models can exceed their cutoff via search, but this
  introduces latency and variability. Treat "the model can search the web"
  as a separate capability, not as a substitute for a recent cutoff.

**Failure mode caught**: A model is deployed for a workload that depends on
recent facts. The cutoff is six months older than the operator assumed, and
the model hallucinates facts that changed after the cutoff.

**Red flag**: The model card states a release date but no knowledge cutoff,
or the cutoff is stated only in an interview, not in the model card.

### 12. Hugging Face Stats

**Ask**: What are the download counts, like counts, and derivative-model
counts on Hugging Face?

**Verify** with the HF API:

```bash
curl -s "https://huggingface.co/api/models/$REPO" \
  | jq '{downloads, likes, gated, lastModified}'
```

- **Downloads** are the strongest adoption signal. A model with millions of
  downloads is being run in production by many parties.
- **Likes** are a social signal, not a storage signal (see criterion 5). A
  repo can have high likes and zero weights.
- **Derivative models** (fine-tunes, quantizations, abliterations) indicate
  an active community. Search the HF model index for the base model name.
- **Recency of `lastModified`** indicates whether the repo is maintained. A
  model with no updates in six months may be abandoned.

Reference: the Hugging Face Model Hub hosts 2M+ models with 1.7B cumulative
downloads (as of 2025). The top open-weight models (DeepSeek, Qwen, Llama)
account for a disproportionate share of downloads.

**Failure mode caught**: An operator picks a model with high likes but low
downloads, or a model with no derivatives. The model is popular in discourse
but unproven in production, and no community tooling exists for it.

**Red flag**: High likes, low (or zero) downloads, and no derivative models.

## Assessment Workflow

1. **Run the 60-second weights check** (criterion 5) first. If the weights
   are not actually available under a usable license, the other criteria are
   moot.
2. **Verify evidence** (criteria 1, 2, 3, 7). These are the criteria most
   often lied about by omission. If the vendor's claims fail verification,
   discount the rest of the model card proportionally.
3. **Verify cost** (criteria 4, 6). On-disk size determines infrastructure;
   per-token pricing determines unit economics.
4. **Verify fit** (criteria 8, 9, 10, 11). These are workload-specific; a
   model that fails fit for one workload may pass for another.
5. **Check adoption** (criterion 12) last. Adoption is a risk signal, not a
   quality signal — a well-adopted model has community tooling and
   documented failure modes; a poorly-adopted model does not.

## Common Anti-Patterns

- **"It says open source on the model card"** — the label is marketing, not
  law. Read the license text. Llama Community, Gemma Terms, and custom
  licenses with MAU thresholds are open weights, not open source.
- **"671B parameters, so it must be expensive to run"** — for MoE, the
  active count (37B) determines inference cost; the total count (671B)
  determines memory. Conflating the two mispredicts both.
- **"It scored X on MMLU"** — without the methodology (shots, prompt format,
  raw outputs), the score is not comparable to any other model's MMLU score.
- **"High likes on HF, so it must be real"** — likes are social, not storage.
  Verify shards exist.
- **"Vendor says it is frontier-class"** — check HELM, LMArena, and
  Artificial Analysis. Vendor self-evaluation is not independent.
- **"Contact sales for pricing"** — the price is not published, which means
  it is not comparable, which means criterion 6 fails.

## Review Triggers

- A new model is announced and the operator is considering adoption.
- A vendor changes the license on an existing model (re-verify criterion 2
  and 5).
- A provider changes pricing (re-verify criterion 6).
- An independent eval suite (HELM, LMArena, Artificial Analysis) releases a
  new leaderboard (re-verify criterion 7).
- The workload's modality, language, or tool-calling requirements change
  (re-verify criteria 8, 9, 10).
- The knowledge cutoff becomes stale for a time-sensitive workload
  (re-verify criterion 11; consider RAG or a newer model).

## Cross-References

- Companion: [LLM Runtime Selection](llm-runtime-selection.md) — the serving
  decision after the model decision. This page covers "which model";
  that page covers "which runtime serves it".
- Related: [Primitive Comparison Matrix](primitive-comparison.md) —
  comparison of AI primitives (skills, agents, workflows), not models.
- Related: [Composition Chain](../composition/composition-chain.md) — the
  agent loop that routes to a chosen model is itself a composition of
  skills/workflows/agents.
