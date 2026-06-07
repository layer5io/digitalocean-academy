---
type: "page"
id: "from-poc-to-production"
title: "From POC to Production"
description: "Graduate a 1-Click Model proof-of-concept to a production deployment by keeping the OpenAI-compatible interface while adding reliability, security, and scale."
weight: 4
---

## The POC-to-Production Gap

A 1-Click Model deployment gets a working endpoint in minutes—ideal for validating a use case. Moving that to production means addressing concerns that do not matter during a proof-of-concept: reliability under load, secure network exposure, observability, and the ability to scale when demand spikes. The good news is that none of this requires changing your application code, because the OpenAI-compatible interface stays constant.

## Keep the Interface Stable

The central advantage of the OpenAI-compatible API is that your application is decoupled from the serving infrastructure. Whether you are running a 1-Click Model on a single Droplet, a self-hosted vLLM cluster, or a multi-GPU deployment, the same `client.chat.completions.create(...)` call works. Design your application against the interface, not against a specific IP address.

Store the base URL and model name as environment variables:

```bash
export LLM_BASE_URL="http://<host>:8000/v1"
export LLM_MODEL="meta-llama/Meta-Llama-3.1-8B-Instruct"
```

```python
import os
from openai import OpenAI

client = OpenAI(base_url=os.environ["LLM_BASE_URL"], api_key="not-used")
model = os.environ["LLM_MODEL"]
```

Swapping the backend is a one-line environment variable change, with no code deployment.

## Harden the Network

A freshly deployed Droplet listens on port 8000 and is reachable from the public internet. For production:

- Place a load balancer or reverse proxy (nginx, Caddy) in front of the Droplet to terminate TLS.
- Restrict port 8000 in the Droplet firewall to accept traffic only from your load balancer's private IP.
- Add an API key check at the proxy layer if external clients need to authenticate.

```bash
# Restrict port 8000 to internal traffic only via doctl firewall
doctl compute firewall create \
  --name llm-fw \
  --inbound-rules "protocol:tcp,ports:8000,address:10.0.0.0/8" \
  --droplet-ids <droplet-id>
```

## Scale Horizontally

One Droplet handles one model instance. When request volume exceeds that instance's throughput, add more Droplets behind the load balancer. Because every instance exposes the same OpenAI-compatible API, the load balancer can round-robin across them without any application-level awareness.

For very large models (70B+) that require tensor parallelism across multiple GPUs, move to a DOKS-based deployment with llm-d or KServe, covered in the Distributed Inference course.

## Add Observability

Before considering a deployment production-ready, instrument these three signals:

| Signal | What to measure |
|--------|----------------|
| Latency | Time-to-first-token (TTFT), end-to-end response time |
| Throughput | Requests per second, tokens per second |
| Errors | HTTP 4xx/5xx rates, timeout rates |

Both vLLM and TGI expose Prometheus-compatible metrics at `/metrics`. Scrape with a Prometheus instance and visualize in Grafana.

## Upgrade Path

If your model needs grow beyond a single Droplet, the upgrade path is incremental: move from 1-Click Models to a self-hosted vLLM deployment (covered in the Self-Hosting LLMs course) or to GPU node pools on DOKS for Kubernetes-native orchestration. At every stage, your application code stays the same because the API contract does not change.

For detailed deployment options, see the [1-Click Models page](https://www.digitalocean.com/products/1-click-models).
