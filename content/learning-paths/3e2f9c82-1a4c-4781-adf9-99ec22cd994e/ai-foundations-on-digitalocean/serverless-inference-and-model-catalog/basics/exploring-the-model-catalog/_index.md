---
type: "page"
id: "exploring-the-model-catalog"
title: "Exploring the Model Catalog"
description: "Browse DigitalOcean's 70+ model catalog, understand model families and capabilities, and create a model access key."
weight: 2
---

## Overview

The **Model Catalog** is the menu of AI models available through DigitalOcean's Inference Engine. It currently includes 70+ open-source models plus early access to frontier models from OpenAI and Anthropic. You do not need to download, host, or manage any of these models — selecting one by name in your API request is all it takes.

## Model Families

The catalog is organized by model family and provider:

| Provider | Model Families | Best For |
|---|---|---|
| Meta | Llama 3.x (8B, 70B, 405B) | General purpose, reasoning, coding |
| Mistral AI | Mistral, Mixtral | Fast inference, multilingual, instruction-following |
| Alibaba (Qwen) | Qwen 2.x | Multilingual, math, coding |
| Google | Gemma 2 | Lightweight, on-device-class tasks |
| NousResearch | Nous Hermes | Fine-tuned instruction following |
| OpenAI | GPT-4o, o-series | Frontier reasoning and multimodal (early access) |
| Anthropic | Claude 3.x, Claude 4.x | Frontier reasoning, long context, code (early access) |

Within each family, models are offered in multiple sizes. Larger models (70B+) produce higher-quality outputs but cost more per token and have higher latency. Smaller models (7B–8B) are faster and cheaper and are often sufficient for classification, summarization, and simple Q&A.

## How to Browse the Catalog

In the Control Panel:

1. Navigate to **AI → Inference → Model Catalog**.
2. Filter by provider, modality (text, code, vision), or context length.
3. Click a model card to see the model ID string you will use in API calls, the supported context window, and pricing per million tokens.

The model ID string (e.g., `meta-llama/Meta-Llama-3.1-70B-Instruct`) is what you pass as the `model` parameter in your API requests.

## Creating a Model Access Key

Model access keys authenticate your Inference requests. To create one:

1. In the Control Panel, go to **AI → Inference → API Keys**.
2. Click **Generate New Key**.
3. Give the key a descriptive name (e.g., `my-app-dev`).
4. Copy the key immediately — it is shown only once.

Store the key as an environment variable:

```bash
export DO_INFERENCE_KEY="doinf_your_key_here"
```

Verify it works with a quick list-models call:

```bash
curl -s https://inference.do-ai.run/v1/models \
  -H "Authorization: Bearer $DO_INFERENCE_KEY" | jq '.data[].id'
```

This returns the full list of model IDs available under your account, which you can use to confirm catalog access before writing application code.

## Choosing a Model for Your Use Case

| Task | Recommended Starting Point |
|---|---|
| General chat / Q&A | Llama 3.1 8B Instruct |
| Complex reasoning / coding | Llama 3.1 70B Instruct or Mixtral 8x22B |
| Fast, low-cost classification | Mistral 7B Instruct |
| Long-document summarization | Model with 128K+ context window |
| Frontier quality required | Claude or GPT-4o (early access) |

Start with a smaller model and upgrade only if output quality is insufficient. The OpenAI-compatible interface means swapping models is a one-line change in your code.

Explore the current catalog at [digitalocean.com/products/1-click-models](https://www.digitalocean.com/products/1-click-models).
