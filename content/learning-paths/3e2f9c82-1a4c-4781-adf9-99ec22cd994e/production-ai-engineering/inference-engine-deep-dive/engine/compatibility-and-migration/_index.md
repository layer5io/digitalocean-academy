---
type: "page"
id: "compatibility-and-migration"
title: "Compatibility & Migration"
description: "Migrate existing OpenAI or Anthropic client code to the DigitalOcean Inference Engine by changing two configuration values."
weight: 3
---

## Why Compatibility Matters

The DigitalOcean Inference Engine speaks the OpenAI and Anthropic wire formats natively. Your existing prompts, function-calling schemas, streaming logic, and retry wrappers all work without modification. Migration is a configuration change, not a code rewrite.

## What You Change

Two values need updating:

| Field | Old value (OpenAI example) | New value |
|---|---|---|
| `base_url` | `https://api.openai.com/v1` | `https://inference.do-ai.run/v1` |
| `api_key` | OpenAI API key | DigitalOcean model access key |

The model name changes too — you pick from the DigitalOcean Model Catalog (70+ open models plus frontier models) rather than OpenAI model IDs.

## Python Migration Example

**Before (OpenAI):**

```python
from openai import OpenAI

client = OpenAI(api_key="sk-...")

response = client.chat.completions.create(
    model="gpt-4o",
    messages=[{"role": "user", "content": "Explain gradient descent."}],
)
```

**After (DigitalOcean Inference Engine):**

```python
from openai import OpenAI

client = OpenAI(
    base_url="https://inference.do-ai.run/v1",
    api_key="<your-do-model-access-key>",
)

response = client.chat.completions.create(
    model="meta-llama/Meta-Llama-3.1-70B-Instruct",
    messages=[{"role": "user", "content": "Explain gradient descent."}],
)
```

Everything else — `messages`, `temperature`, `stream`, `tools`, `response_format` — is identical.

## Environment-Variable Pattern

Avoid hardcoding credentials or URLs. Use environment variables so the same code runs against different endpoints in development and production:

```bash
export OPENAI_BASE_URL="https://inference.do-ai.run/v1"
export OPENAI_API_KEY="<your-do-model-access-key>"
```

```python
import os
from openai import OpenAI

client = OpenAI(
    base_url=os.environ["OPENAI_BASE_URL"],
    api_key=os.environ["OPENAI_API_KEY"],
)
```

The `openai` SDK reads `OPENAI_BASE_URL` and `OPENAI_API_KEY` automatically if you do not pass them explicitly, so in many cases you only need to export the variables — zero code changes.

## Anthropic SDK Migration

If your code uses the Anthropic SDK, the same principle applies. Set the `base_url` to the DigitalOcean endpoint and supply your model access key as the `api_key`. Verify the exact header name in the Inference Engine documentation for Anthropic-compatible calls.

## Streaming and Tool Calls

Streaming (`stream=True`) and tool/function calling work identically after migration. The Inference Engine returns server-sent events in the same format as OpenAI, so any client-side streaming parser you already have continues to work.

## Common Pitfalls

- **Model name not found**: DigitalOcean model IDs use the format `organization/model-name`. Check the Model Catalog for the exact identifier.
- **Auth header mismatch**: Some wrappers hardcode `Authorization: Bearer sk-...` prefixes. Pass your model access key as-is; the `Bearer` scheme is the same.
- **Timeout settings**: Default SDK timeouts may be too short for larger models on first request. Set `timeout=60` or higher when testing.

For the complete model list and endpoint reference, see the [DigitalOcean Gradient AI Platform docs](https://docs.digitalocean.com/products/gradient-ai-platform/).
