---
type: "page"
id: "parameterize-gpu-requests"
title: "Parameterize GPU Requests"
description: "Use Meshery Design parameters to make GPU limits, node selectors, tolerations, and replica counts configurable across DOKS GPU cluster environments."
weight: 2
---

## Overview

A Design authored with hard-coded values is useful for a single deployment, but AI platforms need the same Design to work across multiple environments: development on an RTX 4000 Ada node pool, staging on L40S, and production on H100s with higher replica counts. Meshery Designs support parameterization so a single canonical Design file serves all environments without duplication.

## What to Parameterize in a GPU Inference Design

For a vLLM or Ollama serving stack on DOKS, the fields that vary across environments are:

| Field | Dev | Prod |
|---|---|---|
| `spec.replicas` | 1 | 3 |
| `resources.limits.nvidia.com/gpu` | 1 | 1 |
| `nodeSelector` value | `gpu-rtx4000ada` pool label | `gpu-h100` pool label |
| Model name (arg) | Small model (7B) | Large model (70B) |
| Container image tag | `vllm-openai:latest` | `vllm-openai:v0.4.2` (pinned) |

## Defining Parameters in the Design

In Kanvas, open the Design and click **Parameters** in the Design toolbar. Add parameters with names, types, and default values:

```yaml
parameters:
  - name: replicaCount
    type: integer
    default: 1
  - name: gpuLimit
    type: string
    default: "1"
  - name: gpuNodeLabel
    type: string
    default: "gpu-rtx4000ada"
  - name: modelName
    type: string
    default: "mistralai/Mistral-7B-Instruct-v0.2"
```

## Referencing Parameters in the Deployment Spec

Within the Deployment component, reference parameters using the Meshery template syntax:

```yaml
spec:
  replicas: "{{ .parameters.replicaCount }}"
  template:
    spec:
      containers:
        - name: vllm
          args:
            - "--model"
            - "{{ .parameters.modelName }}"
          resources:
            limits:
              nvidia.com/gpu: "{{ .parameters.gpuLimit }}"
            requests:
              nvidia.com/gpu: "{{ .parameters.gpuLimit }}"
      nodeSelector:
        node-pool: "{{ .parameters.gpuNodeLabel }}"
```

## Using Tolerations for GPU Node Pools

DOKS GPU node pools are often tainted to prevent CPU workloads from scheduling onto expensive GPU nodes. A common taint pattern is:

```yaml
key: "nvidia.com/gpu"
operator: "Exists"
effect: "NoSchedule"
```

Add a toleration parameter to the Design so it can be enabled for pools that carry the taint:

```yaml
tolerations:
  - key: "nvidia.com/gpu"
    operator: "Exists"
    effect: "NoSchedule"
```

In Kanvas, add a boolean parameter `gpuToleration` and conditionally include the toleration block. This way development clusters without the taint work without modification.

## Deploying with Parameter Overrides

When deploying from the Meshery UI, a parameter form appears before the deploy action. Fill in the environment-specific values and deploy. From the CLI, pass overrides as flags:

```bash
mesheryctl design deploy \
  --name vllm-inference-doks \
  --context doks-prod-cluster \
  --set replicaCount=3 \
  --set gpuNodeLabel=gpu-h100 \
  --set modelName="meta-llama/Llama-3-70b-instruct"
```

## Storing Parameter Sets as Environments

Meshery allows you to save named Environment configurations that pre-fill parameter sets. Create a `doks-prod` Environment with the production values, and a `doks-dev` Environment with development values. When deploying, select the Environment and Meshery populates all parameters automatically.

This eliminates the risk of accidentally deploying a 70B model to a development cluster or forgetting to set the correct node pool label.

## Next Steps

With a parameterized Design, the next step is making it reusable beyond your own team by saving it to the Meshery Catalog — covered in the next lesson.

- [Meshery Designs documentation](https://docs.meshery.io/concepts/logical/designs)
- [DOKS GPU Droplets docs](https://docs.digitalocean.com/products/gpu-droplets/)
