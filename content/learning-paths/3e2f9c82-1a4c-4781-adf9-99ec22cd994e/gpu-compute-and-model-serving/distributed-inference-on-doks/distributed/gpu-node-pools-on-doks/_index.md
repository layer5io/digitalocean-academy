---
type: "page"
id: "gpu-node-pools-on-doks"
title: "GPU Node Pools on DOKS"
description: "Add a GPU node pool to a DigitalOcean Kubernetes cluster using doctl, then label and taint the nodes to control GPU workload scheduling."
weight: 1
---

## Why GPU Node Pools?

DigitalOcean Kubernetes (DOKS) lets you mix CPU and GPU node pools in the same cluster. General-purpose workloads—web servers, databases, preprocessing jobs—run on CPU nodes where the per-hour cost is far lower. GPU workloads run on dedicated GPU nodes that are provisioned only when needed and can scale down when idle. This separation keeps costs predictable and cluster resource utilization high.

## Supported GPU Node Types

DOKS GPU node pools support NVIDIA GPU Droplet sizes, including RTX 4000 Ada, RTX 6000 Ada, L40S, and H100 variants. Check current availability with:

```bash
doctl kubernetes options sizes | grep gpu
```

## Creating a GPU Node Pool

First, ensure you have a running DOKS cluster. If not, create one:

```bash
doctl kubernetes cluster create my-cluster \
  --region nyc3 \
  --node-pool "name=cpu-pool;size=s-2vcpu-4gb;count=2"
```

Add a GPU node pool to the existing cluster:

```bash
doctl kubernetes cluster node-pool create my-cluster \
  --name gpu-pool \
  --size gpu-h100x1-80gb \
  --count 1 \
  --label workload=gpu-inference \
  --taint nvidia.com/gpu=present:NoSchedule
```

Key flags:

- `--size` sets the GPU Droplet size for each node in the pool.
- `--count` sets the initial number of nodes. For autoscaling, you will also set `--min-nodes` and `--max-nodes`.
- `--label` attaches a key-value label to every node in the pool, allowing `nodeSelector` targeting.
- `--taint` adds a Kubernetes taint. The `NoSchedule` effect prevents any pod from landing on GPU nodes unless it explicitly tolerates the taint, protecting GPU resources from accidental CPU workload placement.

## Verifying the Node Pool

After the pool is ready (typically under 60 seconds):

```bash
kubectl get nodes -l workload=gpu-inference
```

Check that the NVIDIA device plugin has registered the GPU resource:

```bash
kubectl get node <gpu-node-name> -o json \
  | jq '.status.capacity["nvidia.com/gpu"]'
```

This should return `"1"` for a single-GPU node.

## Labels and Taints Reference

Use labels to express affinity and taints to express exclusivity:

```yaml
# Schedule pods on GPU nodes using nodeSelector
nodeSelector:
  workload: gpu-inference

# Tolerate the NoSchedule taint so the pod can land on GPU nodes
tolerations:
  - key: "nvidia.com/gpu"
    operator: "Equal"
    value: "present"
    effect: "NoSchedule"
```

Pods that request `nvidia.com/gpu` resources must include both the `nodeSelector` (or `nodeAffinity`) and the `toleration` to reliably land on GPU nodes.

## Removing a Node Pool

To delete the GPU node pool and stop billing for the underlying GPU Droplets:

```bash
doctl kubernetes cluster node-pool delete my-cluster gpu-pool --force
```

For full DOKS documentation, see the [Kubernetes documentation](https://docs.digitalocean.com/products/kubernetes/).
