---
type: "lab"
description: "Stand up an open LLM on a DigitalOcean GPU Droplet using a 1-Click Model or vLLM, verify the GPU, and call the OpenAI-compatible endpoint from curl and Python."
title: "Deploy an LLM on GPU Droplets"
---

## Introduction

In this challenge you will deploy an open large language model on a
[DigitalOcean GPU Droplet](https://docs.digitalocean.com/products/gpu-droplets/) and serve it behind
an **OpenAI-compatible** API. You will use either **1-Click Models** (powered by Hugging Face) for a
zero-config path, or **vLLM** for a self-hosted path. Both expose the same `/v1` interface, so client
code is identical.

By the end you will have created a GPU Droplet, verified the GPU, served a model, and called it from
two clients.

## Prerequisites

- A DigitalOcean account (trial credit is fine) and the
  [`doctl` CLI](https://docs.digitalocean.com/reference/doctl/) authenticated with `doctl auth init`.
- An SSH key registered with your account.
- `curl` and Python 3 with the `openai` package installed locally.

## Step 1 — Create a GPU Droplet

GPU Droplets come in single- and 8-GPU configurations across NVIDIA H100/H200, AMD MI300X, L40S, and
RTX 4000/6000 Ada. For this lab a single GPU is plenty. Create one from the **AI/ML-ready image**,
which ships with NVIDIA drivers and CUDA preinstalled:

```bash
doctl compute droplet create llm-lab \
  --region nyc2 \
  --image gpu-h100x1-base \
  --size gpu-h100x1-80gb \
  --ssh-keys <your-ssh-key-fingerprint> \
  --wait
```

> Exact image and size slugs vary by availability; list options with
> `doctl compute image list --public | grep -i gpu` and `doctl compute size list | grep -i gpu`.

## Step 2 — Verify the GPU

SSH in and confirm the GPU and driver are visible:

```bash
ssh root@<droplet-ip>
nvidia-smi
```

`nvidia-smi` should print the GPU model, driver/CUDA version, memory, and utilization. If it errors,
you likely did not boot from an AI/ML-ready image.

## Step 3 — Serve a model

**Option A — 1-Click Models (zero config).** Deploy a model such as Llama 3.1 from the
[1-Click Models](https://www.digitalocean.com/products/1-click-models) catalog. The serving stack and
model are installed and optimized automatically and exposed on an OpenAI-compatible endpoint.

**Option B — Self-host with vLLM.** On the Droplet, serve a model with vLLM's OpenAI-compatible server:

```bash
pip install vllm
python -m vllm.entrypoints.openai.api_server \
  --model meta-llama/Llama-3.1-8B-Instruct \
  --host 0.0.0.0 --port 8000
```

This exposes `http://<droplet-ip>:8000/v1`. (Restrict access with a Cloud Firewall in real use.)

## Step 4 — Call the OpenAI-compatible endpoint

From your machine, test with `curl`:

```bash
curl http://<host>/v1/chat/completions \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "meta-llama/Llama-3.1-8B-Instruct",
    "messages": [{"role": "user", "content": "Explain GPU Droplets in one sentence."}]
  }'
```

Then the same call with the Python `openai` SDK — note that only `base_url` and `api_key` change:

```python
from openai import OpenAI

client = OpenAI(base_url="http://<host>/v1", api_key="<token>")
resp = client.chat.completions.create(
    model="meta-llama/Llama-3.1-8B-Instruct",
    messages=[{"role": "user", "content": "Explain GPU Droplets in one sentence."}],
)
print(resp.choices[0].message.content)
```

## Step 5 — Clean up

GPU Droplets bill per hour, so destroy the Droplet when you are done:

```bash
doctl compute droplet delete llm-lab
```

## What you learned

You created GPU infrastructure, served an open model two ways, and called it through the
OpenAI-compatible API — the exact pattern you reuse for 1-Click Models, self-hosted serving, and the
DigitalOcean Inference Engine. Take the exam to validate your understanding.
