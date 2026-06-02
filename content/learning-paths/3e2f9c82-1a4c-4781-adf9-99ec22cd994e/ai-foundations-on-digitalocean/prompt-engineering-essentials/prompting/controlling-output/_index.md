---
type: "page"
id: "controlling-output"
title: "Controlling Output"
description: "Control response format, length, and determinism using temperature, top_p, and explicit format instructions including structured JSON output."
weight: 2
---

## Overview

A model that gives correct but unusable output is still failing. Controlling *format*, *length*, and *determinism* turns a capable model into a reliable application component. These three dimensions are independent — you can have a short, deterministic, JSON-structured response or a long, creative, prose response depending on what your application needs.

## Controlling Format

The most reliable way to control format is to be explicit in the system or user message:

```
Respond only with a JSON object. No prose, no markdown fences, no explanation.
The JSON must have exactly these fields: "status", "category", "summary".
```

For structured output in the OpenAI-compatible API, use the `response_format` parameter:

```python
import os, json
from openai import OpenAI

client = OpenAI(
    base_url="https://inference.do-ai.run/v1",
    api_key=os.environ["DO_INFERENCE_KEY"],
)

response = client.chat.completions.create(
    model="meta-llama/Meta-Llama-3.1-70B-Instruct",
    messages=[
        {
            "role": "system",
            "content": "Classify the support ticket. Respond with JSON only.",
        },
        {
            "role": "user",
            "content": "My Droplet won't boot after a snapshot restore.",
        },
    ],
    response_format={"type": "json_object"},
    temperature=0.0,
)

result = json.loads(response.choices[0].message.content)
print(result)
# {"status": "open", "category": "compute", "summary": "Droplet fails to boot after snapshot restore"}
```

`response_format: {"type": "json_object"}` instructs the model to return valid JSON. Always combine this with `temperature: 0.0` for parsing pipelines — randomness and structured output are rarely compatible.

## Controlling Length

Length is controlled by two mechanisms:

**In the prompt** — explicit length instructions work well for prose:

```
Summarize in exactly three bullet points.
Keep the total response under 80 words.
Write a one-paragraph executive summary.
```

**Via `max_tokens`** — a hard ceiling on completion tokens:

```python
response = client.chat.completions.create(
    model="meta-llama/Meta-Llama-3.1-8B-Instruct",
    messages=[{"role": "user", "content": "Explain VPC peering."}],
    max_tokens=100,
)
```

If the model reaches `max_tokens` before finishing, `finish_reason` is `"length"`. For user-facing responses this creates an abrupt cutoff. Set `max_tokens` conservatively in pipelines; use prompt-based length instructions for conversational output.

## Controlling Determinism

Determinism matters whenever you need reproducible outputs — test cases, automated grading, parsing pipelines:

| Parameter | Value | Effect |
|---|---|---|
| `temperature` | `0.0` | Greedy decoding; same output every time for the same prompt |
| `temperature` | `0.7` | Balanced; some variation on repeated calls |
| `temperature` | `1.2` | High variation; useful for brainstorming |
| `top_p` | `0.1` | Very conservative sampling; near-deterministic |
| `top_p` | `0.95` | Near-full vocabulary sampling |

Use `temperature: 0.0` for:
- Extracting structured data (classification, entity extraction)
- Parsing pipelines that feed downstream code
- Regression tests where output must be stable

Use higher temperature for:
- Creative writing, brainstorming, marketing copy
- Diverse synthetic data generation

## Combining Controls

A practical pattern for a classification endpoint:

```python
response = client.chat.completions.create(
    model="meta-llama/Meta-Llama-3.1-70B-Instruct",
    messages=[
        {"role": "system", "content": (
            "You are a ticket classifier. "
            "Return JSON with fields: category (billing|compute|network|other), "
            "confidence (high|medium|low). No other output."
        )},
        {"role": "user", "content": ticket_text},
    ],
    response_format={"type": "json_object"},
    temperature=0.0,
    max_tokens=50,
)
```

This combination — explicit format instructions, `json_object` response format, zero temperature, and a tight `max_tokens` — produces a fast, parseable, cost-efficient classification with minimal failure modes.

For parameter reference, see [docs.digitalocean.com/products/gradient-ai-platform/](https://docs.digitalocean.com/products/gradient-ai-platform/).
