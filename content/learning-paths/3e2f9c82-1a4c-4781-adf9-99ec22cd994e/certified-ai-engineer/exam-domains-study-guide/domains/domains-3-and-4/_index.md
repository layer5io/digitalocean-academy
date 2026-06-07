---
type: "page"
id: "domains-3-and-4"
title: "Domains 3 & 4: Agents and RAG"
description: "Objectives for building agents on the Gradient AI Platform and for knowledge bases and retrieval-augmented generation."
weight: 2
---

Domains 3 and 4 are the largest share of the exam at **32%** combined — the core of building useful,
grounded agents.

## Domain 3 — Building agents with the Gradient AI Platform (18%)

You should be able to:

- Configure an agent: **instructions**, **base model**, and sampling parameters (temperature,
  max tokens, top_p).
- Create agents both **no-code** (Control Panel) and **full-code** (API/SDK).
- Use the **playground** to iterate, then **publish** an endpoint with an agent access key.
- Extend agents with **function routes** (calling DigitalOcean Functions or external APIs as tools)
  and design clean **tool schemas**.
- Compose **multi-agent routing**: a router agent classifies intent and delegates to specialized
  sub-agents.
- Use **agent versioning** and **agent insights** to ship safely.

**Prepares you:** *Building Agentic AI with the Gradient AI Platform → Designing AI Agents,
Functions & Tool Use, Multi-Agent Routing, Deploying Agents to Production.*

Sample objective check: *A support bot must look up order status.* → Add a function route to a
Function that queries the orders API, with a typed input/output schema.

## Domain 4 — Knowledge Bases & RAG (14%)

You should be able to:

- Explain the **RAG** pipeline: chunking, embeddings, vector search, retrieval, and grounding.
- Create a **knowledge base**, choose an embedding model, and **index** content.
- Connect **data sources**: uploaded files, Spaces folders, **web crawling**, and S3/Dropbox/Drive
  connectors; re-index when data changes.
- **Attach** a knowledge base to an agent and verify **citations**.
- Measure and improve **retrieval quality** (chunk size/overlap, relevance).

**Prepares you:** *Building Agentic AI with the Gradient AI Platform → Knowledge Bases & RAG.*

Sample objective check: *Answers cite stale content after a docs update.* → Re-index the knowledge
base (or re-crawl the source) so embeddings reflect the new content.

## Study tips

- Build one real agent end-to-end: instructions → model → a function route → an attached knowledge
  base → guardrails. The exam rewards people who have actually shipped one.
- Be able to read a citation and explain which chunk grounded the answer.
- Know the difference between giving an agent a **tool** (function route) and giving it **knowledge**
  (a knowledge base).

Next: **Domains 5, 6 & 7: Serving, Operations, and Production.**
