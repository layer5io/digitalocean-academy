---
type: "page"
id: "evaluating-your-prompts"
title: "Evaluating Your Prompts"
description: "Build a lightweight evaluation harness, define test cases, iterate on prompts before scaling, and understand where a formal Evaluations service fits in."
weight: 4
---

## Overview

A prompt that works on three examples may fail on the fourth. Systematic evaluation — running your prompt against a representative set of test cases before deploying — is the difference between a reliable feature and a support ticket waiting to happen. This lesson gives you a minimal, practical framework you can run locally before scaling up.

## The Evaluation Loop

The core loop is straightforward:

1. Define a set of test cases (input → expected output or quality criteria).
2. Run each test case against the current prompt.
3. Score each result.
4. Edit the prompt and repeat until the pass rate meets your threshold.

This loop should take minutes per iteration, not hours. Keep it fast by starting with 10–20 test cases rather than hundreds.

## Building a Test Case Set

A test case has three parts:

| Field | Description |
|---|---|
| `input` | The user message the prompt will receive |
| `expected` | The ideal output, or criteria it must satisfy |
| `label` | A short name for reporting |

Store test cases in a JSON file:

```json
[
  {
    "label": "happy-path-billing",
    "input": "How do I download my invoice?",
    "expected_contains": "invoice"
  },
  {
    "label": "out-of-scope-competitor",
    "input": "Is AWS cheaper than DigitalOcean?",
    "expected_not_contains": "AWS is"
  },
  {
    "label": "edge-empty-input",
    "input": "",
    "expected_contains": "can you"
  }
]
```

## Running the Evaluation

```python
import os, json
from openai import OpenAI

client = OpenAI(
    base_url="https://inference.do-ai.run/v1",
    api_key=os.environ["DO_INFERENCE_KEY"],
)

SYSTEM_PROMPT = """You are a support assistant for CloudCo.
Answer questions about billing, Droplets, and DNS only.
If out of scope, say: 'I can only help with billing, Droplets, and DNS questions.'"""

def run_eval(test_cases: list[dict]) -> None:
    passed = 0
    for tc in test_cases:
        response = client.chat.completions.create(
            model="meta-llama/Meta-Llama-3.1-8B-Instruct",
            messages=[
                {"role": "system", "content": SYSTEM_PROMPT},
                {"role": "user", "content": tc["input"]},
            ],
            temperature=0.0,
            max_tokens=200,
        )
        reply = response.choices[0].message.content.lower()

        ok = True
        if "expected_contains" in tc and tc["expected_contains"] not in reply:
            ok = False
        if "expected_not_contains" in tc and tc["expected_not_contains"].lower() in reply:
            ok = False

        status = "PASS" if ok else "FAIL"
        if ok:
            passed += 1
        print(f"[{status}] {tc['label']}")

    print(f"\n{passed}/{len(test_cases)} passed")

with open("test_cases.json") as f:
    cases = json.load(f)

run_eval(cases)
```

Run this after every prompt change. A failing test that was previously passing is a regression — revert the change or fix the new edge case before deploying.

## Iterating Effectively

- **Fix the most common failure type first.** If 6 of 10 failures are out-of-scope leakage, tighten the scope instruction before fixing formatting issues.
- **Add a test case for every bug you find in production.** This builds a regression suite over time.
- **Use `temperature: 0.0` during evaluation.** Deterministic outputs make pass/fail stable across runs.
- **Track pass rates per category** (happy path, edge case, adversarial) to see which areas need work.

## Before Scaling

Before moving from 20 test cases to 2,000 — or from a prototype to production traffic — validate:

- Pass rate on happy-path cases is above your quality bar (e.g., 95%).
- No adversarial input in your test set produces a guardrail bypass.
- Format compliance (JSON validity, word count) is consistent across all cases.

## Looking Ahead: Evaluations Services

Manual test harnesses work well at small scale. As your application grows, dedicated evaluation services automate this loop, run LLM-as-a-judge scoring, track prompt versions, and surface regressions in CI/CD. DigitalOcean's AI roadmap includes an Evaluations service that integrates directly with Gradient agents — when available it will replace much of the manual harness shown here.

For current tooling, see [docs.digitalocean.com/products/gradient-ai-platform/](https://docs.digitalocean.com/products/gradient-ai-platform/).
