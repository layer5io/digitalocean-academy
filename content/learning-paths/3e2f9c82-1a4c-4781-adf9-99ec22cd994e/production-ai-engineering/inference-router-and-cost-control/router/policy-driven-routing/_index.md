---
type: "page"
id: "policy-driven-routing"
title: "Policy-Driven Routing"
description: "Define natural-language and structured routing policies in the Inference Router to control which model handles each request."
weight: 1
---

## What Is the Inference Router?

The Inference Router is the control plane that sits in front of the Model Catalog. Every request passes through it, and it decides — at call time — which model, which mode, and which configuration to use. This replaces hardcoded routing logic scattered across application code with a single, observable policy layer.

## Two Policy Formats

The Router accepts routing policies in two forms:

**Natural-language policies** express intent in plain English. The Router interprets the statement and maps it to model selection decisions at runtime.

```yaml
policy:
  description: >
    Use the fastest available model for requests shorter than 200 tokens.
    For requests that include code, use a code-specialized model.
    Fall back to the general-purpose model if no specialist is available.
```

**Structured policies** express the same logic as explicit rules with typed fields. They are more predictable for teams that need deterministic behavior or want to version-control policy changes as code.

```yaml
policy:
  rules:
    - condition:
        token_estimate: { lte: 200 }
      route_to: "fast-model-alias"
    - condition:
        input_contains_code: true
      route_to: "code-model-alias"
    - default:
      route_to: "general-model-alias"
```

## Intent Over Model Names

A key design goal of the Router is that application code expresses **intent** — "I need a response fast" or "accuracy matters more than cost here" — rather than a specific model name. The Router translates that intent into a model selection that satisfies the policy at the current moment. When DigitalOcean adds a faster or cheaper model to the catalog, the Router can start using it without any change to application code.

## Fallback Chains

Policies can include fallback chains so that if a primary model is unavailable or over quota, the Router automatically retries on the next candidate:

```yaml
policy:
  rules:
    - condition:
        intent: "high-quality"
      route_to:
        primary: "frontier-model"
        fallbacks:
          - "large-open-model"
          - "medium-open-model"
```

From the client's perspective the call succeeds; the fallback is transparent.

## Separating Policy from Code

Before the Inference Router, routing decisions lived in application code:

```python
# Fragile: hardcoded model selection
if len(prompt) < 500:
    model = "fast-model-id"
else:
    model = "smart-model-id"
```

With the Router, the application sends every request to the same endpoint and the policy file governs selection:

```python
# Clean: intent expressed via model alias, Router handles the rest
response = client.chat.completions.create(
    model="my-policy-alias",
    messages=[{"role": "user", "content": prompt}],
)
```

This makes model upgrades, cost adjustments, and A/B tests a policy-file change rather than a code deployment.

## Versioning Policies

Store policy files in source control alongside application code. Treat a policy change as a deployment artifact: review it in a pull request, test it in a staging environment using Evaluations, and promote it to production with the same CI/CD pipeline that deploys your application.

For the full policy schema and Router configuration reference, see the [DigitalOcean Gradient AI Platform docs](https://docs.digitalocean.com/products/gradient-ai-platform/).
