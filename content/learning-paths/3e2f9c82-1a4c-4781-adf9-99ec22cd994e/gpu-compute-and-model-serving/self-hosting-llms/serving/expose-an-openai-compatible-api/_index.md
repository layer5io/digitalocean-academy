---
type: "page"
id: "expose-an-openai-compatible-api"
title: "Expose an OpenAI-Compatible API"
description: "Configure vLLM or TGI to expose an OpenAI-compatible REST API and test it with the Python openai SDK pointed at your GPU Droplet."
weight: 3
---

## Why OpenAI Compatibility Matters

Both vLLM and TGI implement the OpenAI Chat Completions API contract. This means any code written for the OpenAI API—SDKs, frameworks like LangChain, and proxy layers—works unchanged with a self-hosted model. You point `base_url` at your server and the rest of the stack stays the same.

## Exposing the Endpoint with vLLM

vLLM's built-in OpenAI server starts with a single command. The `--host 0.0.0.0` flag binds to all interfaces so the Droplet's public IP is reachable:

```bash
python -m vllm.entrypoints.openai.api_server \
  --model meta-llama/Meta-Llama-3.1-8B-Instruct \
  --host 0.0.0.0 \
  --port 8000 \
  --served-model-name llama-3-8b
```

The `--served-model-name` alias lets you reference the model by a short name in API calls instead of the full Hugging Face path.

## Exposing the Endpoint with TGI

TGI exposes an OpenAI-compatible server at the `/v1` prefix:

```bash
docker run --gpus all \
  -p 8000:80 \
  -e HUGGING_FACE_HUB_TOKEN=$HF_TOKEN \
  ghcr.io/huggingface/text-generation-inference:latest \
  --model-id meta-llama/Meta-Llama-3.1-8B-Instruct \
  --hostname 0.0.0.0 \
  --port 80
```

With the `-p 8000:80` port mapping, the endpoint is at `http://<host>:8000/v1`.

## Testing with curl

```bash
# List loaded models
curl http://<host>:8000/v1/models

# Send a chat completion
curl http://<host>:8000/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "llama-3-8b",
    "messages": [
      {"role": "user", "content": "What is tensor parallelism?"}
    ],
    "max_tokens": 150
  }'
```

## Testing with the Python openai SDK

```python
from openai import OpenAI

client = OpenAI(
    base_url="http://<host>:8000/v1",
    api_key="not-required",
)

response = client.chat.completions.create(
    model="llama-3-8b",
    messages=[
        {"role": "user", "content": "What is tensor parallelism?"}
    ],
    max_tokens=150,
)

print(response.choices[0].message.content)
```

## Adding a Simple API Key

Neither vLLM nor TGI enforce authentication by default. For production, add a reverse proxy such as nginx or Caddy that validates a bearer token before forwarding requests to the model server. A minimal nginx snippet:

```bash
# In nginx.conf location block
if ($http_authorization != "Bearer mysecrettoken") {
    return 401;
}
proxy_pass http://127.0.0.1:8000;
```

Your clients then pass `api_key="mysecrettoken"` in the SDK—the same field the OpenAI SDK uses for authentication.

## Running as a Systemd Service

To keep the server alive across reboots or SSH disconnections, create a systemd unit:

```bash
cat > /etc/systemd/system/vllm.service << 'EOF'
[Unit]
Description=vLLM OpenAI Server

[Service]
ExecStart=python -m vllm.entrypoints.openai.api_server \
  --model meta-llama/Meta-Llama-3.1-8B-Instruct \
  --host 0.0.0.0 --port 8000
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

systemctl enable --now vllm
```

For more on self-hosting options and available models, see the [GPU Droplets documentation](https://docs.digitalocean.com/products/gpu-droplets/).
