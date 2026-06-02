---
type: "page"
id: "what-is-the-ai-native-cloud"
title: "What Is the AI-Native Cloud?"
description: "Understand DigitalOcean's AI-Native Cloud vision, its five architectural layers, and how the platform's key services fit together."
weight: 1
---

## Overview

DigitalOcean's **AI-Native Cloud** is an end-to-end platform purpose-built for the inference and agentic era. Unlike general-purpose clouds that bolted AI capabilities onto existing infrastructure, the AI-Native Cloud organizes every service around a single question: *what does a team actually need to build, deploy, and scale AI-powered products?*

## The Five Layers

The platform is organized into five layers, each solving a distinct part of the AI delivery stack:

| Layer | What It Covers |
|---|---|
| **Infrastructure** | GPU Droplets, CPU Droplets, Spaces (object storage), VPC, firewalls |
| **Core Cloud** | App Platform (PaaS), Functions (serverless), Managed PostgreSQL with `pgvector`, DOKS (managed Kubernetes) |
| **Inference** | Inference Engine, Serverless Inference, Batch Inference, Dedicated Inference, Inference Router |
| **Data** | Knowledge bases, vector search, web crawling, RAG pipelines |
| **Managed Agents** | Gradient AI Platform — fully managed agents with routing, guardrails, versioning, and insights |

Each layer is independently useful, but they compose naturally. A typical production application might store embeddings in Managed PostgreSQL, run a knowledge base in the Data layer, invoke foundation models through the Inference layer, and expose the whole thing as an agent through the Gradient AI Platform.

## Key Services at a Glance

**Gradient AI Platform** (formerly the GenAI Platform) is the highest-level managed offering. It lets you build AI agents with knowledge bases (RAG), multi-agent routing, function routes, guardrails, agent versioning, and built-in observability — without managing any infrastructure. The rename from GenAI Platform to Gradient AI Platform reflects its expanded scope beyond simple generation tasks.

**GPU Droplets** sit at the infrastructure layer. They give you raw NVIDIA H100, H200, AMD MI300X, L40S, or RTX Ada GPU compute and are the right choice when you need full control over the runtime environment — fine-tuning, custom inference servers, or specialized frameworks.

**Inference Engine** is the production-grade middle layer: a single OpenAI- and Anthropic-compatible endpoint that unifies Serverless, Batch, and Dedicated inference. You point your existing OpenAI SDK code at `https://inference.do-ai.run/v1`, swap in a DigitalOcean model access key, and you are running against the full Model Catalog of 70+ open-source and frontier models.

## Why It Matters for Builders

The AI-Native Cloud targets the common frustrations of building on general-purpose clouds:

- **Complexity**: Managed services handle orchestration so small teams can ship agents without a dedicated MLOps function.
- **Cost**: Pay-as-you-go serverless inference and per-GPU-hour Droplets avoid large reserved-instance commitments.
- **Compatibility**: OpenAI- and Anthropic-compatible APIs mean existing code works with minimal changes.
- **Ecosystem**: From a single control plane you can manage compute, storage, databases, and agents.

Understanding this layered architecture is the foundation for every subsequent lesson. As you progress through the course, you will work hands-on with services from each layer.

Learn more in the [Gradient AI Platform docs](https://docs.digitalocean.com/products/gradient-ai-platform/).
