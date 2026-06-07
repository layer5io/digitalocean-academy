---
type: "page"
id: "rag-concepts"
title: "RAG Concepts"
description: "Learn how Retrieval-Augmented Generation works, from chunking and embeddings through vector search, retrieval, grounding, and citations."
weight: 1
---

## What Is RAG?

Retrieval-Augmented Generation (RAG) connects a language model to an external knowledge store at inference time. Instead of relying solely on patterns baked into model weights during training, the model retrieves relevant passages from your private data and uses them as grounding context when generating a reply. The result is an agent that can answer questions about documents it has never been trained on — and that can cite its sources.

## The RAG Pipeline

```
User query
    ↓
Embed query → query vector
    ↓
Vector search over knowledge base
    ↓
Retrieve top-k relevant chunks
    ↓
Inject chunks into model context
    ↓
Model generates grounded response
    ↓
Citations returned with response
```

Each step in this pipeline has tunable parameters that affect accuracy and cost.

## Chunking

Raw documents are split into chunks before indexing. Chunk size is a critical parameter:

| Chunk size | Trade-off |
|------------|-----------|
| Small (128–256 tokens) | High precision; may lose context across sentences |
| Medium (512 tokens) | Good balance for most document types |
| Large (1024+ tokens) | Retains context; may dilute relevance signal |

Chunk overlap (repeating a portion of one chunk at the start of the next) reduces the chance of cutting a fact in half. Typical overlap is 10–20% of chunk size.

## Embeddings

An embedding model converts a text chunk into a dense vector — a list of numbers that encodes semantic meaning. Chunks with similar meaning produce vectors that are close together in high-dimensional space. Gradient knowledge bases use embedding models hosted by the platform; you choose the model when creating the knowledge base.

The embedding model used at index time must also be used at query time. Mixing models produces meaningless similarity scores.

## Vector Search

At query time, the user's question is embedded using the same model that indexed the documents. The platform computes similarity (typically cosine similarity) between the query vector and all chunk vectors, then returns the top-k most similar chunks.

```
cosine_similarity(query_vector, chunk_vector) → score in [0, 1]
```

Higher scores mean higher relevance. The retrieval step returns `k` chunks; a typical default is 3–5. Increasing `k` improves recall but adds tokens to the context, raising cost and potentially diluting relevance.

## Grounding

Grounding means the model's answer is derived from the retrieved chunks rather than from its parametric memory. A well-grounded agent says "According to the uploaded support policy, refunds are processed within 5 business days" rather than inventing a number. Grounding is what makes RAG trustworthy for factual tasks.

Without grounding, large language models hallucinate — producing confident-sounding but fabricated facts. RAG does not eliminate hallucination entirely, but it significantly reduces it for in-scope queries.

## Citations

The Gradient AI Platform supports **knowledge-base citations**: when the agent's response draws on a retrieved chunk, the platform can return the source document name, page, or URL alongside the answer. This allows the front end to display "Source: Q3 pricing guide, page 4" under the reply.

Citations are useful for:
- Building user trust in the answer
- Letting users verify the source directly
- Debugging incorrect answers by tracing back to the retrieved chunk

## Summary

RAG gives agents access to current, private, and domain-specific knowledge without retraining. The quality of retrieval — governed by chunking, embedding model choice, and `k` — determines the quality of the final answer. The next lessons walk through creating a knowledge base and connecting it to an agent.

Learn more in the [Gradient AI Platform knowledge-base documentation](https://docs.digitalocean.com/products/gradient-ai-platform/how-to/create-manage-agent-knowledge-bases/).
