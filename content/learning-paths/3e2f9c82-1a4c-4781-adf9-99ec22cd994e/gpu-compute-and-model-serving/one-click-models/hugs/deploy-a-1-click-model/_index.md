---
type: "page"
id: "deploy-a-1-click-model"
title: "Deploy a 1-Click Model"
description: "Launch a popular open-weight model such as Llama 3.1 on a GPU Droplet in minutes using DigitalOcean's 1-Click Models, with no manual configuration required."
weight: 1
---

## What Are 1-Click Models?

DigitalOcean's 1-Click Models (internally called HUGS on DO—Hugging Face GPU Serving on DigitalOcean) let you deploy popular open-weight models directly onto a GPU Droplet without manually installing a serving stack, downloading weights, or configuring the API server. You select a model from the catalog, choose a GPU size, and DigitalOcean handles everything else.

Available models include Llama 3.x variants, Mistral, Qwen, Gemma, and Nous Hermes, with the catalog growing regularly. Each deployment runs a pre-optimized serving stack tuned for the specific model and GPU pairing.

## What Gets Installed

When you deploy a 1-Click Model, the Droplet starts with:

- The correct AI/ML image (CUDA for NVIDIA GPUs)
- Model weights pre-downloaded and placed on disk
- A serving process (vLLM or Hugging Face TGI, pre-configured) already running on port 8000
- An OpenAI-compatible REST API endpoint (`/v1/chat/completions`, `/v1/completions`, `/v1/models`)

No SSH session required to start the server—it is running before the Droplet finishes provisioning.

## Deploying Llama 3.1 via the Control Panel

1. Navigate to **AI/ML > 1-Click Models** in the DigitalOcean Control Panel.
2. Select **Llama 3.1 8B Instruct** (or another model from the catalog).
3. Choose a GPU size. The catalog displays recommended hardware; a 1× RTX 6000 Ada is sufficient for the 8B model, while 70B variants require an H100 or larger.
4. Select your region and SSH key.
5. Click **Deploy**. The Droplet is ready in under 60 seconds.

The Control Panel shows the Droplet's public IP address once provisioning completes.

## Verifying the Deployment

SSH into the Droplet and check that the server is listening:

```bash
ssh root@<public-ipv4>
curl http://localhost:8000/v1/models
```

The response lists the loaded model name and confirms the endpoint is live:

```json
{
  "object": "list",
  "data": [
    {
      "id": "meta-llama/Meta-Llama-3.1-8B-Instruct",
      "object": "model"
    }
  ]
}
```

## Sending Your First Request

With the server running, send a chat completion request from inside the Droplet or from your local machine (replace `<public-ipv4>` with the Droplet's IP):

```bash
curl http://<public-ipv4>:8000/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "meta-llama/Meta-Llama-3.1-8B-Instruct",
    "messages": [{"role": "user", "content": "What is the capital of France?"}]
  }'
```

Because the endpoint is OpenAI-compatible, any existing code that uses the `openai` Python SDK works without modification—just change `base_url` to point at your Droplet.

## Next Steps

The next lesson covers calling this endpoint programmatically using `curl` and the `openai` Python SDK in more depth. For the full model catalog and supported GPU sizes, see the [1-Click Models page](https://www.digitalocean.com/products/1-click-models).
