---
type: "page"
id: "choosing-a-base-model"
title: "Choosing a Base Model"
description: "Evaluate trade-offs across model size, latency, cost, and context window to match the right base model to your agent's workload."
weight: 2
---

## Why Model Choice Matters

Every agent on the Gradient AI Platform runs on a base model. That choice sets a hard ceiling on quality and a hard floor on latency and cost. Picking too large a model wastes money; picking too small a model degrades quality. This lesson gives you a framework for making the right call.

## Key Trade-off Dimensions

### Size and Capability

Larger models generally produce more nuanced, accurate responses, handle complex reasoning better, and follow complicated instructions more reliably. Smaller models are faster and cheaper but can struggle with multi-step reasoning, long documents, or unusual phrasing.

A useful rule of thumb:

| Task type | Suggested model tier |
|-----------|---------------------|
| Simple Q&A, classification, extraction | Small / lightweight |
| Summarization, moderate reasoning | Mid-size |
| Complex reasoning, code generation, agentic chains | Large / frontier |

### Latency

Model latency scales roughly with parameter count. For real-time user-facing agents, a smaller model that responds in under a second often outperforms a larger model that takes four seconds — even if the larger model is marginally more accurate. Measure end-to-end response time in the playground under realistic input lengths.

### Cost

Inference cost is priced per input and output token. A frontier model may cost an order of magnitude more per 1 000 tokens than a lightweight model. For high-volume agents, that difference compounds quickly. Estimate your daily token volume before committing to a model tier.

### Context Window

Context window size determines how much conversation history, retrieved knowledge-base chunks, and tool outputs the model can consider at once. Agents that need to reason over long documents or deep conversation threads require a large context window. Agents that answer short queries can operate comfortably on smaller windows.

## Open-Weight vs. Frontier Models

**Open-weight models** (e.g., models based on the Llama family) run on DigitalOcean's own infrastructure. They offer predictable cost, no external API dependencies, and good performance on focused tasks.

**Frontier models** are large proprietary models accessible through the platform. They excel at generalist tasks, broad world knowledge, and complex reasoning, but carry higher per-token costs and may have additional usage policies.

For internal tooling or domain-specific tasks where you control the vocabulary and documents, open-weight models paired with a strong knowledge base frequently match frontier quality at a fraction of the cost.

## Matching Model to Task: Examples

```yaml
# Billing FAQ bot — high volume, simple lookups
base_model: "lightweight-open-weight-model"
temperature: 0.1
max_tokens: 256

# Code-review assistant — complex reasoning
base_model: "frontier-model"
temperature: 0.2
max_tokens: 2048

# Creative brainstorming tool — expressive output
base_model: "mid-size-model"
temperature: 0.8
max_tokens: 1024
```

Replace the placeholder identifiers with the model names shown in the Gradient Control Panel for your region.

## Iteration Strategy

1. Start with a mid-size model during development to get a baseline.
2. Run evaluations (covered later in this course) to measure quality and latency.
3. Downgrade to a smaller model and re-evaluate. If quality holds, ship the smaller model.
4. Reserve frontier models for tasks where quality differences are measurable and business-critical.

Model selection is not permanent. Agent versioning lets you swap models and compare side-by-side without disrupting production traffic.

Learn more in the [Gradient AI Platform documentation](https://docs.digitalocean.com/products/gradient-ai-platform/).
