---
type: "page"
id: "function-routes"
title: "Function Routes"
description: "Give an agent the ability to call external APIs and code by configuring function routes, and understand how the platform routes a conversation turn to a function."
weight: 1
---

## What Are Function Routes?

A function route connects an agent to an external piece of code or API. When the agent decides it needs real-time data or needs to perform an action — check inventory, look up an account, send a notification — it calls the registered function, receives the result, and incorporates it into its response.

Function routes are how Gradient agents move from pure conversation to real-world action. Without them, an agent is limited to what its model weights and knowledge bases contain. With them, an agent can interact with any system that exposes an HTTP endpoint.

## How Routing Works

When a user message arrives, the model evaluates whether any of the registered function routes should be invoked. This decision is based on:

1. **The function's description** — a plain-language string that tells the model what the function does.
2. **The conversation context** — the user's message and prior turns.
3. **The input schema** — whether the conversation provides the required arguments.

If the model decides to call a function, it emits a structured tool-call object with the function name and arguments. The platform intercepts this, invokes the function endpoint with the provided arguments, and returns the result to the model for a follow-up generation step.

```
User: "What's the current status of order #8821?"
         ↓
Model emits tool call: get_order_status(order_id="8821")
         ↓
Platform calls your HTTP endpoint
         ↓
Endpoint returns: {"status": "shipped", "eta": "2026-06-04"}
         ↓
Model generates: "Order #8821 has shipped and is expected to arrive June 4th."
```

## Defining a Function Route

A function route requires three things: a name, a description, and an input schema.

```json
{
  "name": "get_order_status",
  "description": "Retrieves the current fulfillment status and estimated delivery date for a given order ID.",
  "endpoint_url": "https://api.example.com/orders/status",
  "http_method": "POST",
  "input_schema": {
    "type": "object",
    "properties": {
      "order_id": {
        "type": "string",
        "description": "The unique order identifier, e.g. '8821'."
      }
    },
    "required": ["order_id"]
  }
}
```

The `description` is critical. The model reads it to decide when to call the function. A vague description like "gets data" produces unpredictable behavior. A precise description produces reliable routing.

## Authentication

The platform calls your function endpoint over HTTPS. You can configure authentication headers (e.g., an API key) in the function route configuration so your endpoint can verify that calls originate from the Gradient platform.

## Multiple Function Routes

An agent can have multiple function routes. The model selects the most appropriate one based on context. If a user asks about an order, the model calls `get_order_status`. If the same user then asks to cancel the order, the model calls `cancel_order`. Each function handles a discrete action.

Keep functions focused on a single action. Combining unrelated capabilities into one function degrades routing accuracy.

## Function Calls vs. Knowledge Base Retrieval

Function routes and knowledge bases serve different purposes:

| Need | Use |
|------|-----|
| Real-time data (current status, live prices) | Function route |
| Static or semi-static documents (policies, guides) | Knowledge base |
| Performing write actions (place order, send email) | Function route |
| Answering factual questions from private docs | Knowledge base |

Many production agents use both: a knowledge base for documentation and one or more function routes for live data and actions.

Learn more in the [Gradient AI Platform documentation](https://docs.digitalocean.com/products/gradient-ai-platform/).
