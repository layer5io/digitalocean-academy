---
type: "page"
id: "streaming-parameters-and-cost"
title: "Streaming, Parameters & Cost"
description: "Enable streaming responses, tune temperature and top_p, set max_tokens, and understand how these choices affect output quality and inference cost."
weight: 4
---

## Overview

Two knobs matter most when calling the Inference API: the generation parameters that shape *what* the model produces, and streaming that shapes *how* you receive it. Both also have direct cost implications.

## Streaming Responses

By default, the API returns the full completion once the model finishes generating. For user-facing applications, this means a blank screen until the entire response is ready. Streaming sends tokens as they are generated, so the user sees text appear progressively.

Enable streaming by setting `"stream": true`:

```python
import os
from openai import OpenAI

client = OpenAI(
    base_url="https://inference.do-ai.run/v1",
    api_key=os.environ["DO_INFERENCE_KEY"],
)

stream = client.chat.completions.create(
    model="meta-llama/Meta-Llama-3.1-8B-Instruct",
    messages=[{"role": "user", "content": "Explain RAG in three sentences."}],
    stream=True,
)

for chunk in stream:
    delta = chunk.choices[0].delta.content
    if delta:
        print(delta, end="", flush=True)
print()
```

Each chunk is a partial `ChatCompletionChunk` object. The final chunk has `finish_reason` set to `"stop"`. Streaming does not change the token count or cost — you pay for the same tokens either way.

## Generation Parameters

### temperature

Controls randomness. Range: `0.0` to `2.0`.

- `0.0` — deterministic; the model always picks the highest-probability token. Best for factual retrieval and structured output.
- `0.7–1.0` — balanced creativity. Good default for conversational assistants.
- `1.5+` — highly creative but prone to incoherence. Rarely useful in production.

```python
response = client.chat.completions.create(
    model="meta-llama/Meta-Llama-3.1-8B-Instruct",
    messages=[{"role": "user", "content": "Write a tagline for a cloud company."}],
    temperature=0.9,
)
```

### top_p

Nucleus sampling. Range: `0.0` to `1.0`. Only tokens whose cumulative probability reaches `top_p` are considered. Use `top_p` as an alternative to `temperature`; the OpenAI convention is to adjust one or the other, not both simultaneously.

- `0.1` — very conservative; only the most probable tokens.
- `0.95` — near-full vocabulary; behavior close to unfiltered sampling.

### max_tokens

Caps the number of tokens the model generates in the response. This is the primary lever for controlling output length and **cost per call**.

```python
response = client.chat.completions.create(
    model="meta-llama/Meta-Llama-3.1-8B-Instruct",
    messages=[{"role": "user", "content": "Summarize object storage in one sentence."}],
    max_tokens=60,
    temperature=0.3,
)
```

Setting `max_tokens` too low can result in truncated responses with `finish_reason: "length"` instead of `"stop"`. Monitor the `finish_reason` field in production to detect truncation.

## How Tokens Map to Cost

Serverless Inference is billed per token. The `usage` object in every non-streaming response reports exact counts:

```json
"usage": {
  "prompt_tokens": 35,
  "completion_tokens": 58,
  "total_tokens": 93
}
```

Cost = `total_tokens` × price-per-token for the selected model. Larger models (70B+) have higher per-token rates than smaller models (7B–8B).

## Tips to Control Spend

| Technique | Effect |
|---|---|
| Use a smaller model for simple tasks | Reduces per-token rate |
| Set `max_tokens` to the minimum needed | Caps completion cost |
| Cache identical prompts at the application layer | Eliminates repeat API calls |
| Batch offline jobs instead of streaming | No behavioral change; easier to parallelize |
| Use `temperature: 0` for deterministic tasks | Allows safe caching of responses |

For current per-model token pricing, see [docs.digitalocean.com/products/gradient-ai-platform/](https://docs.digitalocean.com/products/gradient-ai-platform/).
