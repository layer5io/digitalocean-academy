---
type: "page"
id: "wiring-prometheus-and-grafana"
title: "Wiring Prometheus & Grafana"
description: "Connect Prometheus and Grafana to Meshery as data sources, enabling unified observability for GPU inference workloads running on DOKS."
weight: 1
---

## Overview

Observability for AI workloads on DOKS requires metrics at two levels: Kubernetes infrastructure metrics (Pod CPU, memory, network) and GPU-specific metrics (utilization, memory, power). Meshery integrates with Prometheus and Grafana to surface both levels through its UI, so you can move from a Performance Profile result to the underlying infrastructure metrics without switching tools.

## Prerequisites

Before connecting to Meshery, you need Prometheus and Grafana running in the DOKS cluster. The Prometheus Operator (kube-prometheus-stack Helm chart) is the standard way to deploy both:

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

helm install kube-prometheus-stack prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --create-namespace \
  --set grafana.enabled=true \
  --set grafana.service.type=ClusterIP
```

This installs Prometheus, Alertmanager, Grafana, and a set of default dashboards for Kubernetes infrastructure.

## Connecting Prometheus to Meshery

In the Meshery UI, navigate to **Settings → Metrics** and click **Add Prometheus**. Enter the Prometheus server URL. If Prometheus runs inside the same DOKS cluster as Meshery:

```
http://kube-prometheus-stack-prometheus.monitoring.svc.cluster.local:9090
```

If Meshery runs locally (outside the cluster), expose Prometheus via `kubectl port-forward`:

```bash
kubectl port-forward svc/kube-prometheus-stack-prometheus 9090:9090 -n monitoring
```

Then use `http://localhost:9090` as the URL in Meshery.

After saving, Meshery verifies connectivity by querying the Prometheus health endpoint. A green status indicator confirms the connection.

## Connecting Grafana to Meshery

Similarly, click **Add Grafana** under **Settings → Metrics**. Provide the Grafana URL and an API key. Generate a Service Account API key in Grafana:

1. Open Grafana at its ClusterIP (or via port-forward on port 3000).
2. Navigate to **Administration → Service Accounts → Add service account**.
3. Assign the `Viewer` role and generate a token.
4. Copy the token into the Meshery Grafana integration form.

```bash
# Port-forward Grafana for local access
kubectl port-forward svc/kube-prometheus-stack-grafana 3000:80 -n monitoring
```

Meshery uses the Grafana API to list available dashboards and embed them inline in its UI panels.

## Verifying the Data Flow

After both connections are established, open **Lifecycle → Clusters** in Meshery and select your DOKS GPU cluster. The **Metrics** tab shows live Prometheus data for the cluster: Pod CPU, memory usage, network I/O, and — once the DCGM exporter is running — GPU metrics.

Query a specific metric directly from the Meshery metrics panel using PromQL:

```promql
DCGM_FI_DEV_GPU_UTIL{instance=~".*gpu.*"}
```

If values return, Prometheus is successfully scraping the DCGM exporter on the GPU nodes.

## Scoping Metrics to AI Namespaces

Filter the metrics view to the `inference` namespace to reduce noise from system namespaces. Meshery's metrics panel supports namespace filtering, showing only the Pods relevant to your AI workload.

This is particularly useful when correlating a Performance Profile run with resource consumption: scope the metrics to the `inference` namespace during the load test window and you see exactly which Pods consumed CPU, memory, and GPU during that interval.

## Alerting Integration

Grafana Alertmanager can send alerts to Slack, PagerDuty, or email when metrics cross thresholds. Configure Alertmanager through the Helm values or the Grafana UI. Meshery surfaces Alertmanager connection status in the Metrics settings panel, giving you a single place to confirm that the full observability pipeline — DCGM exporter → Prometheus → Grafana → Alertmanager — is wired correctly.

The next lesson covers building GPU and latency dashboards, followed by alert configuration specific to AI workload cost and saturation.

- [Meshery docs](https://docs.meshery.io/)
- [DOKS Kubernetes docs](https://docs.digitalocean.com/products/kubernetes/)
