---
type: "page"
id: "github-backed-designs-and-versioning"
title: "GitHub-Backed Designs & Versioning"
description: "Store Meshery Designs in GitHub as code, track versions, get PR previews of infrastructure changes, and integrate GPU inference stack management into GitOps workflows."
weight: 4
---

## Overview

Meshery Designs are text artifacts — YAML files that describe infrastructure. That means they belong in version control the same way application code does. By backing your GPU inference stack Designs in GitHub, you get change history, pull request reviews, branch-based environments, and integration with CI pipelines — a full GitOps workflow for DOKS AI infrastructure.

## Exporting a Design to YAML

From the Meshery UI, export any Design as a YAML file:

```bash
mesheryctl design export --name vllm-inference-doks -o ./designs/vllm-inference-doks.yaml
```

The exported file is a self-contained representation of all components, their configurations, and their relationships. Commit it to a dedicated infrastructure repository:

```bash
git add designs/vllm-inference-doks.yaml
git commit -m "feat: add vllm inference stack design for DOKS GPU cluster"
git push origin main
```

## Connecting Meshery to a GitHub Repository

Meshery's GitHub integration allows it to read Designs directly from a repository. In the Meshery UI, navigate to **Settings → Integrations → GitHub** and connect your repository. Once connected, Meshery can:

- **Import Designs** from a repository path on demand.
- **Sync changes** — when a Design YAML is updated in Git, Meshery picks up the new version.
- **PR Previews** — when a pull request modifies a Design file, Meshery can render a visual diff in Kanvas showing exactly which components changed.

## Import a Design from GitHub

```bash
mesheryctl design import \
  --url https://github.com/your-org/ai-infra/blob/main/designs/vllm-inference-doks.yaml
```

This fetches the file from GitHub and registers it as a Design in Meshery, preserving the GitHub URL as the source of truth.

## Versioning and the Design History

Every time a Design is saved in Meshery, a version snapshot is created. In the Design detail view, the **History** tab shows a chronological list of versions with timestamps and author information. You can compare any two versions side by side or roll back to a previous version with a single click.

For GitHub-backed Designs, each version corresponds to a Git commit. The Meshery version history and the Git log provide complementary views: Meshery shows what changed in the design structure; Git shows who changed it, why, and in what branch context.

## Pull Request Preview Workflow

A typical change management flow for a GPU inference stack:

1. An engineer creates a branch in the infrastructure repo and updates the `vllm-inference-doks.yaml` to bump the replica count from 1 to 3 and change the model name.
2. They open a pull request.
3. A CI check triggers Meshery (via `mesheryctl` in the pipeline) to validate the Design against Policies and render a Kanvas visual diff.
4. Reviewers see exactly which components changed before approving.
5. On merge, a deployment pipeline runs `mesheryctl design deploy` to apply the update to the staging DOKS cluster.

```bash
# In a CI pipeline (on PR merge to main)
mesheryctl design import -f designs/vllm-inference-doks.yaml
mesheryctl design deploy \
  --name vllm-inference-doks \
  --context doks-staging-cluster
```

## Branch-Based Environments

Use Git branches to maintain per-environment Design variants. A `main` branch holds the production-ready Design; a `staging` branch holds a version with reduced replica counts; a `dev` branch holds development overrides. Each branch deploys to the corresponding DOKS cluster in the CI/CD pipeline.

This pattern means that promoting from dev to staging to production is a pull request merge, reviewable by the team, with a full audit trail in Git history.

- [Meshery Designs documentation](https://docs.meshery.io/concepts/logical/designs)
- [DOKS Kubernetes docs](https://docs.digitalocean.com/products/kubernetes/)
