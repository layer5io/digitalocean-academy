---
type: "page"
id: "design-as-code-and-gitops"
title: "Design-as-Code & GitOps"
description: "Manage AI infrastructure Designs in Git as the source of truth and synchronize changes to DOKS GPU clusters through a GitOps pipeline backed by Meshery."
weight: 2
---

## Overview

GitOps is the practice of using a Git repository as the single source of truth for infrastructure state, with an automated process that reconciles live cluster state to match what is in Git. Meshery Designs are YAML artifacts, which means they integrate naturally into a GitOps workflow: the Design file in Git describes what should be deployed, and Meshery applies it.

## Repository Structure

Organize your AI infrastructure repository to separate Designs by environment and team:

```
ai-infra/
  designs/
    inference/
      vllm-inference-doks.yaml       # parameterized inference Design
      ollama-dev.yaml                 # lightweight dev Design
    vector-db/
      qdrant-cluster.yaml
    monitoring/
      dcgm-prometheus-stack.yaml
  environments/
    dev-overrides.yaml               # parameter values for dev cluster
    staging-overrides.yaml
    prod-overrides.yaml
```

Each Design file is the canonical description of a workload. The environment override files supply parameter values — replica counts, GPU node pool labels, model names — for each deployment target.

## Syncing Designs from Git

Connect Meshery to the repository via **Settings → Integrations → GitHub**. Once connected, Meshery watches the repository. When a Design file changes in Git (on a commit to the `main` branch), Meshery detects the change and offers to apply it to the mapped cluster.

For fully automated sync, add a `mesheryctl` step to your CI/CD pipeline:

```bash
# In your GitHub Actions workflow, on push to main

- name: Deploy inference Design to staging
  run: |
    mesheryctl system login --token ${{ secrets.MESHERY_TOKEN }}
    mesheryctl design import -f designs/inference/vllm-inference-doks.yaml
    mesheryctl design deploy \
      --name vllm-inference-doks \
      --context doks-staging-cluster \
      --params-file environments/staging-overrides.yaml
```

## The GitOps Loop

The full GitOps loop for a DOKS AI workload looks like this:

1. An engineer updates `vllm-inference-doks.yaml` on a feature branch — bumping the model version.
2. A pull request opens. CI runs `mesheryctl design validate` to check the Design against Policies (no missing GPU limits, valid Relationships).
3. A reviewer approves. The PR merges to `main`.
4. The CD pipeline runs `mesheryctl design deploy` targeting the staging DOKS cluster.
5. A Performance Profile runs automatically post-deploy and results are posted to the PR as a comment.
6. If latency passes the threshold, a separate pipeline step promotes to production.

## Design Validation in CI

Add the Design validation step to your CI pipeline to catch errors before merge:

```bash
mesheryctl design validate -f designs/inference/vllm-inference-doks.yaml
```

Validation checks:

- All required fields are present.
- Relationships are valid (Service selector matches Deployment labels).
- Policies pass (GPU limits set, node selectors present).

A failing validation exits with a non-zero status code, blocking the PR merge.

## Drift Detection and Reconciliation

If a team member applies a manual `kubectl` change to the staging cluster (bypassing Git), MeshSync detects the drift. The Meshery UI shows the live state diverging from the Design's last-deployed version.

In a strict GitOps setup, the CD pipeline runs on a schedule (e.g., hourly) and automatically reconciles drift by redeploying the Design from Git state. This ensures the cluster always matches the repository, regardless of out-of-band changes.

## Benefits for AI Platform Teams

- **Auditability** — every change to the inference stack has a Git commit, PR, and author.
- **Reproducibility** — any Design can be redeployed from Git state to any DOKS cluster.
- **Collaboration** — engineers review infrastructure changes the same way they review code.
- **Rollback** — reverting to a previous GPU inference configuration is a `git revert` and a pipeline run.

- [Meshery Designs documentation](https://docs.meshery.io/concepts/logical/designs)
- [DOKS docs](https://docs.digitalocean.com/products/kubernetes/)
