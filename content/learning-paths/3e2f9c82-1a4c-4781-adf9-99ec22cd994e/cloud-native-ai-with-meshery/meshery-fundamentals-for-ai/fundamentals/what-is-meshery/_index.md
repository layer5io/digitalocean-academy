---
type: "page"
id: "what-is-meshery"
title: "What Is Meshery?"
description: "Understand Meshery as the open-source CNCF cloud native manager and learn why AI platform teams adopt it alongside DigitalOcean Kubernetes."
weight: 1
---

## Overview

[Meshery](https://meshery.io/) is the open-source, CNCF cloud native manager — an extensible developer platform for designing and operating Kubernetes-based infrastructure and applications across multi-cloud, multi-cluster environments. Rather than replacing individual tools, Meshery acts as a manager of managers: a single pane of glass through which platform engineers configure, deploy, observe, and performance-test their entire cloud native stack.

For teams running AI workloads on DigitalOcean Kubernetes (DOKS), Meshery removes the operational fragmentation that comes from juggling separate CLIs, dashboards, and GitOps pipelines for every service in the inference stack.

## Why AI Platform Teams Adopt Meshery

Modern AI workloads on DOKS are multi-layer. A production setup typically combines:

- A DOKS GPU node pool (NVIDIA L40S or H100) running a vLLM or Ollama inference server
- A vector database (Qdrant, Weaviate, or Managed PostgreSQL with pgvector) for RAG
- An ingress controller, autoscaler, and monitoring stack

Keeping all these resources consistent across development, staging, and production clusters is where complexity accumulates. Meshery addresses this in three ways:

1. **Visual design and deployment.** The Kanvas designer lets engineers draw the inference stack as a drag-and-drop canvas, then export it as a versioned Design — infrastructure as code that lives in Git.
2. **Real-time discovery.** MeshSync continuously syncs the live state of every Kubernetes resource in every connected cluster, so the dashboard always reflects what is actually running.
3. **Performance testing.** Built-in load generators (fortio, wrk2, nighthawk) let teams run Performance Profiles against the inference endpoint and compare latency and throughput across deploys.

## Relationship to Kubernetes and DOKS

Meshery is not a Kubernetes distribution or a replacement for `kubectl`. It runs alongside your clusters. The Meshery Operator deploys inside each cluster; the Meshery Server (control plane) can run locally via Docker or inside a cluster itself. Once a DOKS cluster is connected, Meshery discovers its nodes, GPU node pools, namespaces, and workloads automatically through MeshSync.

DigitalOcean Kubernetes is a fully supported target. You obtain a kubeconfig from DOKS with `doctl` and hand it to Meshery — that is the entire connection step. From that point Meshery can deploy Designs to the cluster, run performance tests against services inside it, and stream metrics from Prometheus.

## Meshery in the CNCF Ecosystem

Meshery is a CNCF project maintained by [Layer5](https://layer5.io/). Its integration library spans hundreds of CNCF and cloud native projects, meaning the same Meshery instance that manages your DOKS GPU inference cluster can also manage service meshes, gateways, observability stacks, and storage operators — all through a unified API and UI.

The following lessons walk through the architecture in detail, then move straight into connecting a live DOKS cluster and deploying a GPU inference workload.

- [Meshery documentation](https://docs.meshery.io/)
- [DigitalOcean Kubernetes documentation](https://docs.digitalocean.com/products/kubernetes/)
