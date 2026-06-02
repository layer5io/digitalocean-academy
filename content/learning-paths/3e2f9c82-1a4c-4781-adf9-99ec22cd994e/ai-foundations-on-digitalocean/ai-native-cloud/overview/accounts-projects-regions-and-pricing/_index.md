---
type: "page"
id: "accounts-projects-regions-and-pricing"
title: "Accounts, Projects, Regions & Pricing"
description: "Set up your DigitalOcean account, organize resources with Projects, understand regional availability, and learn the pricing model for AI services."
weight: 3
---

## Account Setup

Creating a DigitalOcean account is free. Navigate to [cloud.digitalocean.com](https://cloud.digitalocean.com), sign up with an email address or OAuth provider, and verify your email. New accounts receive a free trial credit that you can apply to any service, including GPU Droplets and Serverless Inference — check the current credit amount on the sign-up page, as it changes periodically.

After signing up:

1. Add a payment method (credit card or PayPal) to unlock resource creation beyond the free tier.
2. Enable two-factor authentication under **Account Settings → Security**.
3. Generate a **Personal Access Token** (PAT) under **API → Tokens** — you will use this for the doctl CLI, SDKs, and API calls throughout this course.

## Organizing Resources with Projects

Every resource you create — Droplets, Spaces buckets, Managed Databases, Gradient agents — belongs to a **Project**. Projects are organizational containers; they do not create network boundaries, but they make billing reports and access management much cleaner.

Best practice for AI workloads:

- Create one project per application environment (e.g., `my-app-dev`, `my-app-prod`).
- Assign all related resources (GPU Droplet, Spaces bucket, Managed PostgreSQL, Gradient agent) to the same project so cost attribution is automatic.
- Use the **Resources** tab inside a project to see spend broken down by resource type.

## Datacenter Regions

DigitalOcean operates datacenters across North America, Europe, and Asia-Pacific. Not all services are available in every region. GPU Droplets and Gradient AI Platform are available in a subset of regions; check the Control Panel dropdown at resource-creation time for the current list.

Key points:

- Choose the region closest to your end users to minimize latency for agent endpoints.
- Serverless Inference requests are routed globally — you specify a model, not a region.
- Spaces buckets are regional; place them in the same region as your GPU Droplets or Gradient agents to avoid cross-region transfer costs.

## Pricing Model

| Service | Billing Unit | Notes |
|---|---|---|
| Serverless Inference | Per token (input + output) | No idle cost; pay only for what you use |
| GPU Droplets | Per GPU-hour | Billed by the second; NVIDIA H100 and H200 priced higher than L40S and Ada |
| 1-Click Models | Per GPU-hour (underlying Droplet) | Same rate as the GPU Droplet tier selected |
| Gradient AI Platform agents | Per request / per token | Includes knowledge base queries and agent calls |
| Managed PostgreSQL | Per hour (node size) | `pgvector` extension available on all plans |
| Spaces | Per GB stored + per GB transferred | First 250 GB storage and 1 TB transfer included on paid plans |

**Key principle**: all AI services are pay-as-you-go. There are no minimum commitments or upfront fees for Serverless Inference or Gradient agents. GPU Droplets are hourly and can be destroyed when not in use — important for controlling costs during development.

## Free Trial Credit

New accounts receive a free trial credit applied automatically to the first invoice. The credit covers most service types including GPU Droplets and Inference. Monitor your remaining credit under **Billing → Usage** in the Control Panel.

For full pricing details, see the [Gradient AI Platform docs](https://docs.digitalocean.com/products/gradient-ai-platform/).
