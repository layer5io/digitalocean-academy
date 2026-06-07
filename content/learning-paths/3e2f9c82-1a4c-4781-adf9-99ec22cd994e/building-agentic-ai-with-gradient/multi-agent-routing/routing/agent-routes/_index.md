---
type: "page"
id: "agent-routes"
title: "Agent Routes"
description: "Delegate from a router agent to specialized sub-agents using agent routes, and learn when splitting agents improves quality and maintainability."
weight: 1
---

## What Are Agent Routes?

An **agent route** is a routing mechanism that allows one agent — the router — to delegate a conversation turn to another agent — the sub-agent — based on intent. The sub-agent handles the query with its own instructions, knowledge bases, and function routes, then returns a response that the router can pass back to the user.

Agent routes are how the Gradient AI Platform supports multi-agent architectures. Rather than one monolithic agent trying to handle every topic, you decompose capabilities across specialized agents and use a router to direct traffic.

## How Delegation Works

```
User message arrives at router agent
         ↓
Router classifies intent
         ↓
Router selects the matching sub-agent route
         ↓
User message is forwarded to the sub-agent
         ↓
Sub-agent processes with its own config (model, KB, functions)
         ↓
Sub-agent response returned to user (via router or directly)
```

The router does not re-generate the answer — it delegates to the sub-agent and passes back the response. This means each sub-agent's quality is independent of the router's model.

## Configuring an Agent Route

In the Control Panel, navigate to your router agent and select **Agent Routes → Add agent route**. Provide:

- **Name**: a short identifier (e.g., `billing_agent`).
- **Description**: plain language the router model uses to decide when to delegate (e.g., "Handle all questions about invoices, payments, subscription changes, and refunds.").
- **Target agent**: the sub-agent UUID to delegate to.

The description is evaluated at runtime by the router's model. Precision matters — overlapping descriptions across routes cause ambiguous routing.

## When to Split Agents

Not every agent needs sub-agents. Splitting is worth the added complexity when:

| Signal | Explanation |
|--------|-------------|
| Distinct knowledge bases per topic | Billing queries need billing docs; technical queries need technical docs |
| Different instruction tones | A legal-advice agent needs conservative language; a marketing agent can be creative |
| Different models per task | A classification task may use a small model; a complex reasoning task needs a large one |
| Token budget pressure | A single agent with 10 knowledge bases and 8 function routes bloats the context |
| Independent update cadence | Billing policies change independently of product documentation |

If a single agent with well-scoped instructions handles all your use cases cleanly, adding sub-agents introduces unnecessary latency and complexity.

## Keeping Scope Boundaries Clean

The most common multi-agent failure is overlapping scope. If the billing agent description says "billing and account questions" and the account agent description says "account management and billing history," the router will make inconsistent choices.

Write descriptions as mutually exclusive as possible:

```
billing_agent:   "Questions about invoices, payment methods, charges, and refunds."
account_agent:   "Questions about account settings, passwords, user roles, and notifications."
tech_agent:      "Technical issues, errors, outages, API behavior, and configuration."
```

Test the router in the playground with boundary queries — questions that could belong to more than one sub-agent — and verify it routes consistently.

## Latency Impact

Each delegation adds one additional model call (the router's classification) plus network overhead for the sub-agent call. For latency-sensitive applications, measure the end-to-end time of the routed path in the playground and compare it to a single-agent approach.

For most support and assistant use cases, the routing overhead is under 200 ms and the quality improvement from specialized sub-agents outweighs the cost.

Learn more in the [Gradient AI Platform documentation](https://docs.digitalocean.com/products/gradient-ai-platform/).
