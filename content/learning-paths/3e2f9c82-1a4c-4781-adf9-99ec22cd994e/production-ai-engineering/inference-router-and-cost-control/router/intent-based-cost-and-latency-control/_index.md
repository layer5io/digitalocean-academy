---
type: "page"
id: "intent-based-cost-and-latency-control"
title: "Intent-Based Cost & Latency Control"
description: "Express cost and latency intent in Inference Router policies to automatically balance quality, speed, and spend."
weight: 2
---

## The Cost-Latency-Quality Triangle

Every inference call involves trade-offs: larger models produce higher-quality output but cost more and respond more slowly. In a real product, different features have different requirements. A background summarization task can tolerate higher latency; a real-time autocomplete feature cannot. An internal tool may accept lower quality to stay within a budget; a customer-facing feature may not.

The Inference Router lets you encode these constraints as intent rather than hard-wiring model IDs for each call path.

## Expressing Intent in Policies

Instead of selecting a model by name, you annotate each request (or policy rule) with intent signals the Router interprets:

```yaml
policy:
  rules:
    - intent: "cheap"
      route_to: "small-fast-model"
      max_cost_per_1k_tokens: 0.002

    - intent: "balanced"
      route_to: "medium-model"

    - intent: "smart"
      route_to: "frontier-model"
      max_latency_p95_ms: 3000
```

Your application code selects an intent, not a model:

```python
# Signal intent via a custom header or model alias
response = client.chat.completions.create(
    model="router:cheap",   # alias mapped to the "cheap" intent rule
    messages=[{"role": "user", "content": prompt}],
)
```

## Cheap vs Smart Routing

A common pattern is two-tier routing: use a cheap, fast model for simple requests and escalate to a capable frontier model only when needed.

```yaml
policy:
  rules:
    - condition:
        estimated_complexity: "low"
      route_to: "small-model"
    - condition:
        estimated_complexity: "high"
      route_to: "large-model"
    - default:
      route_to: "medium-model"
```

Complexity estimation can be as simple as prompt length, or as sophisticated as a classifier running as a lightweight pre-call step.

## Latency Budgets

For latency-sensitive paths, set a `max_latency_p95_ms` target in the policy. If the primary model cannot meet the target under current load, the Router falls back to a faster model automatically:

```yaml
policy:
  rules:
    - intent: "realtime"
      route_to:
        primary: "fastest-model"
        fallbacks:
          - "medium-model"
      max_latency_p95_ms: 800
```

## Cost Budgets

Set monthly or per-request cost caps in the policy to prevent runaway spend:

```yaml
policy:
  cost_controls:
    max_monthly_usd: 500
    alert_threshold_usd: 400
    on_budget_exceeded: "route_to_cheap"
```

When the budget threshold is crossed, the Router automatically shifts traffic to the cheaper fallback tier, keeping the service operational while containing spend.

## Measuring Actual Cost per Request

Instrument your application to log token counts from response headers:

```python
usage = response.usage
cost_estimate = (
    usage.prompt_tokens * prompt_rate +
    usage.completion_tokens * completion_rate
)
print(f"Request cost: ${cost_estimate:.6f}")
```

Feed this data into a dashboard to validate that your intent-based policy is delivering the cost profile you designed.

For policy configuration details and pricing, see the [DigitalOcean Gradient AI Platform docs](https://docs.digitalocean.com/products/gradient-ai-platform/).
