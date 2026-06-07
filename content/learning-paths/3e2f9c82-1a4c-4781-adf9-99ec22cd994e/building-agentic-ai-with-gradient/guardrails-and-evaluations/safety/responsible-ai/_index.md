---
type: "page"
id: "responsible-ai"
title: "Responsible AI"
description: "Apply bias awareness, transparency, auditability, and human oversight principles when building production AI agents on the Gradient platform."
weight: 4
---

## Responsibility Starts at Design

Responsible AI is not a checkbox applied after an agent is built — it is a set of principles woven into every design decision. An agent deployed to thousands of users can amplify small design flaws at scale. Addressing bias, transparency, auditability, and human oversight from the start is far less costly than retrofitting them after deployment.

## Bias Awareness

Language models reflect biases present in their training data. These biases can surface in subtle ways: the agent may give more thorough answers to clearly phrased queries from users with domain vocabulary, use gendered language in role descriptions, or recommend differently priced products to users who phrase requests differently.

Practical steps:

- **Diversify your evaluation dataset.** Include queries that represent different user demographics, technical skill levels, and phrasings of the same underlying question.
- **Review outputs for systematic patterns.** If users asking the same question in formal vs. casual language receive qualitatively different answers, investigate why.
- **Audit knowledge-base content.** Source documents can contain biased assumptions. Review them before indexing, especially legal, policy, and marketing materials.
- **Test across languages and dialects** if your agent serves a multilingual audience.

## Transparency

Users should understand that they are interacting with an AI agent, not a human. Transparency includes:

- **Disclosure at session start.** Clearly identify the agent as an AI in the welcome message or UI.
- **Citing sources.** Enable knowledge-base citations so users can verify the basis of the agent's answers rather than accepting them on faith.
- **Honest uncertainty.** Instruct the agent to say "I don't have reliable information about that" rather than generating a confident-sounding but speculative answer.
- **Legible refusals.** When guardrails block a request, the refusal message should explain what the agent cannot help with, not just produce an opaque error.

## Auditability

Every production agent should maintain an auditable record of its behavior:

| What to record | Where it lives in Gradient |
|----------------|---------------------------|
| Request and response content | Agent Insights logs |
| Guardrail trigger events | Agent Insights safety log |
| Evaluation run results | Evaluation dashboard |
| Agent configuration at each version | Version history |
| Knowledge-base re-index events | KB activity log |

These records support internal compliance reviews, incident investigations, and, where required, regulatory reporting. Version history is particularly important — it allows you to determine exactly what configuration was running at any point in time.

## Human Oversight

No AI agent should be the final decision-maker in high-stakes situations. Define clear escalation paths:

- **Escalation triggers.** Configure the agent's instructions to escalate to a human for: financial transactions above a threshold, legal or medical advice, complaints involving sensitive personal circumstances, or any situation the agent flags as uncertain.
- **Human-in-the-loop review.** For new agents, have a human review a random sample of conversations weekly for the first month. Reduce the sample rate as quality stabilizes.
- **Clear handoff language.** When escalating, the agent should tell the user clearly: "This requires a human review. A team member will follow up within [timeframe]."

```
If the user expresses frustration, requests to speak with a person, or asks about
a transaction over $500, reply: "I'd like to connect you with a member of our
team for this. Please expect a response within one business day."
```

## Ongoing Responsibility

Responsible AI is not a one-time audit. Re-evaluate your agent's behavior regularly, especially after:
- Knowledge base updates that introduce new content.
- Base model upgrades (new models may have different bias profiles).
- Significant changes to user demographics or query distribution.
- Any guardrail event that reveals an unexpected failure mode.

Build evaluation runs (with safety and quality dimensions) into your regular deployment pipeline so that responsible behavior is verified continuously, not just at launch.

Learn more in the [Gradient AI Platform documentation](https://docs.digitalocean.com/products/gradient-ai-platform/).
