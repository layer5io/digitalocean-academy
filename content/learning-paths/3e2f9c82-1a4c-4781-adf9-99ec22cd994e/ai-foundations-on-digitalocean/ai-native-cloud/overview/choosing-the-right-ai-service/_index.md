---
type: "page"
id: "choosing-the-right-ai-service"
title: "Choosing the Right AI Service"
description: "A decision guide that maps your use case to the right DigitalOcean AI service, from managed agents to bare GPU compute."
weight: 2
---

## Overview

DigitalOcean's AI-Native Cloud offers multiple overlapping services. Picking the wrong one early means reworking architecture later. This lesson gives you a practical framework for matching your use case to the right service on day one.

## The Core Trade-off: Control vs. Convenience

Every AI service on DigitalOcean sits somewhere on a spectrum:

- **More control** → more flexibility, more ops burden (GPU Droplets, DOKS)
- **More managed** → faster time to value, less flexibility (Gradient AI Platform, Serverless Inference)

## Service Comparison

| Use Case | Recommended Service | Why |
|---|---|---|
| Build a production AI agent with RAG, routing, and guardrails | **Gradient AI Platform** | Fully managed; handles knowledge bases, function routes, versioning, and observability |
| Call a foundation model via API without managing infrastructure | **Serverless Inference** | Per-token billing, no GPUs to provision, OpenAI/Anthropic-compatible |
| Deploy a popular Hugging Face model (Llama, Mistral, Gemma) in one step | **1-Click Models (HUGS on DO)** | One-click deploy on GPU Droplet; OpenAI-compatible endpoint |
| Fine-tune a model or run a custom inference server | **GPU Droplets** | Full root access to NVIDIA H100/H200, AMD MI300X, L40S, or RTX Ada GPUs |
| Orchestrate multi-container GPU workloads with autoscaling | **DOKS with GPU node pools** | Managed Kubernetes with RTX 4000/6000 Ada, L40S, and H100 nodes |
| Batch inference jobs over large datasets | **Inference Engine — Batch mode** | Async job queue, cost-efficient for offline workloads |
| Route requests across models by cost or latency policy | **Inference Router** | Policy-driven control plane; natural-language or structured policies |

## Decision Flow

Start with the simplest service that meets your requirements and move toward more control only when you hit a constraint.

**Step 1 — Do you need a custom model runtime?**
Yes → GPU Droplets or DOKS. No → continue.

**Step 2 — Is one of the 70+ catalog models sufficient?**
Yes → Serverless Inference or Gradient AI Platform. No → 1-Click Models or GPU Droplets for custom weights.

**Step 3 — Do you need agent features (RAG, routing, guardrails, versioning)?**
Yes → Gradient AI Platform. No → Serverless Inference is the simplest choice.

**Step 4 — Is the workload online (user-facing) or offline (batch)?**
Online → Serverless or Dedicated Inference. Offline → Batch Inference via the Inference Engine.

## Common Mistakes

- **Over-provisioning GPU Droplets** for workloads that Serverless Inference handles at a fraction of the cost.
- **Under-estimating Gradient AI Platform** — it covers RAG, multi-agent routing, and guardrails out of the box, replacing several custom components.
- **Assuming DOKS is only for non-AI workloads** — GPU node pools make it a strong choice for teams already running Kubernetes.

## Quick Summary

For most new projects the fastest path is: **Serverless Inference** to validate the model choice, then **Gradient AI Platform** once you need agent features, with **GPU Droplets** reserved for fine-tuning or bespoke runtimes.

Browse the full service overview at [digitalocean.com/products/gradient](https://www.digitalocean.com/products/gradient).
