---
type: "page"
id: "building-and-testing-in-ci"
title: "Building & Testing in CI"
description: "Set up a GitHub Actions workflow to build, lint, and test an AI application before deployment."
weight: 1
---

## CI Fundamentals for AI Applications

A CI pipeline for an AI application has the same core jobs as any software project — lint, test, build — plus AI-specific steps: prompt regression tests, embedding pipeline smoke tests, and evaluation gates. This lesson covers the base pipeline; the next lesson adds Evaluations as a quality gate on top of it.

## Recommended Pipeline Structure

```
on: push / pull_request
  ├── lint          (ruff, mypy, or eslint)
  ├── unit-tests    (pytest / jest — mock the inference API)
  ├── build         (docker build + push to registry)
  └── evaluate      (run Evaluations — covered in next lesson)
```

## Example GitHub Actions Workflow

```yaml
name: AI Application CI

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

env:
  REGISTRY: registry.digitalocean.com/myteam
  IMAGE: inference-service

jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with:
          python-version: "3.12"
      - run: pip install ruff mypy
      - run: ruff check .
      - run: mypy src/

  test:
    runs-on: ubuntu-latest
    needs: lint
    env:
      # Point tests at a mock or staging endpoint — never production
      OPENAI_BASE_URL: "https://inference.do-ai.run/v1"
      MODEL_ACCESS_KEY: ${{ secrets.STAGING_MODEL_ACCESS_KEY }}
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with:
          python-version: "3.12"
      - run: pip install -r requirements.txt
      - run: pytest tests/ -v --tb=short

  build:
    runs-on: ubuntu-latest
    needs: test
    steps:
      - uses: actions/checkout@v4
      - name: Install doctl
        uses: digitalocean/action-doctl@v2
        with:
          token: ${{ secrets.DIGITALOCEAN_ACCESS_TOKEN }}
      - name: Build and push image
        run: |
          doctl registry login
          docker build -t $REGISTRY/$IMAGE:${{ github.sha }} .
          docker push $REGISTRY/$IMAGE:${{ github.sha }}
```

## Testing Patterns for AI Applications

**Unit tests with mocked inference**: mock the OpenAI client so unit tests do not make real API calls. This keeps tests fast and free:

```python
from unittest.mock import MagicMock, patch

def test_summarize_returns_text():
    mock_response = MagicMock()
    mock_response.choices[0].message.content = "A short summary."

    with patch("myapp.inference.client.chat.completions.create",
               return_value=mock_response):
        result = summarize("A long document text here.")
    assert len(result) > 0
```

**Integration tests against a staging model**: tag a small suite of integration tests that call the real Inference Engine with a staging access key. Run these in CI but keep them in a separate job so a flaky API call does not block routine unit test runs.

## Secrets in CI

Store all credentials as GitHub Actions encrypted secrets, never in the workflow YAML:

- `DIGITALOCEAN_ACCESS_TOKEN` — for `doctl` and the DigitalOcean Container Registry.
- `STAGING_MODEL_ACCESS_KEY` — scoped to staging models only.
- `PRODUCTION_MODEL_ACCESS_KEY` — used only in deployment workflows, never in test jobs.

Reference secrets with `${{ secrets.SECRET_NAME }}`. GitHub Actions masks secret values in log output automatically.

For container registry setup and `doctl` authentication, see the [DigitalOcean Kubernetes docs](https://docs.digitalocean.com/products/kubernetes/).
