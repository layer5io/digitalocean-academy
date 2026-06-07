---
type: "page"
id: "autoscaling-gpu-workloads"
title: "Autoscaling GPU Workloads"
description: "Configure the DOKS cluster autoscaler, HPA, and KEDA to automatically scale GPU inference pods and nodes based on request queue depth or GPU utilization."
weight: 4
---

## The Autoscaling Stack

GPU workloads have bursty demand. Scaling too slowly wastes latency; over-provisioning wastes money. DOKS provides three complementary tools:

| Tool | What it scales | Based on |
|------|---------------|----------|
| Cluster Autoscaler | GPU nodes in a node pool | Unschedulable pods (node-level) |
| HPA (Horizontal Pod Autoscaler) | Pod replica count | CPU, memory, or custom metrics |
| KEDA | Pod replica count | Event sources: queues, HTTP, Prometheus metrics |

## Cluster Autoscaler

The cluster autoscaler monitors for pods stuck in `Pending` state because no node has sufficient resources (including `nvidia.com/gpu`). When detected, it adds a new node to the GPU node pool. When GPU nodes are idle for a configurable period, it removes them.

Enable autoscaling on a GPU node pool:

```bash
doctl kubernetes cluster node-pool update my-cluster gpu-pool \
  --auto-scale \
  --min-nodes 0 \
  --max-nodes 4
```

Setting `--min-nodes 0` allows the pool to scale to zero when there are no pending GPU workloads, eliminating idle GPU cost entirely. When a new GPU pod is submitted, the autoscaler provisions a node (typically in under 60 seconds) before the pod can start.

## Horizontal Pod Autoscaler (HPA)

HPA scales the number of pod replicas for a Deployment based on observed metrics. For inference workloads, the most useful metric is requests per second or GPU utilization exposed via Prometheus.

A basic HPA that scales on CPU utilization as a stand-in before custom metrics are configured:

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: vllm-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: vllm-server
  minReplicas: 1
  maxReplicas: 4
  metrics:
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: 70
```

## KEDA: Event-Driven Autoscaling

KEDA extends HPA with support for event sources such as message queue depth, HTTP request rate, and Prometheus query results. For GPU inference, scaling on **pending request count** (from a Prometheus metric exposed by vLLM) gives more responsive autoscaling than CPU or memory.

Install KEDA in the cluster:

```bash
helm repo add kedacore https://kedacore.github.io/charts
helm install keda kedacore/keda --namespace keda --create-namespace
```

A `ScaledObject` that scales the vLLM Deployment based on the number of waiting requests:

```yaml
apiVersion: keda.sh/v1alpha1
kind: ScaledObject
metadata:
  name: vllm-keda
spec:
  scaleTargetRef:
    name: vllm-server
  minReplicaCount: 1
  maxReplicaCount: 4
  triggers:
    - type: prometheus
      metadata:
        serverAddress: http://prometheus.monitoring.svc:9090
        metricName: vllm_requests_waiting
        query: sum(vllm:num_requests_waiting)
        threshold: "5"
```

When more than 5 requests are queued, KEDA signals HPA to add replicas. Combined with the cluster autoscaler, new GPU nodes are provisioned automatically to accommodate the additional pods.

## End-to-End Scaling Flow

1. Request traffic increases; the vLLM request queue grows.
2. KEDA detects the queue depth exceeds the threshold and requests more replicas.
3. New pods enter `Pending` state because no GPU capacity is available.
4. The cluster autoscaler provisions a new GPU node.
5. The pod schedules on the new node and begins serving.
6. Traffic drops; KEDA reduces replica count; idle GPU nodes are removed after the scale-down delay.

## Tuning Recommendations

- Set scale-down stabilization (`behavior.scaleDown.stabilizationWindowSeconds`) to at least 300 seconds to prevent oscillation when traffic is variable.
- Use `minReplicaCount: 1` in KEDA so the model is always warm for low-latency response to initial requests.
- Monitor `vllm:gpu_cache_usage_perc` alongside queue depth to catch cases where the bottleneck is memory, not replica count.

For DOKS autoscaling documentation, see the [Kubernetes documentation](https://docs.digitalocean.com/products/kubernetes/).
