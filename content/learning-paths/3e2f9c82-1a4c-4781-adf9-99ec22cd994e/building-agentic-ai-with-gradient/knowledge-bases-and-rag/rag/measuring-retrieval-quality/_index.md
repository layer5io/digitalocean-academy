---
type: "page"
id: "measuring-retrieval-quality"
title: "Measuring Retrieval Quality"
description: "Evaluate retrieval relevance and grounding quality, tune chunk size and overlap, and avoid common RAG pitfalls."
weight: 5
---

## Why Measure Retrieval Separately

A RAG agent has two distinct failure modes: the retriever returns wrong or irrelevant chunks, or the generator produces a bad answer even from good chunks. These require different fixes. Measuring retrieval quality in isolation tells you which component to improve.

The Gradient AI Platform's evaluation framework (covered in the Guardrails & Evaluations course) supports LLM-as-a-judge scoring, which works end-to-end. This lesson focuses on the retrieval layer specifically.

## Key Retrieval Metrics

| Metric | Definition | Good threshold |
|--------|------------|---------------|
| Retrieval relevance | Fraction of retrieved chunks that are relevant to the query | > 0.80 |
| Recall @ k | Fraction of queries where the correct chunk appears in the top k results | > 0.90 |
| Grounding rate | Fraction of generated claims traceable to a retrieved chunk | > 0.85 |
| Answer accuracy | Fraction of final answers rated correct by a judge | Depends on task |

For knowledge bases with recent GPU-accelerated OCR improvements, text-question accuracy on document-heavy knowledge bases can reach approximately 95%; table and graph questions see significant gains from the improved layout model.

## Building a Retrieval Test Set

A retrieval test set consists of question–expected-source pairs:

```json
[
  {
    "question": "What is the maximum refund window?",
    "expected_document": "refund-policy-2025.pdf",
    "expected_content_fragment": "30-day window"
  },
  {
    "question": "Which data centers support GPU Droplets?",
    "expected_document": "infrastructure-guide.pdf",
    "expected_content_fragment": "NYC3, AMS3, SFO3"
  }
]
```

Run each question through the knowledge base retrieval API (without generation) and check whether the expected document and fragment appear in the top-k results.

## Chunk Size and Overlap Tuning

Chunk size is the most impactful retrieval parameter. A practical tuning approach:

1. Start with 512-token chunks and 10% overlap.
2. Run your test set and measure retrieval recall.
3. If long-answer questions fail, increase chunk size (try 768 or 1024).
4. If short-answer questions fail, decrease chunk size (try 256).
5. If cross-sentence facts are missed, increase overlap to 20%.

```
Chunk size 256  → high precision, low context coverage
Chunk size 512  → balanced (good starting point)
Chunk size 1024 → high context coverage, lower precision signal
```

Re-index the knowledge base after each configuration change; retrieval improvements only apply after re-indexing.

## Common Pitfalls

**Headers and footers polluting chunks.** PDF extraction sometimes includes page headers, footers, and watermarks in chunks. These add noise. Use a pre-processing step to strip them before uploading, or use the platform's layout-aware extraction which distinguishes body text from structural elements.

**Boilerplate overwhelming content.** Contracts and legal documents repeat standard clauses on every page. These dominate retrieval and push out the unique, query-relevant content. Consider splitting boilerplate into a separate knowledge base or omitting it if it is never queried directly.

**Vocabulary mismatch.** Users ask "cancel subscription" but documents say "terminate service agreement." Bridge this gap with query expansion in instructions ("when a user asks about cancellation, also search for: terminate, end service, discontinue") or by adding a synonym glossary to the knowledge base.

**Too many knowledge bases with overlapping content.** When retrieval draws from multiple overlapping sources, near-duplicate chunks consume the top-k slots and crowd out diverse evidence. Audit and deduplicate content across attached knowledge bases.

**Stale indexes.** Documents updated after the last re-index are not reflected in retrieval. Establish a re-index cadence aligned with your document update frequency.

## Iterating on Quality

Retrieval quality improvement is iterative. After each change — chunk size, overlap, source documents, or embedding model (requires a new knowledge base) — re-run the test set and compare metrics. Use the Gradient evaluation framework to run structured comparisons at scale.

Learn more in the [knowledge-base documentation](https://docs.digitalocean.com/products/gradient-ai-platform/how-to/create-manage-agent-knowledge-bases/).
