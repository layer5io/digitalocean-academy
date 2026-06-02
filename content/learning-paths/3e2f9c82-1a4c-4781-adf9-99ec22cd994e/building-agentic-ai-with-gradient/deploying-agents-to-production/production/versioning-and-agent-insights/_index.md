---
type: "page"
id: "versioning-and-agent-insights"
title: "Versioning & Agent Insights"
description: "Promote agent versions safely to production and use the Agent Insights observability dashboard to monitor behavior, latency, and errors."
weight: 1
---

## Safe Promotion to Production

Agent versioning is the foundation of a safe deployment workflow. Every time you change an agent's instructions, model, knowledge bases, function routes, or sampling parameters, you create a new version. Promotion sets one version as the active configuration served by the production endpoint.

The production endpoint URL never changes across version promotions. Clients — whether a web front end, a mobile app, or a back-end service — continue calling the same URL while the underlying agent configuration is updated transparently.

### Promotion Workflow

```
1. Create new version in Control Panel or API
2. Run evaluation against the standard dataset
3. Compare results to the current production version
4. If all criteria pass → promote
5. Monitor Agent Insights for 24–48 hours
6. If metrics are stable → archive the previous version
7. If metrics degrade → roll back in < 60 seconds
```

Rollback is always one action: navigate to the Versions tab, select the previous version, and click **Set as active**. The change propagates immediately.

## What Is Agent Insights?

Agent Insights is the observability layer of the Gradient AI Platform. It provides real-time and historical visibility into every agent interaction without requiring you to instrument your code or manage a separate monitoring stack.

Key data available in Agent Insights:

| Signal | Description |
|--------|-------------|
| Request volume | Requests per minute / hour / day |
| Latency | p50, p95, p99 response times (time to first token and total) |
| Token usage | Input tokens, output tokens, total per request |
| Error rate | Failed requests, guardrail blocks, function-call failures |
| Routing events | Which sub-agents were invoked and how often |
| Guardrail events | Content blocks, redactions, jailbreak detections |
| Tool call success rate | Function routes called, succeeded, and failed |

## Monitoring After Promotion

The first 24–48 hours after promoting a new version are the highest-risk window. Set up monitoring focus on:

**Latency regression.** If p95 latency increased substantially after swapping to a larger model, investigate whether the performance impact is acceptable or whether a smaller model would suffice.

**Error rate spike.** A jump in error rate after a function-route change typically indicates a schema mismatch between what the model generates and what the function expects. Compare the function-call arguments in the Insights logs against your schema definition.

**Guardrail event volume.** A sudden increase in jailbreak detections may indicate the agent is being probed or that new guardrail rules are triggering on legitimate inputs. Review the flagged conversations individually.

**Token usage increase.** If average token count per conversation increased, the new instructions may be lengthier, or the knowledge base may be returning more (or larger) chunks. Consider tightening chunk size or `k` if cost is a concern.

## Using Insights for Continuous Improvement

Agent Insights is not only for incident response. Mine it regularly for improvement signals:

- **High-latency conversations** often involve long context. Identify common patterns and shorten instructions or reduce `k`.
- **Repeated function-call failures** point to API reliability issues or schema problems worth addressing in the next version.
- **Guardrail events on legitimate queries** indicate the guardrail configuration needs refinement.
- **Routing distribution** in multi-agent setups shows whether traffic matches your expectations. Unexpected routing spikes indicate ambiguous descriptions.

## Accessing Insights via API

Insights data is also available through the API for integration with external monitoring dashboards:

```bash
curl https://api.digitalocean.com/v2/gen-ai/agents/{agent_uuid}/insights \
  -H "Authorization: Bearer $DIGITALOCEAN_TOKEN" \
  -G --data-urlencode "start=$(date -u -d '24 hours ago' +%Y-%m-%dT%H:%M:%SZ)" \
     --data-urlencode "end=$(date -u +%Y-%m-%dT%H:%M:%SZ)"
```

Check the [Gradient API reference](https://docs.digitalocean.com/products/gradient-ai-platform/) for current query parameters and response schema.

Learn more in the [Gradient AI Platform documentation](https://docs.digitalocean.com/products/gradient-ai-platform/).
