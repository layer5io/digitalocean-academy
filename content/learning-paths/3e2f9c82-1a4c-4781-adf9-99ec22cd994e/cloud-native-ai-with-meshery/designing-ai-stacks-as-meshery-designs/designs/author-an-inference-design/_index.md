---
type: "page"
id: "author-an-inference-design"
title: "Author an Inference Design"
description: "Build a Meshery Design that describes a complete vLLM or Ollama GPU inference stack — Deployment, Service, and Ingress — ready to deploy on a DOKS GPU cluster."
weight: 1
---

## Overview

A Meshery **Design** is a declarative, versioned description of an infrastructure or application configuration — infrastructure as code with a visual authoring experience. In this lesson you author a Design for a GPU inference server (vLLM or Ollama) running on DOKS. The Design captures a Deployment requesting an NVIDIA GPU, a Service exposing the OpenAI-compatible endpoint, and an Ingress for external access.

## Starting a New Design in Kanvas

Open Kanvas in Designer mode and click **New Design**. Give it a meaningful name such as `vllm-inference-doks`. The canvas starts empty. From the component palette on the left, search for and drag these resources onto the canvas:

1. `Namespace` — create an `inference` namespace.
2. `Deployment` — the vLLM or Ollama serving container.
3. `Service` — exposes port 8000 (vLLM's default OpenAI-compatible API port).
4. `Ingress` — routes external HTTP/S traffic to the Service.

## Configuring the Deployment

Select the `Deployment` component and fill in the spec. The critical section is the container resource request for the GPU. Below is the equivalent YAML — Kanvas generates this from the form inputs:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: vllm-inference
  namespace: inference
spec:
  replicas: 1
  selector:
    matchLabels:
      app: vllm-inference
  template:
    metadata:
      labels:
        app: vllm-inference
    spec:
      containers:
        - name: vllm
          image: vllm/vllm-openai:latest
          args:
            - "--model"
            - "mistralai/Mistral-7B-Instruct-v0.2"
            - "--port"
            - "8000"
          ports:
            - containerPort: 8000
          resources:
            limits:
              nvidia.com/gpu: "1"
            requests:
              nvidia.com/gpu: "1"
      nodeSelector:
        nvidia.com/gpu: "true"
```

The `nvidia.com/gpu: "1"` limit is what tells the NVIDIA device plugin on the DOKS GPU node to allocate one GPU to this Pod. The `nodeSelector` ensures the Pod lands on a GPU node and not a CPU-only node.

## Wiring the Service

Drag a `Service` component onto the canvas and connect it to the `Deployment` by drawing a relationship line. Kanvas validates that the Service `selector` matches the Deployment's Pod `labels`. Set the port mapping:

```yaml
spec:
  selector:
    app: vllm-inference
  ports:
    - port: 80
      targetPort: 8000
  type: ClusterIP
```

## Adding the Ingress

Connect an `Ingress` component to the Service. Set the backend service name to `vllm-inference` and the backend port to `80`. Configure the host to a domain you control or a wildcard for local testing.

Kanvas validates the Ingress → Service Relationship automatically: if the backend service name or port does not match the Service you wired, the canvas shows an error before you deploy.

## Exporting and Saving

Click **Save Design**. The Design is stored in Meshery with a version timestamp. You can also export it as a YAML file for storage in Git:

```bash
mesheryctl design export --name vllm-inference-doks -o vllm-inference.yaml
```

This YAML file is a portable, reusable artifact. Import it on another Meshery instance or another cluster with:

```bash
mesheryctl design import -f vllm-inference.yaml -s "Kubernetes Manifest"
```

## Use the Ready-Made Design

You don't have to build this from scratch. An importable version of this exact stack ships with the academy at [`designs/vllm-inference-stack.yaml`](https://github.com/layer5io/digitalocean-academy/blob/master/designs/vllm-inference-stack.yaml). Import it straight from its raw URL and open it in Kanvas to inspect, validate, and deploy:

```bash
mesheryctl design import \
  -f https://raw.githubusercontent.com/layer5io/digitalocean-academy/master/designs/vllm-inference-stack.yaml \
  -s "Kubernetes Manifest"
```

{{< meshery-design-embed src="embedded-design-vllm-inference-stack.js" id="embedded-design-c9dcbd0b-b39d-4584-846c-bc2c97a2df4f" size="full" >}}

Two companion designs live alongside it: `qdrant-vector-db.yaml` (a vector database for RAG) and `gpu-observability-stack.yaml` (GPU metrics for Prometheus/Grafana). See the [`designs/` directory](https://github.com/layer5io/digitalocean-academy/tree/master/designs) for all three and their import instructions.

## Next Steps

The Design you just authored has hard-coded GPU counts and a fixed replica number. The next lesson covers parameterizing these values so the same Design can be deployed to a development cluster with one small GPU and a production cluster with multiple H100s.

- [Meshery Designs documentation](https://docs.meshery.io/concepts/logical/designs)
- [DOKS GPU docs](https://docs.digitalocean.com/products/gpu-droplets/)
