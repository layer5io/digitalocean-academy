---
type: "page"
id: "full-fine-tuning-vs-lora"
title: "Full Fine-Tuning vs LoRA"
description: "Compare full fine-tuning and parameter-efficient methods like LoRA and QLoRA to decide which approach fits your GPU memory, dataset size, and quality requirements."
weight: 1
---

## What Fine-Tuning Achieves

Pre-trained foundation models are excellent at general language tasks but may underperform on narrow domains, specific output formats, or proprietary terminology. Fine-tuning adapts a pre-trained model to your task using labeled examples, improving accuracy without training from scratch.

Two broad approaches exist: **full fine-tuning** and **parameter-efficient fine-tuning (PEFT)**, the most popular form of which is LoRA.

## Full Fine-Tuning

Full fine-tuning updates every parameter in the model during training. All attention weights, feed-forward layers, and embeddings receive gradient updates.

**Advantages:**
- Maximum adaptation—the model can change significantly to fit your domain.
- Suitable when your dataset is large (millions of examples) and diverges substantially from the pre-training distribution.

**Disadvantages:**
- VRAM requirement is very high. A 7B model in FP32 requires roughly 28 GB just for weights, plus an equal or larger amount for optimizer states (Adam stores first and second moment estimates for every parameter). In practice, full fine-tuning of a 7B model requires 80+ GB VRAM—at minimum a single H100.
- For a 70B model, full fine-tuning requires multiple H100 GPUs in parallel.
- Training time is proportional to the parameter count.

## LoRA: Low-Rank Adaptation

LoRA (Low-Rank Adaptation) is the most widely used PEFT method. Instead of updating all model weights, LoRA freezes the original weights and injects small trainable rank-decomposition matrices alongside selected layers (usually the attention projection matrices).

During training, only these small adapter matrices are updated. The number of trainable parameters is typically 0.1–1% of the original model's parameters.

**Advantages:**
- Dramatically lower VRAM. A 7B model with LoRA rank 16 trains comfortably on an RTX 6000 Ada (48 GB) or even an RTX 4000 Ada (20 GB) with quantization.
- Fast iteration—adapter training can complete in hours rather than days.
- Multiple LoRA adapters can be swapped onto the same base model at runtime.

**Disadvantages:**
- Maximum adaptation is constrained by the rank. Very large domain shifts may require a higher rank or full fine-tuning.

## QLoRA

QLoRA combines 4-bit quantization of the frozen base model weights with LoRA adapters trained in higher precision. This further reduces the base model's VRAM footprint, making it possible to fine-tune a 13B model on a single RTX 6000 Ada (48 GB).

```
QLoRA = 4-bit quantized base weights (NF4) + LoRA adapters (BF16)
```

The Hugging Face `peft` and `bitsandbytes` libraries implement QLoRA with a few lines of configuration.

## Choosing an Approach

| Scenario | Recommended method |
|----------|-------------------|
| Small dataset (< 10K examples), tight GPU budget | QLoRA |
| Moderate dataset, 1–2 GPUs available | LoRA |
| Large dataset, major domain shift | Full fine-tuning on multi-GPU Droplet |
| Need to swap adapters per tenant/task | LoRA (multiple adapters, one base) |

For most practitioners starting out, **QLoRA is the right default**: it achieves near-full fine-tuning quality on most tasks while fitting on a single GPU Droplet. Reserve full fine-tuning for cases where you have empirically confirmed that LoRA quality is insufficient.

For more on GPU Droplet options for training, see the [GPU Droplets documentation](https://docs.digitalocean.com/products/gpu-droplets/).
