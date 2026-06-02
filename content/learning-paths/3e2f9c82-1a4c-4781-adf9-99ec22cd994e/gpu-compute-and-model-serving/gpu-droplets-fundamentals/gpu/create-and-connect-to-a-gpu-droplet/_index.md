---
type: "page"
id: "create-and-connect-to-a-gpu-droplet"
title: "Create & Connect to a GPU Droplet"
description: "Provision a GPU Droplet via the DigitalOcean Control Panel or doctl, connect over SSH, and confirm the GPU is ready with nvidia-smi."
weight: 3
---

## Two Ways to Create a GPU Droplet

You can provision a GPU Droplet through the web-based Control Panel or entirely from the command line with `doctl`. Both methods reach the same API and produce the same result.

## Using the Control Panel

1. Log in to [cloud.digitalocean.com](https://cloud.digitalocean.com) and click **Create > Droplets**.
2. Select a region that lists GPU Droplets (not all regions carry GPU inventory).
3. Under **Choose an image**, select the **AI/ML** tab and pick the image that matches your GPU vendor (CUDA for NVIDIA, ROCm for AMD).
4. Under **Choose a plan**, click the **GPU** tab and select the size you need (for example, 1x H100 80 GB).
5. Add your SSH key under **Authentication**.
6. Click **Create Droplet**. The Droplet is ready in under 60 seconds.

## Using doctl

Install and authenticate `doctl` first:

```bash
# Install doctl (Linux)
snap install doctl
doctl auth init   # paste your Personal Access Token when prompted
```

List available GPU sizes in a region to confirm inventory:

```bash
doctl compute size list | grep gpu
```

Create the Droplet:

```bash
doctl compute droplet create my-gpu-droplet \
  --region nyc3 \
  --size gpu-h100x1-80gb \
  --image gpu-h100x1-base \
  --ssh-keys <your-ssh-key-fingerprint> \
  --wait
```

The `--wait` flag blocks until the Droplet reaches the `active` state. Typical provisioning time is under 60 seconds. Once complete, retrieve the IP:

```bash
doctl compute droplet get my-gpu-droplet --format PublicIPv4
```

## Connecting Over SSH

```bash
ssh root@<public-ipv4>
```

Accept the host key fingerprint on the first connection. You will land in a standard bash shell as `root`.

## Verifying the GPU

Run `nvidia-smi` immediately after login to confirm the driver is loaded and the GPU is visible:

```bash
nvidia-smi
```

Expected output includes the driver version, CUDA version, the GPU model (e.g., `NVIDIA H100 80GB HBM2e`), memory usage, and an empty process table. If the command is not found, the Droplet may have booted from a non-AI/ML image; verify the image name with `doctl compute droplet get my-gpu-droplet --format Image`.

## Cleaning Up

Destroy the Droplet when you no longer need it to stop billing:

```bash
doctl compute droplet delete my-gpu-droplet --force
```

For a full reference on `doctl compute droplet create` flags, see the [doctl reference documentation](https://docs.digitalocean.com/reference/doctl/).
