---
type: "page"
id: "distributed-inference-with-llm-d-and-kserve"
title: "Distributed Inference with llm-d & KServe"
description: "Learn when and how to use llm-d for disaggregated LLM inference and KServe for model serving on DOKS GPU node pools."
weight: 3
---

## Why Distributed Inference?

A single GPU instance handles inference for models up to roughly 70B parameters with quantization, or 13B in full precision. Beyond that threshold—or when you need very high availability and rolling updates without downtime—distributed inference becomes necessary. Two Kubernetes-native projects address this on DOKS: **llm-d** and **KServe**.

## llm-d: Disaggregated LLM Inference

**llm-d** is an open-source project that implements disaggregated prefill and decode for LLM inference on Kubernetes. Traditional serving stacks run prefill (processing the input prompt) and decode (generating output tokens) on the same GPU. llm-d separates them onto different GPU nodes, allowing each phase to scale independently.

Key concepts:

- **Prefill nodes** handle the computationally intensive initial forward pass over the prompt. These benefit from high compute (H100, H200).
- **Decode nodes** handle the autoregressive generation loop. These are more memory-bandwidth-bound and can run on a wider variety of GPUs.
- A **routing layer** (Gateway API-based) directs incoming requests to prefill nodes and streams decoded tokens back to the client.

When to use llm-d:

- Models too large to fit on a single GPU (70B+ in FP16, 30B+ without quantization)
- Workloads where prefill latency (TTFT) and decode throughput have different scaling requirements
- Production systems that require rolling updates without dropping requests

A minimal llm-d deployment sketch for a 70B model across an 8-GPU node:

```yaml
apiVersion: inference.llm-d.io/v1alpha1
kind: LLMDeployment
metadata:
  name: llama-70b
spec:
  model: meta-llama/Meta-Llama-3.1-70B-Instruct
  prefill:
    replicas: 1
    resources:
      limits:
        nvidia.com/gpu: 4
  decode:
    replicas: 2
    resources:
      limits:
        nvidia.com/gpu: 4
  routing:
    protocol: openai
    port: 8000
```

The resulting endpoint exposes the same OpenAI-compatible API as a single-GPU deployment.

## KServe: Model Serving on Kubernetes

**KServe** is a standardized, Kubernetes-native model serving platform that supports multiple backends—including vLLM and TGI—behind a consistent custom resource (`InferenceService`). KServe handles model download, container lifecycle, canary rollouts, and integrates with Knative for scale-to-zero.

A KServe `InferenceService` using vLLM as the backend:

```yaml
apiVersion: serving.kserve.io/v1beta1
kind: InferenceService
metadata:
  name: llama-8b
  namespace: default
spec:
  predictor:
    model:
      modelFormat:
        name: vllm
      storageUri: "hf://meta-llama/Meta-Llama-3.1-8B-Instruct"
      resources:
        limits:
          nvidia.com/gpu: 1
      nodeSelector:
        workload: gpu-inference
      tolerations:
        - key: "nvidia.com/gpu"
          operator: "Equal"
          value: "present"
          effect: "NoSchedule"
```

Apply with `kubectl apply -f isvc.yaml`. KServe provisions the pod, downloads the model, and exposes an ingress endpoint.

## Choosing Between llm-d and KServe

| Scenario | Recommendation |
|----------|---------------|
| Single large model, multi-GPU tensor parallelism | llm-d |
| Multiple models, canary deployments, scale-to-zero | KServe |
| Multi-model serving with shared GPU pools | KServe |
| Disaggregated prefill/decode for latency optimization | llm-d |

For production systems, both can coexist: KServe manages the lifecycle, while llm-d handles the disaggregated inference engine underneath.

For DOKS setup and GPU node pool documentation, see the [Kubernetes documentation](https://docs.digitalocean.com/products/kubernetes/).
