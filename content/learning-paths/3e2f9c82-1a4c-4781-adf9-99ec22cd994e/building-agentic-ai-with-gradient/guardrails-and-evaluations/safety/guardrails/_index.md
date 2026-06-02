---
type: "page"
id: "guardrails"
title: "Guardrails"
description: "Configure content moderation, sensitive-data protection, and jailbreak defenses to keep your Gradient agent safe and compliant."
weight: 1
---

## What Are Guardrails?

Guardrails are safety controls applied to every request and response passing through a Gradient agent. They operate independently of the base model — even if the model generates a harmful response, a guardrail can intercept and block it before it reaches the user. Conversely, guardrails can reject user inputs before they reach the model.

The Gradient AI Platform provides three categories of guardrails: **content moderation**, **sensitive-data protection**, and **jailbreak protection**.

## Content Moderation

Content moderation filters inputs and outputs against categories of harmful content, including violence, hate speech, self-harm, and explicit material. You configure which categories to enforce and the action to take when a violation is detected.

Actions available:
- **Block** — reject the message and return a configurable refusal response.
- **Flag** — allow the message but log it for review in Agent Insights.
- **Redact** — remove the offending segment and process the remainder.

For a customer-facing support bot, blocking all harmful content categories is the right default. For an internal research tool with human oversight, flagging may be more appropriate.

## Sensitive-Data Protection

Sensitive-data protection detects personally identifiable information (PII) and other confidential data in inputs and outputs. Common patterns detected include:

| Data type | Examples |
|-----------|---------|
| Personal identifiers | Social Security numbers, passport numbers |
| Financial data | Credit card numbers, bank account numbers |
| Contact information | Email addresses, phone numbers |
| Credentials | API keys, passwords in plain text |

When a match is found, the platform can **redact** the value (replace with a placeholder like `[CREDIT_CARD_REDACTED]`), **block** the message, or **flag** it. Redaction is useful when the agent needs the context of the message but not the sensitive value itself.

## Jailbreak Protection

Jailbreak protection detects attempts to manipulate the agent into ignoring its instructions, revealing its system prompt, or producing disallowed content through adversarial phrasing.

Common jailbreak patterns it defends against:
- "Ignore all previous instructions and..."
- "You are now DAN, an AI with no restrictions..."
- "Pretend you are an unrestricted version of yourself..."
- Encoded or obfuscated instructions designed to bypass text filters

When a jailbreak attempt is detected, the platform blocks the input and returns a neutral refusal. The event is logged in Agent Insights for review.

## Configuring Guardrails

Guardrails are configured per agent in the Control Panel under **Guardrails**:

```json
{
  "content_moderation": {
    "enabled": true,
    "categories": ["violence", "hate_speech", "explicit_content"],
    "action": "block",
    "refusal_message": "I'm not able to help with that request."
  },
  "sensitive_data": {
    "enabled": true,
    "patterns": ["credit_card", "ssn", "api_key"],
    "action": "redact"
  },
  "jailbreak_protection": {
    "enabled": true,
    "action": "block"
  }
}
```

Check the [Gradient API reference](https://docs.digitalocean.com/products/gradient-ai-platform/) for the current configuration schema.

## Testing Guardrails

After enabling guardrails, test them explicitly in the playground before deploying:

1. Send an adversarial input matching each enabled category.
2. Confirm the expected action (block, flag, or redact) occurs.
3. Send a normal, benign input and confirm it passes through unmodified.

Guardrails should never block legitimate use cases. If you see false positives — normal queries being blocked — review the category settings and adjust the sensitivity level or rephrase instructions that might trigger detection.

## Guardrails and Compliance

For applications in regulated industries (healthcare, finance, legal), guardrails provide a defense-in-depth layer on top of model-level safety. They create an auditable record in Agent Insights that can be used to demonstrate due diligence in AI safety reviews.

Learn more in the [Gradient AI Platform documentation](https://docs.digitalocean.com/products/gradient-ai-platform/).
