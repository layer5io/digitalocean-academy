---
type: "page"
id: "promoting-across-clusters"
title: "Promoting Across Clusters"
description: "Promote a validated GPU inference stack Design from development through staging to production DOKS clusters using Meshery's multi-cluster deployment and GitOps workflows."
weight: 3
---

## Overview

Promotion is the controlled process of moving an AI workload from one environment to the next — from a dev DOKS cluster with RTX 4000 Ada nodes, through a staging cluster on L40S, to production on H100s — after each environment validates the workload's correctness, performance, and safety. Meshery's parameterized Designs and multi-cluster support make this workflow explicit and auditable.

## The Promotion Model

Each environment maps to:

- A DOKS cluster connected to Meshery
- A Meshery Workspace or environment scope
- A parameter override file supplying environment-specific values
- A set of quality gates that must pass before promotion

```
Dev cluster (RTX 4000 Ada)  →  Staging cluster (L40S)  →  Prod cluster (H100)
    unit test + smoke test         perf profile + policy     final approval + deploy
```

The Design YAML is the same artifact at every stage. Only the parameter values change.

## Step 1 — Deploy to Development

```bash
mesheryctl design deploy \
  --name vllm-inference-doks \
  --context doks-dev-cluster \
  --params-file environments/dev-overrides.yaml
```

`dev-overrides.yaml` sets `replicaCount: 1`, `gpuNodeLabel: gpu-rtx4000ada`, and a small 7B model. Run a smoke test to confirm the endpoint responds:

```bash
curl http://dev-inference.example.com/v1/models
```

## Step 2 — Gate on Policy Validation

Before promoting to staging, run Meshery's policy validation to ensure the Design meets all required rules:

```bash
mesheryctl design validate \
  --name vllm-inference-doks \
  --params-file environments/staging-overrides.yaml
```

If the staging parameter file increases the replica count to 2 and changes the GPU node label, validation checks that the Design is still structurally valid with those values — correct Relationships, GPU limits present, node selector pointing to a valid pool.

## Step 3 — Deploy to Staging and Run Performance Profile

```bash
mesheryctl design deploy \
  --name vllm-inference-doks \
  --context doks-staging-cluster \
  --params-file environments/staging-overrides.yaml

mesheryctl perf apply \
  --profile vllm-mistral7b-baseline \
  --rps 20 \
  --duration 120s \
  --label "staging-post-deploy-$(date +%Y%m%d)"
```

Compare the staging results against the baseline established in development. If p95 latency is within the acceptable range (defined by your team's SLO) and the error rate is zero, the workload is ready for production.

## Step 4 — Promote to Production

Production promotion requires explicit action. In the Meshery UI, open the Design, select the `doks-prod-cluster` environment with the production parameter override, and click **Deploy**. In a pipeline:

```bash
mesheryctl design deploy \
  --name vllm-inference-doks \
  --context doks-prod-cluster \
  --params-file environments/prod-overrides.yaml
```

`prod-overrides.yaml` sets `replicaCount: 3`, `gpuNodeLabel: gpu-h100`, and a pinned image tag.

## Handling Rollbacks

If production shows unexpected behavior after promotion, roll back by redeploying the previous Design version:

```bash
# In Git: revert the overrides file and push
git revert HEAD
git push origin main

# In the CD pipeline on merge:
mesheryctl design deploy \
  --name vllm-inference-doks \
  --context doks-prod-cluster \
  --params-file environments/prod-overrides.yaml
```

Because Meshery stores version history, you can also roll back directly in the UI without a Git revert: open the Design history, select the previous version, and deploy it to the production cluster.

## Enforcing Promotion Gates with RBAC

Use Meshery Workspace RBAC to enforce the promotion gates organizationally. AI engineers have Editor access to dev and staging Workspaces, giving them self-service deployment. The production Workspace is restricted to Admin role (platform engineers only). A promotion to production therefore always involves a platform engineer — either by running the pipeline step or by approving a deployment in the UI.

This separation of duties satisfies most change management policies for production AI infrastructure.

- [Meshery docs](https://docs.meshery.io/)
- [DOKS Kubernetes docs](https://docs.digitalocean.com/products/kubernetes/)
