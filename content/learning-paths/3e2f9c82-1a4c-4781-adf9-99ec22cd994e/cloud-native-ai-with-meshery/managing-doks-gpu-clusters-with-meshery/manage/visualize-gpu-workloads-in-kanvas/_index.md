---
type: "page"
id: "visualize-gpu-workloads-in-kanvas"
title: "Visualize GPU Workloads in Kanvas"
description: "Use Kanvas to explore DOKS GPU node pools, namespaces, and running inference Deployments through a live visual representation of cluster state."
weight: 2
---

## Overview

Once MeshSync is streaming state from your DOKS GPU cluster, Kanvas gives you a live visual representation of everything running in it. This lesson covers using Kanvas in Operator mode to explore GPU node pools, navigate namespaces, and inspect running AI workloads — all without writing a single `kubectl` command.

## Kanvas Operator Mode vs. Designer Mode

Kanvas has two modes:

- **Designer mode** — a blank canvas where you compose new infrastructure by dragging and connecting components. Used when authoring Designs.
- **Operator mode** — a live view populated from MeshSync state, showing what is actually deployed in the cluster at this moment.

For visualizing existing GPU workloads, you work in Operator mode.

## Navigating the Cluster View

Open Kanvas from the Meshery sidebar and select your DOKS cluster from the cluster picker. Kanvas renders a graph of the cluster's topology. From here you can:

- **Filter by namespace** — scope the view to only the `inference` or `ai-workloads` namespace to reduce noise from system namespaces.
- **Filter by resource type** — show only Deployments, or only Services, or only DaemonSets (useful for confirming the NVIDIA device plugin DaemonSet is running on every GPU node).
- **Search by label** — enter `nvidia.com/gpu=true` to highlight all GPU-enabled nodes and the workloads scheduled on them.

## Exploring GPU Node Pools

DOKS GPU node pools surface in Kanvas as Node resources with GPU-specific labels. Select a node to see its full label set, including:

- `node.kubernetes.io/instance-type` — the Droplet size (e.g., `gpu-h100x1`)
- `nvidia.com/gpu.product` — the GPU model (e.g., `NVIDIA-H100-80GB-HBM3`)
- `nvidia.com/gpu` — the allocatable GPU count

This gives you immediate visibility into which nodes are GPU-capable, how many GPUs are available, and which Pods have consumed them, without switching to the DigitalOcean Cloud Console.

## Inspecting an Inference Deployment

Click on a running vLLM or Ollama Deployment in the canvas. The detail panel on the right shows:

- The full Deployment spec as discovered by MeshSync
- Current replica count and readiness
- The `resources.limits` stanza, confirming GPU allocation (`nvidia.com/gpu: 1`)
- The connected Service and its ClusterIP / NodePort / LoadBalancer address

Clicking on the Service shows which Endpoints back it, letting you verify that healthy Pods are actually receiving traffic.

## Spotting Configuration Drift

One practical use of Kanvas Operator mode is drift detection. If someone manually patched a Deployment with `kubectl edit` to change the GPU count, MeshSync picks up that change and Kanvas reflects it. The visual diff between the live state and the last deployed Design is a quick way to catch unauthorized or accidental changes before they cause production incidents.

## Sharing the View

Kanvas views can be shared as links with teammates who have access to the same Meshery Workspace. A GPU cluster topology view can be embedded in a team runbook or incident channel so everyone on the on-call rotation sees the same live picture.

## Next Steps

Visualization is only half the picture. The next lesson covers using Meshery to perform lifecycle operations — deploying new AI workloads, scaling inference Deployments, and detecting drift — all through Designs rather than raw `kubectl` commands.

- [Meshery docs](https://docs.meshery.io/)
- [DOKS GPU docs](https://docs.digitalocean.com/products/gpu-droplets/)
