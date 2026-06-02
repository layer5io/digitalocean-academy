---
type: "page"
id: "cost-and-right-sizing"
title: "Cost & Right-Sizing"
description: "Understand per-GPU-hour billing, realistic cost ranges, and how to choose the right GPU size so you don't overpay for your workload."
weight: 4
---

## How Billing Works

GPU Droplets are billed per GPU-hour and metered by the second, so you pay only for the time the Droplet exists. The clock starts when the Droplet is created and stops when it is destroyed. A powered-off (but not destroyed) Droplet still accrues charges because the underlying hardware remains reserved for you.

Indicative on-demand price ranges (check current pricing in the Control Panel):

| GPU | Approx. price range |
|-----|-------------------|
| RTX 4000 Ada | ~$0.76–$1.20 / GPU-hour |
| RTX 6000 Ada | ~$1.20–$2.00 / GPU-hour |
| L40S | ~$2.00–$3.50 / GPU-hour |
| H100 (80 GB) | ~$3.50–$5.00 / GPU-hour |
| H200 | ~$5.00–$7.99 / GPU-hour |

Prices vary by region and configuration. Always confirm current pricing in the DigitalOcean Control Panel before planning your budget.

## Choosing the Right Size

Ask three questions before picking a GPU:

**1. Does the model fit in VRAM?**
A 7B model in 16-bit precision (BF16/FP16) requires roughly 14 GB. A 70B model needs roughly 140 GB. Add 20–30% for KV cache and activations during inference. If the model does not fit, you either need more VRAM, a quantized variant, or multi-GPU tensor parallelism.

**2. What is my throughput requirement?**
High-throughput serving (hundreds of concurrent requests) favors the H100 or L40S. Low-concurrency or development workloads fit well on the RTX 6000 Ada at a lower hourly rate.

**3. How long will the job run?**
Short, bursty jobs (< 2 hours) cost almost nothing. Continuous serving requires ongoing spend. For continuous inference, compare the hourly cost against Reserved Droplet pricing if your workload runs 24/7.

## Cost Control Patterns

**Destroy when idle.** A fine-tuning run that completes in 4 hours costs 4× the hourly rate. Destroy the Droplet immediately after. Save outputs to Spaces before destroying.

```bash
# After your training job exits
doctl compute droplet delete my-training-droplet --force
```

**Start small, scale up.** Develop and test on an RTX 4000 Ada. Promote to an H100 only for the final production run. Most bugs surface at small scale.

**Use snapshots for fast restart.** If you repeatedly configure the same environment, take a Droplet snapshot after setup. Restoring from a snapshot is faster and costs less than reinstalling dependencies on a fresh Droplet.

```bash
doctl compute droplet-action snapshot <droplet-id> --snapshot-name my-gpu-env
```

**Estimate before running.** Rough estimate formula: `(job_hours) × (gpus) × (price_per_gpu_hour)`. A 3-hour fine-tune on 4× H100s at ~$4.50/GPU-hour costs approximately $54.

## Multi-GPU Cost Considerations

An 8-GPU configuration multiplies your hourly cost by 8. Use multi-GPU Droplets only when the workload genuinely benefits from parallelism—large-batch training, tensor-parallel inference of 70B+ models, or data-parallel jobs that scale linearly. For smaller models, a single GPU with optimized batching almost always delivers better cost-efficiency than splitting across multiple GPUs.

For full pricing details and Reserved Droplet options, see the [GPU Droplets documentation](https://docs.digitalocean.com/products/gpu-droplets/).
