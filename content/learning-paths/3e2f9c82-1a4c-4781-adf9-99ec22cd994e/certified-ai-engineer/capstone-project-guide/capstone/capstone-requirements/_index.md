---
type: "page"
id: "capstone-requirements"
title: "Capstone Requirements"
description: "What you must build and demonstrate for the DO-CAIE hands-on capstone project."
weight: 1
---

The capstone proves you can build *and operate* a production-style AI application on DigitalOcean,
end to end. You will deliver a working system plus a short write-up and a demo.

## The brief

Build a **grounded, agentic application** and run it on infrastructure you manage with Meshery.
A reference scenario: an internal "Docs Assistant" that answers questions about a product, escalates
certain requests via a tool, and is served alongside a self-hosted model.

## Required components

Your submission must include all of the following:

1. **A Gradient agent** with custom instructions and a sensible base model, published to an endpoint.
2. **A knowledge base (RAG)** attached to the agent, populated from at least two data-source types
   (for example, uploaded files and a crawled website), with **citations** working.
3. **At least one function route** giving the agent a real tool (e.g., a DigitalOcean Function that
   calls an API or performs a lookup).
4. **A self-hosted or 1-Click model** served on **GPU** infrastructure — a GPU Droplet or a **DOKS
   GPU node pool** — exposing an OpenAI-compatible endpoint.
5. **Meshery operations** on the DOKS cluster:
   - import the cluster (MeshSync),
   - capture the serving stack as a **Design** (Deployment requesting `nvidia.com/gpu`, Service,
     Ingress),
   - deploy it, and
   - run a **Performance Profile** against the inference endpoint.
6. **Guardrails and an evaluation**: at least one guardrail configured and one Evaluation run with
   results captured.
7. **Observability**: Prometheus + Grafana wired through Meshery, showing GPU and latency metrics.

## Deliverables

- A **Git repository** containing your agent/app code, the Meshery Design (exported YAML/JSON), any
  Kubernetes manifests, and a GitHub Actions workflow.
- A **README** (1–2 pages) describing architecture, the services used, and key decisions.
- A **short demo** (recorded video or live) showing the agent answering a grounded question with a
  citation, invoking the tool, and the Meshery Performance Profile results.
- An **evaluation summary** and a **performance summary** (latency p50/p95, throughput).

## Constraints and tips

- Use **trial credit** where possible and **destroy GPU resources when idle** to control cost.
- Keep secrets out of Git; use least-privilege **model/agent access keys**.
- Favor the **OpenAI-compatible** interface everywhere so components are interchangeable.

Read the **Grading Rubric** next to see exactly how each component is scored.
