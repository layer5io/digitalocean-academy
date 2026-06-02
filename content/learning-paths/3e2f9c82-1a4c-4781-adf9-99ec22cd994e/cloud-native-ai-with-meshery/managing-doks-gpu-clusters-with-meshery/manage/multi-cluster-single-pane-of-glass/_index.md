---
type: "page"
id: "multi-cluster-single-pane-of-glass"
title: "Multi-Cluster Single Pane of Glass"
description: "Manage DigitalOcean and hybrid GPU clusters together through a single Meshery instance, providing a unified view and consistent operations across environments."
weight: 4
---

## Overview

Production AI platforms rarely run on a single Kubernetes cluster. A typical setup has a development DOKS cluster with a small GPU node pool, a staging cluster mirroring production, and a production cluster running H100 nodes for high-throughput inference. Some organizations also run on-premises GPU hardware or workloads on other clouds alongside DOKS. Meshery's multi-cluster management capability provides a single control point for all of them.

## Connecting Multiple Clusters

Each cluster you connect to Meshery gets its own MeshSync instance. From the Meshery UI, navigate to **Settings → Connections** and add each cluster's kubeconfig. Use `doctl` to retrieve kubeconfigs for each DOKS cluster:

```bash
doctl kubernetes cluster kubeconfig save my-dev-cluster
doctl kubernetes cluster kubeconfig save my-prod-cluster
```

After importing both, the Meshery cluster picker in Kanvas and in the Design deploy flow shows all connected clusters. You can switch between them or target multiple clusters simultaneously.

## The Unified Dashboard

The Meshery **Overview** dashboard aggregates resource counts across all connected clusters. For AI platform teams, this provides at a glance:

| Metric | Source |
|---|---|
| Total GPU nodes | MeshSync node inventory across all clusters |
| Running inference Deployments | Filtered Deployment count per namespace |
| Unhealthy Pods | Failed or CrashLoopBackOff Pods in any cluster |
| Pending Pods | Pods awaiting GPU scheduling |

Rather than opening three separate DOKS dashboards or running `kubectl` against each context in turn, the Meshery overview answers "what is the state of my AI platform right now?" in one screen.

## Deploying Across Clusters

A single Design can be deployed to multiple clusters. This is how you promote an inference stack from development to production without maintaining separate YAML copies. Open the Design, click **Deploy**, and select multiple target clusters from the Environment picker.

For environment-specific differences (GPU node pool names, replica counts, domain names), Meshery Designs support parameterization — covered in the Parameterize GPU Requests lesson — so a single Design file accommodates per-cluster overrides.

## Hybrid and On-Premises Clusters

Meshery is not limited to DOKS. If your organization also runs GPU nodes on-premises or on another cloud, you can import those clusters with their kubeconfigs the same way. From Meshery's perspective, a cluster is a cluster. The Operator and MeshSync deploy identically, and the same Designs, Policies, and Performance Profiles apply.

This is particularly useful during DOKS migration projects: import both the on-premises cluster and the target DOKS cluster, compare their workload inventories in the unified dashboard, and use Meshery to progressively promote Designs from on-prem to cloud.

## Workspaces and Multi-Team Access

In Meshery Cloud, **Workspaces** scope cluster access by team. A platform team might have access to all clusters, while an AI engineering team only sees the inference namespace clusters. This prevents accidental cross-environment operations while still providing each team with a full visual view of their scope.

RBAC configuration for Workspaces is covered in the Workspaces, Teams & RBAC lesson.

## Practical Consideration: Context Naming

When managing multiple DOKS clusters, use descriptive kubeconfig context names to avoid mistakes:

```bash
doctl kubernetes cluster kubeconfig save my-dev-cluster  --set-current-context
kubectl config rename-context do-nyc3-my-dev-cluster doks-dev
kubectl config rename-context do-nyc3-my-prod-cluster doks-prod
```

Clear context names prevent accidentally deploying a test workload to production when using `mesheryctl design deploy`.

- [Meshery docs](https://docs.meshery.io/)
- [DOKS docs](https://docs.digitalocean.com/products/kubernetes/)
