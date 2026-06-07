# Meshery Designs — DigitalOcean Academy

This folder contains **importable, runnable Meshery designs** used by the academy's
*Cloud Native AI Infrastructure with Meshery & DOKS* learning path and the *Manage a DOKS GPU
Cluster with Meshery* challenge. Each file is valid Kubernetes YAML, so it can be:

- **imported into Meshery** as a design (and opened in **Kanvas** to visualize and deploy), or
- applied directly with `kubectl` for a quick start.

| Design | File | What it installs |
|--------|------|------------------|
| vLLM GPU inference stack | [`vllm-inference-stack.yaml`](vllm-inference-stack.yaml) | An OpenAI-compatible LLM server on a DOKS GPU node pool (Namespace + Deployment requesting `nvidia.com/gpu` + Service) |
| Qdrant vector database | [`qdrant-vector-db.yaml`](qdrant-vector-db.yaml) | A Qdrant vector DB for RAG, backed by DigitalOcean Block Storage (Namespace + headless Service + StatefulSet with a `do-block-storage` PVC) |
| GPU observability stack | [`gpu-observability-stack.yaml`](gpu-observability-stack.yaml) | The NVIDIA DCGM exporter DaemonSet + Service exposing GPU metrics for Prometheus/Grafana |

## Prerequisites

- A DOKS cluster with a **GPU node pool**. Label the pool so the GPU workloads schedule onto it:
  ```bash
  doctl kubernetes cluster node-pool create <cluster> --name gpu-pool \
    --size gpu-l40sx1-48gb --count 1 --label nvidia.com/gpu=true
  doctl kubernetes cluster kubeconfig save <cluster>
  ```
- [Meshery](https://docs.meshery.io/) running (`mesheryctl system start`) with the cluster connected.

## Import into Meshery

Import a design from a local file (run from the repository root):

```bash
mesheryctl design import -f designs/vllm-inference-stack.yaml -s "Kubernetes Manifest"
```

…or straight from its raw URL once this content is merged:

```bash
mesheryctl design import \
  -f https://raw.githubusercontent.com/layer5io/digitalocean-academy/master/designs/qdrant-vector-db.yaml \
  -s "Kubernetes Manifest"
```

After importing, open the design in **Kanvas** to inspect components and relationships, validate the
configuration, and deploy it to your DOKS cluster. You can also save it to the **Meshery Catalog** as
a reusable template.

## Apply directly with kubectl (quick start)

```bash
kubectl apply -f designs/qdrant-vector-db.yaml
kubectl -n ai-data get pods,svc,pvc
```

## Performance-test the inference endpoint

Once the vLLM design is deployed, run a Meshery Performance Profile against the Service:

```bash
mesheryctl perf apply llm-bench \
  --url http://vllm-llama.ai-inference.svc.cluster.local/v1/models \
  --load-generator fortio --concurrent-requests 10 --duration 60s
```

> Notes
> - The vLLM Deployment references an optional `hf-token` secret for gated Hugging Face models; create
>   it before deploying gated models, or switch `--model` to an open model.
> - These designs are intentionally minimal and education-focused. Harden resource limits, replicas,
>   ingress, and network policy before any production use.
