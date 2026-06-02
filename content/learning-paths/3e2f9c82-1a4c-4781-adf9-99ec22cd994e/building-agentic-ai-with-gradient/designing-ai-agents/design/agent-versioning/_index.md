---
type: "page"
id: "agent-versioning"
title: "Agent Versioning"
description: "Create, compare, roll back, and promote agent versions to evolve your agent safely without disrupting production traffic."
weight: 4
---

## Why Versioning Matters

An agent's behavior is determined by its instructions, model, sampling parameters, attached knowledge bases, and function routes. Any change to these — even a single sentence in the instructions — can shift outputs in unexpected ways. Versioning gives you a checkpoint you can return to, a controlled path for promoting improvements, and a safety net when something goes wrong.

The Gradient AI Platform treats versioning as a first-class feature. Every time you save a distinct configuration, the platform records it as an immutable version with a unique identifier.

## Creating a Version

Versions are created from the Control Panel or the API.

From the Control Panel:
1. Open your agent and make the desired configuration changes.
2. Click **Save as version** and provide a label (e.g., `v3-tighter-scope`).
3. The version is stored alongside all previous versions.

Via the API, a version creation request captures the full agent configuration at that point in time:

```bash
curl -X POST https://api.digitalocean.com/v2/gen-ai/agents/{agent_uuid}/versions \
  -H "Authorization: Bearer $DIGITALOCEAN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"name": "v3-tighter-scope"}'
```

Check the [Gradient API reference](https://docs.digitalocean.com/products/gradient-ai-platform/) for the current endpoint paths and request schema.

## Comparing Versions

Before promoting a new version, compare it against the current production version:

| What to compare | How |
|-----------------|-----|
| Output quality | Run the same test-case set against both versions in the playground |
| Latency | Check token-per-second and wall-clock time in Agent Insights |
| Safety | Verify guardrail behavior on adversarial inputs |
| Cost | Compare average token usage per conversation |

Side-by-side comparison in the Control Panel lets you send the same input to two versions simultaneously and see both responses in one view.

## Rolling Back

If a promoted version causes regressions, rolling back takes seconds:

1. Navigate to the agent's **Versions** tab.
2. Select the previous stable version.
3. Click **Set as active**.

The endpoint immediately begins serving the rolled-back configuration. Clients do not need to change anything — the endpoint URL is stable across versions.

## Promoting a Version

Promotion sets a version as the one served by the live endpoint. A safe promotion workflow:

```
New version created
       ↓
Evaluated in playground against full test suite
       ↓
Optionally: A/B tested in staging environment
       ↓
Promoted to production endpoint
       ↓
Monitored via Agent Insights for 24–48 hours
       ↓
Previous version archived (kept for rollback)
```

Never delete old versions immediately after promotion. Keep at least the previous two stable versions archived so rollback is always one click away.

## Version Labels and Governance

Adopt a consistent labeling convention so the version history is readable at a glance:

```
v1-initial-launch
v2-add-billing-kb
v3-swap-to-smaller-model
v4-guardrails-enabled
```

For teams, add a short change rationale to the version description field. Over time the version history becomes a lightweight audit log of every configuration change made to the agent.

Learn more in the [Gradient AI Platform documentation](https://docs.digitalocean.com/products/gradient-ai-platform/).
