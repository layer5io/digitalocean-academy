---
type: "page"
id: "domains-5-6-and-7"
title: "Domains 5, 6 & 7: Serving, Operations, and Production"
description: "Objectives for GPU compute and model serving, cloud native AI operations with Meshery, and production engineering."
weight: 3
---

The final three domains cover serving models, operating the infrastructure with Meshery, and
running everything in production — **42%** of the exam combined.

## Domain 5 — GPU compute, 1-Click Models & model serving (14%)

You should be able to:

- Pick a **GPU** (H100/H200, MI300X, L40S, RTX 4000/6000 Ada) and a single vs 8-GPU configuration
  for training vs inference.
- Create and connect to a **GPU Droplet** with `doctl`; verify with `nvidia-smi`.
- Deploy a **1-Click Model** and call its OpenAI-compatible endpoint.
- Self-host with **vLLM**, **TGI**, or **Ollama**; reason about quantization, batching, and context
  length; benchmark throughput/latency.
- Schedule GPUs on **DOKS** with the NVIDIA device plugin (`nvidia.com/gpu`).

**Prepares you:** *GPU Compute & Model Serving.*

## Domain 6 — Cloud native AI operations with Meshery & DOKS (16%)

You should be able to:

- Explain Meshery's role and architecture (Server, Operator, **MeshSync**, **Kanvas**, `mesheryctl`).
- **Import** a DOKS GPU cluster and visualize GPU workloads.
- Author an AI serving stack as a **Design** (Deployment requesting `nvidia.com/gpu`, Service,
  Ingress), save it to the **Catalog**, and version it in GitHub.
- Run a **Performance Profile** (fortio/wrk2/nighthawk) against an inference endpoint and compare
  runs over time.
- Wire **Prometheus + Grafana** through Meshery for GPU/latency metrics; validate configs with
  relationships/policies; promote designs across clusters with RBAC.

**Prepares you:** *Cloud Native AI Infrastructure with Meshery & DOKS.*

## Domain 7 — Production engineering (12%)

You should be able to:

- Choose an **Inference Engine** mode (Serverless/Batch/Dedicated) and use the **Inference Router**
  with cost/latency policies and fallbacks.
- Build the **data layer**: Spaces, Managed PostgreSQL + **pgvector**, vector DBs on DOKS.
- Secure AI services with **VPCs**, **Cloud Firewalls**, least-privilege keys, and PII guardrails.
- Run **CI/CD** with GitHub Actions + Meshery, using **Evaluations as a quality gate** and
  progressive delivery.
- Apply **responsible-AI** practices: transparency, auditability, human oversight.

**Prepares you:** *Production AI Engineering & MLOps.*

## Study tips

- Domain 6 is the single largest serving/ops slice — practice the full Meshery loop on a real DOKS
  cluster (import → design → deploy → perf test → observe).
- Be ready to map a production requirement (cost cap, p95 latency, safety) to the right control.

Next: **Practice Questions.**
