---
type: Comparison
title: LLM Runtime Selection — SGLang, vLLM, llama.cpp, Colibri, Glom
description: Scenario-driven selection of LLM serving runtimes on a single GPU box (NVIDIA DGX Spark GB10 128GB). Covers SGLang (default for supported in-VRAM models), vLLM (fallback for unsupported models/quants/parallelism), llama.cpp (first-mover for brand-new architectures and GGUF-only quants), Colibri (frontier MoE that must stream experts from disk), and Glom (sandboxed code execution). Distilled from ADR-202608021744 in levonk-ai-playground.
tags: [ai-primitives, comparison, llm-runtime, sglang, vllm, llama-cpp, colibri, glom, inference, dgx-spark, runtime-selection]
date:
  created: "2026-08-02"
  knowledge-basis: "2026-08-02"
  last-used: "2026-08-02"
sources:
  - id: adr-202608021744
    resource: https://github.com/levonk/levonk-ai-playground/blob/main/internal-docs/adr/2026/08/adr-202608021744-sglang-glom-runtime-mapping.md
    title: "ADR-202608021744: Tiered LLM Runtime Selection on DGX Spark"
  - id: nvidia-sglang-spark
    resource: https://build.nvidia.com/spark/sglang
    title: "NVIDIA — SGLang for Inference | DGX Spark"
  - id: dgx-spark-playbooks-sglang
    resource: https://github.com/NVIDIA/dgx-spark-playbooks/blob/main/nvidia/sglang/README.md
    title: "DGX Spark Playbooks — SGLang"
  - id: weschera-qwen-sglang-spark
    resource: https://github.com/Weschera/qwen-sglang-dgx-spark
    title: "Weschera — Qwen3.6 + SGLang on DGX Spark"
  - id: colibri-quickstart
    resource: https://github.com/JustVugg/colibri/blob/main/docs/quickstart.md
    title: "Colibri — Quick Start (frontier MoE disk-streaming engine)"
  - id: llama-cpp-repo
    resource: https://github.com/ggerganov/llama.cpp
    title: "llama.cpp — ggml/GGUF first-mover runtime"
  - id: vllm-repo
    resource: https://github.com/vllm-project/vllm
    title: "vLLM — fallback inference runtime"
  - id: sglang-server-args
    resource: https://docs.sglang.io/docs/advanced_features/server_arguments
    title: "SGLang — Server Arguments reference (quantization support, --tp, --mem-fraction-static)"
  - id: sglang-install
    resource: https://lmsysorg.mintlify.app/docs/get-started/install
    title: "SGLang — Installation (Docker image tags, cu130 default, pinning guidance)"
  - id: runner-lib-ref
    resource: https://github.com/levonk/levonk-ai-playground/blob/main/runner-lib.sh
    title: "levonk-ai-playground runner-lib.sh — runtime-agnostic runner library with RUNTIME swap (SGLang default, vLLM fallback)"
---

# LLM Runtime Selection — SGLang, vLLM, llama.cpp, Colibri, Glom

Scenario-driven selection of LLM serving runtimes on a single GPU box
(NVIDIA DGX Spark, Blackwell GB10 128GB). No single runtime covers every
scenario; each owns a distinct scenario class.

## Scenario-to-Runtime Mapping

| Scenario | Default runtime | Fallback / alternative |
|----------|:---------------:|:----------------------:|
| Supported model, max throughput on Blackwell, multi-agent long-context | **SGLang (cu130)** | vLLM (if maturity/stability preferred) |
| Model/quant/parallelism SGLang does not support (GPTQ, compressed-tensors, multi-GPU pipeline parallel, some LoRA serving) | **vLLM** | SGLang (once support lands) |
| Brand-new architecture not yet in SGLang or vLLM | **llama.cpp (ggml)** | SGLang/vLLM (once upstream merges) |
| GGUF-only quant (Q4_K_M, Q8_0, IQ4_XS, etc.) | **llama.cpp (ggml)** | Re-quantize to a server-supported format |
| Frontier MoE that does not fit in 128GB VRAM (e.g. GLM-5.2 744B) | **Colibri** | Remote API (temporary; violates self-hosted) |
| Code execution (run code produced by a code model) | **Glom** | — (no alternative; Glom is the only execution sandbox) |

## Per-Model-Type Defaults

| Model Type | SGLang | vLLM (fallback) | llama.cpp (new-arch/GGUF) | Colibri (frontier MoE) | Glom (execute) |
|------------|:------:|:---------------:|:-------------------------:|:----------------------:|:--------------:|
| General | default | fallback | if too new | no | no |
| Chat | default | fallback | if too new | no | no |
| Reasoning | default | fallback | if too new | no | no |
| Code | default (generate) | fallback (generate) | if too new (generate) | no | yes (execute) |
| Frontier MoE (e.g. GLM-5.2) | no | no | no | default | no |

## Runtime Comparison Matrix

| Dimension | SGLang | vLLM | llama.cpp | Colibri | Glom |
|-----------|--------|------|-----------|---------|------|
| **Primary role** | Inference (in-VRAM, default) | Inference (in-VRAM, fallback) | Inference (bring-up / new-arch) | Inference (frontier MoE, disk-streamed) | Code execution (sandbox) |
| **Hardware target** | GB10/GB20, cu130/SM103 | Any CUDA GPU (not cu130-native yet) | CPU-first, GPU optional | CPU-default, GPU optional, NVMe-bound | N/A (sandbox) |
| **Container** | `lmsysorg/sglang:latest-cu130` | `nvcr.io/nvidia/vllm:26.04-py3` | Native build (`-DGGML_CUDA=ON`) | Native C engine (`./setup.sh` or prebuilt) | N/A (sibling/sidecar) |
| **Model format** | NVFP4, FP8, AWQ | GPTQ, AWQ, compressed-tensors, FP8 | GGUF (Q4_K_M, Q8_0, IQ4_XS, etc.) | int4 MoE on disk (~380GB for 744B) | N/A |
| **Throughput strength** | Highest on Blackwell for supported models; speculative decoding (NEXTN, Eagle top-k) | Production maturity; broad format support | First-mover for new architectures; not throughput-optimized | Bounded by NVMe streaming speed (`--topp 0.85` free win) | N/A |
| **Concurrency** | 32–128 concurrent agents at 64k–256k context | High, but lower than SGLang on this hardware | Low (no server-grade batching) | Low (disk-bound, single-stream) | N/A |
| **API** | OpenAI-compatible | OpenAI-compatible | OpenAI-compatible (`llama-server`) | OpenAI-compatible + web dashboard | N/A (called by agent loop) |
| **VRAM requirement** | Fits in 128GB | Fits in 128GB | Fits in 128GB (or CPU-only) | Does NOT fit in VRAM (streams from NVMe) | N/A |
| **Disk requirement** | Model weights only | Model weights only | GGUF file | ~380GB NVMe for int4 744B MoE; NVMe speed = token speed | N/A |
| **When to use** | Default for supported in-VRAM models | When SGLang cannot serve it or stability wins | Brand-new arch / GGUF-only quant (bring-up; migrate when servers support it) | Frontier MoE too big for VRAM | Execute code from any code model |

## Model Download Sharing

Model weights on disk are **runtime-agnostic** — they are standard
HuggingFace format (`safetensors`, `config.json`, `tokenizer.json`) stored
in the HF cache under
`~/.cache/huggingface/hub/models--<account>--<model>/snapshots/<hash>/`.

Both vLLM and SGLang:

1. Use `huggingface_hub` / `transformers` to download from HF Hub
2. Cache to the same default location (`~/.cache/huggingface/hub/` or
   `$HF_HOME/hub/`)
3. Load the same `safetensors` files into GPU memory

The difference is only in **how** they load weights into VRAM (kernels,
KV-cache layout, CUDA graphs) — the on-disk download is shared. When
switching a model from vLLM to SGLang (or running the same model on both),
**no re-download is needed**.

### Shared vs Runtime-Specific Cache Mounts

| Mount | vLLM | SGLang | Shared? |
|-------|:----:|:------:|:-------:|
| `huggingface` cache | yes | yes | **yes — model weights** |
| `torch` cache | yes | no | vLLM-only |
| `torch_extensions` | yes | no | vLLM-only |
| `vllm` cache | yes | no | vLLM-only |
| `flashinfer` cache | yes | no | vLLM-only |
| `sglang` cache | no | yes | SGLang-only |

The runtime-specific caches (`torch`, `vllm`, `sglang`, `flashinfer`) hold
compiled extensions and KV-cache artifacts — they are small,
runtime-generated, and not re-downloads of the model.

### Quantization Compatibility Caveat

The model *download* is shared, but whether a given quantization **loads
successfully** depends on the runtime's kernel support (see Quantization
Format Comparison below). A model downloaded for vLLM with GPTQ quant will
not load on SGLang if SGLang lacks GPTQ kernel support for that model
architecture — the weights are on disk, but the runtime cannot dequantize
them.

## Quantization Format Comparison

### Are Scores the Same Across Runtimes?

**Partially.** Accuracy and VRAM footprint are properties of the
quantization format — they are the same regardless of which runtime loads
the model. Throughput and performance-per-size ratio are
**runtime-dependent** — the same quant loads faster on SGLang (cu130-native,
GB10-optimized kernels) than on vLLM (not cu130-native on the current
pinned image) for supported formats.

The tables below split along this boundary so the operator can reason about
quant choice (format-inherent) and runtime choice (runtime-dependent)
separately.

### Visual Indicators

| Symbol | Meaning |
|:------:|---------|
| 🏆 | Best in category — top pick |
| ✅ | Good — supported and performs well |
| - | Acceptable — neutral / mid-tier |
| ⚠️ | Caution — suboptimal or partial support |
| 🛑 | Unsupported — do not use |

Scores use a **1–100 scale where 1 is best** (lower = better).

### Quantization Support Matrix

| Quant Format | SGLang | vLLM | llama.cpp |
|--------------|:------:|:----:|:---------:|
| AWQ-4bit | ✅ | ✅ | 🛑 |
| FP8 | ✅ | ✅ | 🛑 |
| NVFP4 | 🏆 | ⚠️ | 🛑 |
| GPTQ | ⚠️ | ✅ | 🛑 |
| compressed-tensors | ⚠️ | ✅ | 🛑 |
| GGUF Q4_K_M | 🛑 | 🛑 | 🏆 |
| GGUF Q8_0 | 🛑 | 🛑 | ✅ |
| GGUF IQ4_XS | 🛑 | 🛑 | ✅ |

### Quant-Inherent Characteristics (same across runtimes)

Accuracy and VRAM footprint are determined by the quantization format, not
the runtime. The same AWQ-4bit model has the same output quality and weight
footprint whether loaded by SGLang or vLLM.

| Quant Format | Accuracy (1-100) | VRAM Footprint (1-100) | Notes |
|--------------|:----------------:|:----------------------:|-------|
| FP8 | 🏆 3 | - 35 | Near-lossless 8-bit; minimal quality degradation |
| GGUF Q8_0 | ✅ 5 | - 35 | Near-lossless 8-bit; GGUF-only |
| NVFP4 | ✅ 8 | ✅ 15 | NVIDIA 4-bit FP format; good quality on Blackwell |
| AWQ-4bit | ✅ 10 | ✅ 15 | Activation-aware 4-bit; good quality, well-supported |
| GGUF Q4_K_M | - 12 | ✅ 18 | Good 4-bit k-quant; GGUF-only |
| compressed-tensors | - 15 | ✅ 15 | Variable; scheme-dependent accuracy |
| GPTQ | ⚠️ 20 | ✅ 15 | Older method; more accuracy degradation at same bit width |
| GGUF IQ4_XS | ⚠️ 25 | 🏆 12 | Aggressive sub-4-bit; smallest footprint, most degradation |

**Quick pick for accuracy**: FP8 > GGUF Q8_0 > NVFP4 > AWQ-4bit > GGUF
Q4_K_M > compressed-tensors > GPTQ > GGUF IQ4_XS.

**Quick pick for smallest VRAM**: GGUF IQ4_XS > NVFP4 = AWQ-4bit = GPTQ =
compressed-tensors > GGUF Q4_K_M > FP8 = GGUF Q8_0.

### Runtime-Dependent Performance (differs by runtime)

Throughput and performance-per-size ratio depend on the runtime's kernel
maturity, cu130 nativeness, batching, and speculative decoding support.
Scores below are relative rankings for the DGX Spark GB10 hardware target.

| Quant + Runtime | Throughput (1-100) | Perf/Size (1-100) | Quick Pick |
|-----------------|:------------------:|:------------------:|------------|
| NVFP4 + SGLang | 🏆 3 | 🏆 5 | **Best overall on GB10** — native cu130 + NVFP4 kernels |
| FP8 + SGLang | ✅ 4 | - 20 | Best accuracy + good speed; larger footprint |
| AWQ-4bit + SGLang | ✅ 5 | ✅ 8 | **Good all-rounder** — well-optimized on both runtimes |
| GPTQ + vLLM | ✅ 10 | - 25 | vLLM fallback; mature GPTQ kernels |
| AWQ-4bit + vLLM | ✅ 12 | - 28 | Decent on vLLM; not cu130-native |
| FP8 + vLLM | ✅ 12 | - 35 | Good throughput but 2x weight footprint |
| compressed-tensors + vLLM | - 15 | - 30 | Decent on vLLM; format coverage advantage |
| GPTQ + SGLang | ⚠️ 40 | ⚠️ 45 | Partial support; prefer vLLM for GPTQ |
| compressed-tensors + SGLang | ⚠️ 40 | ⚠️ 45 | Partial support; prefer vLLM |
| GGUF Q4_K_M + llama.cpp | ⚠️ 60 | ⚠️ 65 | Bring-up only; no batching, CPU-first |
| GGUF Q8_0 + llama.cpp | ⚠️ 65 | ⚠️ 70 | Bring-up only; larger footprint, slower |
| GGUF IQ4_XS + llama.cpp | ⚠️ 70 | ⚠️ 75 | Smallest footprint but slowest; bring-up only |

**Quick pick for throughput on GB10**: NVFP4 + SGLang > FP8 + SGLang >
AWQ-4bit + SGLang > GPTQ + vLLM > AWQ-4bit + vLLM.

**Quick pick for perf/size on GB10**: NVFP4 + SGLang > AWQ-4bit + SGLang >
GPTQ + vLLM > AWQ-4bit + vLLM.

### Selection Shortcut

For the common case (model fits in 128GB VRAM, supported architecture):

1. **NVFP4 + SGLang** if the model has an NVFP4 checkpoint — best
   accuracy-per-byte on GB10.
2. **AWQ-4bit + SGLang** as the general default — well-supported, good
   quality, good throughput.
3. **FP8 + SGLang** if accuracy is the priority and VRAM headroom exists —
   near-lossless at the cost of 2x weight footprint.
4. **GPTQ + vLLM** only when the model has no AWQ/FP8/NVFP4 checkpoint —
   vLLM has the most mature GPTQ kernels.
5. **GGUF + llama.cpp** only for brand-new architectures or GGUF-only
   quants — bring-up path, migrate to a server runtime when support lands.

## Why a Tiered Default-with-Fallbacks Model

No single runtime covers every scenario:

- **SGLang** wins on throughput for supported models on Blackwell but does
  not support every model/quant.
- **vLLM** has broader support but is not cu130-native and is slower on this
  hardware.
- **llama.cpp** is the only path for brand-new architectures and GGUF quants
  but lacks server-grade concurrency.
- **Colibri** is the only path for frontier MoE but is disk-bound.
- **Glom** is the only path for sandboxed code execution.

Pretending any one of them is the only runtime leaves real models without a
serving path. The tiered model keeps one **default** per scenario class (so
the operator is not making a fresh decision every time) while documenting
the **fallback** (so the operator is never blocked).

## Selection Decision Tree

```
Does the model fit in 128GB VRAM?
├── No → Is it a frontier MoE (e.g. 744B)?
│        ├── Yes → Colibri (disk-streamed, --topp 0.85, NVMe-bound)
│        └── No  → Remote API (temporary; violates self-hosted)
└── Yes → Is the architecture supported by SGLang?
          ├── Yes → Is max throughput / speculative decoding the priority?
          │         ├── Yes → SGLang (cu130) — DEFAULT
          │         └── No  → vLLM (if stability / format coverage preferred)
          └── No → Is it supported by vLLM?
                   ├── Yes → vLLM (fallback)
                   └── No → llama.cpp (bring-up; migrate when servers support it)

Separately, for any code model output:
  → Glom (sandboxed execution, regardless of which runtime served the code model)
```

## Operational Notes

### SGLang (default path)

- Pin to a specific version tag (e.g., `v0.5.15-cu130`), not `latest`.
- First version with GB10-native Qwen NVFP4 support.
- Speculative decoding (NEXTN, Eagle top-k) for long-context reasoning models.
- KV-cache mem-fraction tuning affects context length and concurrency.

### vLLM (fallback path)

- Retained for models/quants/parallelism SGLang does not support.
- GPTQ, compressed-tensors, some AWQ variants, multi-GPU pipeline parallelism,
  some LoRA-serving features.
- Not cu130-native on the current pinned image — extra work to match SM103.
- Production maturity when stability wins over throughput.

### llama.cpp (bring-up path)

- Build with `-DGGML_CUDA=ON` for the GB10; pin the commit hash.
- First-mover for brand-new architectures (small ggml codebase, fast community
  implementation).
- Only runtime that reads GGUF quants (Q4_K_M, Q8_0, IQ4_XS).
- CPU-first; single-file portable models (GGUF is one file).
- llamafile, ollama, koboldcpp are the same ggml family under different
  launchers.
- **Migration rule**: once SGLang or vLLM merges support, move the model off
  llama.cpp to the server runtime for batching and multi-agent concurrency.
  Without a trigger, bring-up models accumulate as debt.

### Colibri (frontier MoE path)

- Native C engine on the host (outside Docker), CPU-default, GPU optional.
- Streams MoE experts from NVMe on demand; streaming speed = token speed.
- ~16GB RAM minimum, ~380GB disk for int4 744B model, fast NVMe SSD is the
  single biggest factor in tokens/sec.
- `--topp 0.85` reads fewer expert bytes per token with no quality loss —
  default it on for disk-bound serving.
- First launch loads ~10GB resident weights — expect a startup pause.
- Placement only changes speed, never answers or precision (still the full
  model).
- `libgomp.so.1` runtime dep — install `libgomp1` on minimal/cloud images so
  the engine does not exit silently at startup. `coli doctor` names the
  missing library.
- Pin to a specific release archive (e.g.,
  `colibri-v1.1.0-linux-x86_64.tar.gz`), not `main`.

### Glom (code execution)

- Code-execution sandbox, not an inference runtime.
- Receives code produced by a code model (regardless of which runtime served
  it — SGLang, vLLM, or llama.cpp).
- Sandboxed Python/JS/shell evaluation and tool calls.
- Must be isolated from the inference runtimes.

## Agent-Loop Integration

Every runtime exposes an OpenAI-compatible API on a different host port, so
the agent loop treats runtime selection as URL config, not framework changes:

- "Write code" → code model endpoint (SGLang default; vLLM/llama.cpp fallback)
- "Run code" → Glom (sandboxed execution of code-model output)
- "Think deeply" → reasoning model endpoint (SGLang default; fallbacks as above)
- "Chat" / "General tasks" → general/chat model endpoint (SGLang default; fallbacks)
- "Frontier MoE / huge model" → Colibri endpoint (OpenAI-compatible)
- "Brand-new architecture / GGUF-only quant" → llama.cpp endpoint (bring-up)

## Common Anti-Patterns

- **"SGLang for everything in-VRAM"** — leaves models/quants/parallelism SGLang
  does not support without a serving path. vLLM is the documented fallback,
  not a failure.
- **"llama.cpp as the production serving path"** — lacks batching, KV-cache
  reuse, and multi-agent concurrency. It is the bring-up path; migrate when
  the servers support the model.
- **"Colibri for in-VRAM models"** — disk-bound where the server runtimes are
  not. Colibri is only for the size class that does not fit in VRAM.
- **"Glom for inference"** — Glom is a code-execution sandbox, not an
  inference runtime. It has no KV-cache, batching, or model loading.
- **"Floating tags / `main` for production"** — `latest-cu130`, `main`, and
  unpinned llama.cpp commits break reproducibility. Pin everything.

## Review Triggers

- NVIDIA ships a new GB10/GB20 container that changes the cu130 requirement.
- SGLang drops cu130 support.
- vLLM ships a cu130-native image and closes the throughput gap on Blackwell.
- SGLang or vLLM merges out-of-core MoE support (re-evaluate Colibri).
- SGLang or vLLM merges support for a llama.cpp bring-up model (migrate it).
- Glom, Colibri, or llama.cpp becomes deprecated/unsupported.
- A frontier MoE model larger than GLM-5.2 becomes the baseline (~380GB NVMe
  footprint no longer sufficient).

## Cross-References

- Source ADR: [ADR-202608021744 — Tiered LLM Runtime Selection on DGX Spark](https://github.com/levonk/levonk-ai-playground/blob/main/internal-docs/adr/2026/08/adr-202608021744-sglang-glom-runtime-mapping.md)
- Related: [Primitive Comparison Matrix](primitive-comparison.md) — comparison of AI primitives (skills, agents, workflows, etc.)
- Related: [Composition Chain](../composition/composition-chain.md) — how primitives compose; the agent loop that routes to these runtimes is itself a composition of skills/workflows/agents
