---
type: "page"
id: "serving-stacks-vllm-tgi-ollama"
title: "Serving Stacks: vLLM, TGI & Ollama"
description: "Compare vLLM, Hugging Face TGI, and Ollama for self-hosted LLM serving, and see quick-start commands for each on a GPU Droplet."
weight: 1
---

## Why Self-Host?

1-Click Models are the fastest path to a running endpoint, but self-hosting gives you full control: custom model weights, quantization choices, fine-tuned adapters, and the ability to modify every serving parameter. Three open-source stacks dominate self-hosted LLM serving: **vLLM**, Hugging Face **TGI**, and **Ollama**.

## Comparison

| | vLLM | TGI | Ollama |
|---|------|-----|--------|
| Best for | High-throughput production | Production inference, easy HF integration | Development, local use, quick demos |
| OpenAI-compatible API | Yes | Yes | Yes |
| Continuous batching | Yes | Yes | Limited |
| Quantization formats | AWQ, GPTQ, GGUF | AWQ, GPTQ, bitsandbytes | GGUF |
| Multi-GPU (tensor parallel) | Yes | Yes | No |
| Ease of setup | Moderate | Moderate | Very easy |

## vLLM Quick Start

vLLM is the preferred choice for production deployments that need high throughput and low latency. It implements continuous batching and PagedAttention to maximize GPU utilization.

Install and serve a model with pip:

```bash
pip install vllm

python -m vllm.entrypoints.openai.api_server \
  --model meta-llama/Meta-Llama-3.1-8B-Instruct \
  --port 8000 \
  --tensor-parallel-size 1
```

Or run via Docker:

```bash
docker run --gpus all \
  -p 8000:8000 \
  -e HUGGING_FACE_HUB_TOKEN=$HF_TOKEN \
  vllm/vllm-openai:latest \
  --model meta-llama/Meta-Llama-3.1-8B-Instruct
```

The server is available at `http://localhost:8000/v1` with full OpenAI API compatibility.

## TGI Quick Start

Hugging Face Text Generation Inference integrates tightly with the Hugging Face Hub and supports a wide range of model architectures. It is a strong choice when your team is already invested in the Hugging Face ecosystem.

```bash
docker run --gpus all \
  -p 8080:80 \
  -e HUGGING_FACE_HUB_TOKEN=$HF_TOKEN \
  -v $PWD/data:/data \
  ghcr.io/huggingface/text-generation-inference:latest \
  --model-id meta-llama/Meta-Llama-3.1-8B-Instruct \
  --port 80
```

TGI's OpenAI-compatible endpoint is at `http://localhost:8080/v1`.

## Ollama Quick Start

Ollama prioritizes simplicity. It is the fastest way to run a model locally or on a development Droplet, though it lacks the production throughput features of vLLM and TGI.

```bash
# Install
curl -fsSL https://ollama.com/install.sh | sh

# Pull and run a model
ollama run llama3.1

# Start the API server separately
ollama serve &
curl http://localhost:11434/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{"model": "llama3.1", "messages": [{"role": "user", "content": "Hello"}]}'
```

## Choosing a Stack

- Use **vLLM** for production systems that serve multiple concurrent users.
- Use **TGI** when you need deep Hugging Face Hub integration or specific model architectures that TGI supports ahead of vLLM.
- Use **Ollama** when setting up a developer machine, running quick experiments, or onboarding teammates who need a zero-config experience.

For all three stacks, the OpenAI-compatible API means your application code does not change when you switch between them. For more on GPU Droplet setup, see the [GPU Droplets documentation](https://docs.digitalocean.com/products/gpu-droplets/).
