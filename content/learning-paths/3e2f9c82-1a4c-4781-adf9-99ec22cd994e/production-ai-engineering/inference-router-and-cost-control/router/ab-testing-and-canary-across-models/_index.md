---
type: "page"
id: "ab-testing-and-canary-across-models"
title: "A/B Testing & Canary Across Models"
description: "Split traffic across models, run canary deployments, and configure automatic fallbacks using the Inference Router."
weight: 3
---

## Why Traffic Splitting Matters for AI

When you want to evaluate a new model, you cannot simply swap it in and hope for the best. Production traffic is your most honest signal: does the new model produce better outputs, at acceptable latency and cost, for your actual users and prompts? Traffic splitting lets you answer this question with real data before committing to a full rollout.

## Canary Deployment

A canary sends a small percentage of traffic to the new model while the rest continues to the current baseline. The Router's `weight` field controls the split:

```yaml
policy:
  traffic_split:
    - route_to: "llama-3-70b"    # current model
      weight: 90
    - route_to: "llama-3-405b"   # canary
      weight: 10
```

With this policy, 10% of requests go to the 405B model. You observe quality metrics and latency from both populations before deciding whether to increase the canary weight.

To graduate the canary to 100%, update the weights — no application code change required:

```yaml
policy:
  traffic_split:
    - route_to: "llama-3-405b"
      weight: 100
```

## A/B Testing

A/B testing is a symmetric split where neither model is labeled "control":

```yaml
policy:
  traffic_split:
    - route_to: "model-a"
      weight: 50
    - route_to: "model-b"
      weight: 50
  experiment_id: "homepage-summarizer-ab"
```

Log the `experiment_id` alongside each response so you can join split assignment to downstream metrics (user engagement, task completion, thumbs-up rate) in your analytics pipeline.

## Collecting Comparison Data

Attach the model that served each response to your application logs:

```python
response = client.chat.completions.create(
    model="my-ab-policy",
    messages=[{"role": "user", "content": prompt}],
)
serving_model = response.model   # Router sets this to the actual model used
log_event(prompt_id=pid, model=serving_model, latency_ms=elapsed)
```

Feed these logs into Evaluations (LLM-as-a-judge) to score quality per variant at scale rather than relying solely on human review.

## Automatic Fallbacks

Traffic splitting and fallbacks compose. If the canary model returns an error or exceeds a latency threshold, the Router falls back to the stable model for that request:

```yaml
policy:
  traffic_split:
    - route_to: "new-model"
      weight: 20
      on_error: "fallback_to_stable"
    - route_to: "stable-model"
      weight: 80
  fallback_model: "stable-model"
```

This means a bad deploy of a new model degrades gracefully rather than causing user-visible errors.

## Rollback

If canary metrics reveal a regression — higher latency, lower quality scores, or elevated error rates — rollback is a policy update:

```yaml
policy:
  traffic_split:
    - route_to: "stable-model"
      weight: 100
```

Because the Router is the single point of control, rollback takes effect immediately without redeploying application code or restarting containers.

## Summary

The canary and A/B patterns reduce the risk of model upgrades from a binary "swap and hope" to a gradual, data-driven process. Fallbacks ensure stability during experiments, and the Router's weight system makes rollback instant.

For traffic-splitting policy syntax, see the [DigitalOcean Gradient AI Platform docs](https://docs.digitalocean.com/products/gradient-ai-platform/).
