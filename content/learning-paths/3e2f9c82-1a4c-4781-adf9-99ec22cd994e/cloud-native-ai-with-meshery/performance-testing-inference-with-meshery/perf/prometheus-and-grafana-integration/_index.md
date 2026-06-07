---
type: "page"
id: "prometheus-and-grafana-integration"
title: "Prometheus & Grafana Integration"
description: "Connect Prometheus and Grafana to Meshery, then scrape the NVIDIA DCGM exporter to observe GPU utilization and memory alongside inference latency metrics on DOKS."
weight: 4
---

## Overview

Meshery Performance Profiles measure request-level latency and throughput. To understand *why* latency looks the way it does, you need GPU-level metrics — utilization, memory usage, temperature, and power draw. Meshery integrates with Prometheus and Grafana so you can observe both layers from a single interface, correlated in time.

## The NVIDIA DCGM Exporter

On DOKS GPU clusters, the **NVIDIA DCGM (Data Center GPU Manager) exporter** is the standard way to expose GPU metrics to Prometheus. It runs as a DaemonSet on every GPU node and exposes metrics at `http://<node-ip>:9400/metrics`.

Key metrics exposed by DCGM:

| Metric | Description |
|---|---|
| `DCGM_FI_DEV_GPU_UTIL` | GPU core utilization (%) |
| `DCGM_FI_DEV_MEM_COPY_UTIL` | GPU memory bandwidth utilization (%) |
| `DCGM_FI_DEV_FB_USED` | Framebuffer (GPU memory) used (MiB) |
| `DCGM_FI_DEV_FB_FREE` | Framebuffer memory free (MiB) |
| `DCGM_FI_DEV_POWER_USAGE` | Current power draw (W) |
| `DCGM_FI_DEV_GPU_TEMP` | GPU temperature (°C) |

Deploy the DCGM exporter to your DOKS cluster if it is not already present:

```bash
helm repo add gpu-helm-charts https://nvidia.github.io/dcgm-exporter/helm-charts
helm install dcgm-exporter gpu-helm-charts/dcgm-exporter \
  --namespace monitoring \
  --create-namespace
```

## Connecting Prometheus to Meshery

In the Meshery UI, navigate to **Settings → Metrics**. Click **Add Prometheus** and provide the Prometheus server URL. If Prometheus is running inside the same DOKS cluster, use the in-cluster Service URL:

```
http://prometheus-operated.monitoring.svc.cluster.local:9090
```

After saving, Meshery queries Prometheus to confirm connectivity. The Metrics dashboard in Meshery now reflects cluster-wide Prometheus data.

## Connecting Grafana to Meshery

Similarly, add a Grafana instance under **Settings → Metrics → Add Grafana**. Provide the Grafana URL and an API key with `Viewer` permissions. Meshery can then embed Grafana dashboards directly in the Meshery UI panels.

```
http://grafana.monitoring.svc.cluster.local:3000
```

## Configuring Prometheus to Scrape DCGM

Add a `ServiceMonitor` (if using the Prometheus Operator) to scrape the DCGM exporter Service:

```yaml
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: dcgm-exporter
  namespace: monitoring
spec:
  selector:
    matchLabels:
      app.kubernetes.io/name: dcgm-exporter
  endpoints:
    - port: metrics
      interval: 15s
```

After applying this, GPU metrics flow into Prometheus and are accessible in Meshery's metrics view.

## Correlating GPU Metrics with Performance Profile Results

The most powerful workflow is running a Performance Profile in Meshery while watching the Prometheus metrics panel side by side. During a 60-second wrk2 run at 20 RPS against a vLLM endpoint:

- `DCGM_FI_DEV_GPU_UTIL` should spike to near 100% if the model is being actively used.
- `DCGM_FI_DEV_FB_USED` shows whether GPU memory is near capacity (risk of OOM).
- A sudden drop in GPU utilization mid-test while errors increase suggests the serving process crashed and restarted.

Meshery overlays the performance test duration as a time range on the metrics view, so you can see exactly which metric movements correspond to the load test.

## Pre-Built Dashboards

The DCGM exporter project ships Grafana dashboard JSON files for GPU monitoring. Import them into Grafana and connect the Grafana datasource to Meshery. Meshery renders these dashboards inline in the Lifecycle or Performance views for connected clusters, eliminating the need to switch browser tabs between the load test results and the GPU dashboard.

- [Meshery Performance Management docs](https://docs.meshery.io/guides/performance-management)
- [DOKS GPU Droplets docs](https://docs.digitalocean.com/products/gpu-droplets/)
