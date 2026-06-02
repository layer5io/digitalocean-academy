---
type: "page"
id: "measuring-inference-performance"
title: "Measuring Inference Performance"
description: "Measure latency percentiles, request throughput, and error rate against a vLLM or Ollama endpoint on DOKS using Meshery Performance Profiles."
weight: 2
---

## Overview

LLM inference has a distinct performance profile compared to traditional API services. A single request can take hundreds of milliseconds to several seconds depending on the model size, prompt length, and output token count. Understanding what to measure — and how to measure it correctly — prevents false alarms and missed regressions. This lesson covers the key metrics for inference performance and how Meshery surfaces them.

## Key Metrics for LLM Inference

| Metric | Definition | Why It Matters |
|---|---|---|
| **p50 latency** | Median request latency | Typical user experience |
| **p95 latency** | 95th-percentile latency | Latency under moderate load |
| **p99 latency** | 99th-percentile latency | Worst-case experience for 1 in 100 requests |
| **Throughput (req/s)** | Requests completed per second | Overall serving capacity |
| **Token throughput (tokens/s)** | Output tokens generated per second | GPU efficiency metric |
| **Error rate** | Percentage of requests returning non-2xx | Service health |
| **Time to first token (TTFT)** | Time from request to first output token | Perceived responsiveness for streaming |

Meshery's built-in load generators (fortio, wrk2, nighthawk) measure request-level latency and throughput directly. GPU-level metrics like token throughput are observed through the Prometheus + DCGM exporter integration covered in a later lesson.

## Configuring a Representative Load Test

A realistic inference load test differs from a traditional API benchmark because request size matters. A prompt of 10 tokens generates a different latency than a prompt of 2000 tokens. Design your Performance Profile with a representative request body:

```json
{
  "model": "mistralai/Mistral-7B-Instruct-v0.2",
  "messages": [
    {
      "role": "user",
      "content": "Summarize the benefits of Kubernetes for AI workloads in three bullet points."
    }
  ],
  "max_tokens": 150,
  "temperature": 0.7
}
```

Set `Content-Type: application/json` in the Profile headers. vLLM and Ollama both accept this payload format at the `/v1/chat/completions` endpoint.

## Running the Test at Multiple Load Levels

Run separate Performance Profile executions at different RPS values to build a latency-vs-throughput curve:

```bash
for rps in 1 5 10 20; do
  mesheryctl perf apply \
    --profile vllm-chat-completions \
    --load-generator wrk2 \
    --rps $rps \
    --duration 60s \
    --name "run-rps-$rps"
done
```

This produces a series of data points. Plot p95 latency against RPS and you will see the characteristic "knee" of the curve — the point where latency begins rising sharply as the GPU saturates. For an H100 running a 7B model, this knee might appear around 30–50 req/s; for an RTX 4000 Ada it appears much earlier.

## Error Rate and Timeout Tuning

At high RPS, the inference server may start returning HTTP 429 (rate limited) or 503 (overloaded) responses. Meshery counts these as errors. An error rate above 1% is a signal that the current load exceeds the server's capacity.

For DOKS deployments, also watch for:

- Pod OOMKilled events (GPU memory exhausted by large batches)
- Pending Pods (GPU node pool capacity fully allocated)
- Readiness probe failures (server still warming up between tests)

All of these appear in the Meshery Lifecycle view alongside the performance results.

## Correlating with GPU Utilization

A high p95 latency does not always mean the GPU is the bottleneck. It could be CPU throttling on the node, network latency to the LoadBalancer, or queue depth inside vLLM's batching engine. Correlate the performance test timestamps with GPU utilization metrics from the DCGM exporter (covered in the Prometheus & Grafana Integration lesson) to distinguish these cases.

A common pattern: during a 60-second wrk2 run, GPU utilization spikes to 95–100% and stays there, while p95 latency climbs steadily. This confirms GPU saturation and points to scaling the GPU node pool or upgrading to a larger GPU SKU on DOKS.

## Saving Results for Comparison

Every Performance Profile run in Meshery is saved automatically. The next lesson covers comparing runs over time to detect regressions after a model update or infrastructure change.

- [Meshery Performance Management docs](https://docs.meshery.io/guides/performance-management)
- [DOKS GPU docs](https://docs.digitalocean.com/products/gpu-droplets/)
