---
type: "page"
id: "quantization-batching-and-context"
title: "Quantization, Batching & Context"
description: "Learn how quantization formats, continuous batching, KV cache, and context length interact to determine the throughput and memory efficiency of your LLM deployment."
weight: 2
---

## Quantization: Fitting More in Less VRAM

Quantization reduces the precision of model weights, shrinking VRAM usage and often improving throughput at some cost to output quality. Three formats are common in production:

| Format | Bits | Typical VRAM saving | Use case |
|--------|------|--------------------|-|
| GPTQ | 4-bit | ~4× vs FP16 | High-quality 4-bit, GPU-only inference |
| AWQ | 4-bit | ~4× vs FP16 | Fast, hardware-efficient 4-bit |
| GGUF | 2–8-bit | Variable | CPU + GPU hybrid, Ollama |

A 7B model in FP16 needs roughly 14 GB of VRAM. The same model quantized to 4-bit AWQ fits in roughly 4–5 GB, making it runnable on an RTX 4000 Ada with headroom for KV cache.

To load an AWQ-quantized model with vLLM:

```bash
python -m vllm.entrypoints.openai.api_server \
  --model TheBloke/Llama-2-7B-Chat-AWQ \
  --quantization awq \
  --port 8000
```

**Trade-off**: Quantization reduces perplexity quality slightly. For most instruction-following and chat tasks the difference is small at 4-bit AWQ/GPTQ. For tasks requiring precise numerical reasoning, evaluate before deploying.

## Continuous Batching

Traditional static batching waits for a full batch of requests before starting inference. A single slow or long request blocks the rest. **Continuous batching** (also called iteration-level scheduling) processes each forward pass with the largest group of requests whose KV state fits in memory at that moment. New requests join in-flight without waiting for the current batch to finish.

Both vLLM and TGI implement continuous batching by default. This is the single biggest throughput improvement over naïve single-request serving: GPU utilization stays high even when request arrival rates are bursty.

You do not need to configure continuous batching explicitly—it is enabled automatically. You can tune the maximum batch size:

```bash
# vLLM: limit concurrent sequences
python -m vllm.entrypoints.openai.api_server \
  --model meta-llama/Meta-Llama-3.1-8B-Instruct \
  --max-num-seqs 256
```

## KV Cache

During autoregressive decoding, the model computes key and value tensors for each token in the prompt. These tensors are cached so that subsequent generation steps do not recompute them. This KV cache lives in VRAM and grows with both batch size and sequence length.

vLLM's **PagedAttention** manages KV cache with a virtual memory-inspired paging scheme, which prevents fragmentation and allows near-100% VRAM utilization for the cache without over-reserving memory per sequence.

When VRAM is constrained, reduce `--max-model-len` to limit how much KV cache each sequence can occupy:

```bash
python -m vllm.entrypoints.openai.api_server \
  --model meta-llama/Meta-Llama-3.1-8B-Instruct \
  --max-model-len 8192   # 8K context instead of 128K
```

## Context Length Trade-offs

Longer context increases the KV cache footprint linearly with sequence length. Halving the maximum context nearly halves the per-sequence VRAM cost, allowing more concurrent sequences—and therefore higher throughput—on the same GPU.

Guidelines for choosing context length:

- Set `max_model_len` to the maximum input + output length your actual use case requires, not the model's theoretical maximum.
- For RAG pipelines, a 4K–8K context is usually sufficient; only enable long-context if your retrieval strategy genuinely sends 32K+ token inputs.
- Monitor KV cache hit rates and VRAM usage with `nvidia-smi` and the `/metrics` endpoint to tune the limit over time.

For deeper guidance on serving configuration, see the [GPU Droplets documentation](https://docs.digitalocean.com/products/gpu-droplets/).
