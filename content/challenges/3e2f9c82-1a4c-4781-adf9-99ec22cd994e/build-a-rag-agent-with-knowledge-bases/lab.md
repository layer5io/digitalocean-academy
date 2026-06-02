---
type: "lab"
description: "Create a Gradient AI Platform agent, ground it on your own data with a knowledge base, attach the knowledge base, and verify retrieval and citations."
title: "Build a RAG Agent with Knowledge Bases"
---

## Introduction

In this challenge you will build a **retrieval-augmented (RAG)** agent on the
[DigitalOcean Gradient AI Platform](https://docs.digitalocean.com/products/gradient-ai-platform/).
You will create an agent, build a **knowledge base** from your own data, attach it, and confirm that
answers are grounded with **citations** that trace back to your sources.

RAG lets an agent answer from private, up-to-date, domain-specific data instead of relying only on the
base model's training. The knowledge base handles chunking, embeddings, indexing, and retrieval for
you.

## Prerequisites

- A DigitalOcean account with access to the Gradient AI Platform.
- A small corpus to ground on — for example, a handful of product docs (PDF/Markdown) and/or a public
  documentation website URL.
- Optional: a [Spaces](https://docs.digitalocean.com/products/spaces/) bucket if you want to load data
  from object storage.

## Step 1 — Create an agent

In the Control Panel, open the Gradient AI Platform and create an agent. Give it:

- a clear **name** (e.g., `docs-assistant`),
- **instructions** that define scope and tone, such as: *"You are a product documentation assistant.
  Answer only from the attached knowledge base. If the answer is not present, say so and suggest where
  to look. Always cite your sources."*,
- a suitable **base model**, and
- a low **temperature** (e.g., 0.2) for factual consistency.

Test it in the **playground** before adding knowledge — note how it answers product questions *without*
grounding.

## Step 2 — Create a knowledge base

Create a knowledge base and choose an **embedding model**. Then add **data sources**. Use at least two
source types to practice the connectors:

- **Upload files** (PDF, Markdown, text), and/or
- a **Spaces folder**, and/or
- **web crawling** of a public docs site, and/or
- a connector (AWS S3, Dropbox, Google Drive).

Start **indexing**. Indexing chunks your content, generates embeddings, and stores vectors for
retrieval. Re-index whenever the source data changes.

## Step 3 — Attach the knowledge base to the agent

Attach the knowledge base to your agent. Now the agent will **retrieve** relevant chunks at query time
and ground its response on them. You can attach and detach knowledge bases as your needs change.

## Step 4 — Verify retrieval and citations

Back in the playground, ask a question whose answer lives in your corpus. Confirm that:

- the answer reflects **your** content (not generic base-model knowledge), and
- the response includes **citations** pointing to the source chunk/document.

Then ask something deliberately **not** in your corpus and confirm the agent says it does not know,
per your instructions — this validates grounding rather than hallucination.

## Step 5 — Call the agent endpoint

Publish the agent and call its OpenAI-compatible endpoint. Only `base_url`/`api_key` differ from a
standard OpenAI client:

```python
from openai import OpenAI

client = OpenAI(
    base_url="https://<agent-id>.agents.do-ai.run/api/v1",
    api_key="<agent-access-key>",
)
resp = client.chat.completions.create(
    model="n/a",  # the agent's configured model is used server-side
    messages=[{"role": "user", "content": "How do I rotate an API key?"}],
)
print(resp.choices[0].message.content)
```

## Step 6 — Improve retrieval (optional)

If answers miss relevant content, revisit chunk size/overlap, choose a different embedding model, add
more sources, or re-index. Small retrieval changes often beat prompt tweaks.

## What you learned

You grounded an agent on private data with a knowledge base, verified citations, and called the agent
through the OpenAI-compatible API — the foundation of trustworthy, auditable AI assistants. Take the
exam to validate your understanding.
