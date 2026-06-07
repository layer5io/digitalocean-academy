---
type: "page"
id: "the-nvidia-device-plugin-and-scheduling"
title: "The NVIDIA Device Plugin & Scheduling"
description: "Understand how the NVIDIA device plugin advertises GPU resources in Kubernetes, and write pod manifests that request and schedule GPU workloads correctly."
weight: 2
---

## What the NVIDIA Device Plugin Does

Kubernetes has no built-in understanding of GPUs. The **NVIDIA Device Plugin** is a DaemonSet that runs on each GPU node and performs three functions:

1. Discovers the NVIDIA GPUs present on the node.
2. Advertises them to the Kubernetes API server as the extended resource `nvidia.com/gpu`.
3. Mounts the necessary device files and libraries into pods that request the resource.

Without the device plugin, `nvidia.com/gpu` does not appear in node capacity and no pod can use the GPU.

## Verifying the Device Plugin Is Running

On DOKS, the NVIDIA device plugin is installed automatically when you provision a GPU node pool. Confirm it is running:

```bash
kubectl get daemonset -n kube-system nvidia-device-plugin-daemonset
```

Check that the GPU node reports capacity:

```bash
kubectl describe node <gpu-node-name> | grep -A5 "Capacity:"
```

You should see a line such as:

```
nvidia.com/gpu:  1
```

## A Minimal GPU Pod Manifest

Pods request GPUs using `resources.limits`. The device plugin enforces that only the requested number of GPUs are visible to the container.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: gpu-test
spec:
  restartPolicy: Never
  tolerations:
    - key: "nvidia.com/gpu"
      operator: "Equal"
      value: "present"
      effect: "NoSchedule"
  nodeSelector:
    workload: gpu-inference
  containers:
    - name: gpu-test
      image: nvidia/cuda:12.4.0-base-ubuntu22.04
      command: ["nvidia-smi"]
      resources:
        limits:
          nvidia.com/gpu: 1
```

Apply and watch it complete:

```bash
kubectl apply -f gpu-test.yaml
kubectl logs gpu-test
```

The logs show the same `nvidia-smi` output you would see on a bare Droplet, confirming the GPU is accessible inside the container.

## Requesting Multiple GPUs

For tensor-parallel inference or data-parallel training, request more than one GPU:

```yaml
resources:
  limits:
    nvidia.com/gpu: 8   # request all 8 GPUs on an 8-GPU node
```

Kubernetes will only schedule this pod on a node that has 8 free `nvidia.com/gpu` units. If no such node exists and the cluster autoscaler is enabled, it will provision a new 8-GPU node automatically.

## GPU Requests in Deployments

The same `resources.limits` field applies to Deployments:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: vllm-server
spec:
  replicas: 1
  selector:
    matchLabels:
      app: vllm-server
  template:
    metadata:
      labels:
        app: vllm-server
    spec:
      tolerations:
        - key: "nvidia.com/gpu"
          operator: "Equal"
          value: "present"
          effect: "NoSchedule"
      nodeSelector:
        workload: gpu-inference
      containers:
        - name: vllm
          image: vllm/vllm-openai:latest
          args:
            - "--model"
            - "meta-llama/Meta-Llama-3.1-8B-Instruct"
            - "--port"
            - "8000"
          ports:
            - containerPort: 8000
          resources:
            limits:
              nvidia.com/gpu: 1
```

## Important Rules

- GPU resources can only be expressed in `limits`, not `requests`. Kubernetes treats them as non-overcommittable resources.
- One GPU can only be assigned to one pod at a time unless you use NVIDIA's MIG (Multi-Instance GPU) partitioning (available on A100/H100).
- The container runtime must be configured with the NVIDIA Container Toolkit (`nvidia` runtime class). On DOKS GPU nodes this is pre-configured.

For full DOKS and GPU node pool documentation, see the [Kubernetes documentation](https://docs.digitalocean.com/products/kubernetes/).
