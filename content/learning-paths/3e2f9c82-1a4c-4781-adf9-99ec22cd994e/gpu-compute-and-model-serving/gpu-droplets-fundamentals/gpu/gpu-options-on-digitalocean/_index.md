---
type: "page"
id: "gpu-options-on-digitalocean"
title: "GPU Options on DigitalOcean"
description: "Compare DigitalOcean's GPU lineup—H100, H200, MI300X, L40S, RTX 4000 and 6000 Ada—and learn which configuration fits training versus inference workloads."
weight: 1
---

## Overview

DigitalOcean GPU Droplets give you access to enterprise-grade accelerators without long-term commitments. Droplets come in single-GPU and 8-GPU configurations, letting you match hardware to workload rather than over-provisioning from day one.

## Available GPUs

| GPU | Architecture | VRAM | Best for |
|-----|-------------|------|----------|
| NVIDIA H100 | Hopper | 80 GB HBM2e | Large model training, high-throughput inference |
| NVIDIA H200 | Hopper | 141 GB HBM3e | Very large models, long-context inference |
| AMD MI300X | CDNA 3 | 192 GB HBM3 | Large-batch training, memory-bound workloads |
| NVIDIA L40S | Ada Lovelace | 48 GB GDDR6 | Multi-modal inference, video, mid-scale fine-tuning |
| NVIDIA RTX 6000 Ada | Ada Lovelace | 48 GB GDDR6 | Cost-effective inference, experimentation |
| NVIDIA RTX 4000 Ada | Ada Lovelace | 20 GB GDDR6 | Light inference, development, low-cost testing |

## Single-GPU vs 8-GPU Configurations

A **single-GPU Droplet** is the right starting point for most inference tasks, fine-tuning runs with 7B–13B parameter models, and iterative experimentation. You pay only for one GPU and can destroy the Droplet when the job is done.

An **8-GPU Droplet** is designed for workloads that require parallelism:

- Pre-training or continued pre-training of foundation models
- Multi-GPU tensor parallelism for serving very large models (70B+) at low latency
- Distributed fine-tuning of 30B+ parameter models with full precision weights

## Choosing by Workload

**Training large models**: Start with the H100 (80 GB HBM) or H200 (141 GB HBM3e) in an 8-GPU configuration. The high-bandwidth memory is critical for keeping large weight matrices and optimizer states resident on-device. The MI300X's 192 GB per card makes it an option when a model's combined weights and activations exceed 80 GB per GPU.

**Inference at scale**: The H100 and L40S are the most common choices. The L40S strikes a good balance between cost and throughput for 7B–34B models at moderate request rates. The H100 becomes worthwhile when you need sub-100 ms time-to-first-token at high concurrency.

**Development and experimentation**: RTX 4000 Ada or RTX 6000 Ada reduce hourly cost while still supporting CUDA 12 workloads. Both are suitable for testing vLLM, running quantized models, or validating fine-tuning pipelines before scaling up.

**Memory-bound or very large models**: The MI300X's 192 GB per card and ROCm software stack suit workloads that would otherwise require multi-GPU tensor parallelism. Verify that your framework (PyTorch, vLLM) supports ROCm before committing.

## Practical Tips

- Prototype on a single RTX 4000 Ada or RTX 6000 Ada, then promote to H100 for production.
- For inference, memory capacity sets the floor: a 70B model in 16-bit precision requires roughly 140 GB. One MI300X or two H100s (NVLink) can hold that comfortably.
- Destroy Droplets when idle; on-demand billing means you only pay while the Droplet is running.

For the full list of available configurations and current pricing, see the [GPU Droplets documentation](https://docs.digitalocean.com/products/gpu-droplets/).
