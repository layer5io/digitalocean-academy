---
type: "lab"
description: "Import a DigitalOcean Kubernetes GPU cluster into Meshery, capture an inference serving stack as a Design, deploy it, and run a Performance Profile against the endpoint."
title: "Manage a DOKS GPU Cluster with Meshery"
---

## Introduction

In this challenge you will operate AI infrastructure the cloud native way. You will use
[Meshery](https://meshery.io/) — the open-source cloud native manager — to import a
[DigitalOcean Kubernetes (DOKS)](https://docs.digitalocean.com/products/kubernetes/) GPU cluster,
capture an LLM serving stack as a reusable **Design**, deploy it, and **performance-test** the
inference endpoint with a Meshery **Performance Profile**.

This mirrors how platform teams run model serving at scale: declarative designs, real-time cluster
visibility, and repeatable performance measurement — all from a single pane of glass.

## Prerequisites

- A DOKS cluster with a **GPU node pool** (e.g., L40S or RTX 6000 Ada).
- [`doctl`](https://docs.digitalocean.com/reference/doctl/) and `kubectl` installed and authenticated.
- [Meshery](https://docs.meshery.io/) installed (`mesheryctl system start`).

## Step 1 — Create a GPU node pool

If your cluster does not already have GPU nodes, add a GPU node pool:

```bash
doctl kubernetes cluster node-pool create <cluster-name> \
  --name gpu-pool \
  --size gpu-l40sx1-48gb \
  --count 1
```

Save the kubeconfig so local tools (and Meshery) can reach the cluster:

```bash
doctl kubernetes cluster kubeconfig save <cluster-name>
```

## Step 2 — Connect the cluster to Meshery

Start Meshery and connect your DOKS cluster by registering its kubeconfig context. Meshery deploys
the **Meshery Operator** and **MeshSync** into the cluster, which discover nodes and workloads in
real time:

```bash
mesheryctl system start
mesheryctl system check          # confirms cluster connectivity
```

In the Meshery UI, open **Kanvas** and confirm you can see the GPU node pool and namespaces. MeshSync
keeps this view in sync as the cluster changes.

## Step 3 — Author an inference Design

Create a Meshery **Design** that captures a vLLM serving stack. The Deployment must request a GPU so
the scheduler places it on the GPU node pool:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: vllm-llama
spec:
  replicas: 1
  selector:
    matchLabels: { app: vllm-llama }
  template:
    metadata:
      labels: { app: vllm-llama }
    spec:
      containers:
        - name: vllm
          image: vllm/vllm-openai:latest
          args: ["--model", "meta-llama/Llama-3.1-8B-Instruct", "--port", "8000"]
          ports:
            - containerPort: 8000
          resources:
            limits:
              nvidia.com/gpu: 1
---
apiVersion: v1
kind: Service
metadata:
  name: vllm-llama
spec:
  selector: { app: vllm-llama }
  ports:
    - port: 80
      targetPort: 8000
```

Save the Design to the **Catalog** so it becomes a reusable template, and (optionally) back it with
GitHub for versioning and pull-request previews.

## Step 4 — Validate and deploy

Use Meshery's **relationship and policy validation** to catch misconfigurations — for example, a
missing `nvidia.com/gpu` limit that would schedule the workload onto CPU nodes. Once the design is
valid, **deploy** it to the cluster from Meshery. Watch the workload appear in Kanvas and confirm the
pod lands on a GPU node:

```bash
kubectl get pods -o wide
kubectl describe pod -l app=vllm-llama | grep -i gpu
```

## Step 5 — Run a Performance Profile

Create a Meshery **Performance Profile** targeting the inference Service. Meshery uses load
generators such as **fortio**, **wrk2**, or **nighthawk** to drive traffic and record latency,
throughput, and error rate:

```bash
mesheryctl perf apply llm-bench \
  --url http://<service-endpoint>/v1/models \
  --load-generator fortio \
  --concurrent-requests 10 \
  --duration 60s
```

Review p50/p95 latency and requests/second. Save the profile so you can **compare runs over time**
and detect regressions after future design changes.

## Step 6 — Observe (optional)

Connect **Prometheus** and **Grafana** through Meshery and scrape the **NVIDIA DCGM exporter** to see
GPU utilization and memory alongside inference latency.

## What you learned

You brought a DOKS GPU cluster under Meshery management, captured serving as a versioned Design,
validated and deployed it, and measured it with a Performance Profile — the cloud native operating
loop for AI workloads. Take the exam to validate your understanding.
