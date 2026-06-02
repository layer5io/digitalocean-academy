---
type: "page"
id: "cost-monitoring-and-scaling"
title: "Cost Monitoring & Scaling"
description: "Track token-based costs, identify optimization opportunities, and scale your Gradient agent application efficiently."
weight: 4
---

## How Costs Accumulate

Gradient AI Platform inference is billed on token consumption: every request incurs an input token cost (the prompt, instructions, retrieved chunks, and conversation history) and an output token cost (the generated response). In a production agent, costs accumulate from several sources:

| Cost source | Description |
|-------------|-------------|
| System prompt / instructions | Sent with every request; long instructions multiply cost at scale |
| Knowledge-base chunks | Retrieved chunks injected into context add input tokens |
| Conversation history | Long conversation threads send more tokens per turn |
| Function-route responses | Tool outputs injected into context add tokens |
| Output generation | Longer responses cost more than shorter ones |

Understanding which source dominates your cost informs where to optimize.

## Monitoring Token Usage

Agent Insights provides per-request and aggregate token usage metrics. Key metrics to track:

- **Average input tokens per request** — baseline for prompt cost.
- **Average output tokens per request** — baseline for generation cost.
- **p95 total tokens** — identifies outlier conversations that consume disproportionate tokens.
- **Daily total tokens** — multiply by your per-token rate to get daily spend.

Export token-usage data via the Insights API and feed it into your existing cost dashboards or billing alerts:

```bash
curl "https://api.digitalocean.com/v2/gen-ai/agents/{agent_uuid}/insights?metric=token_usage&period=7d" \
  -H "Authorization: Bearer $DIGITALOCEAN_TOKEN"
```

Check the [Gradient API reference](https://docs.digitalocean.com/products/gradient-ai-platform/) for current query parameters.

## Optimization Strategies

### Shorten System Prompts

Every byte of instructions is paid for on every request. Audit your instructions for:
- Redundant restatements of the same rule.
- Examples that can be moved to the knowledge base instead.
- Formatting instructions that can be inferred from context.

A 30% reduction in instruction length produces a 30% reduction in prompt-token cost at no quality loss if the removed text was redundant.

### Tune Knowledge-Base `k`

Retrieving fewer chunks reduces input tokens. If you are retrieving `k=5` chunks but most answers only use one or two, reduce `k` to 3 and re-evaluate quality. The token saving scales with every request that uses the knowledge base.

### Limit Conversation History

Sending the full conversation history on every turn is the fastest way to inflate input tokens in a chat application. Implement a sliding window or summarization strategy:

```python
def trim_history(messages, max_turns=10):
    # Keep system message + last max_turns user/assistant pairs
    system = [m for m in messages if m["role"] == "system"]
    turns = [m for m in messages if m["role"] != "system"]
    return system + turns[-(max_turns * 2):]
```

### Right-size the Model

If evaluations show a smaller model matches the quality of a larger one on your workload, switch. Token pricing scales with model size. A 4× smaller model at equivalent quality reduces inference cost by a proportional amount.

### Cache Repeated Lookups

For function routes that return the same data for the same input within a short window (e.g., account status that updates hourly), cache the result in your function implementation. Fewer tool calls reduce round-trip latency and any upstream API costs.

## Scaling

The Gradient endpoint scales automatically with request volume — no configuration is required. However, scaling on the client side requires attention:

- **Connection pooling**: reuse HTTP connections across requests rather than opening a new connection per call.
- **Async processing**: use async/await patterns to handle multiple concurrent requests without blocking threads.
- **Queue-based load leveling**: for batch workloads, place requests in a queue and process them at a rate below your TPM limit to avoid rate-limit errors.

```python
import asyncio
import openai

async def process_batch(client, batch_messages):
    tasks = [
        client.chat.completions.create(model="n/a", messages=msgs)
        for msgs in batch_messages
    ]
    return await asyncio.gather(*tasks, return_exceptions=True)
```

Monitor p95 latency after any scaling change. High concurrency can increase queuing time at the inference layer, so validate that latency stays within acceptable bounds.

Learn more in the [Gradient AI Platform documentation](https://docs.digitalocean.com/products/gradient-ai-platform/).
