---
type: "page"
id: "from-observation-to-redesign"
title: "From Observation to Redesign"
description: "Close the observability loop by feeding GPU utilization findings and latency regressions back into a Meshery Design update, redeploy, and measure the improvement."
weight: 4
---

## Overview

Observability is not an end in itself. The value of GPU utilization graphs, latency dashboards, and saturation alerts is what you do with the findings. This final lesson in the observability course walks through a complete feedback loop: an alert fires, you investigate in Meshery, you update the Design, you redeploy, and you run a Performance Profile to confirm the improvement.

## The Closed Loop

```
Alert fires → Investigate in Meshery → Update Design → Deploy → Performance Profile → Confirm
```

Each stage uses a different Meshery capability. Together they form a continuous improvement loop for AI infrastructure on DOKS.

## Example: GPU Memory Pressure Triggers a Redesign

Suppose the `GPUMemoryPressure` alert fires on the production DOKS H100 cluster. Memory used is at 94% and climbing. The on-call engineer opens Meshery.

**Step 1 — Investigate.** In Meshery's Lifecycle view, filter to the `inference` namespace. MeshSync shows the `vllm-inference` Deployment with 3 replicas, each on a separate H100 node. The Metrics panel shows all three GPUs at > 90% memory. The alert started approximately 20 minutes after a new batch of users began running longer prompts.

**Step 2 — Identify the cause.** The vLLM queue depth metric (`vllm:num_requests_waiting`) is 35 — requests are batching up. vLLM is accumulating a large KV cache per request. The Design currently sets `--max-model-len 8192`. Users are submitting prompts of up to 6000 tokens with 2000-token outputs, approaching the limit and forcing large KV cache allocations.

**Step 3 — Update the Design.** Open the `vllm-inference-doks` Design in Kanvas. Locate the container args and change `--max-model-len` from `8192` to `4096`. This reduces the maximum KV cache per request, allowing vLLM to batch more requests simultaneously within the same GPU memory budget. Also increase `replicaCount` from 3 to 4 to spread the queue.

```yaml
args:
  - "--model"
  - "mistralai/Mistral-7B-Instruct-v0.2"
  - "--max-model-len"
  - "4096"          # reduced from 8192
  - "--port"
  - "8000"
```

Save the Design. The version history records the change with a timestamp.

**Step 4 — Validate and Deploy.** Run policy validation to confirm the updated Design still satisfies all rules:

```bash
mesheryctl design validate --name vllm-inference-doks
```

Deploy to production:

```bash
mesheryctl design deploy \
  --name vllm-inference-doks \
  --context doks-prod-cluster \
  --params-file environments/prod-overrides.yaml
```

Meshery performs a rolling update, replacing Pods one at a time to avoid downtime.

**Step 5 — Confirm with a Performance Profile.** Run the baseline Performance Profile at production load:

```bash
mesheryctl perf apply \
  --profile vllm-mistral7b-baseline \
  --rps 20 \
  --duration 120s \
  --label "post-max-model-len-reduction"
```

Compare this run against the pre-change run. Expected results: GPU memory utilization drops to 75–80%, the queue depth clears, and p95 latency returns to within the 3-second SLO. If the latency improvement is confirmed, the `GPUMemoryPressure` alert clears.

## Committing the Fix to Git

The updated Design YAML now reflects operational knowledge gained from a production incident. Commit it to the infrastructure repository:

```bash
mesheryctl design export --name vllm-inference-doks -o designs/inference/vllm-inference-doks.yaml
git add designs/inference/vllm-inference-doks.yaml
git commit -m "fix: reduce max-model-len to 4096 to prevent GPU memory pressure under long prompts"
git push origin main
```

Future deployments from Git carry this fix. The Performance Profile run and the Design version history in Meshery provide the paper trail linking the alert, the investigation, the fix, and the confirmed improvement.

## The Continuous Improvement Pattern

This loop — observe, investigate, redesign, deploy, measure — is the operational rhythm for mature AI platforms on DOKS. Meshery provides all four tools in a single interface:

- MeshSync for investigation (what is running, what changed)
- Kanvas and Designs for redesign (update the canonical description)
- Lifecycle operations for deploy (controlled rollout)
- Performance Profiles for measurement (quantified confirmation)

- [Meshery docs](https://docs.meshery.io/)
- [Meshery Performance Management docs](https://docs.meshery.io/guides/performance-management)
- [DOKS GPU Droplets docs](https://docs.digitalocean.com/products/gpu-droplets/)
