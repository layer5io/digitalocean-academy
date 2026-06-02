---
type: "page"
id: "choosing-an-inference-mode"
title: "Choosing an Inference Mode"
description: "Match your workload characteristics to the right Inference Engine mode — Serverless, Batch, or Dedicated."
weight: 2
---

## Why Mode Selection Matters

Picking the wrong inference mode wastes money or harms user experience. A chatbot on Batch mode frustrates users waiting minutes for replies. A nightly scoring job on Dedicated pays for idle GPU time. The decision tree below makes the choice mechanical.

## Decision Framework

Work through these questions in order:

**1. Does the user need a response in under a few seconds?**

Yes → consider **Serverless** or **Dedicated**.
No → **Batch** is likely the right fit.

**2. Is your traffic bursty or unpredictable?**

Yes → **Serverless** handles autoscaling without pre-provisioning.
No, traffic is steady and high-volume → **Dedicated** gives better economics.

**3. Do you have a strict latency SLA (p95 < X ms) or compliance requirement for capacity isolation?**

Yes → **Dedicated**.
No → **Serverless** is sufficient.

## Workload Profiles

### Real-Time / Interactive (Serverless)

Use Serverless for any user-facing feature where a human is waiting: chat assistants, autocomplete, live document summarization, or tool-calling agents. Traffic spikes and troughs naturally, and Serverless scales with them.

```python
# Serverless — just point at the unified endpoint
client = OpenAI(
    base_url="https://inference.do-ai.run/v1",
    api_key="<model-access-key>",
)
```

### Async / Bulk Processing (Batch)

Use Batch for workloads where you have a queue of items and time to process them: ingesting new product descriptions, evaluating thousands of model outputs overnight, or generating embeddings for a freshly uploaded dataset. Batch optimizes for throughput, not latency.

```bash
# Upload your JSONL input file, then submit
curl https://inference.do-ai.run/v1/files \
  -H "Authorization: Bearer $MODEL_ACCESS_KEY" \
  -F purpose=batch \
  -F file=@prompts.jsonl
```

### High-QPS Production Services (Dedicated)

Once a Serverless prototype reaches sustained high request rates — typically several hundred requests per second — Dedicated pricing becomes favorable and the predictability of reserved capacity becomes operationally valuable. Teams running regulated services also use Dedicated to guarantee data-plane isolation.

## Quick Reference

| Signal in your workload | Recommended mode |
|---|---|
| User is waiting for the reply | Serverless or Dedicated |
| Processing a dataset file | Batch |
| Need p95 latency guarantee | Dedicated |
| Traffic pattern is unpredictable | Serverless |
| Cost per token must be minimized at scale | Dedicated |
| Prototyping or low-traffic feature | Serverless |

## Iterating Over Time

Most teams start with **Serverless**, validate product-market fit, instrument cost-per-request, and then migrate the highest-traffic paths to **Dedicated** once traffic is stable and predictable. Batch is added as a parallel path for offline workloads that do not need to share capacity with real-time traffic.

Learn more about the available inference options in the [DigitalOcean Gradient AI Platform docs](https://docs.digitalocean.com/products/gradient-ai-platform/).
