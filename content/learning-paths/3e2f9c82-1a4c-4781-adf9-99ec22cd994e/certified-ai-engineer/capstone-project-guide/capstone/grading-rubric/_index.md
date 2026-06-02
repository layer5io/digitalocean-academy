---
type: "page"
id: "grading-rubric"
title: "Grading Rubric"
description: "The scoring rubric reviewers use to grade the DO-CAIE capstone."
weight: 2
---

The capstone is graded out of **100 points** across six categories. You need **70+** to pass, with
**no category scoring zero**. Reviewers return a per-category breakdown and written feedback.

## Rubric

| Category | Points | What reviewers look for |
|----------|-------:|-------------------------|
| Agent & application | 20 | A working Gradient agent with clear instructions, an appropriate base model, a published endpoint, and at least one functioning **function route** tool. |
| Grounding & RAG | 20 | A knowledge base populated from two+ source types, accurate retrieval, and visible **citations** tracing answers to sources. |
| GPU serving | 15 | A self-hosted/1-Click model served on GPU (Droplet or DOKS node pool) with a reachable OpenAI-compatible endpoint. |
| Meshery operations | 20 | Cluster imported; serving stack captured as a **Design** (with `nvidia.com/gpu` limits); deployed via Meshery; a **Performance Profile** executed with results. |
| Safety & evaluation | 15 | At least one **guardrail** configured and one **Evaluation** run, with results and a short interpretation. |
| Observability & docs | 10 | Prometheus + Grafana via Meshery showing GPU/latency metrics; a clear README and demo. |

## How points are awarded

- **Full marks** require the component to actually work in the demo, not just exist in code.
- **Partial marks** are given for a component that is present but incomplete (e.g., a knowledge base
  with one source type, or a Performance Profile with no comparison run).
- **Zero** in a category fails the capstone regardless of total — every category is mandatory.

## Common point losses

- Citations not enabled or not demonstrable (Grounding).
- GPU limits missing from the Design, so the workload schedules on CPU (Meshery operations).
- Secrets committed to Git, or overly broad access keys (deductions across categories).
- No comparison between performance runs, so regressions cannot be shown (Meshery operations).
- Evaluation run with no interpretation of the results (Safety & evaluation).

## Raising your score

- Add a **second** function route or a **multi-agent route** to strengthen the Agent category.
- Show a **before/after** Performance Profile after a Design change to demonstrate the
  observe-to-redesign loop.
- Include an evaluation that compares **two model or prompt versions**.

Proceed to **Submission Process** to package and submit your work.
