---
type: "page"
id: "managed-postgresql-and-pgvector"
title: "Managed PostgreSQL & pgvector"
description: "Enable the pgvector extension on Managed PostgreSQL, create a vector column with an index, and run a similarity search query."
weight: 2
---

## pgvector on Managed PostgreSQL

DigitalOcean Managed PostgreSQL supports the `pgvector` extension, which adds a native vector data type and similarity search operators to PostgreSQL. This means you can store text embeddings alongside your relational data in the same database your application already uses — no separate vector store to operate.

## Enable the Extension

Connect to your Managed PostgreSQL cluster as the `doadmin` user and enable the extension:

```sql
CREATE EXTENSION IF NOT EXISTS vector;
```

Verify installation:

```sql
SELECT extname, extversion FROM pg_extension WHERE extname = 'vector';
```

## Create a Table with a Vector Column

Store document chunks and their embeddings together:

```sql
CREATE TABLE documents (
    id          BIGSERIAL PRIMARY KEY,
    content     TEXT        NOT NULL,
    source      TEXT,
    created_at  TIMESTAMPTZ DEFAULT NOW(),
    embedding   VECTOR(1536)   -- dimension must match your embedding model
);
```

The dimension (1536 in this example) must match the output dimension of the embedding model you use. For `text-embedding-3-small` from OpenAI this is 1536; adjust for other models.

## Insert Embeddings

Generate embeddings with the DigitalOcean Inference Engine (or any compatible endpoint) and insert them:

```python
import psycopg2
from openai import OpenAI

embed_client = OpenAI(
    base_url="https://inference.do-ai.run/v1",
    api_key="<model-access-key>",
)

conn = psycopg2.connect("<managed-postgres-connection-string>")
cur = conn.cursor()

def upsert_document(content: str, source: str):
    resp = embed_client.embeddings.create(
        model="text-embedding-3-small",
        input=content,
    )
    vector = resp.data[0].embedding   # list of 1536 floats
    cur.execute(
        "INSERT INTO documents (content, source, embedding) VALUES (%s, %s, %s)",
        (content, source, vector),
    )
    conn.commit()
```

## Create a Vector Index

Without an index, similarity search performs a sequential scan — fine for thousands of rows, slow for millions. Create an IVFFlat index for approximate nearest-neighbor search:

```sql
CREATE INDEX ON documents
USING ivfflat (embedding vector_cosine_ops)
WITH (lists = 100);
```

Use `vector_cosine_ops` for cosine similarity (most embedding models) or `vector_l2_ops` for Euclidean distance. The `lists` parameter should be roughly `sqrt(row_count)` as a starting point.

## Run a Similarity Query

Find the five most relevant documents to a query:

```sql
SELECT
    id,
    content,
    1 - (embedding <=> '[0.021, -0.003, ...]'::vector) AS cosine_similarity
FROM documents
ORDER BY embedding <=> '[0.021, -0.003, ...]'::vector
LIMIT 5;
```

The `<=>` operator computes cosine distance; subtract from 1 to get similarity. Replace the literal vector with a parameter when calling from application code:

```python
def find_similar(query_embedding: list[float], k: int = 5):
    cur.execute(
        """
        SELECT id, content,
               1 - (embedding <=> %s::vector) AS score
        FROM documents
        ORDER BY embedding <=> %s::vector
        LIMIT %s
        """,
        (query_embedding, query_embedding, k),
    )
    return cur.fetchall()
```

## When to Use pgvector vs a Dedicated Vector DB

pgvector is the right choice when your embedding count is in the low millions and you want to avoid operating another service. For hundreds of millions of vectors, high-QPS ANN workloads, or advanced filtering at the vector layer, a dedicated vector database running on DOKS is the better option (covered in the next lesson).

For connection string formats and cluster configuration, see the [DigitalOcean Managed PostgreSQL docs](https://docs.digitalocean.com/products/databases/postgresql/).
