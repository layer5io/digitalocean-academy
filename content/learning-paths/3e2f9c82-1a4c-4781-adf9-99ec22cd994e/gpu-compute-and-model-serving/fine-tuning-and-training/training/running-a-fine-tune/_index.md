---
type: "page"
id: "running-a-fine-tune"
title: "Running a Fine-Tune"
description: "Run a LoRA fine-tune on a GPU Droplet using Hugging Face PEFT and transformers, then save the trained adapter to DigitalOcean Spaces."
weight: 3
---

## Prerequisites

This lesson assumes you have:

- A GPU Droplet running an AI/ML image (CUDA, NVIDIA driver pre-installed)
- A JSONL dataset uploaded to DigitalOcean Spaces (covered in the previous lesson)
- A Hugging Face access token for gated model weights

Install the required Python packages:

```bash
pip install transformers peft datasets bitsandbytes accelerate trl awscli
```

## Download the Dataset from Spaces

Pull the training data to the Droplet's scratch disk:

```bash
aws s3 cp \
  s3://my-training-bucket/datasets/v2/train.jsonl \
  /scratch/train.jsonl \
  --endpoint-url https://nyc3.digitaloceanspaces.com
```

## Fine-Tuning Script with QLoRA

The following script fine-tunes Llama 3.1 8B Instruct with 4-bit QLoRA using Hugging Face PEFT and the SFTTrainer from `trl`:

```python
import torch
from datasets import load_dataset
from transformers import AutoModelForCausalLM, AutoTokenizer, BitsAndBytesConfig
from peft import LoraConfig, get_peft_model
from trl import SFTTrainer, SFTConfig

MODEL_ID = "meta-llama/Meta-Llama-3.1-8B-Instruct"
OUTPUT_DIR = "/scratch/adapter-output"

# 4-bit quantization config
bnb_config = BitsAndBytesConfig(
    load_in_4bit=True,
    bnb_4bit_quant_type="nf4",
    bnb_4bit_compute_dtype=torch.bfloat16,
)

# Load model in 4-bit
model = AutoModelForCausalLM.from_pretrained(
    MODEL_ID,
    quantization_config=bnb_config,
    device_map="auto",
)
tokenizer = AutoTokenizer.from_pretrained(MODEL_ID)
tokenizer.pad_token = tokenizer.eos_token

# LoRA configuration
lora_config = LoraConfig(
    r=16,
    lora_alpha=32,
    target_modules=["q_proj", "v_proj"],
    lora_dropout=0.05,
    bias="none",
    task_type="CAUSAL_LM",
)
model = get_peft_model(model, lora_config)
model.print_trainable_parameters()

# Load dataset
dataset = load_dataset("json", data_files="/scratch/train.jsonl", split="train")

# Training
trainer = SFTTrainer(
    model=model,
    train_dataset=dataset,
    args=SFTConfig(
        output_dir=OUTPUT_DIR,
        num_train_epochs=3,
        per_device_train_batch_size=4,
        gradient_accumulation_steps=4,
        learning_rate=2e-4,
        bf16=True,
        logging_steps=10,
        save_steps=100,
    ),
)

trainer.train()
trainer.save_model(OUTPUT_DIR)
```

`model.print_trainable_parameters()` confirms that only the LoRA adapter weights are being trained—typically a fraction of a percent of total parameters.

## Monitoring GPU Usage During Training

In a second SSH session, watch GPU utilization and memory:

```bash
watch -n 2 nvidia-smi
```

For a 7B model with rank-16 LoRA on a single H100, expect training throughput of roughly 2,000–5,000 tokens per second and VRAM usage around 20–40 GB depending on batch size and sequence length.

## Saving the Adapter to Spaces

After training completes, upload the adapter weights to Spaces for long-term storage:

```bash
aws s3 sync /scratch/adapter-output/ \
  s3://my-training-bucket/checkpoints/llama-3.1-8b-lora-v1/ \
  --endpoint-url https://nyc3.digitaloceanspaces.com
```

The adapter directory is small (typically 50–500 MB for a rank-16 LoRA) compared to the full model weights, making storage and transfer fast.

The next lesson covers evaluating the fine-tuned adapter and packaging it for serving. For GPU Droplet options suited for training, see the [GPU Droplets documentation](https://docs.digitalocean.com/products/gpu-droplets/).
