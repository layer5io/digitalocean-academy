---
type: "lab"
description: "The DO-CAIE capstone: build and operate an end-to-end agentic AI application on DigitalOcean, served on GPU infrastructure and managed with Meshery, then pass the written certification exam."
title: "DO-CAIE Capstone & Certification"
---

## Introduction

This is the capstone for the
[**DigitalOcean Certified AI Engineer (DO-CAIE)**](https://cloud.layer5.io/academy/certifications/3e2f9c82-1a4c-4781-adf9-99ec22cd994e/digitalocean-certified-ai-engineer/)
credential. It brings
together everything in the academy: building a grounded agent on the
[Gradient AI Platform](https://docs.digitalocean.com/products/gradient-ai-platform/), serving a model
on GPU infrastructure, and operating it all with [Meshery](https://meshery.io/). You must pass both
this capstone (graded by rubric) and the written **exam** in this challenge.

## What to build

Build a **grounded, agentic application** and run it on infrastructure you manage with Meshery. A
reference scenario is an internal "Docs Assistant" that answers from your documentation, escalates
certain requests through a tool, and is served alongside a self-hosted model.

Your submission must demonstrate all of the following:

1. **A Gradient agent** with custom instructions, a sensible base model, and a published endpoint.
2. **A knowledge base (RAG)** attached to the agent, built from at least two data-source types, with
   working **citations**.
3. **At least one function route** giving the agent a real tool (e.g., a DigitalOcean Function).
4. **A self-hosted or 1-Click model** on **GPU** (a GPU Droplet or a **DOKS GPU node pool**) exposing
   an OpenAI-compatible endpoint.
5. **Meshery operations**: import the DOKS cluster (MeshSync), capture the serving stack as a
   **Design** (Deployment requesting `nvidia.com/gpu`, Service, Ingress), deploy it, and run a
   **Performance Profile**.
6. **Guardrails and an Evaluation**: at least one guardrail configured and one Evaluation run.
7. **Observability**: Prometheus + Grafana via Meshery showing GPU and latency metrics.

## How it is graded

The capstone is scored against the published rubric (see *Certified AI Engineer → Capstone Project
Guide*): Agent & application (20), Grounding & RAG (20), GPU serving (15), Meshery operations (20),
Safety & evaluation (15), Observability & docs (10). You need **70+** with no category scoring zero.

## Deliverables

- A Git repository with agent/app code, the exported Meshery Design, Kubernetes manifests, evaluation
  results, and a CI workflow.
- A 1–2 page README and a 5–8 minute demo.
- A `SELF-ASSESSMENT.md` mapping each rubric category to where it is satisfied.

## The written exam

The **exam** in this challenge is the comprehensive DO-CAIE written test. It samples all seven
domains — AI-Native Cloud fundamentals, serverless inference, agents, RAG, GPU serving, Meshery
operations, and production engineering. The pass mark is **70%**.

## Preparing

Work through the five core learning paths and the *Certified AI Engineer* track, complete the three
skill challenges (Deploy an LLM on GPU Droplets; Build a RAG Agent with Knowledge Bases; Manage a DOKS
GPU Cluster with Meshery), then attempt the exam below.

Good luck — passing both the capstone and the exam earns your **DigitalOcean Certified AI Engineer**
badge.
