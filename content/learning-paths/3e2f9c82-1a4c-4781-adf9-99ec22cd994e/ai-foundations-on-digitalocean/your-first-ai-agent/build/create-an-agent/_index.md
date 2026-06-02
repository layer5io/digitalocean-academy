---
type: "page"
id: "create-an-agent"
title: "Create an Agent"
description: "Build a Gradient AI Platform agent through the Control Panel no-code flow and through the API, setting instructions and a base model both ways."
weight: 2
---

## Overview

The Gradient AI Platform supports two creation paths: a **no-code Control Panel** flow suitable for quick prototyping, and a **full-code API/SDK** path for teams that need repeatable, version-controlled deployments. Both produce identical agents.

## Path 1: No-Code Control Panel

1. In the DigitalOcean Control Panel, navigate to **AI → Gradient Agents**.
2. Click **Create Agent**.
3. Choose a **template** (e.g., Customer Support, Research Assistant, Coding Helper) or select **Blank Agent** for a clean start.
4. Under **Model**, select a foundation model from the catalog. `meta-llama/Meta-Llama-3.1-70B-Instruct` is a strong default.
5. In the **Instructions** field, write the agent's system prompt. Example:

   ```
   You are a helpful support assistant for a cloud hosting company.
   Answer questions about billing, Droplets, and DNS only.
   If the user asks about something outside these topics, politely decline.
   Keep responses under 150 words.
   ```

6. Set **Temperature** (0.3 is a good starting point for support bots).
7. Click **Save Draft**. The agent is now in draft state and accessible in the playground but not publicly deployed.

## Path 2: API / SDK (Full-Code)

Use the DigitalOcean API to create agents programmatically. This is the right approach for CI/CD pipelines and infrastructure-as-code workflows.

Using `curl`:

```bash
curl -s -X POST "https://api.digitalocean.com/v2/gen-ai/agents" \
  -H "Authorization: Bearer $DIGITALOCEAN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "support-bot-v1",
    "model": {
      "uuid": "meta-llama/Meta-Llama-3.1-70B-Instruct"
    },
    "instruction": "You are a helpful support assistant for a cloud hosting company. Answer questions about billing, Droplets, and DNS only.",
    "description": "Customer support agent for billing and infrastructure topics",
    "temperature": 0.3
  }'
```

Using the Python `pydo` SDK:

```python
import os
import pydo

client = pydo.Client(token=os.environ["DIGITALOCEAN_TOKEN"])

agent = client.gen_ai.create_agent(body={
    "name": "support-bot-v1",
    "model": {
        "uuid": "meta-llama/Meta-Llama-3.1-70B-Instruct"
    },
    "instruction": (
        "You are a helpful support assistant for a cloud hosting company. "
        "Answer questions about billing, Droplets, and DNS only."
    ),
    "description": "Customer support agent for billing and infrastructure topics",
    "temperature": 0.3,
})

print("Agent ID:", agent["agent"]["uuid"])
print("Status:", agent["agent"]["status"])
```

Save the returned `uuid` — you will need it to attach knowledge bases, create versions, and build the endpoint URL.

## Writing Effective Instructions

Instructions are evaluated before every user message. Make them explicit:

| Good | Avoid |
|---|---|
| "Respond only about billing, Droplets, and DNS" | "Help with cloud questions" |
| "Always respond in English" | "Be professional" |
| "If unsure, say 'I don't know'" | "Be accurate" |
| "Keep responses under 150 words" | "Be concise" |

Short, specific instructions outperform long, vague ones. You will iterate on instructions in the next lesson using the playground.

## What's Next

With the agent created, the next step is testing it in the playground and publishing a live endpoint. See [docs.digitalocean.com/products/gradient-ai-platform/](https://docs.digitalocean.com/products/gradient-ai-platform/) for the full agent API reference.
