---
type: "page"
id: "performance-profiles-and-load-generators"
title: "Performance Profiles & Load Generators"
description: "Create Meshery Performance Profiles using fortio, wrk2, and nighthawk load generators to establish baseline latency and throughput benchmarks for DOKS inference endpoints."
weight: 1
---

## Overview

Deploying a vLLM or Ollama inference server on a DOKS GPU cluster is only the beginning. Before you can detect regressions or make scaling decisions, you need a repeatable way to measure how the endpoint performs. Meshery's **Performance Profiles** give you exactly that: a saved, reusable test configuration that runs a load generator against an endpoint and records the results for comparison over time.

## Built-In Load Generators

Meshery ships with three load generators, each suited to different testing scenarios:

| Generator | Best For | Key Metric Output |
|---|---|---|
| **fortio** | HTTP/gRPC benchmarks, simple load patterns | Latency histogram, QPS, error rate |
| **wrk2** | Constant-rate load with accurate latency percentiles | p50, p75, p95, p99 latency at a fixed RPS |
| **nighthawk** | Advanced HTTP/2 and gRPC, per-connection concurrency | Detailed percentile distribution, connection stats |

For OpenAI-compatible inference endpoints (the API surface exposed by vLLM, Ollama, and DigitalOcean's 1-Click Models), `fortio` and `wrk2` are the most common choices because they produce clean latency histograms against HTTP endpoints.

## Creating a Performance Profile in the UI

Navigate to **Performance → Profiles** in the Meshery UI and click **New Profile**. Fill in the fields:

- **Name** — e.g., `vllm-mistral7b-baseline`
- **Endpoint URL** — the URL of the inference Service, e.g., `http://vllm-inference.inference.svc.cluster.local/v1/completions` (internal) or the external LoadBalancer/Ingress URL
- **Load generator** — select `wrk2` for constant-rate testing
- **Duration** — e.g., `60s`
- **Requests per second (RPS)** — start with `10` for a baseline
- **Concurrent connections** — e.g., `5`
- **Request body** — a JSON payload matching the OpenAI completions schema:

```json
{
  "model": "mistralai/Mistral-7B-Instruct-v0.2",
  "prompt": "Explain cloud native computing in one sentence.",
  "max_tokens": 100
}
```

Save the Profile. It is now reusable — you can run it at any time and Meshery stores each run's results.

## Running a Profile with mesheryctl

```bash
mesheryctl perf apply \
  --profile vllm-mistral7b-baseline \
  --load-generator wrk2 \
  --duration 60s \
  --rps 10
```

Meshery executes the test and returns a run ID. Retrieve the results:

```bash
mesheryctl perf result --profile vllm-mistral7b-baseline --latest
```

## Interpreting the Output

A typical result summary looks like:

```
Duration: 60s | RPS: 10 | Concurrent: 5
Requests: 600 | Errors: 0 | Error rate: 0.0%
Latency:
  p50:  842ms
  p95: 1240ms
  p99: 1890ms
Max throughput: 10.0 req/s
```

For a GPU inference server, latency is dominated by the model's time-to-first-token (TTFT) and the generation speed (tokens per second). These numbers become your baseline. Future runs that show a p95 above 2000ms signal a regression worth investigating.

## Connecting to a DOKS Inference Endpoint

If the vLLM Service is exposed via a DigitalOcean LoadBalancer, the endpoint URL uses the external IP assigned by DOKS:

```bash
kubectl get svc vllm-inference -n inference
# NAME             TYPE           CLUSTER-IP     EXTERNAL-IP     PORT(S)
# vllm-inference   LoadBalancer   10.245.0.100   203.0.113.42    80:32000/TCP
```

Use `http://203.0.113.42/v1/completions` as the Profile endpoint. For internal testing where Meshery runs inside the cluster, use the ClusterIP URL directly to avoid LoadBalancer egress costs.

## Next Steps

With a baseline Performance Profile established, the next lesson covers the specific metrics that matter for LLM inference — latency percentiles, token throughput, and error rate — and how to interpret them in the context of DOKS GPU utilization.

- [Meshery Performance Management docs](https://docs.meshery.io/guides/performance-management)
- [DOKS Kubernetes docs](https://docs.digitalocean.com/products/kubernetes/)
