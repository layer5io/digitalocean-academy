---
type: "page"
id: "import-clusters-with-meshsync"
title: "Import Clusters with MeshSync"
description: "Connect a DOKS GPU cluster to Meshery and watch MeshSync discover nodes, GPU node pools, and running AI workloads in real time."
weight: 1
---

## Overview

MeshSync is the Meshery component responsible for continuous, real-time discovery and state synchronization of Kubernetes cluster resources. Once you import a DOKS GPU cluster, MeshSync streams everything — Nodes, Deployments, Services, GPU device plugin labels, Ingresses, ConfigMaps, and more — into the Meshery Server, keeping the UI always current without manual refresh.

## How MeshSync Works

After you provide a kubeconfig, Meshery deploys the Meshery Operator into the target cluster. The Operator launches MeshSync as an in-cluster controller. MeshSync watches the Kubernetes API server for resource events (create, update, delete) and publishes them as a structured event stream to the Meshery Server over NATS. The Server indexes these events and surfaces them in the Lifecycle and Kanvas views.

The result is a live mirror: if a vLLM Pod is evicted and rescheduled on a different GPU node, the Meshery UI reflects that within seconds — no polling interval, no stale cache.

## Step 1 — Retrieve the DOKS Kubeconfig

```bash
doctl kubernetes cluster kubeconfig save <cluster-name>
```

This writes credentials to `~/.kube/config`. Verify the active context:

```bash
kubectl config current-context
```

## Step 2 — Import the Cluster in Meshery

Open the Meshery UI and navigate to **Settings → Connections**. Click **Add Kubernetes Cluster** and choose one of two methods:

- **Kubeconfig upload** — upload the file directly.
- **Auto-detect** — Meshery reads the active context from the environment.

After confirming, Meshery installs the Operator and MeshSync into the `meshery` namespace of the DOKS cluster. Watch the install complete:

```bash
kubectl get pods -n meshery --watch
```

You should see `meshery-operator-*` and `meshsync-*` Pods reach `Running` status.

## Step 3 — Explore What MeshSync Discovered

In the Meshery UI open **Lifecycle → Connections** and select the newly imported cluster. The overview panel shows:

- **Node inventory** — each node with its instance type, zone, and GPU labels. DOKS GPU nodes carry labels like `node.kubernetes.io/instance-type=gpu-h100x1` and `nvidia.com/gpu=true`.
- **Namespace list** — every namespace in the cluster.
- **Workload summary** — Deployments, StatefulSets, DaemonSets with current replica counts.

For a cluster running a vLLM inference server, you will see the `vllm` Deployment and its Service listed immediately. Clicking a resource opens its full spec as Meshery discovered it.

## What MeshSync Does Not Do

MeshSync is read-only from the cluster's perspective during discovery. It does not modify any resource it has not been explicitly instructed to manage through a Meshery Design. Importing a cluster is safe to do on a production DOKS cluster — MeshSync observes; it does not change.

## GPU-Specific Discovery Details

DOKS GPU clusters run the NVIDIA device plugin DaemonSet, which annotates nodes with allocatable GPU counts. MeshSync discovers these annotations and surfaces them in Meshery. When you later build a Design requesting `nvidia.com/gpu: 1`, Meshery can cross-reference which nodes in the connected cluster are eligible to schedule that workload.

For clusters also running the NVIDIA DCGM exporter, MeshSync discovers the DaemonSet and its associated Service, which is later used to wire Prometheus scraping through Meshery's observability features.

## Next Steps

With MeshSync running, your DOKS GPU cluster is fully visible inside Meshery. The next lesson explores how to navigate that visibility using Kanvas to visualize GPU node pools and running inference workloads graphically.

- [Meshery docs](https://docs.meshery.io/)
- [DOKS docs](https://docs.digitalocean.com/products/kubernetes/)
- [doctl reference](https://docs.digitalocean.com/reference/doctl/)
