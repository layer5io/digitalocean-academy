---
type: "page"
id: "throughput-quotas-and-reliability"
title: "Throughput, Quotas & Reliability"
description: "Understand concurrency limits, quota management, and retry strategies for reliable production inference."
weight: 4
---

## Production Reliability Basics

Even well-designed inference services encounter transient errors, rate-limit responses, and bursts beyond provisioned capacity. Handling these conditions gracefully — rather than crashing or silently dropping requests — separates a prototype from a production system.

## Quotas and Concurrency

The Inference Engine enforces quotas at the account and project level. Common limits include:

- **Requests per minute (RPM)**: total API calls within a sliding window.
- **Tokens per minute (TPM)**: input + output tokens across concurrent requests.
- **Concurrent connections**: maximum in-flight requests at any instant.

When a quota is exceeded the API returns HTTP `429 Too Many Requests`. Your client must handle this response explicitly rather than treating it as a fatal error.

Quota increases are available through the DigitalOcean control panel. For Dedicated mode, your reserved capacity directly determines your effective concurrency ceiling.

## Retry with Exponential Backoff

A `429` or transient `5xx` response should trigger a retry with exponential backoff and jitter. Jitter prevents clients from synchronizing retries into another burst.

```python
import time
import random
from openai import OpenAI, RateLimitError, APIStatusError

client = OpenAI(
    base_url="https://inference.do-ai.run/v1",
    api_key="<your-model-access-key>",
)

def chat_with_retry(messages, max_retries=5):
    delay = 1.0
    for attempt in range(max_retries):
        try:
            return client.chat.completions.create(
                model="meta-llama/Meta-Llama-3.1-70B-Instruct",
                messages=messages,
            )
        except RateLimitError:
            if attempt == max_retries - 1:
                raise
            sleep_time = delay + random.uniform(0, delay * 0.3)
            time.sleep(sleep_time)
            delay *= 2
        except APIStatusError as e:
            if e.status_code >= 500 and attempt < max_retries - 1:
                time.sleep(delay)
                delay *= 2
            else:
                raise
```

## Idempotency

For Batch jobs or any workflow where a retry could produce duplicate side effects, implement idempotency at the application layer:

- Assign a stable `request_id` derived from the input content (e.g., a hash of the prompt).
- Before submitting, check whether a result for that ID already exists in your database.
- Store completed results with the `request_id` as the primary key so a retry is a no-op.

```python
import hashlib

def make_request_id(prompt: str) -> str:
    return hashlib.sha256(prompt.encode()).hexdigest()[:16]
```

## Circuit Breaker Pattern

For high-QPS services, wrap inference calls in a circuit breaker so that a sustained outage does not exhaust your request pool with failing calls. Open the circuit after a threshold of consecutive failures; half-open it after a cooldown period to probe recovery.

Libraries such as `pybreaker` (Python) or `opossum` (Node.js) provide drop-in circuit breakers. The key configuration parameters are:

| Parameter | Typical value |
|---|---|
| Failure threshold | 5 consecutive errors |
| Recovery timeout | 30 seconds |
| Half-open probe count | 1 request |

## Monitoring Quota Usage

Track your TPM and RPM consumption via DigitalOcean billing and usage dashboards. Set alerts before you reach quota ceilings so you can request increases proactively rather than reactively.

Instrument your application to log the `x-ratelimit-remaining-requests` and `x-ratelimit-remaining-tokens` response headers on every call. Trending these values reveals whether you are approaching limits during traffic spikes before users see errors.

For quota details and limits documentation, see the [DigitalOcean Gradient AI Platform docs](https://docs.digitalocean.com/products/gradient-ai-platform/).
