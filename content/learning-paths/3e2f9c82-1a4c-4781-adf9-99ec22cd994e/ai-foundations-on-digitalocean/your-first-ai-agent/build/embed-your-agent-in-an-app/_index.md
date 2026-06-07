---
type: "page"
id: "embed-your-agent-in-an-app"
title: "Embed Your Agent in an App"
description: "Call your published Gradient agent from a Python script and a minimal JavaScript application using the OpenAI-compatible endpoint."
weight: 4
---

## Overview

A published Gradient agent exposes an OpenAI-compatible `/v1/chat/completions` endpoint. Any application that can make HTTP requests can call it. This lesson shows two concrete integration patterns: a Python backend service and a browser-based JavaScript chat widget.

## Prerequisites

- A published agent with its endpoint URL and an agent access key.
- Environment variables set:

```bash
export DO_AGENT_ID="your-agent-id"
export DO_AGENT_KEY="doagent_your_key_here"
```

## Python Integration

Use the `openai` library and override `base_url` to point to your agent:

```python
import os
from openai import OpenAI

AGENT_BASE_URL = f"https://{os.environ['DO_AGENT_ID']}.agents.do-ai.run/api/v1"

client = OpenAI(
    base_url=AGENT_BASE_URL,
    api_key=os.environ["DO_AGENT_KEY"],
)

def ask_agent(user_message: str, history: list[dict] = None) -> str:
    messages = history or []
    messages.append({"role": "user", "content": user_message})

    response = client.chat.completions.create(
        messages=messages,
        # model field is optional for agent endpoints; the agent's configured model is used
        model="n/a",
    )

    reply = response.choices[0].message.content
    messages.append({"role": "assistant", "content": reply})
    return reply, messages

# Single turn
reply, _ = ask_agent("What topics can you help me with?")
print(reply)

# Multi-turn conversation
reply, history = ask_agent("Tell me about billing.")
reply, history = ask_agent("How do I get an invoice?", history)
print(reply)
```

The `history` list preserves conversation context across turns. Pass it back on each subsequent call to give the agent memory of the exchange.

## JavaScript Integration

For a browser-based chat widget, use the `fetch` API directly:

```js
const AGENT_ID = "<your-agent-id>";
const AGENT_KEY = "<your-agent-access-key>"; // load from env in production
const BASE_URL = `https://${AGENT_ID}.agents.do-ai.run/api/v1/chat/completions`;

async function sendMessage(userText, history = []) {
  const messages = [...history, { role: "user", content: userText }];

  const res = await fetch(BASE_URL, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      Authorization: `Bearer ${AGENT_KEY}`,
    },
    body: JSON.stringify({ messages }),
  });

  if (!res.ok) {
    throw new Error(`Agent request failed: ${res.status}`);
  }

  const data = await res.json();
  const reply = data.choices[0].message.content;
  return { reply, history: [...messages, { role: "assistant", content: reply }] };
}

// Usage
let { reply, history } = await sendMessage("What can you help me with?");
console.log(reply);

({ reply, history } = await sendMessage("How do I upgrade my plan?", history));
console.log(reply);
```

**Important**: never expose your agent access key in client-side browser code in production. Route agent calls through a backend that holds the key and proxies requests from the browser.

## Production Considerations

| Concern | Recommendation |
|---|---|
| Key exposure | Proxy agent calls through your backend; never expose keys to browsers |
| Error handling | Check for `finish_reason: "length"` and retry or warn the user |
| Conversation history size | Trim old messages when history approaches the model's context limit |
| Latency | Display a loading indicator; agent responses may take 1–5 seconds |
| Cost visibility | Log `usage.total_tokens` per call to track spend in your own analytics |

With the agent embedded, you have a full pipeline: a foundation model, managed infrastructure, and a production endpoint callable from any application stack.

Full integration reference: [docs.digitalocean.com/products/gradient-ai-platform/](https://docs.digitalocean.com/products/gradient-ai-platform/).
