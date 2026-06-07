---
type: "page"
id: "call-the-openai-compatible-endpoint"
title: "Call the OpenAI-Compatible Endpoint"
description: "Query a 1-Click Model deployment using curl and the Python openai SDK by pointing base_url at your Droplet's IP address."
weight: 2
---

## The OpenAI-Compatible API

Every 1-Click Model deployment exposes an OpenAI-compatible REST API. This means the same HTTP routes, request schema, and response schema that the OpenAI API uses are available on your Droplet. Routes include:

- `GET  /v1/models` — list available models
- `POST /v1/chat/completions` — chat completion (messages array)
- `POST /v1/completions` — raw text completion

No API key is required by default; the Droplet is secured at the network level by its firewall.

## Querying with curl

Replace `<host>` with your Droplet's public IP or hostname.

**List models:**

```bash
curl http://<host>:8000/v1/models
```

**Chat completion:**

```bash
curl http://<host>:8000/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "meta-llama/Meta-Llama-3.1-8B-Instruct",
    "messages": [
      {"role": "system", "content": "You are a helpful assistant."},
      {"role": "user", "content": "Explain backpropagation in two sentences."}
    ],
    "max_tokens": 200,
    "temperature": 0.7
  }'
```

## Querying with the Python openai SDK

Install the SDK if you have not already:

```bash
pip install openai
```

Point `base_url` at the Droplet instead of the OpenAI API. Set `api_key` to any non-empty string—the server accepts it but does not validate it.

```python
from openai import OpenAI

client = OpenAI(
    base_url="http://<host>:8000/v1",
    api_key="not-used",
)

response = client.chat.completions.create(
    model="meta-llama/Meta-Llama-3.1-8B-Instruct",
    messages=[
        {"role": "system", "content": "You are a helpful assistant."},
        {"role": "user", "content": "Explain backpropagation in two sentences."},
    ],
    max_tokens=200,
    temperature=0.7,
)

print(response.choices[0].message.content)
```

## Streaming Responses

For interactive applications, enable streaming to receive tokens as they are generated:

```python
stream = client.chat.completions.create(
    model="meta-llama/Meta-Llama-3.1-8B-Instruct",
    messages=[{"role": "user", "content": "Write a short poem about the sea."}],
    stream=True,
)

for chunk in stream:
    delta = chunk.choices[0].delta.content
    if delta:
        print(delta, end="", flush=True)
```

## Migrating Existing Code

If you have existing code that calls `api.openai.com`, migration is two lines:

```python
# Before
client = OpenAI()  # uses OPENAI_API_KEY env var, api.openai.com

# After
client = OpenAI(base_url="http://<host>:8000/v1", api_key="not-used")
```

The rest of your code—prompt structure, parameters, response parsing—stays identical. This is the key advantage of the OpenAI-compatible interface: your application logic is decoupled from the underlying model provider.

For the full model catalog and deployment options, see the [1-Click Models page](https://www.digitalocean.com/products/1-click-models).
