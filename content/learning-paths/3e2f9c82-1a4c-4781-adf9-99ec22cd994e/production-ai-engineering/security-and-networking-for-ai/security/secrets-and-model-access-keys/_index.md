---
type: "page"
id: "secrets-and-model-access-keys"
title: "Secrets & Model Access Keys"
description: "Manage model access keys and application secrets with least-privilege controls and automated rotation."
weight: 2
---

## Why Key Management Is Critical for AI Services

AI services accumulate credentials quickly: model access keys for the Inference Engine, Spaces access key pairs, database connection strings, and third-party API keys. A single leaked credential can result in unauthorized model usage, data exfiltration, or unexpected billing charges. Treating key management as a first-class concern from day one is far cheaper than remediating a breach.

## Model Access Keys

DigitalOcean model access keys authenticate calls to the Inference Engine. They are distinct from your personal API token and can be scoped to specific models or namespaces, enabling least-privilege access.

**Least-privilege principle**: create a separate model access key for each service or environment. A staging service key should not be able to invoke production models, and vice versa.

```bash
# Create a model access key via the DigitalOcean CLI
doctl ai model-access-key create \
  --name "inference-service-prod" \
  --scope "inference:read,inference:write"
```

Store the key value immediately — it is only shown once.

## Storing Secrets Securely

Never store secrets in:
- Source code or configuration files committed to git
- Docker images or container environment variables set in `Dockerfile`
- Log output or error messages

**In Kubernetes (DOKS)**: use Kubernetes Secrets and mount them as environment variables:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: inference-credentials
  namespace: production
type: Opaque
stringData:
  MODEL_ACCESS_KEY: "<your-key>"
  SPACES_SECRET: "<spaces-secret>"
```

Reference the secret in your Deployment:

```yaml
envFrom:
  - secretRef:
      name: inference-credentials
```

For production clusters, consider Sealed Secrets or a secrets manager (e.g., HashiCorp Vault, Doppler) that integrates with DOKS to avoid storing raw secret values in source control.

## Accessing Keys in Application Code

Read credentials from the environment, never from code:

```python
import os
from openai import OpenAI

client = OpenAI(
    base_url="https://inference.do-ai.run/v1",
    api_key=os.environ["MODEL_ACCESS_KEY"],  # injected by Kubernetes Secret
)
```

## Key Rotation

Rotate model access keys and Spaces keys on a schedule or immediately after a suspected exposure:

1. Create a new key with the same scope as the key being rotated.
2. Deploy the new key to all services (update the Kubernetes Secret; trigger a rolling restart if needed).
3. Verify all services are healthy using the new key.
4. Revoke the old key.

```bash
# Step 1: create replacement key
doctl ai model-access-key create --name "inference-service-prod-v2" --scope "inference:read,inference:write"

# Step 4: revoke old key (after confirming new key works)
doctl ai model-access-key delete <old-key-id>
```

Zero-downtime rotation is possible because you create the new key before revoking the old one.

## Auditing Key Usage

Enable audit logging on the DigitalOcean control panel to record which key made which API call and when. Set up billing alerts to detect unusual inference spend that may indicate a compromised key being used.

Key metadata to track:

| Field | Purpose |
|---|---|
| Key name | Identifies the owning service |
| Created date | Triggers rotation schedule |
| Last used | Detects dormant (or active but unexpected) keys |
| Associated budget | Caps blast radius of a leaked key |

For key management and the Inference Engine security model, see the [DigitalOcean Gradient AI Platform docs](https://docs.digitalocean.com/products/gradient-ai-platform/).
