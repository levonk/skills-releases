---
type: Comparison
title: LLM Model Assessment — Selection Criteria and Verification Checklist
description: Twenty-two-criterion framework for assessing an LLM before adoption. Covers benchmark methodology disclosure, open-weights vs open-model verification, active vs total parameter counts for MoE, on-disk model size, license and weights-availability verification, per-million-token pricing, independent third-party evaluations, language and tool support, modality coverage, knowledge cutoff, Hugging Face adoption signals, context window, data privacy and retention, throughput and latency, rate limits and concurrency, compliance and data residency, fine-tuning and customization, structured output, safety and refusal behavior, vendor viability and deprecation policy, and release cadence. Each criterion pairs the question to ask with the verification step and the failure mode it catches.
tags: [ai-primitives, comparison, model-assessment, llm, evaluation, open-weights, licensing, pricing, benchmarks, huggingface, moe, context-window, data-privacy, throughput, rate-limits, compliance, fine-tuning, structured-output, safety, deprecation]
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
  - id: openai-data-controls
    resource: https://developers.openai.com/api/docs/guides/your-data
    title: "OpenAI — Data controls, zero data retention, abuse monitoring, training opt-in"
  - id: anthropic-data-retention
    resource: https://platform.claude.com/docs/en/manage-claude/api-and-data-retention
    title: "Anthropic — API and data retention, zero data retention (ZDR), HIPAA readiness"
  - id: gemini-zdr
    resource: https://ai.google.dev/gemini-api/docs/zdr
    title: "Google — Zero data retention in the Gemini Developer API"
  - id: openai-rate-limits
    resource: https://developers.openai.com/api/docs/guides/rate-limits
    title: "OpenAI — Rate limits (RPM, TPM, RPD), usage tiers 1–5"
  - id: anthropic-rate-limits
    resource: https://platform.claude.com/docs/en/api/rate-limits
    title: "Anthropic — Rate limits (RPM, ITPM, OTPM), cache-aware ITPM"
  - id: openai-deprecations
    resource: https://developers.openai.com/api/docs/deprecations
    title: "OpenAI — Model deprecations and notice periods (6 months GA, 3 months specialized, 2 weeks preview)"
  - id: anthropic-deprecations
    resource: https://platform.claude.com/docs/en/about-claude/model-deprecations
    title: "Anthropic — Model deprecations, lifecycle (active/legacy/deprecated/retired)"
  - id: anthropic-deprecation-commitments
    resource: https://www.anthropic.com/research/deprecation-commitments
    title: "Anthropic — Commitments on model deprecation and preservation"
  - id: context-window-guide
    resource: https://www.swfte.com/blog/llm-context-window-explained
    title: "LLM Context Window Explained (2026) — input/output caps, long-context surcharge, lost-in-the-middle"
  - id: llm-runtime-selection
    resource: ../llm-runtime-selection.md
    title: "LLM Runtime Selection — companion concept page (runtime choice after model choice)"
---

# LLM Model Assessment — Selection Criteria and Verification Checklist

A twenty-two-criterion framework for assessing an LLM before adoption. Each
criterion pairs the question to ask with the verification step and the failure
mode it catches. Use this before committing a model to a production path;
pair with [LLM Runtime Selection](llm-runtime-selection.md) for the serving
decision after the model decision.

The criteria split into four groups: **evidence** (does the claim have a
verifiable source), **cost** (what does it actually cost to run), **fit**
(does it do what the workload needs), and **adoption** (is anyone else
running it, and will it still be there tomorrow). Verify evidence and cost
first — they are the criteria most often lied about by omission.

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
| 9 | Tools and runtime integration | Fit | Does the model support tool/function calling, and which runtimes/integrations are verified? | Check the model card for tool-calling format, parallel calls, and verified integrations (vLLM, SGLang, LangChain) |
| 10 | Modalities (image, text, audio, video) | Fit | Which input and output modalities does the model handle, and is each native or routed? | Check the model card; distinguish "accepts" from "generates", native from routed |
| 11 | Knowledge cutoff | Fit | What is the latest date the training data covers? | Check the model card; do not confuse release date with cutoff |
| 12 | Hugging Face stats | Adoption | What are the download counts, likes, and derivative-model counts? | `curl` the HF API for `downloads`, `likes`, and search for derivatives |
| 13 | Context window (input + output caps) | Fit | What is the max input context, the max output, and is there a long-context surcharge? | Check the model card; input and output share the budget but have separate caps |
| 14 | Data privacy and retention | Evidence | Does the provider retain prompts, train on inputs, or offer zero-data-retention? | Check the provider's data-controls page; ZDR may require sales approval |
| 15 | Throughput and latency | Cost | What are tokens/sec, time-to-first-token, and inter-token latency under load? | Check Artificial Analysis; benchmark with the workload's prompt distribution |
| 16 | Rate limits and concurrency | Cost | What are the RPM, TPM, and concurrency caps at the operator's tier? | Check the provider's rate-limit page; "custom" or "contact sales" is a red flag |
| 17 | Compliance and data residency | Evidence | Does the model have SOC 2, ISO 27001, HIPAA, GDPR, and regional processing? | Check the provider's compliance page; absence blocks regulated workloads |
| 18 | Fine-tuning and customization | Fit | Does the model support full FT, LoRA, continued pretraining, or distillation? | Check the model card and provider fine-tuning docs; open weights are required for full FT |
| 19 | Structured output (JSON mode, grammar) | Fit | Does the model support constrained decoding, JSON schema, or grammar constraints? | Check the model card and runtime docs; distinct from tool calling |
| 20 | Safety and refusal behavior | Fit | What is the over-refusal rate, and does the safety policy match the workload? | Run workload-specific prompts; check the model card's safety section |
| 21 | Vendor viability and deprecation policy | Adoption | What is the deprecation notice period, and is the vendor likely to outlive the workload? | Check the provider's deprecation page; 6 months GA / 2 weeks preview is the OpenAI floor |
| 22 | Release cadence and versioning | Adoption | How often is the model updated, are old versions retained, and are updates breaking? | Check the model's version history and changelog; pin to a specific version in production |

## The Twenty-Two Criteria

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

### 9. Tools and Runtime Integration

**Ask**: Does the model support tool/function calling, which schemas
(OpenAI function calling, Anthropic tool use, Hermes-style, custom), and
which serving runtimes and agent frameworks are verified to work with it?

**Verify**:
- Check the model card for the tool-calling format and any verified
  integrations (e.g., "tested with LangChain, LlamaIndex").
- Distinguish "trained for tool use" from "prompted into tool use". The
  former has a dedicated tool-calling format and post-training; the latter
  is a base model with a tool prompt and is less reliable.
- For agentic workloads, check whether the model supports parallel tool
  calls, multi-step tool chains, and forced tool use (forcing the model to
  call a specific tool rather than answering in prose).
- Check **runtime integration** separately from tool calling. A model may
  support tool calling but only work with one runtime (e.g., vLLM's
  `--enable-auto-tool-choice --tool-call-parser hermes`), or only with a
  specific parser. Cross-reference with
  [LLM Runtime Selection](llm-runtime-selection.md) — the runtime must
  support the model's tool-calling format, not just the model architecture.
- Check **agent-framework integration**: LangChain, LlamaIndex, CrewAI,
  AutoGen, OpenAI Agents SDK. A model that works with the OpenAI client
  library but no agent framework is harder to deploy in agentic workloads.

**Failure mode caught**: A model is deployed for an agentic workload based
on a "supports tools" claim, but the support is a prompt template, not a
trained capability. Tool-call reliability is low and the agent loop fails
silently. Or: the model supports tools, but the chosen runtime does not
implement the model's tool-call parser, and tool calls never fire.

**Red flag**: The model card says "tool-capable" but names no tool-calling
format, no parser, and no verified runtime or framework integration.

### 10. Modalities (Image, Text, Audio, Video) — Supported, Native or Routed?

**Ask**: Which input and output modalities does the model handle, and for
each, is the modality native or routed through a separate encoder/decoder?

**Verify**:
- Check the model card. Distinguish **accepts** (the model can take the
  modality as input) from **generates** (the model can produce the
  modality as output). Many "multimodal" models accept images but generate
  only text.
- For each modality, distinguish **native** (the model architecture
  processes the modality directly — e.g., a vision-language model with
  image tokens in the context) from **routed** (the modality passes through
  a separate encoder/decoder, e.g., Whisper for audio input, a TTS model
  for audio output). Native is lower latency and cheaper; routed is more
  flexible but adds a hop, a separate model, and a separate bill.
- For production use, check the modality-specific pricing. Audio and video
  tokens are typically priced differently from text tokens (e.g., per-minute
  for audio, per-frame for video).
- Check modality-specific context limits. An image may consume 1,000+ text
  tokens of context; a 1-minute audio clip may consume 10,000+. The
  effective text context shrinks when modalities are in the prompt.

**Failure mode caught**: A model is deployed for a multimodal workload based
on a "multimodal" label, but the model only accepts images and generates
text. The video-generation requirement was never going to be met. Or: the
modality is routed, not native, and the operator did not budget for the
second model or the extra latency hop.

**Red flag**: The model card says "multimodal" without a per-modality
capability matrix that distinguishes accepts/generates and native/routed.

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

### 13. Context Window (Input + Output Caps)

**Ask**: What is the maximum input context, the maximum output, and is there
a long-context surcharge above a threshold?

**Verify**:
- Check the model card for **both** numbers. Input and output share the
  context budget but have separate caps. A model with 1M total context and
  8K max output can ingest a codebase but generates short responses; a model
  with 400K context and 128K max output generates longer responses.
- Compute the **effective input limit**: total context minus max output.
  A 1M-context / 64K-output model has an effective input limit of 936K, not
  1M.
- Check for a **long-context surcharge**. Most providers charge more per
  token above a threshold (e.g., 2x past 200K for Gemini, 2x past 272K for
  GPT-5.x). The headline per-token price (criterion 6) applies only to the
  short-context tier.
- Check the **lost-in-the-middle** behavior. Some models retrieve
  information at the start and end of a long context but miss information in
  the middle. A 1M context that loses middle facts is not a 1M context for
  retrieval workloads.

Reference points (mid-2026):

| Model | Total context | Max output | Long-context surcharge |
|-------|:------------:|:----------:|:----------------------:|
| Gemini 3.1 Pro | 2M | 64K | 2x past 200K |
| GPT-5.5 | 1M | 64K | 2x past 272K |
| Claude Opus 4.7 | 1M | 64K | None |
| DeepSeek V4 Pro | 1M | 32K | None |
| Grok 4.20 | 256K | 32K | None |
| Llama 4 Maverick | 128K | 8K | N/A (self-host) |

**Failure mode caught**: An operator deploys a 1M-context model for a
long-document workload, assumes 1M input, and hits the output cap at 32K.
Or: the workload uses 500K context, the surcharge kicks in at 200K, and the
realized cost is 2x the headline price.

**Red flag**: The model card quotes a single "context window" number with no
separate output cap and no surcharge threshold.

### 14. Data Privacy and Retention

**Ask**: Does the provider retain prompts, train on inputs, or offer a
zero-data-retention (ZDR) arrangement? What is the default retention period?

**Verify**:
- Check the provider's data-controls page (not the model card — privacy
  policy is provider-level, not model-level).
- Distinguish three questions:
  1. **Training on inputs**: Does the provider use API prompts to train
     models? OpenAI, Anthropic, and Google all default to **no** for paid
     API tiers (as of 2026). Consumer chat products may differ.
  2. **Retention for abuse monitoring**: Are prompts logged for abuse
     detection, and for how long? OpenAI defaults to 30-day retention;
     Anthropic and Google have similar defaults.
  3. **Zero Data Retention (ZDR)**: Is there a ZDR arrangement that
     excludes prompts from abuse-monitoring logs? ZDR typically requires
     sales approval and may disable features (e.g., OpenAI ZDR forces
     `store=false`; Anthropic ZDR is per-organization).
- Check whether ZDR covers the **specific features** the workload uses.
  Grounding with Google Search stores prompts for 30 days with no opt-out.
  Some endpoints are ineligible for ZDR.
- For self-hosted open-weight models, this criterion is moot — no prompts
  leave the operator's infrastructure.

**Failure mode caught**: An operator deploys a model for a regulated
workload (healthcare, finance, legal) assuming "API does not train on
inputs" is sufficient. The 30-day abuse-monitoring retention violates the
data-handling policy, and ZDR was never requested.

**Red flag**: The provider's data-controls page is silent on retention
period, or ZDR is "contact sales" with no published eligibility table.

### 15. Throughput and Latency

**Ask**: What are the tokens/sec, time-to-first-token (TTFT), and
inter-token latency under the workload's expected load?

**Verify**:
- Check **Artificial Analysis** for independent throughput and latency
  measurements across providers and models.
- Distinguish three metrics:
  - **Time to first token (TTFT)**: latency before the first token streams.
    Critical for interactive workloads; dominated by prefill.
  - **Inter-token latency (ITL)**: time between successive output tokens.
    Critical for streaming UX; dominated by decode.
  - **Throughput (tokens/sec)**: aggregate output rate. Critical for batch
    workloads; depends on batching and concurrency.
- Benchmark with the **workload's prompt distribution**, not a synthetic
  benchmark. A model that hits 200 tok/s on short prompts may drop to 40
  tok/s on 64K-context prompts.
- For self-hosted models, throughput depends on the runtime (see
  [LLM Runtime Selection](llm-runtime-selection.md)) — SGLang on cu130
  outperforms vLLM on the same model for supported formats.

**Failure mode caught**: An operator picks a model on price and quality,
deploys it for an interactive chat workload, and discovers TTFT is 4
seconds. Users perceive the model as broken even though the answers are
correct.

**Red flag**: The provider quotes only "tokens/sec" with no TTFT or ITL,
or quotes throughput on a short-prompt benchmark that does not match the
workload.

### 16. Rate Limits and Concurrency

**Ask**: What are the RPM (requests per minute), TPM (tokens per minute),
and concurrency caps at the operator's usage tier? Can the model serve the
workload's peak QPS?

**Verify**:
- Check the provider's rate-limit page for the operator's **current tier**,
  not the top tier. OpenAI tiers 1–5 are spend-graduated; Anthropic tiers
  are similar.
- Distinguish the three limits that can bind independently:
  - **RPM**: counts HTTP calls regardless of size. Binds for many-small-calls
    workloads (agent tool loops, classification fan-out).
  - **TPM**: counts input + output tokens. Binds for long-prompt workloads
    (RAG, long-context). One 80K-token request can exhaust TPM while RPM
    is at 1%.
  - **Concurrency**: in-flight calls at once. Binds for streaming sessions
    held open (agent swarms, long-running tool calls).
- Check whether **prompt caching affects rate limits**. Anthropic's
  cache-aware ITPM counts only uncached input tokens, so effective
  throughput is higher than the raw limit suggests.
- Check the **batch quota** separately if the workload uses async batch
  (OpenAI Batch, Anthropic Message Batches). Batch has a separate pool and
  does not consume realtime TPM.

**Failure mode caught**: An operator deploys an agent loop that fans out
50 parallel tool calls, each a separate API request. RPM is exhausted at
call 20, the agent loop stalls, and the failure is silent (retries with
backoff, not a hard error).

**Red flag**: Rate limits are "custom" or "contact sales" with no published
per-tier table, or the operator's tier is not named.

### 17. Compliance and Data Residency

**Ask**: Does the model/provider have SOC 2 Type II, ISO 27001, HIPAA,
GDPR, and regional processing (data residency) for the operator's
jurisdictions?

**Verify**:
- Check the provider's compliance page (not the model card — compliance is
  provider-level).
- Distinguish **certification** (audited, report available under NDA) from
  **readiness** (the provider claims the controls but has not been audited).
  "HIPAA-ready" is not "HIPAA-certified" — there is no such thing as
  HIPAA certification, only Business Associate Agreements (BAAs).
- Check **data residency** for regulated workloads. Some providers offer
  regional processing endpoints (e.g., OpenAI's US-only inference, EU
  data residency) at a price uplift (typically 10%).
- Check **DPAs and BAAs** are available for signing. A provider with
  HIPAA-ready infrastructure but no BAA process is not usable for PHI.
- For self-hosted open-weight models, compliance is the operator's
  responsibility — the model itself has no compliance posture, but the
  infrastructure does.

**Failure mode caught**: An operator deploys a model for a healthcare
workload, assumes "HIPAA-ready" means usable, and discovers the BAA process
takes 8 weeks or is not offered for the operator's plan tier.

**Red flag**: The compliance page lists certifications with no report
availability, or "HIPAA-ready" with no BAA process.

### 18. Fine-Tuning and Customization

**Ask**: Does the model support full fine-tuning, LoRA/QLoRA, continued
pretraining, distillation, or preference tuning (DPO/KTO)? What is
required to fine-tune it?

**Verify**:
- Check the model card and the provider's fine-tuning docs.
- Distinguish the customization levels:
  - **Full fine-tuning**: all parameters updated. Requires open weights and
    significant GPU resources. Only possible for open-weight models.
  - **LoRA / QLoRA**: low-rank adapters on a frozen base. Cheaper; possible
    for open-weight models and some provider APIs (OpenAI, Anthropic do not
    offer LoRA; they offer supervised fine-tuning of a hosted snapshot).
  - **Continued pretraining**: further pretraining on domain data. Requires
    open weights and large compute.
  - **Provider-hosted fine-tuning**: the provider trains a private snapshot
    on your data. No weight download; the snapshot is served only via the
    provider's API.
  - **Distillation**: a smaller model is trained to mimic a larger one.
    Requires open weights for the student.
- Check whether the license **permits fine-tuning and derivative
  distribution**. Llama Community permits fine-tuning but restricts
  derivative distribution above 700M MAU. CC-BY-NC permits fine-tuning but
  not commercial use of the derivative.
- Check whether the provider-hosted fine-tuning produces a **portable**
  artifact or a **locked** snapshot. A locked snapshot cannot be exported
  to another provider or self-hosted.

**Failure mode caught**: An operator plans to fine-tune a provider-hosted
model for a domain-specific workload, then discovers the fine-tuned
snapshot is locked to the provider, cannot be exported, and the operator
cannot migrate without retraining from scratch.

**Red flag**: The fine-tuning docs describe only provider-hosted
fine-tuning with no export path, or the license restricts derivative
distribution.

### 19. Structured Output (JSON Mode, Grammar Constraints)

**Ask**: Does the model support constrained decoding — JSON mode, JSON
schema enforcement, grammar constraints, or regex constraints?

**Verify**:
- Check the model card and the **runtime** docs (this is often a runtime
  feature, not a model feature — vLLM's `--guided-decoding`, SGLang's
  `--json-schema`, llama.cpp's GBNF grammars).
- Distinguish the constraint levels:
  - **JSON mode**: output is valid JSON (syntax guaranteed, schema not
    enforced).
  - **JSON schema enforcement**: output conforms to a specific JSON schema
    (syntax + structure guaranteed).
  - **Grammar constraints**: output conforms to a context-free grammar
    (e.g., GBNF in llama.cpp). Most flexible; can enforce non-JSON formats.
  - **Regex constraints**: output matches a regex. Simplest constraint.
- Check whether the constraint is **decoded** (the model is forced to
  produce valid output at each token) or **validated** (the model produces
  freely and invalid output is rejected). Decoded constraints are reliable;
  validated constraints require retries.
- This criterion is **distinct from tool calling** (criterion 9). Tool
  calling is about the model deciding to call a tool; structured output is
  about the model's response format when it answers directly. A model can
  support one without the other.

**Failure mode caught**: An operator deploys a model for a structured-data
extraction workload, assumes "supports JSON" means schema enforcement, and
gets syntactically valid JSON that does not match the expected schema.
Retries and repair prompts add latency and cost.

**Red flag**: The model card says "JSON mode" but does not distinguish
syntax-only from schema enforcement, or the runtime does not support
guided decoding for this model.

### 20. Safety and Refusal Behavior

**Ask**: What is the model's over-refusal rate on legitimate requests, and
does the safety policy match the workload's risk tolerance?

**Verify**:
- Run **workload-specific prompts** through the model, including edge cases
  that are legitimate but might trigger safety filters (e.g., medical
  questions for a healthcare workload, security questions for a
  cybersecurity workload, violent-content analysis for a content-moderation
  workload).
- Check the model card's safety section for the stated policy and any
  published refusal rates.
- Distinguish **trained refusals** (the model itself declines) from
  **filter refusals** (an input or output filter blocks the request). Filter
  refusals can sometimes be disabled; trained refusals cannot.
- Check whether the model supports **system-prompt safety overrides**. Some
  models allow the system prompt to relax refusals for legitimate
  workloads; others do not.
- For agentic workloads, check whether the model refuses to call tools that
  have safety-relevant side effects (e.g., sending an email, executing
  code). Over-refusal here breaks the agent loop.

**Failure mode caught**: A model is deployed for a cybersecurity workload
and refuses to analyze malicious code samples. The workload is legitimate,
the model is capable, but the safety policy blocks the use case and the
operator discovers this only in production.

**Red flag**: The model card has no safety section, or the safety policy is
not documented, or refusal rates are not published.

### 21. Vendor Viability and Deprecation Policy

**Ask**: What is the deprecation notice period for the model, and is the
vendor likely to outlive the workload's expected lifetime?

**Verify**:
- Check the provider's deprecation page for the **notice period** by model
  class:
  - **Generally available (GA)**: OpenAI guarantees at least 6 months;
    Anthropic provides 6 months from deprecation announcement.
  - **Specialized variants** (chat-latest, codex, deep-research): OpenAI
    provides at least 3 months.
  - **Preview models**: OpenAI may retire with 2 weeks' notice. Anthropic
    does not recommend preview models for business-critical workloads.
- Check the model's **lifecycle status**: active, legacy, deprecated, or
  retired (Anthropic's terminology). A model in "legacy" status has no
  announced retirement date but is no longer updated and may be deprecated
  soon.
- Assess **vendor viability**: Is the vendor funded for the workload's
  expected lifetime? A model from a startup with 12 months of runway is a
  higher deprecation risk than a model from a hyperscaler.
- For **self-hosted open-weight models**, deprecation is not a vendor
  risk — the weights are downloaded and the operator controls the lifetime.
  The risk shifts to **runtime deprecation** (does the runtime continue to
  support the model architecture?).

**Failure mode caught**: An operator deploys a preview model for a
production workload, receives a 2-week deprecation notice, and cannot
migrate in time. Or: a startup vendor shuts down and the hosted model
disappears with no migration path.

**Red flag**: The model is in "preview" status with no GA commitment, or
the vendor has no published deprecation policy.

### 22. Release Cadence and Versioning

**Ask**: How often is the model updated, are old versions retained after an
update, and are updates breaking or backward-compatible?

**Verify**:
- Check the model's **version history** and changelog. A model updated
  weekly with no changelog is harder to track than a model updated quarterly
  with a detailed changelog.
- Distinguish **point releases** (e.g., `claude-sonnet-4.6` → `4.7`) from
  **silent updates** (the same model name points to a different underlying
  version). Silent updates break reproducibility — the same prompt produces
  different outputs before and after the update.
- Check whether **old versions remain available** after a new release.
  OpenAI and Anthropic typically keep the previous version available for a
  transition period; some providers replace in place.
- Check whether the model name supports **pinning to a specific version**
  (e.g., `gpt-5.5-2026-07-15` vs. `gpt-5.5-latest`). Pin in production;
  use `-latest` only for development.
- For **self-hosted open-weight models**, versioning is the operator's
  responsibility — pin to a specific checkpoint commit hash, not a branch.

**Failure mode caught**: An operator deploys `model-latest` in production.
The vendor silently updates the model, outputs change, and the operator
cannot reproduce the previous behavior or determine what changed.

**Red flag**: The model has no version pinning option, or the provider
updates models in place with no changelog or notification.

## Assessment Workflow

1. **Run the 60-second weights check** (criterion 5) first. If the weights
   are not actually available under a usable license, the other criteria are
   moot.
2. **Verify evidence** (criteria 1, 2, 3, 7, 14, 17). These are the criteria
   most often lied about by omission. If the vendor's claims fail
   verification, discount the rest of the model card proportionally.
3. **Verify cost** (criteria 4, 6, 15, 16). On-disk size determines
   infrastructure; per-token pricing determines unit economics; throughput
   and rate limits determine whether the model can serve the workload's
   peak.
4. **Verify fit** (criteria 8, 9, 10, 11, 13, 18, 19, 20). These are
   workload-specific; a model that fails fit for one workload may pass for
   another.
5. **Check adoption and longevity** (criteria 12, 21, 22) last. Adoption is
   a risk signal, not a quality signal. Deprecation policy and release
   cadence determine whether the model will still be servable for the
   workload's lifetime.

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
- **"1M context, so it can handle my workload"** — the context window is a
  shared budget with separate input and output caps, a long-context
  surcharge, and lost-in-the-middle degradation. Check criterion 13, not
  just the headline number.
- **"API does not train on inputs, so privacy is fine"** — training and
  retention are separate questions. The 30-day abuse-monitoring retention
  may violate the data-handling policy even when training is off. Check
  criterion 14.
- **"Tokens/sec is X, so throughput is fine"** — throughput on a
  short-prompt benchmark does not predict throughput on the workload's
  prompt distribution, and TTFT is a separate metric. Check criterion 15
  with the workload's prompts.
- **"It supports JSON, so structured output is fine"** — JSON mode
  (syntax-only) is not JSON schema enforcement (structure guaranteed).
  Check criterion 19 for the constraint level the workload needs.
- **"It is the latest model, so it will be around"** — preview models can be
  retired with 2 weeks' notice. Check criterion 21 for the deprecation
  policy and lifecycle status.
- **"I will just use `model-latest`"** — silent updates break
  reproducibility. Pin to a specific version in production. Check criterion
  22.

## Review Triggers

- A new model is announced and the operator is considering adoption.
- A vendor changes the license on an existing model (re-verify criteria 2
  and 5).
- A provider changes pricing (re-verify criterion 6).
- An independent eval suite (HELM, LMArena, Artificial Analysis) releases a
  new leaderboard (re-verify criterion 7).
- The workload's modality, language, tool-calling, context, or
  structured-output requirements change (re-verify criteria 8, 9, 10, 13,
  19).
- The knowledge cutoff becomes stale for a time-sensitive workload
  (re-verify criterion 11; consider RAG or a newer model).
- A provider announces a deprecation or changes the deprecation policy
  (re-verify criteria 21 and 22).
- The workload's compliance or data-residency requirements change (re-verify
  criterion 17).
- The workload's peak QPS or prompt distribution changes (re-verify
  criteria 15 and 16).
- A provider changes its data-retention or ZDR policy (re-verify criterion
  14).

## Cross-References

- Companion: [LLM Runtime Selection](llm-runtime-selection.md) — the serving
  decision after the model decision. This page covers "which model";
  that page covers "which runtime serves it".
- Related: [Primitive Comparison Matrix](primitive-comparison.md) —
  comparison of AI primitives (skills, agents, workflows), not models.
- Related: [Composition Chain](../composition/composition-chain.md) — the
  agent loop that routes to a chosen model is itself a composition of
  skills/workflows/agents.
