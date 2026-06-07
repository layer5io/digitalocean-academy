---
type: "page"
id: "compliance-and-audit-trails"
title: "Compliance & Audit Trails"
description: "Implement logging, audit trails, and data residency controls for AI services that must meet regulatory requirements."
weight: 4
---

## Why Audit Trails Matter for AI

AI systems make decisions that affect users, and those decisions must be explainable, reproducible, and traceable. Regulatory frameworks including GDPR, HIPAA, and SOC 2 require organizations to demonstrate who had access to data, what operations were performed, and when. For AI services this means capturing not just web server access logs, but the full request-response lifecycle at the inference layer.

## What to Log

A complete audit record for an inference call includes:

| Field | Description |
|---|---|
| `timestamp` | UTC timestamp of the request |
| `request_id` | Unique ID assigned to this call |
| `user_id` (hashed) | Anonymized identifier of the initiating user |
| `model` | Exact model ID returned by the Inference Engine |
| `prompt_tokens` | Input token count |
| `completion_tokens` | Output token count |
| `latency_ms` | End-to-end response time |
| `guardrail_triggered` | Whether a guardrail blocked or modified the response |
| `policy_applied` | Inference Router policy that selected the model |
| `source_ip` | Originating IP (store hashed if privacy-sensitive) |

Do not log raw prompt or response text unless your compliance policy explicitly requires it and you have appropriate encryption and access controls in place for that data.

## Structured Logging

Use structured (JSON) log output so logs are machine-queryable from day one:

```python
import json
import time
import logging

logger = logging.getLogger(__name__)

def log_inference_event(request_id, user_hash, model, usage, latency_ms):
    event = {
        "event": "inference_call",
        "request_id": request_id,
        "user_id_hash": user_hash,
        "model": model,
        "prompt_tokens": usage.prompt_tokens,
        "completion_tokens": usage.completion_tokens,
        "latency_ms": latency_ms,
        "timestamp": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
    }
    logger.info(json.dumps(event))
```

Ship these logs to a centralized log store — Managed PostgreSQL, an S3-compatible archive in Spaces, or a hosted logging service — with retention aligned to your compliance requirements (often 1–7 years).

## DigitalOcean Audit Logs

The DigitalOcean control panel generates audit events for every account-level action: key creation, key deletion, cluster resize, firewall rule change. Enable audit log export and review it regularly for unexpected activity. Control-plane audit logs are separate from application-level inference logs and together form a complete record.

## Data Residency

For workloads subject to data residency requirements (e.g., GDPR data must not leave the EU), choose a DigitalOcean region in the required geography for:

- Your DOKS cluster.
- Your Managed PostgreSQL cluster.
- Your Spaces bucket.
- Your Inference Engine project (confirm region availability in the control panel).

Document the region selection in your compliance artifacts. Verify that no intermediate processing steps route data through out-of-region services.

## Access Control for Audit Logs

Audit logs are sensitive. Restrict read access to security and compliance personnel:

```bash
# Grant read-only access to the audit logs bucket to a specific team member
s3cmd setacl s3://my-ai-audit-logs \
  --acl-grant=read:<canonical-user-id> \
  --host=nyc3.digitaloceanspaces.com
```

Enable immutability (object lock) on the audit log bucket so that logs cannot be modified or deleted before the retention period expires — a common requirement for compliance frameworks that require tamper-evident logs.

## Incident Response Readiness

Log enough context that you can answer these questions from logs alone after an incident:

- Which user triggered this inference call?
- What model and policy were applied?
- Was any guardrail triggered?
- What was the approximate cost of the call?

Runbooks for your incident response process should specify exactly how to query the log store to answer each question.

For Spaces object lock and data retention options, see the [DigitalOcean Spaces docs](https://docs.digitalocean.com/products/spaces/).
