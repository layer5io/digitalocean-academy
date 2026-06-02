---
type: "page"
id: "evaluations-as-a-quality-gate"
title: "Evaluations as a Quality Gate"
description: "Run LLM-as-a-judge Evaluations in CI and fail the build automatically when quality, latency, or cost regressions are detected."
weight: 2
---

## What Are Evaluations?

DigitalOcean's Evaluations feature uses an LLM as a judge to automatically score model outputs against criteria you define: quality, factual accuracy, response latency, token cost, and safety. By running Evaluations in CI, you turn subjective model quality into a measurable, automatable signal — the same way unit tests turn software correctness into a pass/fail signal.

## The Evaluation Loop in CI

```
PR opened
  → build & unit tests pass
  → Evaluation job runs:
      run golden-set prompts against the candidate model
      judge scores each response
      compare scores to baseline thresholds
      if any score below threshold → fail the build, block merge
  → deploy only if all gates pass
```

## Defining Evaluation Criteria

Create an evaluation configuration that specifies the golden prompt set, the judge model, and the pass thresholds:

```yaml
# evaluations/config.yaml
evaluation:
  name: "summarizer-quality-gate"
  judge_model: "meta-llama/Meta-Llama-3.1-70B-Instruct"
  golden_set: "evaluations/golden_prompts.jsonl"
  thresholds:
    quality_score:    0.80   # LLM judge score 0–1
    latency_p95_ms:   2000
    cost_per_1k_usd:  0.50
  on_failure: "block"
```

The golden set is a JSONL file with input prompts and (optionally) reference answers:

```jsonl
{"id": "sum-001", "prompt": "Summarize the following: ...", "reference": "..."}
{"id": "sum-002", "prompt": "What is the main argument of: ...", "reference": "..."}
```

## Running Evaluations in GitHub Actions

Add an evaluation job after the build step:

```yaml
  evaluate:
    runs-on: ubuntu-latest
    needs: build
    env:
      MODEL_ACCESS_KEY: ${{ secrets.STAGING_MODEL_ACCESS_KEY }}
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with:
          python-version: "3.12"
      - run: pip install -r requirements-eval.txt

      - name: Run evaluations
        run: |
          python scripts/run_evaluations.py \
            --config evaluations/config.yaml \
            --model "meta-llama/Meta-Llama-3.1-70B-Instruct" \
            --output evaluations/results.json

      - name: Check thresholds
        run: |
          python scripts/check_thresholds.py \
            --results evaluations/results.json \
            --config evaluations/config.yaml

      - name: Upload evaluation report
        uses: actions/upload-artifact@v4
        with:
          name: evaluation-report
          path: evaluations/results.json
```

The `check_thresholds.py` script exits with code 1 if any metric is below its threshold, causing the CI job to fail and blocking the PR from merging.

## Threshold Check Script Pattern

```python
import json
import sys

def check_thresholds(results_path: str, config_path: str):
    with open(results_path) as f:
        results = json.load(f)
    with open(config_path) as f:
        import yaml
        config = yaml.safe_load(f)

    thresholds = config["evaluation"]["thresholds"]
    failures = []

    if results["quality_score"] < thresholds["quality_score"]:
        failures.append(
            f"Quality {results['quality_score']:.2f} < {thresholds['quality_score']}"
        )
    if results["latency_p95_ms"] > thresholds["latency_p95_ms"]:
        failures.append(
            f"Latency {results['latency_p95_ms']}ms > {thresholds['latency_p95_ms']}ms"
        )

    if failures:
        print("EVALUATION GATE FAILED:")
        for f in failures:
            print(f"  - {f}")
        sys.exit(1)

    print("All evaluation thresholds passed.")
```

## Baseline Management

Store baseline evaluation results alongside golden prompts in source control. When you intentionally upgrade a model and accept the new performance characteristics, update the baseline and thresholds in the same PR. This creates an explicit, reviewed record of every quality trade-off.

For Evaluation configuration and judge model options, see the [DigitalOcean Gradient AI Platform docs](https://docs.digitalocean.com/products/gradient-ai-platform/).
