---
type: "page"
id: "comparing-evaluation-runs"
title: "Comparing Evaluation Runs"
description: "Use the Gradient evaluation dashboard to compare results across agent versions, detect regressions, and make data-driven promotion decisions."
weight: 3
---

## The Purpose of Comparison

A single evaluation run tells you how good an agent is. Comparing two runs tells you whether a change made it better or worse. This is the core of data-driven agent development: every change to instructions, model, or knowledge base should be accompanied by a comparative evaluation before promotion to production.

## What Can Be Compared

The Gradient evaluation framework allows you to compare runs that differ along any of these axes:

| Axis | Example |
|------|---------|
| Agent version | v2-instructions vs. v3-instructions |
| Base model | Lightweight model vs. mid-size model |
| Knowledge base version | KB before re-index vs. KB after re-index |
| Sampling parameters | temperature=0.1 vs. temperature=0.3 |

Compare only one axis at a time. Changing instructions and swapping the model simultaneously makes it impossible to attribute improvement or regression to a specific change.

## Running a Comparison

From the evaluation dashboard:

1. Select an existing evaluation run as the **baseline**.
2. Create a new run with the changed configuration against the same dataset.
3. Click **Compare runs** and select the new run alongside the baseline.

The dashboard displays a side-by-side view of aggregate scores and a per-case diff.

## Reading the Comparison View

The comparison table shows score deltas:

```
Dimension         | Baseline (v2) | Candidate (v3) | Delta
------------------+---------------+----------------+------
Quality           | 3.8 / 5       | 4.2 / 5        | +0.4
Groundedness      | 4.1 / 5       | 4.0 / 5        | -0.1
Safety            | 5.0 / 5       | 5.0 / 5        |  0.0
Latency (p50 ms)  | 1 240         | 980            | -260
Cost (tokens avg) | 820           | 790            | -30
```

In this example, v3 improves quality and latency while keeping safety perfect and slightly reducing groundedness. Whether the groundedness drop is acceptable depends on your use case.

## Detecting Regressions

A regression is a statistically meaningful drop in any dimension you care about. When reviewing comparisons, flag these patterns:

- **Safety regression**: any drop in the safety score is a blocker. Do not promote.
- **Quality regression on high-value cases**: filter the per-case view to your most important query categories and check for quality drops even if the aggregate is neutral.
- **Latency spike**: a large increase in p95 latency degrades user experience even if average latency is similar.
- **Cost increase with no quality benefit**: a change that costs more without measurable quality improvement should be reconsidered.

The per-case diff is essential for finding regressions that aggregate scores mask. An agent might improve on 80% of cases and regress significantly on 20% — the aggregates look fine, but the regression cases may be your most critical query types.

## Using Tags for Targeted Analysis

Evaluation datasets with tagged cases let you filter comparisons by segment:

```
Filter: tags = ["billing"]   → Compare only billing-related cases
Filter: tags = ["adversarial"] → Check safety impact in isolation
Filter: tags = ["table-queries"] → Assess impact of KB re-index on structured data
```

This is especially useful when a change is scoped to one sub-domain (e.g., new billing KB content) — you focus comparison effort on billing cases rather than reviewing all 200 cases.

## Promotion Decision Criteria

Formalize the criteria for promoting a new version:

1. Safety score is equal to or better than baseline.
2. Quality score improves or holds within a 0.1 tolerance.
3. Latency does not exceed baseline p95 by more than 10%.
4. No regressions on tagged high-priority cases.

If all criteria pass, promote. If any fail, iterate and re-evaluate.

## Archiving Runs

Keep historical evaluation runs. As new models become available on the platform, you can re-run your standard dataset against them and compare directly to the archived baseline of your current production version — without needing to redeploy or reconfigure anything.

Learn more in the [Gradient AI Platform documentation](https://docs.digitalocean.com/products/gradient-ai-platform/).
