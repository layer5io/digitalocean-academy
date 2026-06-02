---
type: "page"
id: "alerting-on-cost-and-saturation"
title: "Alerting on Cost & Saturation"
description: "Configure Grafana Alertmanager rules for GPU saturation, inference queue depth, and token cost to protect the reliability and budget of DOKS AI workloads."
weight: 3
---

## Overview

Dashboards require human attention. Alerts fire when no one is watching. For production AI workloads on DOKS GPU clusters, alerts on GPU saturation, growing queue depth, and token cost thresholds are the difference between a degraded user experience and a timely intervention. This lesson covers the alert rules that matter most for LLM inference and how to configure them through Grafana with Meshery providing the metric pipeline.

## Alert Categories for AI Inference

| Category | What to Alert On | Action |
|---|---|---|
| **GPU Saturation** | Utilization > 90% for > 5 minutes | Scale GPU node pool |
| **Memory Pressure** | GPU memory > 90% used | Reduce batch size or add replicas |
| **Queue Depth** | Pending requests > threshold | Scale inference replicas |
| **Latency Regression** | p95 latency > SLO threshold | Investigate model or load change |
| **Error Rate** | HTTP 5xx rate > 1% | Investigate server crashes |
| **Cost Indicator** | Token throughput × GPU-hours > budget | Review scaling policy |

## Configuring Prometheus Alert Rules

Add alert rules to Prometheus via a `PrometheusRule` resource (when using the Prometheus Operator):

```yaml
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: ai-inference-alerts
  namespace: monitoring
spec:
  groups:
    - name: gpu-saturation
      rules:
        - alert: GPUHighUtilization
          expr: avg(DCGM_FI_DEV_GPU_UTIL) by (instance) > 90
          for: 5m
          labels:
            severity: warning
          annotations:
            summary: "GPU utilization above 90% on {{ $labels.instance }}"
            description: "Sustained high GPU utilization may indicate the node pool needs scaling."

        - alert: GPUMemoryPressure
          expr: >
            DCGM_FI_DEV_FB_USED /
            (DCGM_FI_DEV_FB_USED + DCGM_FI_DEV_FB_FREE) * 100 > 90
          for: 2m
          labels:
            severity: critical
          annotations:
            summary: "GPU memory above 90% on {{ $labels.instance }}"
            description: "Risk of OOM. Consider reducing max_model_len or adding GPU nodes."

        - alert: InferenceQueueDepth
          expr: vllm:num_requests_waiting > 20
          for: 1m
          labels:
            severity: warning
          annotations:
            summary: "vLLM queue depth {{ $value }} requests waiting"
            description: "Inference requests are queuing. Scale replica count or GPU node pool."
```

## Latency SLO Alert

Define an SLO alert tied to your inference endpoint's p95 latency target:

```yaml
- alert: InferenceLatencySLOBreach
  expr: >
    histogram_quantile(0.95,
      rate(vllm:e2e_request_latency_seconds_bucket[5m])
    ) > 3
  for: 5m
  labels:
    severity: critical
  annotations:
    summary: "Inference p95 latency exceeds 3s SLO"
    description: "p95 latency is {{ $value }}s. Investigate GPU saturation or model load."
```

## Cost Estimation Alerting

DigitalOcean bills GPU node pools by the hour per node. You can approximate token cost by combining GPU utilization and token throughput:

```promql
# GPU-hours consumed in the last hour (per node)
sum(avg_over_time(DCGM_FI_DEV_GPU_UTIL[1h])) by (instance) / 100
```

If your DOKS H100 node costs $X per hour and utilization is consistently below 20%, the cluster is costing far more than the workload justifies. Alert when utilization drops below a floor threshold for an extended period — a signal that the node pool should be scaled down:

```yaml
- alert: GPUUnderutilized
  expr: avg(DCGM_FI_DEV_GPU_UTIL) by (instance) < 10
  for: 30m
  labels:
    severity: info
  annotations:
    summary: "GPU underutilized on {{ $labels.instance }}"
    description: "Consider scaling down the GPU node pool to reduce costs."
```

## Routing Alerts to the Right Teams

Configure Alertmanager to route by severity and label:

```yaml
route:
  group_by: ['alertname', 'severity']
  routes:
    - match:
        severity: critical
      receiver: pagerduty-inference-oncall
    - match:
        severity: warning
      receiver: slack-ai-platform
    - match:
        severity: info
      receiver: slack-cost-channel
```

Platform engineering receives critical alerts (GPU OOM, SLO breach). AI engineering receives warnings (high utilization, queue depth). Finance or leadership receives cost-related info alerts.

## Viewing Alert State in Meshery

Meshery's connected Prometheus integration surfaces active alerts in the **Metrics** panel. When the `GPUMemoryPressure` alert is firing, Meshery shows it alongside the live cluster state from MeshSync, giving the on-call engineer a complete picture: the alert, the affected node, the Pods consuming GPU memory, and the Design that deployed them.

- [Meshery docs](https://docs.meshery.io/)
- [DOKS GPU Droplets docs](https://docs.digitalocean.com/products/gpu-droplets/)
