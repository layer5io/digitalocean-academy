---
type: "page"
id: "progressive-delivery-and-rollback"
title: "Progressive Delivery & Rollback"
description: "Deploy AI services using canary and blue-green strategies, and automate rollback when quality or reliability regressions are detected."
weight: 4
---

## Why Progressive Delivery for AI

AI service updates carry unique risks: a new model version may behave differently in ways that automated unit tests do not catch. A new RAG pipeline may retrieve subtly different context. A routing policy change may shift cost distribution unexpectedly. Progressive delivery limits the blast radius of these changes by exposing them to a fraction of traffic before full rollout.

## Canary Deployments

In a canary deployment, the new version receives a small percentage of traffic — typically 5–10% — while the current version handles the rest. Metrics from both populations are compared before promoting the canary.

With Meshery, define the canary weight in your Design:

```yaml
name: inference-canary
services:
  inference-stable:
    type: Deployment
    namespace: production
    settings:
      replicas: 9
      image: registry.digitalocean.com/myteam/inference-service:v1.4.0
  inference-canary:
    type: Deployment
    namespace: production
    settings:
      replicas: 1
      image: registry.digitalocean.com/myteam/inference-service:v1.5.0
```

A 9:1 replica ratio routes approximately 10% of traffic to the canary. Adjust the ratio as confidence grows.

## Blue-Green Deployments

Blue-green maintains two complete environments: the current live version (blue) and the next version (green). Traffic is switched atomically when the green environment is ready.

```yaml
# Switch from blue to green by updating the Service selector
name: inference-blue-green
services:
  inference-svc:
    type: Service
    namespace: production
    settings:
      selector:
        app: inference-service
        slot: green    # was: blue
```

Apply the updated Design via `mesheryctl design apply` to execute the cutover. Blue remains running and can receive traffic again with a single selector change — rollback is instant.

## Automated Promotion and Rollback

Integrate canary promotion with your evaluation pipeline. After a canary has served traffic for a defined soak period, run Evaluations against canary traffic samples:

```bash
# In your promotion script
CANARY_QUALITY=$(python scripts/score_canary_sample.py --variant canary)
STABLE_QUALITY=$(python scripts/score_canary_sample.py --variant stable)

if (( $(echo "$CANARY_QUALITY < $STABLE_QUALITY * 0.95" | bc -l) )); then
  echo "Canary quality regression detected. Rolling back."
  mesheryctl design apply --file infrastructure/rollback-stable.yaml \
    --context my-doks-cluster
  exit 1
fi

echo "Canary healthy. Promoting to 100%."
mesheryctl design apply --file infrastructure/promote-canary.yaml \
  --context my-doks-cluster
```

A 5% quality regression threshold triggers automatic rollback; a passing canary is promoted.

## Rollback Procedure

Because Meshery Designs are stored in git, rollback is always available:

```bash
# Identify the last known-good commit
git log infrastructure/production-inference.yaml

# Apply the previous design version
git show <previous-commit>:infrastructure/production-inference.yaml \
  > /tmp/rollback-design.yaml

mesheryctl design apply --file /tmp/rollback-design.yaml \
  --context my-doks-cluster
```

At the Inference Router level, rollback is even simpler — update the routing policy to shift 100% of traffic back to the stable model. This takes effect immediately without redeploying any containers.

## Metrics to Watch During Rollout

| Metric | Threshold action |
|---|---|
| Error rate (5xx) | Rollback if > 1% for 5 minutes |
| p95 latency | Rollback if exceeds SLA threshold |
| Evaluation quality score | Rollback if < 95% of baseline |
| Cost per request | Alert if > 20% above baseline |

Instrument your service to export these metrics to a dashboard and configure alerts that trigger the rollback script automatically when thresholds are breached.

For Meshery Design management and deployment workflows, see the [Meshery docs](https://docs.meshery.io/).
