---
type: "page"
id: "designing-tool-schemas"
title: "Designing Tool Schemas"
description: "Write clear tool names, typed JSON schemas, and robust error contracts so agents route reliably and handle failures gracefully."
weight: 3
---

## Schema as the Contract Between Agent and Tool

A function route's schema is more than documentation — it is the contract the model uses to decide when and how to call the tool. A well-designed schema produces consistent, correct tool calls. A poorly designed schema produces missed calls, malformed arguments, and unexpected behavior.

Three elements require deliberate design: the **name**, the **description**, and the **input schema**.

## Naming

Tool names should be verb-noun pairs that unambiguously describe a single action.

| Good | Avoid |
|------|-------|
| `get_invoice_status` | `invoice` |
| `cancel_subscription` | `do_stuff` |
| `send_password_reset_email` | `handle_user_request` |
| `list_open_support_tickets` | `support` |

Names are case-sensitive and should use `snake_case`. They appear in logs and traces; descriptive names make debugging straightforward.

## Descriptions

The description is read by the model at inference time. It should answer: "When should I call this tool and what does it return?"

```json
{
  "name": "get_invoice_status",
  "description": "Returns the payment status, amount due, and due date for a specific invoice. Call this when a user asks about an unpaid, overdue, or recent invoice. Do not call this for questions about general billing policies."
}
```

Include:
- What the function does.
- When to call it (positive examples).
- When NOT to call it (negative constraints) — this reduces false positives.
- What the return value contains.

## Input Schema (JSON Schema)

Use standard JSON Schema to define inputs. Every property should have a `type` and a `description`.

```json
{
  "type": "object",
  "properties": {
    "invoice_id": {
      "type": "string",
      "description": "The invoice identifier, e.g. 'INV-2026-0042'. Found on any invoice document."
    },
    "customer_id": {
      "type": "string",
      "description": "The customer account UUID. Optional — use if invoice_id is unavailable."
    }
  },
  "required": ["invoice_id"]
}
```

Best practices:
- Mark only truly required fields as `required`. Optional fields give the model flexibility.
- Use `enum` for parameters with a fixed set of values to prevent free-form strings.
- Add `"format": "date"` or `"format": "uuid"` hints where applicable.
- Avoid deeply nested objects — flat schemas are easier for the model to populate correctly.

## Idempotency

Write-action tools (cancel, delete, send) should be idempotent where possible. If the agent calls the function twice due to a retry, the second call should produce the same result as the first rather than a duplicate action.

```python
# Idempotent cancellation — checks state before acting
def cancel_subscription(customer_id: str) -> dict:
    sub = db.get_subscription(customer_id)
    if sub["status"] == "cancelled":
        return {"already_cancelled": True, "cancelled_at": sub["cancelled_at"]}
    db.cancel(customer_id)
    return {"cancelled": True, "cancelled_at": datetime.utcnow().isoformat()}
```

## Error Handling

Functions must return structured errors that the model can understand and communicate to the user. Never let unhandled exceptions propagate as empty 500 responses.

```json
{
  "error": {
    "code": "INVOICE_NOT_FOUND",
    "message": "No invoice found with ID 'INV-9999'. Verify the invoice number and try again.",
    "recoverable": true
  }
}
```

Include a `recoverable` flag or equivalent signal so downstream logic can decide whether to retry or escalate to a human.

## Output Schema

Document what the function returns. This is not enforced by the platform but improves model behavior significantly — the model can refer to field names in its response and use values correctly.

```json
{
  "invoice_id": "INV-2026-0042",
  "status": "overdue",
  "amount_due_usd": 149.00,
  "due_date": "2026-05-15",
  "days_overdue": 18
}
```

Clear, flat output schemas produce more accurate agent responses than opaque nested structures.

Learn more in the [Gradient AI Platform documentation](https://docs.digitalocean.com/products/gradient-ai-platform/).
