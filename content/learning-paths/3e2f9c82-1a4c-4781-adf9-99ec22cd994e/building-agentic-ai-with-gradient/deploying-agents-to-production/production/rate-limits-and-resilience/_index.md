---
type: "page"
id: "rate-limits-and-resilience"
title: "Rate Limits & Resilience"
description: "Implement retries, timeouts, exponential backoff, graceful degradation, and fallback strategies to keep your agent application reliable under load."
weight: 3
---

## Why Resilience Matters

Any networked service can experience transient errors, elevated latency, or rate limiting. AI inference endpoints are no exception — during peak hours or large batch requests, calls may fail or slow down. An agent application without resilience handling passes those failures directly to users. A resilient application absorbs transient errors gracefully and maintains a usable experience.

## Understanding Rate Limits

The Gradient AI Platform enforces rate limits on agent endpoint calls. Limits are typically expressed as:

- **Requests per minute (RPM)** — the number of API calls allowed per minute.
- **Tokens per minute (TPM)** — the total input + output tokens allowed per minute.

When a limit is exceeded, the endpoint returns an HTTP `429 Too Many Requests` response with a `Retry-After` header indicating how many seconds to wait.

Check the [Gradient documentation](https://docs.digitalocean.com/products/gradient-ai-platform/) for current rate limit values for your plan.

## Retry with Exponential Backoff

Retrying immediately after a `429` or transient `5xx` error typically hits the same limit again. Exponential backoff adds progressively longer waits between retries.

```python
import time
import openai

def call_agent_with_retry(client, messages, max_retries=4):
    delay = 1.0
    for attempt in range(max_retries):
        try:
            return client.chat.completions.create(
                model="n/a",
                messages=messages
            )
        except openai.RateLimitError as e:
            retry_after = float(e.response.headers.get("Retry-After", delay))
            wait = max(retry_after, delay)
            print(f"Rate limited. Waiting {wait:.1f}s (attempt {attempt + 1})")
            time.sleep(wait)
            delay *= 2  # exponential backoff
        except openai.APIStatusError as e:
            if e.status_code >= 500 and attempt < max_retries - 1:
                time.sleep(delay)
                delay *= 2
            else:
                raise
    raise RuntimeError("Max retries exceeded")
```

Add a small random jitter (`delay += random.uniform(0, 0.5)`) to prevent multiple clients from retrying in lockstep.

## Timeouts

Always set explicit timeouts on agent calls. Without them, a slow response can block a thread indefinitely.

```python
client = openai.OpenAI(
    base_url="https://<agent-id>.agents.do-ai.run/api/v1",
    api_key="<agent-access-key>",
    timeout=30.0  # 30 seconds total; set lower for real-time UIs
)
```

For streaming responses, also set a timeout on the stream read loop so stalled streams are abandoned.

## Graceful Degradation

When an agent endpoint is unavailable or consistently slow, a graceful degradation strategy maintains partial functionality:

| Failure scenario | Degraded response |
|-----------------|-------------------|
| Agent endpoint down | Return a static fallback message with contact info |
| Rate limit hit repeatedly | Queue the request and notify the user of delay |
| Function route unavailable | Answer from knowledge base only; flag that live data is unavailable |
| Knowledge base unavailable | Answer from model knowledge with an uncertainty disclaimer |

Inform the user clearly when degraded mode is active. "I'm currently unable to retrieve live account data. Here's what I know from our documentation..." is more useful than an opaque error.

## Fallback Models

For critical applications, configure a fallback to a smaller, lower-cost model when the primary model endpoint is unavailable:

```python
def get_response(messages):
    for base_url, key in [
        (PRIMARY_AGENT_URL, PRIMARY_KEY),
        (FALLBACK_AGENT_URL, FALLBACK_KEY)
    ]:
        try:
            client = openai.OpenAI(base_url=base_url, api_key=key, timeout=15.0)
            return client.chat.completions.create(model="n/a", messages=messages)
        except (openai.APIConnectionError, openai.APIStatusError):
            continue
    raise RuntimeError("All agent endpoints unavailable")
```

## Circuit Breakers

For high-volume applications, implement a circuit breaker to stop sending requests to an endpoint that is consistently failing, allowing it time to recover:

```
Closed (normal) → too many errors → Open (stop requests, use fallback)
                                              ↓ after timeout
                                    Half-open (test one request)
                                              ↓ if success
                                    Closed (resume normal)
```

Libraries like `pybreaker` (Python) or `opossum` (Node.js) provide circuit-breaker implementations that integrate with HTTP clients.

Learn more in the [Gradient AI Platform documentation](https://docs.digitalocean.com/products/gradient-ai-platform/).
