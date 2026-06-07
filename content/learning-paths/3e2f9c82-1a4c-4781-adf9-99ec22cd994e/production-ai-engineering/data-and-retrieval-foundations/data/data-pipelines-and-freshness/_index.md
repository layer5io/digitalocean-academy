---
type: "page"
id: "data-pipelines-and-freshness"
title: "Data Pipelines & Freshness"
description: "Keep RAG retrieval data current with re-embedding pipelines, incremental updates, and scheduled refresh jobs."
weight: 4
---

## Why Data Freshness Matters

A RAG system is only as good as the documents it retrieves. Stale embeddings mean the model answers based on outdated information. A product FAQ updated yesterday may be invisible to the retrieval layer if embeddings were computed a month ago. Freshness is an operational concern, not just a setup task.

## Anatomy of a RAG Data Pipeline

A complete pipeline has four stages:

1. **Ingest** — pull new or updated source documents from their origin (database, CMS, Spaces, API).
2. **Chunk** — split documents into retrieval-sized segments (typically 200–500 tokens with overlap).
3. **Embed** — compute vector embeddings using the Inference Engine.
4. **Index** — upsert embeddings into pgvector or your vector database, keyed by document ID.

```python
from openai import OpenAI
import psycopg2

embed_client = OpenAI(
    base_url="https://inference.do-ai.run/v1",
    api_key="<model-access-key>",
)

def embed_and_index(chunks: list[dict], conn):
    """chunks: list of {"id": str, "content": str}"""
    texts = [c["content"] for c in chunks]
    resp = embed_client.embeddings.create(
        model="text-embedding-3-small",
        input=texts,
    )
    cur = conn.cursor()
    for chunk, emb_obj in zip(chunks, resp.data):
        cur.execute(
            """
            INSERT INTO documents (id, content, embedding)
            VALUES (%s, %s, %s)
            ON CONFLICT (id) DO UPDATE
              SET content   = EXCLUDED.content,
                  embedding = EXCLUDED.embedding,
                  updated_at = NOW()
            """,
            (chunk["id"], chunk["content"], emb_obj.embedding),
        )
    conn.commit()
```

The `ON CONFLICT ... DO UPDATE` pattern (upsert) ensures re-running the pipeline on updated documents is idempotent.

## Detecting Changed Documents

Track a `content_hash` alongside each embedding to detect changes without re-embedding the entire corpus:

```python
import hashlib

def content_hash(text: str) -> str:
    return hashlib.sha256(text.encode()).hexdigest()
```

During ingestion, compare the hash of each incoming document against the stored hash. Only re-embed documents whose hash has changed. This can reduce embedding API costs by 90% or more on corpora where most documents are stable.

## Scheduled Refresh Jobs

Run the pipeline on a schedule using a Kubernetes CronJob on DOKS:

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: rag-re-embed
spec:
  schedule: "0 2 * * *"   # nightly at 02:00 UTC
  jobTemplate:
    spec:
      template:
        spec:
          containers:
            - name: embedder
              image: registry.digitalocean.com/myrepo/embedder:latest
              envFrom:
                - secretRef:
                    name: inference-credentials
          restartPolicy: OnFailure
```

For near-real-time freshness, trigger the pipeline from a webhook or a change-data-capture stream whenever source documents are updated, rather than waiting for the nightly job.

## Artifact Storage

Store intermediate pipeline artifacts — chunked document files, embedding batches, pipeline run logs — in Spaces so they are reproducible and auditable:

```bash
aws s3 cp ./chunks_2026-06-02.jsonl s3://my-ai-datasets/pipelines/chunks/ \
  --endpoint-url https://nyc3.digitaloceanspaces.com
```

Retaining pipeline artifacts lets you replay a pipeline run from a known-good checkpoint if a downstream indexing step fails.

## Monitoring Pipeline Health

Track these metrics per pipeline run:

| Metric | Why it matters |
|---|---|
| Documents processed | Confirms the ingestion stage ran correctly |
| Documents re-embedded | Quantifies change volume; a sudden spike may indicate upstream data issues |
| Embedding API latency | Alerts on Inference Engine degradation |
| Index lag (minutes since last update) | The key freshness SLI for your RAG system |

For CronJob and workload configuration on DOKS, see the [DigitalOcean Kubernetes docs](https://docs.digitalocean.com/products/kubernetes/).
