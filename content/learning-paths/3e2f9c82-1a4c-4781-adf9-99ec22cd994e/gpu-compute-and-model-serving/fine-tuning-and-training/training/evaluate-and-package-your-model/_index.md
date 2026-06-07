---
type: "page"
id: "evaluate-and-package-your-model"
title: "Evaluate & Package Your Model"
description: "Evaluate a LoRA fine-tune against a held-out set, merge the adapter into the base model, and serve the result with vLLM."
weight: 4
---

## Why Evaluate Before Serving

Training loss tells you the model fit the training data. It does not tell you whether the model generalizes to unseen examples or whether the fine-tuning regressed on general language capabilities. A brief evaluation step on a held-out set catches both problems before you expose the model to users.

## Evaluating on a Held-Out Set

Prepare a small evaluation set in the same JSONL format as your training data. A common approach is to hold out 5–10% of your dataset before training and never use it for weight updates.

```python
from datasets import load_dataset
from transformers import AutoModelForCausalLM, AutoTokenizer, pipeline
from peft import PeftModel
import json

BASE_MODEL = "meta-llama/Meta-Llama-3.1-8B-Instruct"
ADAPTER_PATH = "/scratch/adapter-output"
EVAL_FILE = "/scratch/eval.jsonl"

# Load base + adapter
base = AutoModelForCausalLM.from_pretrained(BASE_MODEL, device_map="auto")
model = PeftModel.from_pretrained(base, ADAPTER_PATH)
tokenizer = AutoTokenizer.from_pretrained(BASE_MODEL)

generator = pipeline("text-generation", model=model, tokenizer=tokenizer)

# Run inference on eval set
with open(EVAL_FILE) as f:
    examples = [json.loads(line) for line in f]

correct = 0
for ex in examples[:100]:   # spot-check 100 examples
    prompt = ex["messages"][-2]["content"]   # last user turn
    expected = ex["messages"][-1]["content"]
    output = generator(prompt, max_new_tokens=100)[0]["generated_text"]
    # Task-specific comparison (exact match, ROUGE, etc.)
    if expected.strip().lower() in output.lower():
        correct += 1

print(f"Accuracy (spot check): {correct}/100")
```

For generative tasks, automated metrics like ROUGE-L or BERTScore complement human spot-checks.

## Merging the LoRA Adapter

A LoRA adapter adds small matrices alongside frozen base weights. Before serving with vLLM, merge the adapter into the base model to produce a single set of full-precision weights. This eliminates the adapter overhead at inference time.

```python
from transformers import AutoModelForCausalLM, AutoTokenizer
from peft import PeftModel

BASE_MODEL = "meta-llama/Meta-Llama-3.1-8B-Instruct"
ADAPTER_PATH = "/scratch/adapter-output"
MERGED_PATH = "/scratch/merged-model"

base = AutoModelForCausalLM.from_pretrained(BASE_MODEL, device_map="cpu")
model = PeftModel.from_pretrained(base, ADAPTER_PATH)
merged = model.merge_and_unload()
merged.save_pretrained(MERGED_PATH)

tokenizer = AutoTokenizer.from_pretrained(BASE_MODEL)
tokenizer.save_pretrained(MERGED_PATH)

print(f"Merged model saved to {MERGED_PATH}")
```

The merged directory contains a standard Hugging Face model—no PEFT dependency needed at serving time.

## Uploading the Merged Model to Spaces

```bash
aws s3 sync /scratch/merged-model/ \
  s3://my-training-bucket/models/llama-3.1-8b-finetuned-v1/ \
  --endpoint-url https://nyc3.digitaloceanspaces.com
```

## Serving the Merged Model with vLLM

On a serving Droplet, download the merged model from Spaces and start vLLM:

```bash
aws s3 sync \
  s3://my-training-bucket/models/llama-3.1-8b-finetuned-v1/ \
  /models/llama-3.1-8b-finetuned-v1/ \
  --endpoint-url https://nyc3.digitaloceanspaces.com

python -m vllm.entrypoints.openai.api_server \
  --model /models/llama-3.1-8b-finetuned-v1 \
  --host 0.0.0.0 \
  --port 8000 \
  --served-model-name my-fine-tuned-model
```

The endpoint is immediately OpenAI-compatible. Any client that worked with the base model works with the fine-tuned version—update only the `model` parameter in your API calls.

For GPU sizing and Spaces documentation, see the [GPU Droplets documentation](https://docs.digitalocean.com/products/gpu-droplets/).
