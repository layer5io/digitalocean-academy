---
type: "page"
id: "practice-questions"
title: "Practice Questions"
description: "Worked sample questions across all seven DO-CAIE domains, with answers explained."
weight: 4
---

Use these sample questions to gauge readiness. Try to answer before expanding the reasoning. The
full, scored practice exam lives in the **DO-CAIE Certification Exam** challenge.

## Domain 1 — Service selection

**Q.** A team needs to embed an occasional summarization feature with the least operational
overhead and no idle cost. Which service fits best?

- A. A dedicated 8×H100 GPU Droplet
- B. Serverless inference
- C. A self-hosted vLLM server on DOKS
- D. Bare Metal GPUs

**Answer: B.** Serverless inference has no infrastructure to manage and you pay per token, ideal for
intermittent, low-volume features.

## Domain 2 — Inference API

**Q.** You want to reuse existing code written against the OpenAI SDK. What is the minimum change to
call a DigitalOcean catalog model?

**Answer.** Point the SDK's `base_url` at `https://inference.do-ai.run/v1` and set `api_key` to a
DigitalOcean **model access key**. The endpoint is OpenAI-compatible, so no other code changes are
required.

## Domain 3 — Agents

**Q.** An agent must fetch live order status from an internal API. Knowledge base or function route?

**Answer.** A **function route**. Knowledge bases supply *retrieved knowledge*; function routes let
the agent *take an action* by calling code/an API with a typed schema.

## Domain 4 — RAG

**Q.** Multiple-answer: which improve retrieval quality in a knowledge base? (Select all that apply.)

- A. Tuning chunk size and overlap
- B. Increasing `temperature`
- C. Re-indexing after the source data changes
- D. Choosing an appropriate embedding model

**Answer: A, C, D.** Temperature affects generation, not retrieval.

## Domain 5 — Serving

**Q.** On DOKS, how does a pod request one GPU?

**Answer.** With `resources.limits: { nvidia.com/gpu: 1 }`, advertised by the NVIDIA device plugin
running on the GPU node pool.

## Domain 6 — Meshery operations

**Q.** You captured a vLLM serving stack as a Meshery Design and want to catch a missing
`nvidia.com/gpu` limit before deploying. Which Meshery capability helps?

**Answer.** **Relationship/policy validation** — Meshery validates the design and flags
misconfigurations prior to deployment. Performance Profiles then measure the running endpoint.

## Domain 7 — Production

**Q.** You must cap cost while keeping p95 latency acceptable, choosing a cheaper model when quality
allows. Which control fits?

**Answer.** The **Inference Router** with a cost/latency policy that routes by intent and falls back
across models — no hardcoded model selection.

## Ready check

If you answered most of these confidently and have built the end-to-end project described in the
**Capstone Project Guide**, you are ready to schedule the exam.
