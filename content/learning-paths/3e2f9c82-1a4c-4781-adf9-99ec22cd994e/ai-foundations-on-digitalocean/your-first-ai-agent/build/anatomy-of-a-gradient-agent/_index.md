---
type: "page"
id: "anatomy-of-a-gradient-agent"
title: "Anatomy of a Gradient Agent"
description: "Learn the core components of a Gradient AI Platform agent: model, instructions, knowledge bases, functions, guardrails, and its public endpoint."
weight: 1
---

## Overview

A **Gradient AI Platform agent** is a fully managed AI system that combines a foundation model with configuration, memory, tooling, and an HTTP endpoint — all without you managing any servers. Understanding the components before you build saves significant iteration time.

## Core Components

### Model

Every agent is backed by a foundation model from the Model Catalog. You choose the model when you create the agent. The model determines the agent's baseline capabilities, context window, and cost per inference.

Common choices:
- Llama 3.1 70B Instruct — strong general-purpose reasoning
- Llama 3.1 8B Instruct — lower latency and cost for simpler tasks
- Claude or GPT-4o — frontier quality for demanding use cases (early access)

The model can be changed after creation, but changing it resets any cached context.

### Instructions (System Prompt)

The instructions field is the agent's persistent system prompt. It defines:
- The agent's persona and tone
- The domain and scope of topics it should handle
- Formatting rules for responses
- Fallback behavior when asked out-of-scope questions

Instructions are baked into every request the agent receives. Write them precisely — they are the single most impactful configuration choice.

### Temperature

Like the raw Inference API, agents expose a temperature setting. Lower values (0.1–0.3) are appropriate for factual, consistent responses; higher values (0.7–1.0) suit creative or conversational agents.

### Knowledge Bases

Knowledge bases connect the agent to your own documents through **Retrieval-Augmented Generation (RAG)**. When a user asks a question, the agent retrieves relevant chunks from the knowledge base and includes them in the model context before generating a response.

Knowledge bases support:
- File uploads (PDF, Markdown, plain text)
- Web crawling (automatically index URLs)
- Citations — the agent can surface the source document alongside its answer

You can attach multiple knowledge bases to a single agent to cover different topic areas.

### Function Routes

Function routes let the agent call external APIs or run business logic. You define a function schema (name, description, parameters), and the agent decides at runtime whether to call it based on the user's request. The Gradient platform handles the tool-call loop — you provide the endpoint, the agent provides the arguments.

### Guardrails

Guardrails are content policies applied before the model generates a response. They can block or redact:
- Off-topic requests
- Personally identifiable information (PII)
- Harmful or unsafe content

Guardrails run at the platform layer, outside the model, so they apply regardless of model choice.

### Endpoint

Every published agent gets a unique HTTPS endpoint:

```
https://<agent-id>.agents.do-ai.run
```

The endpoint is OpenAI-compatible. Append `/v1/chat/completions` to call it from any OpenAI SDK. Requests are authenticated with an **agent access key** passed as the bearer token.

### Versioning and Insights

Agents support versioning — you can publish a new version without replacing the current live version, enabling staged rollouts. The **Agent Insights** dashboard shows request volume, latency, token usage, and knowledge base hit rates per version.

## How Components Interact

At request time, the sequence is:

1. Guardrails evaluate the incoming message.
2. If knowledge bases are attached, relevant documents are retrieved.
3. Instructions + retrieved context + conversation history are assembled into the model prompt.
4. The model generates a response.
5. If a function route is triggered, the function is called and its output is fed back into the model.
6. The final response is returned to the caller.

Understanding this flow is essential for debugging unexpected behavior — you will know which layer to inspect first.

Learn more at [docs.digitalocean.com/products/gradient-ai-platform/](https://docs.digitalocean.com/products/gradient-ai-platform/).
