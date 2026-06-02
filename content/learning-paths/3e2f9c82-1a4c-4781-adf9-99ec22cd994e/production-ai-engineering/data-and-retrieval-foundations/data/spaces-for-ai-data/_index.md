---
type: "page"
id: "spaces-for-ai-data"
title: "Spaces for AI Data"
description: "Store datasets, embeddings, and model artifacts in DigitalOcean Spaces using the S3-compatible API."
weight: 1
---

## Why Object Storage for AI Workloads

AI systems produce and consume large binary artifacts: training datasets, pre-computed embedding files, fine-tuned model weights, evaluation result archives, and RAG document corpora. Relational databases are the wrong tool for these objects — they are large, write-once, and accessed by path rather than by query. DigitalOcean Spaces provides S3-compatible object storage that integrates with every major ML toolchain.

## Spaces S3 Compatibility

Spaces speaks the S3 API, which means any tool that works with Amazon S3 works with Spaces unchanged — you only update the endpoint URL and credentials.

| Tool | Spaces endpoint |
|---|---|
| `s3cmd` | `--host=nyc3.digitaloceanspaces.com` |
| AWS CLI (`aws s3`) | `--endpoint-url https://nyc3.digitaloceanspaces.com` |
| Python `boto3` | `endpoint_url="https://nyc3.digitaloceanspaces.com"` |

Replace `nyc3` with the region where your Space lives.

## Creating and Configuring a Bucket

```bash
# Create a Space with s3cmd
s3cmd mb s3://my-ai-datasets \
  --host=nyc3.digitaloceanspaces.com \
  --host-bucket="%(bucket)s.nyc3.digitaloceanspaces.com"
```

For programmatic access, create a Spaces access key in the DigitalOcean control panel and store it as an environment variable — never hardcode it in source files.

## Uploading AI Artifacts

```bash
# Upload a dataset file
s3cmd put ./training_data.jsonl s3://my-ai-datasets/datasets/training_data.jsonl \
  --host=nyc3.digitaloceanspaces.com

# Sync an entire embeddings directory
aws s3 sync ./embeddings/ s3://my-ai-datasets/embeddings/ \
  --endpoint-url https://nyc3.digitaloceanspaces.com
```

## Reading Artifacts in Python

Use `boto3` to download files at the start of a training or inference job:

```python
import boto3

session = boto3.session.Session()
client = session.client(
    "s3",
    region_name="nyc3",
    endpoint_url="https://nyc3.digitaloceanspaces.com",
    aws_access_key_id="<spaces-key>",
    aws_secret_access_key="<spaces-secret>",
)

# Download embeddings file
client.download_file(
    Bucket="my-ai-datasets",
    Key="embeddings/corpus_v3.npy",
    Filename="/tmp/corpus_v3.npy",
)
```

## Organizing AI Artifacts

Use a consistent prefix (pseudo-folder) scheme to keep artifacts navigable:

```
my-ai-datasets/
  datasets/          raw and processed training data
  embeddings/        pre-computed vector files
  models/            fine-tuned weights and GGUF exports
  evaluations/       evaluation result JSON archives
  pipelines/         intermediate pipeline outputs
```

Versioning by date or semantic version in the prefix (e.g. `embeddings/2026-06-01/`) makes it easy to roll back to a previous artifact set.

## Access Control

Grant minimal permissions. A data-ingestion job needs `s3:PutObject` on the `datasets/` prefix only. An inference service that reads embeddings needs `s3:GetObject` on `embeddings/` only. Use separate Spaces access key pairs for each role so that a compromised key has limited blast radius.

For full Spaces documentation including CDN, lifecycle policies, and CORS settings, see the [DigitalOcean Spaces docs](https://docs.digitalocean.com/products/spaces/).
