---
type: "page"
id: "what-is-serverless-inference"
title: "What Is Serverless Inference?"
description: "Learn what serverless inference is, when to use it over self-hosted models, and how DigitalOcean's OpenAI-compatible endpoint works."
weight: 1
---

## Overview

**Serverless Inference** lets you send requests to foundation models without provisioning or managing any GPU infrastructure. You call an API endpoint, pay per token, and DigitalOcean handles everything else: hardware allocation, driver management, model loading, autoscaling, and availability.

This is the fastest way to start using AI models on DigitalOcean. There are no Droplets to create, no Kubernetes clusters to configure, and no idle compute costs when your application is not active.

## How It Works

When you send a request to the Serverless Inference endpoint, the Inference Engine:

1. Authenticates your request using your **model access key**.
2. Routes the request to the appropriate model based on the `model` field in your payload.
3. Runs the inference on shared GPU infrastructure.
4. Returns the response in the same format as the OpenAI or Anthropic API.

The base URL for all OpenAI-compatible calls is:

```
https://inference.do-ai.run/v1
```

The bearer token is a **model access key**, which you create in the DigitalOcean Control Panel under **AI → Inference → API Keys**. Model access keys are scoped to inference and are separate from your Personal Access Token.

## OpenAI and Anthropic Compatibility

The endpoint is designed to be a drop-in replacement for the OpenAI and Anthropic APIs. If you already have code that calls OpenAI's `chat/completions` endpoint, switching to DigitalOcean Serverless Inference requires two changes:

1. Change `base_url` to `https://inference.do-ai.run/v1`
2. Change `api_key` to your model access key

The request and response schemas — including streaming, tool calls, and structured outputs — are identical. This compatibility extends to the Anthropic Messages API format for Claude models.

## Serverless Inference vs. Self-Hosting

| Consideration | Serverless Inference | Self-Hosted (GPU Droplet) |
|---|---|---|
| Setup time | Seconds (API key only) | Minutes to hours (Droplet + runtime) |
| Cost at low traffic | Very low (pay per token) | Higher (GPU-hours billed even when idle) |
| Cost at sustained high traffic | Higher per token | Lower per hour at scale |
| Custom model weights | Not supported | Supported |
| Runtime customization | Not available | Full root access |
| Maintenance burden | None | You manage drivers, updates |
| Cold start | None (shared infra) | Droplet must be running |

**Choose Serverless Inference when** you are prototyping, building an application with variable traffic, or want to eliminate infrastructure ops entirely.

**Choose GPU Droplets when** you need to run custom weights, require specific runtime configurations, or your sustained request volume makes per-GPU-hour pricing more economical.

## Model Access Keys

A model access key is the credential you include as the bearer token in every Serverless Inference request. Best practices:

- Create one key per application or environment (dev, staging, prod).
- Never embed a key in client-side code or public repositories.
- Rotate keys periodically and immediately if a key is compromised.
- Set keys as environment variables: `export DO_INFERENCE_KEY=<your-key>`

See the full Serverless Inference documentation at [docs.digitalocean.com/products/gradient-ai-platform/](https://docs.digitalocean.com/products/gradient-ai-platform/).
