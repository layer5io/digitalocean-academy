---
type: "page"
id: "domains-1-and-2"
title: "Domains 1 & 2: Foundations and Inference"
description: "Objectives for AI-Native Cloud fundamentals and for foundation models, serverless inference, and the model catalog."
weight: 1
---

This study guide breaks each exam domain into concrete objectives and maps them to the lessons that
prepare you. Domains 1 and 2 together account for **26%** of the written exam.

## Domain 1 — AI-Native Cloud fundamentals & service selection (12%)

You should be able to:

- Explain what the **AI-Native Cloud** is and name its five layers (infrastructure, core cloud,
  inference, data, managed agents).
- Distinguish the **Gradient AI Platform**, **GPU Droplets**, the **Inference Engine**, **1-Click
  Models**, and **DOKS**, and pick the right one for a workload.
- Organize resources with **projects**, choose **regions**, and reason about the **pricing** model
  (per-token serverless vs per-GPU-hour Droplets).
- Use the core tooling: `doctl`, the API, the `pydo`/`godo` SDKs, and the DigitalOcean MCP server.

**Prepares you:** *AI Foundations on DigitalOcean → The DigitalOcean AI-Native Cloud.*

Sample objective check: *Given a bursty, low-volume chat feature, which service minimizes
operational overhead?* → Serverless inference, because there is no infrastructure to manage and you
pay per token.

## Domain 2 — Foundation models, serverless inference & the model catalog (14%)

You should be able to:

- Describe **serverless inference** and when to prefer it over self-hosting.
- Browse the **model catalog** (70+ open models plus frontier models) and create a **model access
  key**.
- Make chat completions against `https://inference.do-ai.run/v1` with `curl`, the Python `openai`
  SDK, and TypeScript.
- Use **streaming**, and tune `temperature`, `top_p`, and `max_tokens`; reason about token cost.
- Understand **OpenAI/Anthropic compatibility** and how it simplifies migration.

**Prepares you:** *AI Foundations on DigitalOcean → Serverless Inference & the Model Catalog* and
*Prompt Engineering Essentials.*

Sample objective check: *You must cap spend per request.* → Set `max_tokens`, prefer a smaller
catalog model, and measure tokens used per response.

## Study tips

- Practice the same chat completion three ways (`curl`, Python, TypeScript) until it is muscle memory.
- Memorize the service-selection table from
  [the Gradient platform docs](https://docs.digitalocean.com/products/gradient-ai-platform/).
- Be ready to justify a service choice from cost, latency, and operational-overhead angles.

Next: **Domains 3 & 4: Agents and RAG.**
