---
type: "page"
id: "few-shot-and-prompt-patterns"
title: "Few-Shot & Prompt Patterns"
description: "Apply zero-shot, few-shot, role prompting, and chain-of-thought techniques to reliably improve model outputs for common tasks."
weight: 3
---

## Overview

Prompt engineering is the practice of structuring inputs to reliably elicit desired outputs. A small number of patterns — zero-shot, few-shot, role prompting, and chain-of-thought — cover the vast majority of real-world use cases. Knowing when to apply each one prevents over-engineering.

## Zero-Shot Prompting

A zero-shot prompt gives the model only instructions, with no examples:

```python
messages = [
    {"role": "system", "content": "Classify the sentiment of the review as positive, negative, or neutral."},
    {"role": "user", "content": "The Droplet setup was fast but the documentation was confusing."},
]
```

Zero-shot works well when:
- The task is well-defined and the model has strong prior training on it (sentiment, translation, summarization).
- You want to minimize prompt length and token cost.
- You are iterating quickly and do not yet have labeled examples.

## Few-Shot Prompting

Few-shot provides example input/output pairs before the actual input. Examples "tune" the model's behavior without fine-tuning:

```python
messages = [
    {
        "role": "system",
        "content": (
            "Classify support tickets into one of: billing, compute, network, other.\n\n"
            "Examples:\n"
            "Input: I was double-charged this month. Label: billing\n"
            "Input: My Droplet is unresponsive after a reboot. Label: compute\n"
            "Input: DNS records are not propagating. Label: network\n"
        ),
    },
    {"role": "user", "content": "Input: I can't SSH into my server. Label:"},
]
```

Few-shot works well when:
- Zero-shot produces inconsistent formats or wrong categories.
- You have 3–10 high-quality examples that represent the full output space.
- The task requires a specific output style or terminology not standard in training data.

Keep examples short and representative. Three well-chosen examples often outperform ten mediocre ones.

## Role Prompting

Role prompting assigns the model a specific expert identity to shift its vocabulary and reasoning style:

```
You are a senior cloud infrastructure engineer with 10 years of experience optimizing Kubernetes workloads for GPU inference.
```

Role prompting is effective for:
- Technical depth (security auditor, database administrator, API designer)
- Tone calibration (friendly support agent vs. precise technical writer)
- Domain vocabulary (medical, legal, financial contexts)

Pair role prompting with scope constraints to prevent the model from over-applying the persona to off-topic questions.

## Chain-of-Thought (CoT)

Chain-of-thought prompting asks the model to reason step by step before producing an answer. This reliably improves accuracy on multi-step reasoning tasks:

```python
messages = [
    {
        "role": "system",
        "content": (
            "When answering questions that require reasoning or calculation, "
            "think step by step before giving your final answer. "
            "Show your reasoning in a <thinking> block, then give the final answer."
        ),
    },
    {
        "role": "user",
        "content": (
            "My application makes 50,000 inference calls per day, each using "
            "about 800 tokens. How many tokens is that per month?"
        ),
    },
]
```

CoT increases output token count (and cost), so use it only for tasks where correctness matters more than speed — complex reasoning, math, multi-step planning.

## Pattern Summary

| Pattern | When to Use | Token Cost |
|---|---|---|
| Zero-shot | Well-defined, common tasks | Lowest |
| Few-shot | Custom output format, domain vocabulary | Low–medium |
| Role prompting | Expert tone or domain depth needed | Low |
| Chain-of-thought | Multi-step reasoning, calculations | Medium–high |

## Combining Patterns

Patterns compose. A production prompt for a technical Q&A agent might use role prompting for expertise, few-shot examples to establish answer format, and chain-of-thought for complex diagnostic questions. Start with zero-shot, add patterns only when the output fails a quality bar, and measure the impact before scaling.

For further reading, see [docs.digitalocean.com/products/gradient-ai-platform/](https://docs.digitalocean.com/products/gradient-ai-platform/).
