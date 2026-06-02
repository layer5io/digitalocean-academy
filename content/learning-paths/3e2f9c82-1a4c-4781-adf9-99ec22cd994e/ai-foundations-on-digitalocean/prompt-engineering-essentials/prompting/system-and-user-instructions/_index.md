---
type: "page"
id: "system-and-user-instructions"
title: "System & User Instructions"
description: "Understand the roles of system and user messages, how to structure effective instructions, and why role design matters for model behavior."
weight: 1
---

## Overview

Every chat completion request is built from a sequence of **messages**, each with a role. Getting the roles right is the single most important prompt engineering skill — it directly determines how the model interprets its task, its persona, and its constraints.

## The Three Roles

| Role | Who It Represents | Typical Content |
|---|---|---|
| `system` | The application developer | Persona, rules, scope, format requirements |
| `user` | The end user | Questions, requests, inputs |
| `assistant` | The model's prior responses | Previous turns (used to maintain history) |

The `system` message is processed before the conversation begins. Models are trained to treat it as authoritative — it is the operator layer, above the user. Use it to set invariants that the user should not be able to override.

## Structuring System Instructions

A well-structured system message has four components:

1. **Persona** — who the assistant is
2. **Scope** — what it should and should not do
3. **Format rules** — how it should structure responses
4. **Fallback behavior** — what to do when uncertain

Example:

```
You are Milo, a technical support assistant for CloudCo.

Scope:
- Answer questions about CloudCo's Droplet, Managed Database, and Networking products only.
- Do not answer questions about competitors, pricing beyond what is in the knowledge base, or legal matters.

Format:
- Use plain prose. Do not use markdown headers.
- Keep responses under 120 words unless the user explicitly asks for detail.

Fallback:
- If you do not know the answer, say "I'm not sure — please contact support@cloudco.example."
```

Separate concerns with whitespace or short headers inside the system prompt. This makes the prompt easier to maintain and helps the model parse distinct rules.

## User Messages

The `user` message contains the end user's input. You rarely control its format in a real application, but in automated pipelines you do. When constructing user messages programmatically:

- Put dynamic data (retrieved context, user-provided values) in the user message, not in the system message. Mixing variable content into the system message makes caching harder and the prompt harder to reason about.
- Clearly delimit injected content with XML-style tags or triple-backtick blocks so the model knows where user input ends and your injected data begins.

```python
user_message = f"""Answer based on the following excerpt:

<excerpt>
{retrieved_chunk}
</excerpt>

User question: {user_question}
"""
```

## Assistant Messages for History

Append previous responses as `assistant` messages to give the model conversation context:

```python
messages = [
    {"role": "system", "content": system_prompt},
    {"role": "user", "content": "What is object storage?"},
    {"role": "assistant", "content": "Object storage is a data storage architecture..."},
    {"role": "user", "content": "How does it differ from a file system?"},
]
```

The model uses this history to maintain coherence. Keep history trimmed: once the conversation exceeds roughly 80% of the model's context window, remove the oldest turns (but always keep the system message).

## Common Mistakes

- **Putting rules in the user message** — the model treats user messages as lower-trust than system messages.
- **Vague persona definitions** — "be helpful" gives the model no guidance; "you are a billing specialist who only discusses invoices and payment methods" does.
- **Overloading the system message** — if your system message exceeds 500 words, break it into sections with clear headers and consider whether some rules belong in the knowledge base instead.

For API reference, see [docs.digitalocean.com/products/gradient-ai-platform/](https://docs.digitalocean.com/products/gradient-ai-platform/).
