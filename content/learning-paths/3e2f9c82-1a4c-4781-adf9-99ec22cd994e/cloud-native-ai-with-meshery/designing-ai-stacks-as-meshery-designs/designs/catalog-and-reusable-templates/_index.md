---
type: "page"
id: "catalog-and-reusable-templates"
title: "Catalog & Reusable Templates"
description: "Publish a GPU inference Design to the Meshery Catalog so teams can discover, clone, and deploy curated AI stack templates with embedded best practices."
weight: 3
---

## Overview

The **Meshery Catalog** is a curated library of reusable Designs. Instead of every team starting from a blank canvas when they need a new vLLM deployment or vector database setup, they pick a catalog template that already encodes best practices — correct GPU resource requests, node selectors, health probes, and Relationship wiring — and customize it from there.

## What the Catalog Contains

The catalog aggregates Designs published by the Meshery community, Layer5, and your own organization. For AI workloads on DOKS, catalog entries might include:

- A vLLM serving stack with GPU limits, readiness probes, and a LoadBalancer Service
- An Ollama single-node inference setup for development clusters
- A Qdrant vector database StatefulSet with a PersistentVolumeClaim backed by DigitalOcean block storage
- A full RAG pipeline: vLLM + Qdrant + an ingress routing layer

Each entry is a complete, deployable Design with documentation, parameter descriptions, and version history.

## Publishing a Design to the Catalog

After authoring and validating a Design (such as the `vllm-inference-doks` Design from the previous lessons), publish it from the Meshery UI:

1. Open the Design and click **Publish to Catalog**.
2. Fill in the catalog metadata: name, description, category (e.g., `AI/ML`, `Inference`), and tags.
3. Review the parameter documentation — Meshery auto-generates descriptions from the parameter names, but you can add human-readable explanations.
4. Click **Submit**. The Design appears in the Catalog under your organization's namespace.

Published Designs are versioned. When you update the Design and republish, the catalog retains the version history, allowing consumers to pin to a specific version or always pull the latest.

## Discovering and Cloning a Catalog Template

From any Meshery instance, open **Catalog** in the sidebar. Use the search and filter controls to find a template:

```
Search: vllm
Category: Inference
Tag: gpu, doks
```

Click **Clone** to create a personal copy of the template in your Design workspace. The cloned Design is fully editable — you own it and can modify it without affecting the original catalog entry.

## Embedding Best Practices

Catalog templates are most valuable when they encode operational knowledge, not just YAML structure. For GPU inference stacks, embed the following best practices as defaults in the template:

- `resources.limits.nvidia.com/gpu` always equals `resources.requests.nvidia.com/gpu` (no fractional GPU sharing with the standard device plugin).
- `nodeSelector` targets the GPU node pool label, preventing accidental CPU scheduling.
- A `readinessProbe` on the `/health` or `/v1/models` endpoint so the Service only routes traffic to warm inference servers.
- A `terminationGracePeriodSeconds` of at least 60 seconds to allow in-flight inference requests to complete during rolling updates.

When a team clones the template, they inherit these settings and get a working deployment out of the box.

## Organization-Scoped Catalogs

In Meshery Cloud, Workspaces support private catalog entries visible only to your organization. This lets platform teams publish validated, security-reviewed templates for internal use without exposing them publicly. AI teams consume these internal templates the same way they consume public ones.

## Example: Catalog-Driven Onboarding

A new team joining the AI platform wants to deploy a Llama 3 inference server on DOKS. Without the catalog, they research GPU scheduling, write YAML from scratch, and iterate through several broken deployments. With the catalog:

1. Search for `llama inference doks`.
2. Clone the template.
3. Set the `modelName` and `gpuNodeLabel` parameters.
4. Deploy to the dev cluster.

The same workflow that took a senior engineer a day the first time takes a new team member thirty minutes.

## Try It: Import the Academy's Designs

The academy ships three ready-made, importable designs you can treat as your starter catalog —
import them, customize, and publish your own versions:

| Design | Installs |
|--------|----------|
| [`vllm-inference-stack.yaml`](https://github.com/layer5io/digitalocean-academy/blob/master/designs/vllm-inference-stack.yaml) | A vLLM OpenAI-compatible server on a DOKS GPU node pool |
| [`qdrant-vector-db.yaml`](https://github.com/layer5io/digitalocean-academy/blob/master/designs/qdrant-vector-db.yaml) | A Qdrant vector database backed by DigitalOcean block storage |
| [`gpu-observability-stack.yaml`](https://github.com/layer5io/digitalocean-academy/blob/master/designs/gpu-observability-stack.yaml) | The NVIDIA DCGM exporter for GPU metrics |

```bash
mesheryctl design import \
  -f https://raw.githubusercontent.com/layer5io/digitalocean-academy/master/designs/vllm-inference-stack.yaml \
  -s "Kubernetes Manifest"
```

After importing, open the design in Kanvas, then **Publish to Catalog** to share it with your team.

- [Meshery Designs documentation](https://docs.meshery.io/concepts/logical/designs)
- [DOKS Kubernetes docs](https://docs.digitalocean.com/products/kubernetes/)
