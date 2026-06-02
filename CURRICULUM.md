# DigitalOcean Academy — Curriculum Master Outline

> A comprehensive, AI‑first learning library for the **DigitalOcean Academy**, built on the
> [Layer5 Academy](https://docs.layer5.io/cloud/academy/) platform. The curriculum focuses
> heavily on DigitalOcean's **Gradient™ AI Platform** and the broader **AI‑Native Cloud**, and
> threads **[Meshery](https://meshery.io/)** — the open‑source cloud native manager — through the
> infrastructure, operations, and observability content so that learners can design, deploy,
> performance‑test, and govern AI workloads on DigitalOcean Kubernetes (DOKS) and GPU Droplets.

This document is the **skeletal outline** of the entire academy. It defines the learning paths,
their courses and chapters, the hands‑on challenges, and the **DigitalOcean Certified AI Engineer
(DO‑CAIE)** certification. The generated Hugo content under `content/` implements this outline.

- **Organization UID:** `3e2f9c82-1a4c-4781-adf9-99ec22cd994e`
- **Content model:** `Learning Path → Course → Chapter (module) → Lesson (page)`
- **Assessment model:** `Challenge → { lab, exam }`

---

## Curriculum at a glance

| # | Learning Path | Level | Courses | Focus |
|---|---------------|-------|---------|-------|
| 0 | Getting Started with DigitalOcean Kubernetes | Beginner | 2 | DOKS foundations *(pre‑existing)* |
| 1 | AI Foundations on DigitalOcean | Beginner | 4 | AI‑Native Cloud, serverless inference, first agent, prompting |
| 2 | Building Agentic AI with the Gradient AI Platform | Intermediate | 6 | Agents, RAG, tools, routing, guardrails, production |
| 3 | GPU Compute & Model Serving | Intermediate–Advanced | 5 | GPU Droplets, 1‑Click Models, self‑hosting, fine‑tuning, distributed inference |
| 4 | Cloud Native AI Infrastructure with Meshery & DOKS | Advanced | 6 | Meshery designs, GPU clusters, perf testing, GitOps, observability |
| 5 | Production AI Engineering & MLOps | Advanced | 5 | Inference Engine/Router, data & retrieval, security, CI/CD |
| 6 | DigitalOcean Certified AI Engineer (DO‑CAIE) | Certification | 3 | Exam blueprint, study guide, capstone |

**Hands‑on challenges:** 4 standalone challenges (lab + graded exam each), including the
certification capstone exam.

---

## Learning Path 1 — AI Foundations on DigitalOcean

**Level:** Beginner · **Audience:** Developers new to building on DigitalOcean's AI stack ·
**Outcome:** Understand the AI‑Native Cloud, call foundation models with serverless inference, and
ship a first managed agent.

1. **The DigitalOcean AI‑Native Cloud**
   - What "AI‑Native Cloud" means; the five layers (infrastructure, core cloud, inference, data, managed agents)
   - The Gradient™ AI Platform vs. GPU Droplets vs. Inference Engine — choosing the right tool
   - Accounts, projects, regions, and pricing model for AI services
   - Tooling tour: Control Panel, `doctl`, API, SDKs, and the DigitalOcean MCP server
2. **Serverless Inference & the Model Catalog**
   - What serverless inference is and when to use it
   - The model catalog: 70+ open models plus frontier models (OpenAI, Anthropic)
   - Model access keys; the OpenAI/Anthropic‑compatible endpoint
   - Your first chat completion (cURL, Python, TypeScript)
   - Streaming, parameters, and token/cost basics
3. **Your First AI Agent**
   - Anatomy of a Gradient agent: model, instructions, temperature, endpoint
   - Creating an agent in the Control Panel (no‑code) and via API (full‑code)
   - Testing in the agent playground; publishing an endpoint
   - Embedding the agent in a simple web app
4. **Prompt Engineering Essentials**
   - System vs. user instructions; structure, roles, and few‑shot prompting
   - Controlling output: format, length, determinism (temperature/top‑p)
   - Common failure modes and how to mitigate them
   - Evaluating prompt quality before you scale

---

## Learning Path 2 — Building Agentic AI with the Gradient AI Platform

**Level:** Intermediate · **Outcome:** Build, ground, extend, route, guard, and ship production agents.

1. **Designing AI Agents**
   - Agent configuration deep dive; instruction design patterns
   - Choosing a base model; temperature, max tokens, top‑p tuning
   - Agent playground, sample inputs, and iteration loops
   - Versioning an agent and comparing versions
2. **Knowledge Bases & Retrieval‑Augmented Generation (RAG)**
   - RAG concepts: chunking, embeddings, vector search, retrieval, citations
   - Creating a knowledge base; data sources (Spaces, file upload, web crawling, S3/Dropbox/Drive connectors)
   - Indexing, re‑indexing, and embedding models
   - Attaching/detaching knowledge bases to agents; knowledge base citations
   - Measuring retrieval quality
3. **Functions & Tool Use**
   - Function routes: giving agents the ability to call external APIs/code
   - DigitalOcean Functions (serverless) as agent tools
   - Designing tool schemas, inputs, and outputs
   - Knowledge Bases exposed as MCP tools
4. **Multi‑Agent Routing**
   - Agent routes and orchestrating specialized sub‑agents
   - Router agents, intent classification, and delegation patterns
   - Designing a multi‑agent customer‑support system
5. **Guardrails, Evaluations & Responsible AI**
   - Guardrails: content moderation, sensitive‑data and jailbreak protection
   - Evaluations: datasets, LLM‑as‑a‑judge, quality/latency/cost/safety scoring
   - Iterating safely; comparing evaluation runs across model/prompt versions
   - Responsible AI: bias, transparency, and auditability
6. **Deploying Agents to Production**
   - Agent versioning, insights, and observability
   - Hosting front ends on App Platform; securing endpoints
   - Rate limits, retries, and graceful degradation
   - Cost monitoring and scaling considerations

---

## Learning Path 3 — GPU Compute & Model Serving

**Level:** Intermediate–Advanced · **Outcome:** Run, serve, and fine‑tune models on DigitalOcean GPUs.

1. **GPU Droplets Fundamentals**
   - GPU options: NVIDIA H100/H200, AMD MI300X, L40S, RTX 4000/6000 Ada; single vs. 8‑GPU
   - AI/ML‑ready images, drivers (CUDA/ROCm), boot vs. scratch disks
   - Creating and connecting to a GPU Droplet; verifying the GPU
   - Cost, regions, and right‑sizing for training vs. inference
2. **1‑Click Models powered by Hugging Face (HUGS on DO)**
   - Deploying Llama, Mistral, Qwem, Gemma, and friends in one click
   - The OpenAI‑compatible endpoint; calling the model
   - Micro‑burst usage patterns and cost control
   - Moving from POC to production without code changes
3. **Self‑Hosting LLMs**
   - Serving stacks: vLLM, Hugging Face TGI, and Ollama
   - Quantization, batching, and context‑length trade‑offs
   - Exposing an OpenAI‑compatible API from your own server
   - Benchmarking tokens/sec and latency
4. **Fine‑Tuning & Training**
   - Full fine‑tuning vs. LoRA/QLoRA/PEFT
   - Preparing datasets; storing artifacts in Spaces
   - Running a fine‑tune on a GPU Droplet / Bare Metal GPU
   - Evaluating and packaging the resulting model
5. **Distributed Inference on DOKS**
   - GPU node pools on DigitalOcean Kubernetes
   - The NVIDIA device plugin and GPU scheduling
   - Distributed inference with `llm-d` / KServe
   - Autoscaling GPU workloads

---

## Learning Path 4 — Cloud Native AI Infrastructure with Meshery & DOKS

**Level:** Advanced · **Theme:** **Meshery‑first** operations for AI on DigitalOcean ·
**Outcome:** Design, deploy, performance‑test, and govern AI infrastructure as Meshery Designs across one or more DOKS clusters.

1. **Meshery Fundamentals for AI Platform Engineers**
   - What Meshery is: the cloud native manager / "manager of managers"
   - Architecture: Meshery Server, Operator, MeshSync, Adapters, Kanvas
   - Installing Meshery and connecting a DOKS cluster
   - Models, components, relationships, and the integrations catalog
2. **Managing DOKS GPU Clusters with Meshery**
   - Importing DOKS GPU clusters; real‑time topology with MeshSync
   - Visualizing GPU node pools, namespaces, and AI workloads in Kanvas
   - Lifecycle operations: deploy/undeploy, scale, and drift detection
   - Multi‑cluster single pane of glass (DO + hybrid/on‑prem GPU)
3. **Designing AI Inference Stacks as Meshery Designs**
   - Authoring a Design for an LLM serving stack (vLLM/Ollama + service + ingress)
   - Parameterizing GPU requests/limits and node selectors
   - Saving to the Meshery Catalog; reusing curated AI templates
   - GitHub‑backed designs and design versioning
4. **Performance Testing Inference Endpoints with Meshery**
   - Performance Profiles and load generators (fortio, wrk2, nighthawk)
   - Measuring latency, throughput, and error rates for inference APIs
   - Comparing runs over time; regression detection
   - Prometheus + Grafana integration for GPU and app metrics
5. **GitOps & Multi‑Cluster AI Operations**
   - Workspaces, teams, and RBAC for AI platform teams
   - GitOps workflows: design‑as‑code and pull‑request previews
   - Promoting AI stacks across dev → staging → prod DOKS clusters
   - Policy and relationship validation to catch misconfigurations
6. **Observability for AI Workloads**
   - Wiring Prometheus + Grafana through Meshery
   - GPU utilization, memory, and inference‑latency dashboards
   - Alerting on token cost, saturation, and queue depth
   - Closing the loop: from observation to redesign

---

## Learning Path 5 — Production AI Engineering & MLOps

**Level:** Advanced · **Outcome:** Operate AI in production: routing, data, security, and CI/CD.

1. **The Inference Engine**
   - Serverless, Batch, and Dedicated inference under one endpoint
   - Choosing a mode by workload (real‑time, async, reserved)
   - OpenAI/Anthropic compatibility and migration
   - Throughput, quotas, and reliability
2. **The Inference Router & Cost Control**
   - Policy‑driven model selection; natural‑language and structured policies
   - Intent‑based control over cost vs. latency
   - A/B and canary across models; fallback chains
   - Tracking spend and unit economics
3. **Data & Retrieval Foundations**
   - Spaces (S3‑compatible) for datasets, embeddings, and model artifacts
   - Managed PostgreSQL + `pgvector` for vector search
   - Running Qdrant/Weaviate/Milvus on DOKS (deployed via Meshery)
   - Data pipelines and freshness for RAG
4. **Security & Networking for AI**
   - VPCs, firewalls, and private networking for inference services
   - Secrets, model access keys, and least privilege
   - Guardrails and PII handling at the edge
   - Compliance and audit trails
5. **CI/CD for AI with GitHub Actions + Meshery**
   - Building and testing agents/models in CI
   - Evaluations as a quality gate
   - Deploying infrastructure designs with Meshery in pipelines
   - Progressive delivery and rollback

---

## Certification — DigitalOcean Certified AI Engineer (DO‑CAIE)

**Format:** Multiple‑choice + scenario questions and a hands‑on capstone ·
**Pass mark:** 70% on the written exam **and** a passing capstone submission ·
**Recommended prep:** Learning Paths 1–5.

### Exam blueprint (domains & weighting)

| Domain | Weight |
|--------|--------|
| 1. AI‑Native Cloud fundamentals & service selection | 12% |
| 2. Foundation models, serverless inference & the model catalog | 14% |
| 3. Building agents with the Gradient AI Platform | 18% |
| 4. Knowledge Bases & RAG | 14% |
| 5. GPU compute, 1‑Click Models & model serving | 14% |
| 6. Cloud native AI operations with Meshery & DOKS | 16% |
| 7. Production engineering: routing, security, observability & responsible AI | 12% |

### Certification learning path (content)

1. **Certification Overview** — who it's for, format, scheduling, scoring, recertification
2. **Exam Domains Study Guide** — domain‑by‑domain objectives mapped to learning paths and lessons
3. **Capstone Project Guide** — requirements, rubric, and submission process for the hands‑on capstone

### Capstone (delivered as a challenge)

Build and operate an end‑to‑end agentic application: a RAG agent on the Gradient AI Platform backed
by a knowledge base, served alongside a self‑hosted model on DOKS GPU nodes, deployed and
performance‑tested with Meshery, with guardrails and evaluations in place. Graded by rubric + a
written certification exam.

---

## Hands‑on Challenges

Each challenge ships a guided **lab** and a graded **exam** (`pass_percentage: 70`).

1. **Deploy an LLM on GPU Droplets** — stand up a 1‑Click / vLLM model and call its OpenAI‑compatible endpoint.
2. **Build a RAG Agent with Knowledge Bases** — ground a Gradient agent on your own data and verify citations.
3. **Manage a DOKS GPU Cluster with Meshery** — import a cluster, deploy an inference Design, and run a Performance Profile.
4. **DO‑CAIE Certification Exam** — the comprehensive certification capstone exam.

---

## Content conventions (for contributors)

Front matter by level (matches the Layer5 Academy theme):

```yaml
# Learning Path  (_index.md)
type: "learning-path"
title: "…"
description: "…"
id: "<uuid>"
banner: "digitalocean.svg"
weight: <n>
level: "beginner|intermediate|advanced"
```

```yaml
# Course (_index.md)
type: "course"
id: "<slug>"
title: "…"
description: "…"
weight: <n>
banner: "digitalocean.svg"
tags: ["…"]
categories: "…"
level: "…"
```

```yaml
# Chapter / module (_index.md)
type: "module"
id: "<slug>"
title: "…"
weight: <n>
```

```yaml
# Lesson / page (_index.md)
type: "page"
id: "<slug>"
title: "…"
weight: <n>
```

Assessments use `type: "test"` (`exam.md`) and `type: "lab"` (`lab.md`) as documented in the
[README](./README.md). Images are referenced with the `usestatic` shortcode for multi‑tenant
compatibility.
