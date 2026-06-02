---
type: "page"
id: "creating-a-knowledge-base"
title: "Creating a Knowledge Base"
description: "Create a Gradient knowledge base, select an embedding model, and index your content using the Control Panel and the API."
weight: 2
---

## Overview

A knowledge base on the Gradient AI Platform is a managed vector store. You provide the content; the platform handles embedding, indexing, and similarity search at query time. This lesson covers creating a knowledge base from scratch using both the Control Panel and the API.

## Prerequisites

- A DigitalOcean account with access to the Gradient AI Platform.
- Content ready to index: PDFs, text files, a Spaces bucket, or a URL to crawl.
- An agent to attach the knowledge base to (can be done after creation).

## Creating a Knowledge Base in the Control Panel

1. In the [Gradient AI Platform](https://cloud.digitalocean.com/gen-ai), select **Knowledge Bases** from the left navigation.
2. Click **Create Knowledge Base**.
3. Provide a **name** (e.g., `support-docs-kb`).
4. Select an **embedding model**. The embedding model converts your text into vectors. Choose a model appropriate for your document language and required precision. The model cannot be changed after the knowledge base is created.
5. Select a **data source**: uploaded files, a Spaces folder, a URL for web crawling, or a cloud storage connector.
6. Click **Create**. The platform begins indexing immediately.

## Creating a Knowledge Base via the API

```bash
curl -X POST https://api.digitalocean.com/v2/gen-ai/knowledge_bases \
  -H "Authorization: Bearer $DIGITALOCEAN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "support-docs-kb",
    "embedding_model_uuid": "<embedding-model-uuid>",
    "datasource": {
      "type": "file_upload"
    }
  }'
```

The response includes a `uuid` for the knowledge base. Use that UUID in subsequent calls to upload files and attach the knowledge base to agents. Check the [Gradient API reference](https://docs.digitalocean.com/products/gradient-ai-platform/) for current endpoint paths and available embedding model UUIDs.

## Choosing an Embedding Model

The embedding model encodes the semantic meaning of your documents. Key considerations:

| Factor | Guidance |
|--------|----------|
| Language | Prefer a multilingual model if documents are not in English |
| Dimension count | Higher dimensions capture more nuance but cost more to store and search |
| Model family | Match the model to the domain — general-purpose models work well for most use cases |
| Consistency | Never mix embedding models within a single knowledge base |

You cannot change the embedding model after a knowledge base is created. If you need a different model, create a new knowledge base and re-index.

## Indexing Content

After creation, content moves through these stages:

```
Uploaded / fetched
       ↓
Parsed and cleaned (OCR for scanned PDFs, layout extraction for tables)
       ↓
Split into chunks
       ↓
Embedded (each chunk → vector)
       ↓
Stored in vector index
       ↓
Status: Ready
```

The Control Panel shows indexing progress. For large document sets, indexing may take several minutes. GPU-accelerated OCR is used for scanned documents and PDFs with complex layouts, which enables accurate extraction of text from tables and figures.

## Re-indexing

When your source documents change, trigger a re-index to update the vector store. Re-indexing fetches the latest content from the data source and rebuilds the affected chunks. You can re-index on demand from the Control Panel or via API.

## Verifying the Index

After indexing completes, test retrieval quality by attaching the knowledge base to an agent in the playground and asking questions that should match your documents. If expected content is not retrieved, inspect:

- Whether the document was successfully ingested (check the datasource status).
- Whether chunk size is appropriate for the document type.
- Whether the query phrasing matches the document vocabulary.

Learn more in the [knowledge-base documentation](https://docs.digitalocean.com/products/gradient-ai-platform/how-to/create-manage-agent-knowledge-bases/).
