---
type: "page"
id: "gpu-and-latency-dashboards"
title: "GPU & Latency Dashboards"
description: "Build Grafana dashboards in Meshery that combine NVIDIA DCGM GPU utilization and memory metrics with inference latency data from DOKS AI workloads."
weight: 2
---

## Overview

Raw metrics in Prometheus are useful for queries and alerts, but dashboards transform them into the operational picture your team actually looks at. This lesson covers building two dashboards visible through Meshery: a GPU health dashboard fed by the DCGM exporter, and an inference latency dashboard combining Meshery Performance Profile results with Kubernetes request metrics.

## GPU Health Dashboard

The GPU health dashboard focuses on the NVIDIA hardware metrics that determine whether the inference serving infrastructure is healthy and correctly utilized.

### Key Panels

**GPU Utilization by Node**

```promql
avg by (instance, gpu) (DCGM_FI_DEV_GPU_UTIL)
```

Displays a time-series per GPU per node. A utilization consistently below 30% suggests over-provisioning; above 90% for extended periods suggests the node pool needs to scale out.

**GPU Memory Used vs. Free**

```promql
DCGM_FI_DEV_FB_USED / (DCGM_FI_DEV_FB_USED + DCGM_FI_DEV_FB_FREE) * 100
```

Shows memory pressure as a percentage. LLM inference uses GPU memory for the model weights plus the KV cache for in-flight requests. When this gauge approaches 95%, OOM errors become likely.

**GPU Power Draw**

```promql
DCGM_FI_DEV_POWER_USAGE
```

Power draw correlates with GPU utilization but also signals thermal throttling. An H100 typically draws 300–400W under full load; a sudden drop in power during high utilization may indicate throttling.

**GPU Temperature**

```promql
DCGM_FI_DEV_GPU_TEMP
```

DOKS GPU nodes are managed by DigitalOcean, so cooling is handled at the data center level, but temperature trends are still useful for diagnosing performance anomalies.

## Inference Latency Dashboard

The inference latency dashboard combines request-level metrics from the vLLM or Ollama server with Kubernetes service metrics.

### Key Panels

**Request Rate (req/s)**

If vLLM exposes Prometheus metrics (enabled with `--enable-metrics`), query:

```promql
rate(vllm:request_success_total[1m])
```

For general Kubernetes-level request counting, use ingress-nginx metrics:

```promql
rate(nginx_ingress_controller_requests{ingress="vllm-ingress"}[1m])
```

**p95 Latency**

From vLLM's built-in metrics:

```promql
histogram_quantile(0.95, rate(vllm:e2e_request_latency_seconds_bucket[5m]))
```

**Queue Depth**

```promql
vllm:num_requests_waiting
```

A growing queue means the server is receiving more requests than it can process. This precedes latency degradation.

**Token Throughput**

```promql
rate(vllm:generation_tokens_total[1m])
```

Tokens per second is the primary efficiency metric for LLM serving. Divide by GPU utilization to get tokens per GPU-second — a measure of how efficiently the hardware is being used.

## Importing the Dashboard into Grafana

Export the dashboard as a JSON file and import it into Grafana via the UI or API:

```bash
curl -X POST http://localhost:3000/api/dashboards/import \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $GRAFANA_API_KEY" \
  -d @gpu-inference-dashboard.json
```

Once imported, the dashboard is accessible in Grafana and Meshery can embed it in the Metrics panel for the connected DOKS cluster.

## Combining Both Views

The most powerful observability configuration pins the GPU health dashboard and the inference latency dashboard side by side in Grafana. When Meshery Performance Profile results show a p95 spike, switch to the GPU health dashboard for the same time window and check whether GPU memory pressure or thermal throttling coincides with the latency event.

This two-panel correlation is the foundation of effective AI infrastructure diagnosis on DOKS.

- [Meshery Performance Management docs](https://docs.meshery.io/guides/performance-management)
- [DOKS GPU Droplets docs](https://docs.digitalocean.com/products/gpu-droplets/)
