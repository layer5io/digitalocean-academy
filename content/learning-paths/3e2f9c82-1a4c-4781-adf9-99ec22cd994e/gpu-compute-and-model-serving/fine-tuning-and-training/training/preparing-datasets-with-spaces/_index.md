---
type: "page"
id: "preparing-datasets-with-spaces"
title: "Preparing Datasets with Spaces"
description: "Format a fine-tuning dataset as JSONL, upload it to DigitalOcean Spaces using the S3-compatible API, and version your data for reproducible training runs."
weight: 2
---

## Dataset Format for Fine-Tuning

Most Hugging Face PEFT and transformers training pipelines consume datasets in **JSONL** (JSON Lines) format—one JSON object per line. For instruction fine-tuning, the standard schema is the prompt-completion pair or the messages array:

**Prompt-completion format:**

```json
{"prompt": "Translate to French: Hello, world!", "completion": "Bonjour, monde!"}
{"prompt": "Summarize: The Eiffel Tower was built in 1889.", "completion": "The Eiffel Tower dates to 1889."}
```

**Chat / messages format (preferred for instruction-tuned models):**

```json
{"messages": [{"role": "user", "content": "What is the boiling point of water?"}, {"role": "assistant", "content": "100°C at standard pressure."}]}
{"messages": [{"role": "system", "content": "You are a chemistry tutor."}, {"role": "user", "content": "Define molarity."}, {"role": "assistant", "content": "Molarity is moles of solute per liter of solution."}]}
```

Validate your JSONL file before uploading:

```bash
python -c "
import json, sys
with open('train.jsonl') as f:
    for i, line in enumerate(f, 1):
        try:
            json.loads(line)
        except json.JSONDecodeError as e:
            print(f'Line {i}: {e}')
            sys.exit(1)
print('All lines valid.')
"
```

## DigitalOcean Spaces Overview

Spaces is DigitalOcean's object storage service. It is S3-compatible, meaning any tool that speaks the S3 API—`aws` CLI, `s3cmd`, Python `boto3`—works with Spaces by changing the endpoint URL.

Create a Space in the Control Panel (choose the region closest to your GPU Droplet to minimize data transfer latency) and generate a Spaces Access Key under **API > Spaces Keys**.

## Uploading with the AWS CLI

The `aws` CLI is convenient because it supports sync and multipart uploads for large files:

```bash
pip install awscli

aws configure set aws_access_key_id     <spaces-access-key>
aws configure set aws_secret_access_key <spaces-secret-key>

# Upload the dataset
aws s3 cp train.jsonl \
  s3://my-training-bucket/datasets/v1/train.jsonl \
  --endpoint-url https://nyc3.digitaloceanspaces.com

# Sync an entire directory
aws s3 sync ./datasets/ \
  s3://my-training-bucket/datasets/v1/ \
  --endpoint-url https://nyc3.digitaloceanspaces.com
```

## Uploading with s3cmd

```bash
pip install s3cmd

s3cmd --access_key=<key> --secret_key=<secret> \
  --host=nyc3.digitaloceanspaces.com \
  --host-bucket="%(bucket)s.nyc3.digitaloceanspaces.com" \
  put train.jsonl s3://my-training-bucket/datasets/v1/train.jsonl
```

## Versioning Your Datasets

Object storage has no native versioning like git, but you can establish a convention with path prefixes. A simple scheme:

```
s3://my-training-bucket/
  datasets/
    v1/train.jsonl
    v2/train.jsonl          # added 500 more examples
    v2/eval.jsonl
  checkpoints/
    run-20260101/adapter_model.bin
```

Pair dataset versions with a metadata file:

```json
{"version": "v2", "num_examples": 12500, "created": "2026-01-01", "notes": "Added legal domain examples"}
```

Store the metadata file alongside the dataset so any training run can record exactly which version it used.

## Downloading to a GPU Droplet at Training Time

On the GPU Droplet, download the dataset to the scratch disk before training:

```bash
aws s3 cp \
  s3://my-training-bucket/datasets/v2/train.jsonl \
  /scratch/datasets/train.jsonl \
  --endpoint-url https://nyc3.digitaloceanspaces.com
```

For Spaces documentation and region endpoints, see the [GPU Droplets documentation](https://docs.digitalocean.com/products/gpu-droplets/).
