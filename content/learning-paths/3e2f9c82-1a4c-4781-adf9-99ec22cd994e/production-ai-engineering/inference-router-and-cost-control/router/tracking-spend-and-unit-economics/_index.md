---
type: "page"
id: "tracking-spend-and-unit-economics"
title: "Tracking Spend & Unit Economics"
description: "Measure cost per request and per token, use dashboards to monitor spend, and set budgets to prevent runaway inference costs."
weight: 4
---

## Why Unit Economics Matter

Total monthly spend is a lagging indicator. By the time a bill arrives, an expensive model swap or a prompt bloat bug may have already cost hundreds or thousands of dollars. Unit economics — cost per request, cost per token, cost per user session — are leading indicators you can act on in real time.

## Cost Components

Inference cost breaks down into two parts:

| Component | Description |
|---|---|
| **Prompt tokens** | Tokens in the input (system prompt + user message + context) |
| **Completion tokens** | Tokens the model generates in its response |

Both are billed separately and at different rates. Long system prompts, large RAG context windows, and verbose tool-call schemas all inflate prompt token counts. Unconstrained `max_tokens` settings inflate completion costs.

## Extracting Token Counts per Request

Every response includes a `usage` object. Log it on every call:

```python
response = client.chat.completions.create(
    model="meta-llama/Meta-Llama-3.1-70B-Instruct",
    messages=messages,
)

usage = response.usage
print(f"Prompt tokens:     {usage.prompt_tokens}")
print(f"Completion tokens: {usage.completion_tokens}")
print(f"Total tokens:      {usage.total_tokens}")

# Estimate cost (fill in actual rates from the pricing page)
PROMPT_RATE     = 0.00090 / 1000   # $ per token
COMPLETION_RATE = 0.00090 / 1000
cost = (usage.prompt_tokens * PROMPT_RATE +
        usage.completion_tokens * COMPLETION_RATE)
print(f"Estimated cost:    ${cost:.6f}")
```

Aggregate these logs in your data warehouse to compute cost per feature, per user cohort, and per model variant.

## Dashboards

DigitalOcean's control panel exposes usage and billing dashboards broken down by project and model. Use these to:

- Track cumulative monthly spend vs budget.
- Identify which models or endpoints account for the largest share of cost.
- Correlate spend spikes with code deployments or traffic events.

For custom dashboards, export usage data to a time-series store (for example, a Managed PostgreSQL database) and visualize with Grafana or a similar tool.

## Setting Budgets and Alerts

Configure budget alerts in the DigitalOcean billing panel to receive notifications before you hit a threshold. In your Inference Router policy, you can also set cost controls that automatically shift traffic to cheaper models when spend approaches a cap:

```yaml
policy:
  cost_controls:
    max_monthly_usd: 300
    alert_threshold_usd: 240
    on_budget_exceeded: "route_to_cheap_tier"
```

## Reducing Cost Without Degrading Quality

| Technique | Impact |
|---|---|
| Trim system prompts | Reduces prompt tokens on every call |
| Cap `max_tokens` | Prevents verbose completions from inflating cost |
| Use a smaller model for simple requests | Often 5–10x cheaper per token |
| Cache frequent identical prompts at the application layer | Eliminates API calls entirely for repeated queries |
| Prefer Dedicated mode for sustained high-QPS traffic | Lower effective per-token cost than Serverless at scale |

## Cost Attribution

Tag requests with metadata (user ID, feature name, team) using request headers or a structured logging field. This enables chargeback reporting and helps teams understand which features drive the most cost — a prerequisite for prioritizing optimization work.

For billing details and current model pricing, see the [DigitalOcean Gradient AI Platform docs](https://docs.digitalocean.com/products/gradient-ai-platform/).
