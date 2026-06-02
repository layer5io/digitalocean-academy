---
type: "page"
id: "pii-handling-and-guardrails"
title: "PII Handling & Guardrails"
description: "Detect and redact personally identifiable information in prompts and responses, and configure Inference Engine guardrails at the edge."
weight: 3
---

## The PII Risk Surface in AI Applications

AI applications introduce new PII risk vectors that traditional security tools do not cover. Users paste email addresses, phone numbers, and account numbers into chat inputs. RAG systems retrieve documents that contain customer records. Models occasionally reproduce training-time PII in their outputs. Addressing PII requires controls at multiple layers: before the prompt reaches the model, in the model's response, and in your stored logs.

## Guardrails at the Inference Edge

The DigitalOcean Model Catalog includes built-in Guardrails that operate at the Inference Engine level — they intercept requests and responses before and after the model call. Guardrails can:

- Detect and block prompts containing PII patterns (credit card numbers, SSNs, email addresses).
- Redact PII from model responses before they are returned to the client.
- Block unsafe or off-topic content categories (hate speech, violence, jailbreaks).
- Enforce safety thresholds configurable per model and per application.

Configure guardrails in your Inference Engine project settings via the DigitalOcean control panel. When a guardrail triggers, the API returns a structured rejection response rather than the model output, so your application can handle it gracefully.

## Application-Layer PII Detection

For cases where you need custom detection logic or want to redact PII before it reaches the model at all, add a pre-processing step in your application:

```python
import re

# Simple regex-based PII detector for common patterns
PII_PATTERNS = {
    "email":       r"[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z]{2,}",
    "phone_us":    r"\b(?:\+1[\s.-]?)?\(?\d{3}\)?[\s.-]?\d{3}[\s.-]?\d{4}\b",
    "ssn":         r"\b\d{3}-\d{2}-\d{4}\b",
    "credit_card": r"\b(?:\d[ -]?){13,16}\b",
}

def redact_pii(text: str) -> str:
    for label, pattern in PII_PATTERNS.items():
        text = re.sub(pattern, f"[REDACTED_{label.upper()}]", text)
    return text

# Apply before sending to the model
safe_prompt = redact_pii(user_input)
```

For production use, consider a dedicated NLP-based PII library (e.g., `presidio` from Microsoft) that handles more complex patterns and supports multiple languages.

## Redacting PII from RAG Context

When your RAG pipeline retrieves documents to include as context, scan the retrieved chunks for PII before injecting them into the prompt:

```python
def build_rag_prompt(query: str, retrieved_chunks: list[str]) -> str:
    safe_chunks = [redact_pii(chunk) for chunk in retrieved_chunks]
    context = "\n\n".join(safe_chunks)
    return f"Context:\n{context}\n\nQuestion: {query}"
```

## Logging Without Storing PII

Logs are a common source of PII leakage. Hash or redact user identifiers before writing to log storage:

```python
import hashlib

def anonymize_user_id(user_id: str) -> str:
    return hashlib.sha256(user_id.encode()).hexdigest()[:12]

# Log the anonymized ID, not the raw value
logger.info("inference_call user_id=%s tokens=%d",
            anonymize_user_id(user_id), total_tokens)
```

## Guardrails as a Policy Layer

| Concern | Layer | Mechanism |
|---|---|---|
| Unsafe user input | Edge | Inference Engine Guardrails |
| PII in user input | App | Pre-processing redaction |
| PII in retrieved context | App | RAG chunk redaction |
| PII in model output | Edge | Inference Engine Guardrails |
| PII in logs | App | Log anonymization |

Defense in depth applies to PII just as it applies to network security. No single layer catches everything; the combination of edge guardrails and application-layer controls provides robust protection.

For Guardrails configuration and safety policy options, see the [DigitalOcean Gradient AI Platform docs](https://docs.digitalocean.com/products/gradient-ai-platform/).
