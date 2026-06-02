---
type: "page"
id: "building-a-multi-agent-support-system"
title: "Building a Multi-Agent Support System"
description: "Worked example: build a triage router that delegates to billing, technical, and sales sub-agents, each with its own knowledge base."
weight: 3
---

## System Overview

This lesson walks through a realistic multi-agent support system with the following structure:

```
User
  ↓
triage_agent  (router)
  ├── billing_agent   (KB: billing-policies, function: get_invoice_status)
  ├── tech_agent      (KB: product-docs, function: get_service_status)
  └── sales_agent     (KB: pricing-guide, function: create_sales_lead)
```

Each sub-agent has a focused instruction set, a dedicated knowledge base, and one or two function routes. The triage agent holds no knowledge bases and calls no functions — it only classifies and routes.

## Step 1 — Create the Knowledge Bases

Create three knowledge bases in the Control Panel:

| KB name | Content |
|---------|---------|
| `billing-policies-kb` | Refund policy PDF, billing FAQ, subscription terms |
| `product-docs-kb` | API reference, troubleshooting guides, release notes |
| `pricing-guide-kb` | Plan comparison, add-on pricing, enterprise tiers |

Index each KB separately. Keep them non-overlapping — do not put the pricing guide in the product-docs KB.

## Step 2 — Create the Sub-Agents

**billing_agent**

```
Instructions: You are a billing support specialist. Answer questions about
invoices, charges, refunds, and subscription changes. Use the billing policies
knowledge base to ground your answers. Always cite the policy section.
Do not answer technical or sales questions.

Model: lightweight (billing queries are simple lookups)
Temperature: 0.1
Knowledge bases: billing-policies-kb
Function routes: get_invoice_status
```

**tech_agent**

```
Instructions: You are a technical support engineer. Diagnose and resolve
product errors, API issues, configuration problems, and outages. Use the
product documentation knowledge base. Provide step-by-step remediation.
Do not answer billing or sales questions.

Model: mid-size (technical reasoning requires more capability)
Temperature: 0.2
Knowledge bases: product-docs-kb
Function routes: get_service_status
```

**sales_agent**

```
Instructions: You are a sales consultant. Help users choose the right plan,
explain pricing, handle upgrade requests, and capture leads for the sales team.
Refer to the pricing guide. Be conversational and helpful.
Do not answer billing or technical questions.

Model: mid-size
Temperature: 0.4
Knowledge bases: pricing-guide-kb
Function routes: create_sales_lead
```

## Step 3 — Create the Router Agent

```
Instructions: You are a customer support triage agent. Route every incoming
request to the correct department. Do not answer questions yourself.

Departments:
- billing_agent: invoices, charges, refunds, payment methods, subscription changes.
- tech_agent: errors, API issues, outages, configuration, troubleshooting.
- sales_agent: pricing, plan selection, upgrades, new subscriptions, partnerships.

If the request does not match any department, reply:
"I can connect you with billing, technical support, or sales. Which do you need?"

Model: lightweight (classification only — no generation needed)
Temperature: 0.0
Agent routes: billing_agent, tech_agent, sales_agent
```

Setting temperature to 0.0 for the router maximizes routing determinism.

## Step 4 — Wire the Endpoint

Deploy the `triage_agent` endpoint. Client applications call this single endpoint; routing happens transparently.

```python
import openai

client = openai.OpenAI(
    base_url="https://<triage-agent-id>.agents.do-ai.run/api/v1",
    api_key="<agent-access-key>"
)

response = client.chat.completions.create(
    model="n/a",
    messages=[
        {"role": "user", "content": "I was charged twice for my Pro subscription."}
    ]
)
print(response.choices[0].message.content)
```

## Step 5 — Test the Full Path

Run these inputs against the triage endpoint and verify the route and response:

| Input | Expected route | Expected behavior |
|-------|---------------|-------------------|
| "Invoice #1042 shows two charges." | billing_agent | Calls `get_invoice_status`, cites billing policy |
| "The API is returning 503 errors." | tech_agent | Calls `get_service_status`, references product docs |
| "I want to upgrade from Starter to Pro." | sales_agent | Explains upgrade, captures lead if applicable |
| "What time does your office open?" | triage_agent | Out-of-scope response |

Use the Agent Insights dashboard to trace each request through the routing path and verify sub-agent selection.

Learn more in the [Gradient AI Platform documentation](https://docs.digitalocean.com/products/gradient-ai-platform/).
