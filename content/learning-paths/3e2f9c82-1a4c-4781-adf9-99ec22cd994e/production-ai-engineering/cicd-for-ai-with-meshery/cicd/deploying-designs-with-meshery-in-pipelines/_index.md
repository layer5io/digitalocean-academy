---
type: "page"
id: "deploying-designs-with-meshery-in-pipelines"
title: "Deploying Designs with Meshery in Pipelines"
description: "Apply a Meshery Design to a DOKS cluster from a CI pipeline using mesheryctl for GitOps-driven infrastructure deployment."
weight: 3
---

## Meshery Designs as Deployable Artifacts

A Meshery Design is a version-controlled blueprint that describes a set of Kubernetes resources — Deployments, Services, ConfigMaps, HelmCharts, and custom resources — as a single, named unit. Designs can be applied to any Meshery-managed cluster using `mesheryctl`, making them the ideal artifact to deploy from CI.

This approach gives you GitOps: every infrastructure state change is a pull request, every deployment is auditable, and rollback is a git revert followed by a pipeline run.

## Prerequisites

- A DOKS cluster registered as a Meshery environment.
- `mesheryctl` installed and authenticated in the CI runner.
- A Meshery Design file committed to the repository.

## Installing mesheryctl in CI

```yaml
- name: Install mesheryctl
  run: |
    curl -L https://meshery.io/install | MESHERY_VERSION=stable bash
    mesheryctl version
```

## Authenticating to Meshery

Provide a Meshery API token as a CI secret:

```yaml
- name: Configure Meshery context
  env:
    MESHERY_TOKEN: ${{ secrets.MESHERY_TOKEN }}
    MESHERY_SERVER: ${{ secrets.MESHERY_SERVER_URL }}
  run: |
    mesheryctl system context create ci-context \
      --url "$MESHERY_SERVER" \
      --token "$MESHERY_TOKEN" \
      --set
```

## Applying a Design from CI

The core deployment step is a single `mesheryctl design apply` command:

```yaml
- name: Apply Meshery Design
  run: |
    mesheryctl design apply \
      --file infrastructure/production-inference.yaml \
      --context my-doks-cluster
```

A complete deployment job in GitHub Actions:

```yaml
  deploy:
    runs-on: ubuntu-latest
    needs: [build, evaluate]
    if: github.ref == 'refs/heads/main'
    steps:
      - uses: actions/checkout@v4

      - name: Install mesheryctl
        run: curl -L https://meshery.io/install | MESHERY_VERSION=stable bash

      - name: Configure Meshery context
        env:
          MESHERY_TOKEN: ${{ secrets.MESHERY_TOKEN }}
          MESHERY_SERVER: ${{ secrets.MESHERY_SERVER_URL }}
        run: |
          mesheryctl system context create ci-context \
            --url "$MESHERY_SERVER" --token "$MESHERY_TOKEN" --set

      - name: Apply infrastructure Design
        run: |
          mesheryctl design apply \
            --file infrastructure/production-inference.yaml \
            --context my-doks-cluster

      - name: Verify deployment
        run: |
          kubectl rollout status deployment/inference-service \
            --namespace production --timeout=120s
```

The job only runs on pushes to `main` (not on PRs), and only after both the build and evaluation gates pass.

## Example Design File

```yaml
name: production-inference-service
version: "1.0"
services:
  inference-service:
    type: Deployment
    namespace: production
    settings:
      replicas: 3
      image: registry.digitalocean.com/myteam/inference-service:{{ .ImageTag }}
      env:
        - name: MODEL_ACCESS_KEY
          valueFrom:
            secretKeyRef:
              name: inference-credentials
              key: MODEL_ACCESS_KEY
  inference-svc:
    type: Service
    namespace: production
    settings:
      selector:
        app: inference-service
      port: 8080
```

The `{{ .ImageTag }}` placeholder is resolved at apply time by passing parameters to `mesheryctl design apply`, allowing the same Design to deploy different image versions across environments.

## GitOps Benefits

| Benefit | How Meshery delivers it |
|---|---|
| Auditability | Every design change is a git commit with author and message |
| Rollback | Revert the design commit; re-run the pipeline |
| Environment parity | Same design, different parameter values, per environment |
| Drift detection | Meshery can compare live cluster state to the design |

For the full `mesheryctl` command reference and Design schema, see the [Meshery docs](https://docs.meshery.io/).
