---
type: "page"
id: "vector-databases-on-doks"
title: "Vector Databases on DOKS"
description: "Run Qdrant, Weaviate, or Milvus on DigitalOcean Kubernetes Service using Meshery Designs, and know when to choose a dedicated vector database."
weight: 3
---

## When a Dedicated Vector Database Makes Sense

`pgvector` on Managed PostgreSQL covers most RAG use cases up to tens of millions of vectors. Beyond that — or when you need advanced hybrid search, built-in reranking, multi-tenancy at the vector layer, or specialized filtering — a purpose-built vector database is the right tool. DigitalOcean Kubernetes Service (DOKS) provides the compute substrate, and Meshery provides the GitOps deployment workflow.

## Options: Qdrant, Weaviate, Milvus

| Database | Key strengths | Typical use case |
|---|---|---|
| **Qdrant** | Low memory footprint, fast filtered ANN, easy Helm install | Production RAG, semantic search at scale |
| **Weaviate** | Built-in vectorization modules, GraphQL API, multi-modal | Knowledge graphs, semantic + keyword hybrid search |
| **Milvus** | High scalability, distributed architecture, GPU support | Billion-vector workloads, large-scale similarity search |

All three are open-source with production-ready Helm charts.

## Deploying with Meshery

Meshery manages infrastructure Designs — version-controlled blueprints of Kubernetes resources. Instead of running `kubectl apply` commands by hand, you encode your vector database deployment as a Meshery Design and apply it from CI or the Meshery UI.

**Step 1: Install Meshery CLI**

```bash
curl -L https://meshery.io/install | bash
mesheryctl system start
```

**Step 2: Create a Design for Qdrant**

```yaml
# qdrant-design.yaml (Meshery Design format)
name: qdrant-production
services:
  qdrant:
    type: HelmChart
    namespace: vector-db
    settings:
      chart: qdrant/qdrant
      version: "0.8.4"
      values:
        replicaCount: 3
        persistence:
          size: 100Gi
        resources:
          requests:
            memory: "4Gi"
            cpu: "1"
```

**Step 3: Apply the Design to DOKS**

```bash
mesheryctl design apply -f qdrant-design.yaml \
  --context my-doks-cluster
```

Meshery validates the Design, resolves dependencies, and applies it to the target cluster. The Design is stored in source control, making every change auditable and reversible.

## Connecting Your Application

Once Qdrant is running on DOKS, connect from your application using the official client:

```python
from qdrant_client import QdrantClient

client = QdrantClient(
    host="qdrant.vector-db.svc.cluster.local",
    port=6333,
)

# Insert vectors
client.upsert(
    collection_name="documents",
    points=[
        {"id": 1, "vector": embedding, "payload": {"content": text}},
    ],
)

# Search
results = client.search(
    collection_name="documents",
    query_vector=query_embedding,
    limit=5,
)
```

## Network Isolation

Run the vector database in a dedicated namespace and restrict access using Kubernetes NetworkPolicies so only your inference service pods can reach the vector DB port. Place both the DOKS cluster and your inference services within the same DigitalOcean VPC to keep traffic off the public internet.

## Persistent Storage

Configure each vector database with a `PersistentVolumeClaim` backed by DigitalOcean Block Storage. This ensures vector data survives pod restarts and cluster node replacements.

For DOKS cluster setup and node sizing, see the [DigitalOcean Kubernetes docs](https://docs.digitalocean.com/products/kubernetes/). For Meshery Design reference, see the [Meshery docs](https://docs.meshery.io/).
