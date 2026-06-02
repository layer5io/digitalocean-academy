---
type: "page"
id: "benchmarking-throughput-and-latency"
title: "Benchmarking Throughput & Latency"
description: "Measure tokens per second, time-to-first-token, and p95 latency for a self-hosted LLM endpoint using standard load testing tools."
weight: 4
---

## Key Metrics

Before optimizing, define what you are measuring. Three metrics drive most serving decisions:

| Metric | Definition | Why it matters |
|--------|-----------|---------------|
| Time-to-first-token (TTFT) | Milliseconds from request submission to first output token | Perceived responsiveness in streaming UIs |
| Tokens per second (throughput) | Output tokens generated per second across all concurrent requests | Capacity planning, cost-per-token |
| p95 latency | The 95th-percentile end-to-end response time | Worst-case user experience under load |

A GPU may produce high throughput in aggregate while still having high TTFT if the batch size is large and requests must wait. Both dimensions matter.

## Benchmarking with vLLM's Built-In Tool

vLLM ships a benchmarking script in its repository. Clone the repo on your GPU Droplet and run:

```bash
git clone https://github.com/vllm-project/vllm.git
cd vllm

python benchmarks/benchmark_serving.py \
  --backend vllm \
  --base-url http://localhost:8000 \
  --model meta-llama/Meta-Llama-3.1-8B-Instruct \
  --dataset-name sharegpt \
  --num-prompts 200 \
  --request-rate 10
```

The script simulates 200 requests arriving at 10 requests per second and reports mean TTFT, mean inter-token latency, and total throughput.

## Benchmarking with locust

For HTTP-level load testing with more control over concurrency and ramp-up patterns, use `locust`:

```bash
pip install locust
```

```python
# locustfile.py
from locust import HttpUser, task
import json

class LLMUser(HttpUser):
    @task
    def chat(self):
        self.client.post(
            "/v1/chat/completions",
            json={
                "model": "llama-3-8b",
                "messages": [{"role": "user", "content": "Summarize quantum entanglement."}],
                "max_tokens": 100,
            },
            headers={"Content-Type": "application/json"},
        )
```

```bash
locust -f locustfile.py --host http://<host>:8000 \
  --users 50 --spawn-rate 5 --run-time 60s --headless
```

Locust outputs requests/sec, median and p95 response times, and error rates.

## Reading the Prometheus Metrics Endpoint

Both vLLM and TGI expose a `/metrics` endpoint compatible with Prometheus:

```bash
curl http://localhost:8000/metrics | grep -E "vllm|tgi"
```

Key metrics to watch:

- `vllm:gpu_cache_usage_perc` — KV cache utilization; if consistently near 100%, add VRAM or reduce context length.
- `vllm:num_requests_running` — current in-flight requests; compare against your target concurrency.
- `vllm:time_to_first_token_seconds` — histogram of TTFT values; extract the 0.95 quantile.

## Interpreting Results

A single H100 (80 GB) running a Llama 3.1 8B model in FP16 with continuous batching typically achieves 2,000–5,000 output tokens per second at moderate concurrency. Quantizing to AWQ 4-bit can push that to 4,000–8,000 tokens per second with minimal quality impact.

If p95 latency climbs as concurrency increases, the GPU is saturated. Options: reduce `max_tokens` per request, lower `max-num-seqs`, apply quantization, or move to a larger GPU.

For guidance on GPU sizing and available hardware, see the [GPU Droplets documentation](https://docs.digitalocean.com/products/gpu-droplets/).
