---
type: "page"
id: "install-meshery-and-connect-doks"
title: "Install Meshery & Connect DOKS"
description: "Install Meshery with mesheryctl, save a DOKS kubeconfig with doctl, and connect the cluster so MeshSync can begin discovering GPU workloads."
weight: 3
---

## Overview

This lesson walks through the minimum steps required to get Meshery running locally and connected to a live DigitalOcean Kubernetes (DOKS) cluster. By the end, MeshSync will be streaming the state of your GPU node pool and any running AI workloads back to the Meshery Server.

## Prerequisites

- [doctl](https://docs.digitalocean.com/reference/doctl/) installed and authenticated (`doctl auth init`)
- Docker running locally
- A DOKS cluster with at least one GPU node pool

## Step 1 — Install mesheryctl

`mesheryctl` is distributed as a single binary. Install it with the official installer:

```bash
curl -L https://meshery.io/install | PLATFORM=kubernetes bash -
```

Or via Homebrew on macOS/Linux:

```bash
brew install meshery/tap/mesheryctl
```

Verify the installation:

```bash
mesheryctl version
```

## Step 2 — Start Meshery

The quickest way to start Meshery is with Docker Compose, which `mesheryctl system start` manages automatically:

```bash
mesheryctl system start
```

This pulls the Meshery Server and supporting containers, starts them, and opens the Meshery UI at `http://localhost:9081`. On first run you are prompted to authenticate with Meshery Cloud (Layer5 Cloud) — this enables collaboration features including Workspaces and RBAC.

```bash
mesheryctl system login
```

## Step 3 — Save the DOKS Kubeconfig

Meshery connects to a DOKS cluster via a standard kubeconfig. Use `doctl` to retrieve it:

```bash
doctl kubernetes cluster kubeconfig save <your-cluster-name>
```

This merges the cluster credentials into your default kubeconfig at `~/.kube/config` and sets it as the active context. If you have multiple clusters, specify the context name explicitly:

```bash
kubectl config get-contexts
kubectl config use-context <doks-context-name>
```

## Step 4 — Connect the Cluster in Meshery

With the kubeconfig active, open the Meshery UI and navigate to **Settings → Environments → Connections**. Click **Add Cluster** and either upload the kubeconfig file directly or let Meshery detect the active context automatically.

Alternatively, configure the connection from the CLI:

```bash
mesheryctl system config
```

Meshery will deploy the Meshery Operator and MeshSync into the DOKS cluster. After a few seconds the cluster appears in the UI with a green connection indicator, and the Cluster Overview panel begins populating with node counts, GPU node pool labels, namespaces, and running Deployments.

## Step 5 — Verify Discovery

In the Meshery UI, open the **MeshSync** view (or **Lifecycle → Workloads**). Confirm that:

- Your GPU nodes appear with the expected NVIDIA GPU labels (e.g., `nvidia.com/gpu.product=NVIDIA-L40S`).
- Namespaces match what `kubectl get namespaces` returns.
- Any existing AI workloads show their Pods, Services, and replica counts.

If the cluster does not appear within 60 seconds, check that the Meshery Operator Pod is running:

```bash
kubectl get pods -n meshery
```

## Next Steps

With the cluster connected, MeshSync maintains a live mirror of its state. The next lesson covers Meshery's data model — Models, Components, and Relationships — which is the foundation for authoring Designs that describe GPU inference stacks.

- [Meshery docs](https://docs.meshery.io/)
- [doctl reference](https://docs.digitalocean.com/reference/doctl/)
- [DOKS docs](https://docs.digitalocean.com/products/kubernetes/)
