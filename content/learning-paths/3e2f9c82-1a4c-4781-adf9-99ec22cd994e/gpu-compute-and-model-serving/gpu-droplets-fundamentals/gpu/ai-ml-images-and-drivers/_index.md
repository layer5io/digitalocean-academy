---
type: "page"
id: "ai-ml-images-and-drivers"
title: "AI/ML Images & Drivers"
description: "Understand DigitalOcean's AI/ML-ready Droplet images, when to use CUDA versus ROCm, how to verify GPU access, and the difference between boot and scratch disks."
weight: 2
---

## AI/ML-Ready Images

When you create a GPU Droplet, DigitalOcean offers purpose-built AI/ML images alongside standard OS images. These images ship with the GPU drivers, runtime libraries, and toolchains pre-installed, so you can start a training run or inference server within minutes of provisioning rather than spending an hour configuring the software stack.

What an AI/ML image typically includes:

- NVIDIA drivers (for H100, H200, L40S, RTX 4000/6000 Ada)
- CUDA Toolkit and cuDNN
- AMD ROCm drivers and HIP runtime (for MI300X)
- Python with common ML packages (PyTorch, NumPy)
- Docker with the NVIDIA Container Toolkit (for NVIDIA GPUs) or ROCm Docker support (for AMD)

## CUDA vs ROCm

CUDA is NVIDIA's parallel computing platform. All NVIDIA GPU Droplets (H100, H200, L40S, RTX 4000 Ada, RTX 6000 Ada) use CUDA. The ecosystem is mature, and nearly all open-source ML frameworks—PyTorch, TensorFlow, JAX—target CUDA by default.

ROCm is AMD's open-source GPU compute stack. MI300X Droplets run ROCm. PyTorch supports ROCm through its `rocm` build variant. Before using the MI300X, verify that your specific library versions (vLLM, PEFT, Flash Attention) have published ROCm-compatible releases.

A quick check of which runtime is active:

```bash
# NVIDIA GPU Droplets
nvidia-smi

# AMD GPU Droplets
rocm-smi
```

## Verifying the GPU with nvidia-smi

After SSH-ing into an NVIDIA GPU Droplet, run:

```bash
nvidia-smi
```

The output shows the driver version, CUDA version, GPU model, memory usage, and running processes. A healthy single-H100 Droplet looks similar to:

```
+-----------------------------------------------------------------------------+
| NVIDIA-SMI 550.xx.xx    Driver Version: 550.xx.xx    CUDA Version: 12.x    |
|-------------------------------+----------------------+----------------------+
| GPU  Name        Persistence-M| Bus-Id        Disp.A | Volatile Uncorr. ECC |
| Fan  Temp  Perf  Pwr:Usage/Cap|         Memory-Usage | GPU-Util  Compute M. |
|===============================+======================+======================|
|   0  NVIDIA H100 80GB HBM2e  Off| 00000000:01:00.0 Off |                    0 |
| N/A   32C    P0    70W / 700W |      1MiB / 81920MiB |      0%      Default |
+-----------------------------------------------------------------------------+
```

If `nvidia-smi` is not found, the NVIDIA driver is not installed. Use the AI/ML image or install the driver manually from the CUDA repository.

## Boot Disks and Scratch Disks

GPU Droplets attach two types of storage:

**Boot disk** — persistent block storage that survives reboots and Droplet resizing. Store your operating system, installed packages, model checkpoints you want to keep, and any code repository here. Write to `/root` or a mounted volume attached to this disk.

**Scratch disk** — temporary local NVMe storage with higher throughput, but the data is lost when the Droplet is powered off or destroyed. Use scratch storage for intermediate outputs, unpacked datasets during training, and inference caches where regenerating the data is fast. On many GPU Droplets the scratch disk mounts at `/scratch` or `/mnt/scratch`.

A common pattern is to download your dataset from DigitalOcean Spaces to the scratch disk at job start, run training, then upload the final checkpoint back to Spaces before destroying the Droplet.

For more details on AI/ML images and storage layout, see the [GPU Droplets documentation](https://docs.digitalocean.com/products/gpu-droplets/).
