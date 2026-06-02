---
type: "page"
id: "agent-configuration-deep-dive"
title: "Agent Configuration Deep Dive"
description: "Understand every core parameter that shapes an agent's behavior, from base model selection to sampling settings, knowledge bases, and function routes."
weight: 1
---

## What Makes an Agent

A Gradient AI Platform agent is assembled from a small set of explicit configuration choices. Getting those choices right determines how reliably the agent behaves in production. The four primary building blocks are: a **base model**, **instructions**, **sampling parameters**, and optional **knowledge bases** and **function routes**.

## Instructions

Instructions are the system prompt. They tell the model who it is, what it is allowed to do, and how it should format responses. Keep them specific and testable.

Effective instructions follow this pattern:

- **Role** — "You are a customer-support agent for Acme Cloud."
- **Scope** — "Answer questions only about billing, account access, and service status."
- **Tone** — "Reply in plain English. Avoid jargon."
- **Format** — "Always end troubleshooting responses with a numbered action list."

Vague instructions like "be helpful" produce inconsistent behavior. Concrete constraints produce predictable agents.

## Base Model

The base model determines capability, latency, and cost. Gradient exposes both open-weight and frontier models. When you create or edit an agent in the Control Panel you select the model from a dropdown; the API accepts the model identifier as a string. Choosing the right model is covered in detail in the next lesson.

## Sampling Parameters

Three parameters control how the model samples tokens:

| Parameter | What it controls | Typical range |
|-----------|-----------------|---------------|
| `temperature` | Randomness / creativity | 0.0 – 1.0 |
| `max_tokens` | Maximum length of each response | 128 – 4096+ |
| `top_p` | Nucleus sampling — probability mass to sample from | 0.1 – 1.0 |

Lower temperature (0.1–0.3) produces factual, deterministic replies — the right choice for support bots or data extraction. Higher temperature (0.7–1.0) suits creative tasks. `max_tokens` caps cost and prevents runaway responses; always set it explicitly. `top_p` can be left at the default (1.0) unless you need tighter nucleus sampling.

```json
{
  "temperature": 0.2,
  "max_tokens": 512,
  "top_p": 1.0
}
```

## Knowledge Bases (Overview)

Attaching a knowledge base enables **Retrieval-Augmented Generation (RAG)**. When a user asks a question, the platform searches the knowledge base for relevant chunks and injects them into the context before the model generates a reply. This grounds answers in your private data without fine-tuning.

You can attach multiple knowledge bases to a single agent and detach them independently. Knowledge bases are covered in depth in the "Knowledge Bases & RAG" course.

## Function Routes (Overview)

A function route registers an external API or serverless function as a callable tool. The agent decides at runtime whether to invoke the function based on the conversation context and the function's description. You define input/output schemas so the model knows what arguments to pass and what to expect back.

A minimal function route definition looks like this:

```json
{
  "name": "get_account_status",
  "description": "Returns current subscription status for a given account ID.",
  "input_schema": {
    "type": "object",
    "properties": {
      "account_id": { "type": "string" }
    },
    "required": ["account_id"]
  }
}
```

Function routes are covered in the "Functions & Tool Use" course.

## Putting It Together

A well-configured agent has tight instructions, a model sized for the task, conservative sampling parameters, and only the knowledge bases and functions it actually needs. Start minimal and add capabilities once baseline behavior is verified in the playground.

Learn more in the [Gradient AI Platform documentation](https://docs.digitalocean.com/products/gradient-ai-platform/).
