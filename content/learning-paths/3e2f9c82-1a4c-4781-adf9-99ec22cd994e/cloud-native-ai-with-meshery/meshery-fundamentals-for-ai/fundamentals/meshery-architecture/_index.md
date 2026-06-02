---
type: "page"
id: "meshery-architecture"
title: "Meshery Architecture"
description: "Explore the components of Meshery — Server, Operator, MeshSync, Adapters, Kanvas, and mesheryctl — and understand how they interact with a DOKS GPU cluster."
weight: 2
---

## Overview

Meshery is composed of several cooperating components. Understanding each one helps you reason about what runs where, what talks to what, and how a change you make in the Kanvas designer eventually reaches a running vLLM Pod on a DOKS GPU node.

## Component Reference

| Component | Where It Runs | Role |
|---|---|---|
| **Meshery Server** | Outside the cluster (local or cloud VM) | Control plane, REST/GraphQL API, web UI |
| **Meshery Operator** | Inside each connected cluster | Manages in-cluster resources on behalf of the server |
| **MeshSync** | Inside each connected cluster (managed by Operator) | Real-time discovery and state sync of all cluster resources |
| **Adapters / Integrations** | Sidecar processes or built-in plugins | Connect Meshery to hundreds of cloud native tools |
| **Kanvas** | Browser (served by Meshery Server) | Visual designer and operator for infrastructure and applications |
| **mesheryctl** | Developer workstation | CLI for all Meshery operations |

## Meshery Server

The Server is the brains of the platform. It exposes a REST and GraphQL API consumed by the Kanvas UI and by `mesheryctl`. It stores Designs, Performance Profiles, and user configuration. When you click "Deploy" in Kanvas, the Server translates the Design into Kubernetes API calls routed through the Meshery Operator in the target cluster.

For DOKS, the Server can run as a local Docker container (`mesheryctl system start`) or as a Deployment inside the cluster itself.

## Meshery Operator and MeshSync

When you connect a DOKS cluster, Meshery installs the Operator into it. The Operator in turn runs MeshSync, a lightweight controller that watches every Kubernetes resource — Nodes, Deployments, Services, ConfigMaps, GPU node pool labels, and more — and streams live state back to the Server.

For AI workloads, MeshSync's continuous discovery means Meshery always knows which Pods are requesting `nvidia.com/gpu`, which nodes belong to the GPU node pool, and whether the inference Deployment is healthy — without any manual refresh.

## Adapters and Integrations

Meshery ships with a large library of integrations (called Models) covering service meshes, observability stacks, databases, gateways, and AI serving frameworks. Each integration is described by Components and Relationships. When you add a vLLM Deployment and a Kubernetes Service to a Kanvas canvas, Meshery validates their relationship and flags misconfigurations before deployment.

## Kanvas

Kanvas is Meshery's visual designer and operator. It has two modes:

- **Designer mode** — drag, drop, and wire components to compose an infrastructure Design, such as a vLLM Deployment connected to a Service connected to an Ingress, all sitting on a GPU node pool.
- **Operator mode** — view the live state of deployed resources overlaid on the same canvas.

Designs produced in Kanvas are exportable as YAML and can be stored in GitHub for GitOps workflows.

## mesheryctl

`mesheryctl` is the command-line interface for Meshery. Key commands used throughout this learning path:

```bash
mesheryctl system start          # Start Meshery (Docker-based)
mesheryctl system login          # Authenticate with Meshery Cloud
mesheryctl design import         # Import a Design from a file or URL
mesheryctl perf profile          # List or create Performance Profiles
mesheryctl perf apply            # Execute a performance test
```

## How the Pieces Connect for a DOKS AI Workload

1. `mesheryctl system start` launches the Server locally.
2. You save the DOKS kubeconfig (`doctl kubernetes cluster kubeconfig save <cluster>`) and upload it to Meshery.
3. The Server deploys the Operator into the DOKS cluster; MeshSync begins streaming GPU node and workload state.
4. In Kanvas, you compose a Design for your inference stack and deploy it.
5. You run a Performance Profile against the inference endpoint and view results in the Server UI.

The next lesson walks through steps 1–3 hands-on.

- [Meshery architecture docs](https://docs.meshery.io/)
- [DigitalOcean Kubernetes docs](https://docs.digitalocean.com/products/kubernetes/)
