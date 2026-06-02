---
type: "page"
id: "comparing-runs-over-time"
title: "Comparing Runs Over Time"
description: "Save Meshery Performance Profile runs, compare latency and throughput across deploys, and catch inference performance regressions before they reach production."
weight: 3
---

## Overview

A single performance measurement tells you how the system behaves right now. A series of measurements tells you whether it is getting better or worse. Meshery stores every Performance Profile run and provides a comparison view that lets you see at a glance whether the latest deploy of your vLLM or Ollama server on DOKS introduced a regression.

## How Run History Works

Each time you execute a Performance Profile — whether from the Meshery UI or via `mesheryctl perf apply` — Meshery saves the full result set: latency histogram, throughput, error count, and test parameters (RPS, duration, concurrency, load generator). Results are associated with the Profile and optionally tagged with a Design version or a free-form label.

List saved runs for a Profile:

```bash
mesheryctl perf result --profile vllm-mistral7b-baseline
```

Output example:

```
RUN ID     DATE                 RPS  DURATION  p50 (ms)  p95 (ms)  ERRORS
run-001    2026-05-10 09:00     10   60s       840       1230      0
run-002    2026-05-17 14:30     10   60s       860       1280      0
run-003    2026-05-24 10:15     10   60s       910       1950      2
```

Run 003 shows a p95 jump from 1280ms to 1950ms and two errors. That warrants investigation.

## Comparing Two Runs in the UI

In the Meshery UI, open **Performance → Profiles**, select the Profile, and click **Compare**. Select two runs from the list — for example, the run before and after a model version update. Meshery renders a side-by-side table:

| Metric | Run 002 (before) | Run 003 (after) | Delta |
|---|---|---|---|
| p50 latency | 860ms | 910ms | +5.8% |
| p95 latency | 1280ms | 1950ms | +52.3% |
| Error rate | 0% | 0.33% | +0.33% |
| Throughput | 10.0 req/s | 9.97 req/s | -0.3% |

The p95 regression of 52% is an immediate flag. Combined with 2 errors, this looks like memory pressure — possibly the new model version has a larger KV cache footprint that is intermittently exhausting GPU memory on the RTX 6000 Ada nodes.

## Tagging Runs for Context

When running a performance test after a meaningful event (model update, replica count change, node pool upgrade), add a descriptive label:

```bash
mesheryctl perf apply \
  --profile vllm-mistral7b-baseline \
  --label "after-mistral-0.4.2-upgrade" \
  --rps 10 \
  --duration 60s
```

Labels appear in the run history and comparison view, making it easy to correlate performance changes with specific infrastructure or software changes without hunting through deployment logs.

## Integrating Comparisons into CI/CD

Meshery's CLI output is machine-parseable. In a CI pipeline, run the Performance Profile after each deploy and fail the pipeline if a key metric regresses beyond a threshold:

```bash
mesheryctl perf apply \
  --profile vllm-mistral7b-baseline \
  --rps 10 \
  --duration 30s \
  --output json > perf-result.json

# Extract p95 latency and compare to threshold
P95=$(jq '.latency.p95_ms' perf-result.json)
if [ "$P95" -gt 2000 ]; then
  echo "p95 latency $P95ms exceeds 2000ms threshold — blocking deploy"
  exit 1
fi
```

This prevents a model or configuration change from silently degrading inference performance in production.

## Trend Analysis

Beyond pairwise comparisons, the run history table gives you a trend line. If p95 latency climbs by 5–10% each week without any deliberate change, it signals gradual degradation — possibly a growing request queue, a memory leak in the serving framework, or increasing prompt complexity from users.

Catching this trend early, while latency is at 1400ms, is far easier than diagnosing it after it crosses 5000ms and users start complaining.

## Practical Cadence

For a production DOKS inference cluster, run Performance Profiles:

- After every Design deploy (model update, scaling event, configuration change)
- On a weekly schedule to detect gradual degradation
- Before and after DOKS cluster upgrades or GPU node pool changes

- [Meshery Performance Management docs](https://docs.meshery.io/guides/performance-management)
- [DOKS Kubernetes docs](https://docs.digitalocean.com/products/kubernetes/)
