---
type: "page"
id: "serverless-batch-and-dedicated"
title: "Serverless, Batch & Dedicated"
description: "Understand the three inference modes the DigitalOcean Inference Engine provides and the trade-offs that determine which to choose."
weight: 1
---

## Overview

The DigitalOcean Inference Engine is the production system that serves models at scale. Rather than exposing three separate APIs, it unifies **Serverless**, **Batch**, and **Dedicated** inference under one OpenAI/Anthropic-compatible endpoint, letting you switch modes without rewriting client code.

## The Three Modes at a Glance

| Mode | Request style | Latency profile | Best for |
|---|---|---|---|
| **Serverless** | Synchronous, real-time | Low, pay-per-token | Interactive features, chatbots, streaming responses |
| **Batch** | Asynchronous, bulk job | Higher (minutes–hours) | Offline scoring, data enrichment, nightly summarization |
| **Dedicated** | Synchronous, reserved capacity | Predictable, SLA-backed | High-QPS products, regulated workloads, cost-capped at scale |

## Serverless Inference

Serverless is the lowest-friction entry point. You send a request and receive a response in real time; capacity scales automatically behind the scenes. There are no instances to provision or warm-up delays to manage. The trade-off is that at very high, sustained throughput the per-token cost is higher than Dedicated.

```python
from openai import OpenAI

client = OpenAI(
    base_url="https://inference.do-ai.run/v1",
    api_key="<your-model-access-key>",
)

response = client.chat.completions.create(
    model="meta-llama/Meta-Llama-3.1-70B-Instruct",
    messages=[{"role": "user", "content": "Summarize this support ticket."}],
)
print(response.choices[0].message.content)
```

## Batch Inference

Batch mode accepts a job payload containing many prompts and processes them asynchronously. You submit the job, receive a job ID, and poll (or receive a callback) when results are ready. This is ideal when latency is not a user-facing concern and you want to amortize cost across thousands of items at once — for example, re-embedding a corpus overnight or scoring a dataset of customer reviews.

```python
# Pseudocode — submit a batch job
job = client.batches.create(
    input_file_id=uploaded_file_id,
    endpoint="/v1/chat/completions",
    completion_window="24h",
)
print(job.id)  # poll this ID for status
```

## Dedicated Inference

Dedicated reserves a fixed amount of GPU capacity exclusively for your workload. You get predictable latency, guaranteed throughput, and protection from noisy-neighbor effects. Dedicated is the right choice once you have validated your model in Serverless and your traffic volume makes reserved capacity economically favorable compared to per-token pricing.

## One Unified Endpoint

All three modes share the base URL `https://inference.do-ai.run/v1` and accept the same request schema. The mode is selected at provisioning time (Serverless/Dedicated) or via the job submission path (Batch), not by changing the API surface. This means you can prototype in Serverless and graduate to Dedicated with a single configuration change.

## Summary

Choose the mode that matches your latency budget, traffic shape, and cost target. Serverless removes operational overhead for variable workloads; Batch maximizes throughput per dollar for offline jobs; Dedicated provides SLA-backed capacity for production services that cannot tolerate variance.

For full specifications see the [DigitalOcean Gradient AI Platform docs](https://docs.digitalocean.com/products/gradient-ai-platform/).
