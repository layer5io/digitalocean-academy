---
type: "certification"
title: "DigitalOcean Certified AI Engineer (DO-CAIE)"
description: "Prove you can design, build, serve, and operate production AI applications on DigitalOcean's Gradient AI Platform and AI-Native Cloud, and manage the underlying cloud native infrastructure with Meshery and DigitalOcean Kubernetes (DOKS)."
id: "2b81f9cd-d726-4334-b3ef-23bf232fe677"
banner: "digitalocean.svg"
weight: 1
level: "advanced"
categories: "AI"
tags: ["AI", "Certification", "DigitalOcean", "Gradient", "Meshery"]

# Exam blueprint — domains and their weighting (sums to 100).
competencies:
  - title: "AI-Native Cloud fundamentals & service selection"
    percentage: 12
    items:
      - "The five layers of the AI-Native Cloud"
      - "Choosing among Gradient AI Platform, Serverless Inference, 1-Click Models, GPU Droplets, and DOKS"
      - "Projects, regions, and the pay-as-you-go pricing model"
      - "Tooling: doctl, the API, the pydo/godo SDKs, and the DigitalOcean MCP server"
  - title: "Foundation models, serverless inference & the model catalog"
    percentage: 14
    items:
      - "Serverless inference and when to use it"
      - "Browsing the model catalog and creating model access keys"
      - "Chat completions over the OpenAI/Anthropic-compatible endpoint"
      - "Streaming, sampling parameters, and token cost"
  - title: "Building agents with the Gradient AI Platform"
    percentage: 18
    items:
      - "Agent configuration: instructions, base model, and sampling parameters"
      - "No-code and full-code agent creation, testing, and publishing"
      - "Function routes and well-designed tool schemas"
      - "Multi-agent routing and intent-based delegation"
      - "Agent versioning and insights"
  - title: "Knowledge Bases & RAG"
    percentage: 14
    items:
      - "The RAG pipeline: chunking, embeddings, retrieval, and grounding"
      - "Creating and indexing knowledge bases"
      - "Data sources, connectors, and web crawling"
      - "Attaching knowledge bases and verifying citations"
      - "Measuring and improving retrieval quality"
  - title: "GPU compute, 1-Click Models & model serving"
    percentage: 14
    items:
      - "Selecting GPUs and Droplet sizes for training vs. inference"
      - "AI/ML images, drivers, and verifying the GPU"
      - "1-Click Models and OpenAI-compatible endpoints"
      - "Self-hosting with vLLM, TGI, and Ollama"
      - "GPU scheduling on DOKS with the NVIDIA device plugin"
  - title: "Cloud native AI operations with Meshery & DOKS"
    percentage: 16
    items:
      - "Meshery architecture and connecting a DOKS cluster"
      - "Importing clusters and visualizing GPU workloads in Kanvas"
      - "Authoring AI inference stacks as Meshery Designs"
      - "Performance Profiles for inference endpoints"
      - "Observability, GitOps, and policy validation across clusters"
  - title: "Production engineering: routing, security, observability & responsible AI"
    percentage: 12
    items:
      - "Inference Engine modes and the Inference Router"
      - "Data and retrieval: Spaces, pgvector, and vector databases"
      - "Security and networking: VPC, firewalls, keys, and PII handling"
      - "CI/CD with evaluations as a quality gate"
      - "Responsible AI: transparency, auditability, and human oversight"

# Recommended preparation before attempting the exam and capstone.
prerequisite_knowledge:
  - title: "Learning Paths"
    children:
      - title: "AI Foundations on DigitalOcean"
        link: "https://cloud.layer5.io/academy/learning-paths/3e2f9c82-1a4c-4781-adf9-99ec22cd994e/ai-foundations-on-digitalocean/"
      - title: "Building Agentic AI with the Gradient AI Platform"
        link: "https://cloud.layer5.io/academy/learning-paths/3e2f9c82-1a4c-4781-adf9-99ec22cd994e/building-agentic-ai-with-gradient/"
      - title: "GPU Compute & Model Serving"
        link: "https://cloud.layer5.io/academy/learning-paths/3e2f9c82-1a4c-4781-adf9-99ec22cd994e/gpu-compute-and-model-serving/"
      - title: "Cloud Native AI Infrastructure with Meshery & DOKS"
        link: "https://cloud.layer5.io/academy/learning-paths/3e2f9c82-1a4c-4781-adf9-99ec22cd994e/cloud-native-ai-with-meshery/"
      - title: "Production AI Engineering & MLOps"
        link: "https://cloud.layer5.io/academy/learning-paths/3e2f9c82-1a4c-4781-adf9-99ec22cd994e/production-ai-engineering/"
      - title: "DO-CAIE Certification Prep"
        link: "https://cloud.layer5.io/academy/learning-paths/3e2f9c82-1a4c-4781-adf9-99ec22cd994e/certified-ai-engineer/"
  - title: "Recommended skills"
    children:
      - title: "Comfort with the Linux command line"
        link: "https://linuxcommand.org/"
      - title: "Basic Kubernetes (Getting Started with DOKS)"
        link: "https://cloud.layer5.io/academy/learning-paths/3e2f9c82-1a4c-4781-adf9-99ec22cd994e/getting-started/"

# Hands-on challenges and documentation for further study.
related_resources:
  - title: "Hands-on Challenges"
    children:
      - title: "Deploy an LLM on GPU Droplets"
        link: "https://cloud.layer5.io/academy/challenges/3e2f9c82-1a4c-4781-adf9-99ec22cd994e/deploy-an-llm-on-gpu-droplets/"
      - title: "Build a RAG Agent with Knowledge Bases"
        link: "https://cloud.layer5.io/academy/challenges/3e2f9c82-1a4c-4781-adf9-99ec22cd994e/build-a-rag-agent-with-knowledge-bases/"
      - title: "Manage a DOKS GPU Cluster with Meshery"
        link: "https://cloud.layer5.io/academy/challenges/3e2f9c82-1a4c-4781-adf9-99ec22cd994e/manage-a-doks-gpu-cluster-with-meshery/"
      - title: "DO-CAIE Certification Exam"
        link: "https://cloud.layer5.io/academy/challenges/3e2f9c82-1a4c-4781-adf9-99ec22cd994e/docaie-certification-exam/"
  - title: "Documentation"
    children:
      - title: "DigitalOcean Gradient AI Platform"
        link: "https://docs.digitalocean.com/products/gradient-ai-platform/"
      - title: "DigitalOcean GPU Droplets"
        link: "https://docs.digitalocean.com/products/gpu-droplets/"
      - title: "Meshery"
        link: "https://docs.meshery.io/"

# Exam logistics and policies.
additional_attributes:
  - title: "Exam Format"
    value: "60 questions"
    description: "Multiple-choice and scenario questions; 90 minutes; proctored online"
  - title: "Pass Mark"
    value: "70%"
    description: "On the written exam, plus a passing hands-on capstone"
  - title: "Capstone"
    value: "Mandatory"
    description: "End-to-end agentic build on DigitalOcean, operated with Meshery, graded by rubric"
  - title: "Retake Policy"
    value: "14 days"
    description: "Retake after 14 days; a second retake after 30 days"
  - title: "Validity"
    value: "2 years"
    description: "Recertify via a delta exam or a recertification capstone"
---

The **DigitalOcean Certified AI Engineer (DO-CAIE)** is the DigitalOcean Academy's flagship
credential. It validates that you can take an AI application from idea to production on DigitalOcean's
AI-Native Cloud — building grounded, agentic applications on the
[Gradient AI Platform](https://docs.digitalocean.com/products/gradient-ai-platform/), serving models
on GPU infrastructure, and operating it all with [Meshery](https://meshery.io/) on
[DigitalOcean Kubernetes](https://docs.digitalocean.com/products/kubernetes/).

## How you earn it

The credential has two required parts:

1. A **written exam** — 60 multiple-choice and scenario questions across the seven domains above
   (90 minutes, proctored). Pass mark **70%**.
2. A **hands-on capstone** — an end-to-end agentic application served on GPU infrastructure and
   operated with Meshery, graded against a published rubric.

Both the exam and the capstone are delivered as the
[DO-CAIE Certification Exam challenge](https://cloud.layer5.io/academy/challenges/3e2f9c82-1a4c-4781-adf9-99ec22cd994e/docaie-certification-exam/).

## How to prepare

Work through the five core learning paths, then the
[DO-CAIE Certification Prep](https://cloud.layer5.io/academy/learning-paths/3e2f9c82-1a4c-4781-adf9-99ec22cd994e/certified-ai-engineer/)
path for the exam blueprint, a domain-by-domain study guide, practice questions, and the capstone
guide. The competency blueprint above shows where to focus your study time.

## What it proves

A certified DO-CAIE holder can select the right DigitalOcean AI service for a workload, call models
through serverless inference and the Inference Engine, build agents with knowledge bases and tools,
serve open models on GPU Droplets and DOKS, and operate the infrastructure with Meshery — designing,
deploying, performance-testing, and observing AI workloads cloud-natively.
