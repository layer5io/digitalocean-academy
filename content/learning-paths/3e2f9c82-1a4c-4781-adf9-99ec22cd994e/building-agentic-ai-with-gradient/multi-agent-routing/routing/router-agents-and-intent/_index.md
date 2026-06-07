---
type: "page"
id: "router-agents-and-intent"
title: "Router Agents & Intent Classification"
description: "Build a router agent that classifies user intent and dispatches to the right specialized sub-agent reliably."
weight: 2
---

## The Router Agent's Job

A router agent has one primary responsibility: classify the user's intent and forward the conversation to the sub-agent best equipped to handle it. The router should not answer questions itself (except for generic greetings or out-of-scope deflections). Its value is precision in routing, not breadth of knowledge.

## Writing Effective Router Instructions

The router's system prompt should be explicit about its role and the available routes.

```
You are a routing agent. Your only job is to determine which department should
handle the user's request and delegate accordingly.

Available departments:
- billing_agent: invoices, payments, charges, refunds, subscription changes.
- tech_agent: product errors, outages, API issues, configuration problems.
- sales_agent: pricing questions, new subscriptions, upgrades, partnerships.

Rules:
1. Do not answer the user's question directly.
2. Route every request to exactly one department.
3. If the request is ambiguous, route to the department most likely to help.
4. If the request is completely out of scope, reply: "I can help with billing,
   technical support, and sales questions. How can I direct you?"
```

Explicit enumeration of routes and strict rules produce more consistent behavior than a generic "classify this" instruction.

## Intent Classification Strategies

### Keyword-anchored routing

For simple cases, agent-route descriptions that include domain-specific vocabulary act as an implicit classifier. The model matches words in the user message against descriptions.

### Few-shot examples in router instructions

For ambiguous domains, add examples directly to the router instructions:

```
Examples:
- "My card was charged twice" → billing_agent
- "The API returns a 503 error" → tech_agent
- "I want to upgrade to the Pro plan" → sales_agent
- "How do I reset my password?" → tech_agent (account security is a technical issue)
```

Examples anchor edge cases and override the model's default generalization.

### Confidence thresholds

Some applications require explicit confidence handling. Instruct the router to escalate low-confidence cases:

```
If you are not confident which department should handle the request, ask the user
one clarifying question before routing. Do not guess if the request could equally
belong to two departments.
```

## Testing the Router

Build a routing test matrix with queries spanning all sub-agent domains, boundary cases, and adversarial inputs:

```json
[
  {"input": "I was charged twice for the same invoice.", "expected_route": "billing_agent"},
  {"input": "The dashboard shows a 404 error.", "expected_route": "tech_agent"},
  {"input": "I'd like to add five more seats.", "expected_route": "sales_agent"},
  {"input": "What are your business hours?", "expected_route": "out_of_scope"},
  {"input": "My subscription renewal failed and now I can't log in.", "expected_route": "billing_agent"}
]
```

The last entry is a boundary case — it involves billing (failed renewal) and access (can't log in). Your routing decision for such cases should be documented and consistent.

Run every entry through the playground and record which route was selected. Aim for 95%+ accuracy on your defined test matrix before deploying the router to production.

## Handling Unrecognized Intent

Always define an out-of-scope response path. Without it, the router may attempt to answer questions it cannot handle well, or select a sub-agent arbitrarily. The out-of-scope path should:

- Acknowledge the user politely.
- State what the system can help with.
- Optionally offer a handoff to a human agent.

```
"I'm able to help with billing, technical support, and sales questions.
For anything else, please contact our team at support@example.com."
```

## Chained Routing

For complex workflows, a router can delegate to a sub-agent that is itself a router. For example, the top-level router delegates to a `tech_agent`, which then routes between a `cloud-infra_agent` and an `app-platform_agent`. Keep chains shallow (at most two levels) to avoid latency accumulation and debugging complexity.

Learn more in the [Gradient AI Platform documentation](https://docs.digitalocean.com/products/gradient-ai-platform/).
