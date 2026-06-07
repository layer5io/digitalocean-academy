---
type: "page"
id: "your-first-chat-completion"
title: "Your First Chat Completion"
description: "Send your first chat completion request using curl, the Python openai SDK, and TypeScript against DigitalOcean's Serverless Inference endpoint."
weight: 3
---

## Overview

DigitalOcean's Serverless Inference endpoint is OpenAI-compatible, which means the exact same request format works whether you are calling it with `curl`, the Python `openai` library, or any TypeScript/JavaScript client. In this lesson you will send the same request three ways.

## Prerequisites

- A model access key stored as `DO_INFERENCE_KEY` in your environment.
- Python 3.9+ with `pip install openai` for the Python example.
- Node.js 18+ with `npm install openai` for the TypeScript example.

## Using curl

The most direct way to verify your setup is a raw HTTP call:

```bash
curl -s https://inference.do-ai.run/v1/chat/completions \
  -H "Authorization: Bearer $DO_INFERENCE_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "meta-llama/Meta-Llama-3.1-8B-Instruct",
    "messages": [
      {"role": "system", "content": "You are a helpful assistant."},
      {"role": "user", "content": "What is DigitalOcean Spaces used for?"}
    ]
  }' | jq '.choices[0].message.content'
```

The response is a standard OpenAI `ChatCompletion` object. The `choices[0].message.content` field contains the model's reply.

## Using the Python openai SDK

Because the endpoint is OpenAI-compatible, the official `openai` Python package works without modification — you only change two values:

```python
import os
from openai import OpenAI

client = OpenAI(
    base_url="https://inference.do-ai.run/v1",
    api_key=os.environ["DO_INFERENCE_KEY"],
)

response = client.chat.completions.create(
    model="meta-llama/Meta-Llama-3.1-8B-Instruct",
    messages=[
        {"role": "system", "content": "You are a helpful assistant."},
        {"role": "user", "content": "What is DigitalOcean Spaces used for?"},
    ],
)

print(response.choices[0].message.content)
```

Install the dependency if you have not already:

```bash
pip install openai
```

## Using TypeScript

The same `openai` npm package works in TypeScript with identical `baseURL` and `apiKey` overrides:

```ts
import OpenAI from "openai";

const client = new OpenAI({
  baseURL: "https://inference.do-ai.run/v1",
  apiKey: process.env.DO_INFERENCE_KEY,
});

async function main() {
  const response = await client.chat.completions.create({
    model: "meta-llama/Meta-Llama-3.1-8B-Instruct",
    messages: [
      { role: "system", content: "You are a helpful assistant." },
      { role: "user", content: "What is DigitalOcean Spaces used for?" },
    ],
  });

  console.log(response.choices[0].message.content);
}

main();
```

Install the dependency:

```bash
npm install openai
```

Run with `ts-node` or compile with `tsc` first.

## Understanding the Response

All three examples return the same structure:

```json
{
  "id": "chatcmpl-...",
  "object": "chat.completion",
  "model": "meta-llama/Meta-Llama-3.1-8B-Instruct",
  "choices": [
    {
      "index": 0,
      "message": { "role": "assistant", "content": "..." },
      "finish_reason": "stop"
    }
  ],
  "usage": {
    "prompt_tokens": 42,
    "completion_tokens": 128,
    "total_tokens": 170
  }
}
```

The `usage` block is important for cost tracking — you are billed on `total_tokens`. Next, you will learn how to stream responses and tune generation parameters to control both quality and cost.

Full API reference: [docs.digitalocean.com/products/gradient-ai-platform/](https://docs.digitalocean.com/products/gradient-ai-platform/).
