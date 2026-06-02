---
type: "page"
id: "policy-and-relationship-validation"
title: "Policy & Relationship Validation"
description: "Use Meshery Policies and Relationship validation to catch GPU limit misconfigurations and broken service wiring before deploying AI workloads to DOKS clusters."
weight: 4
---

## Overview

Deploying a broken GPU inference stack to production costs time, money, and GPU-hours. A Deployment missing the `nvidia.com/gpu` resource limit schedules on a CPU node and fails silently. A Service with a mismatched label selector sends traffic to zero Pods. Meshery's Policies and Relationship validation catch both classes of error at design time — before `kubectl apply` ever runs.

## Relationships: Wiring Validation

Meshery **Relationships** are typed, validated connections between Components. When you wire a Service to a Deployment in Kanvas, Meshery evaluates the relationship:

- The Service's `selector` must match at least one label in the Deployment's Pod template `labels`.
- If they do not match, Kanvas highlights the connection in red and explains the mismatch.

Similarly, an Ingress → Service relationship validates:

- The Ingress `backend.service.name` matches an existing Service name in the Design.
- The Ingress `backend.service.port.number` matches a port exposed by that Service.

These validations run in real time as you edit the Design in Kanvas, and again when you run `mesheryctl design validate`. A Design with failing Relationship validations cannot be deployed until the errors are resolved.

## Policies: Rule-Based Validation

**Policies** are evaluation rules that run against a Design or against live cluster state. For AI workloads on DOKS GPU clusters, define policies such as:

**Policy: GPU limits required**

Every Deployment in a namespace tagged `workload-type: inference` must include a `resources.limits` entry with `nvidia.com/gpu`.

**Policy: Node selector required**

Every Deployment requesting GPU resources must include a `nodeSelector` or `nodeAffinity` targeting the GPU node pool. This prevents inference Pods from being scheduled on CPU-only nodes where they would remain Pending indefinitely.

**Policy: No latest image tags in production**

Deployments in the `inference-prod` namespace must not use image tags of `latest`. This enforces pinned, reproducible image versions.

## Defining a Policy

Policies in Meshery use a declarative format evaluated against Design components. An example GPU limits policy:

```yaml
kind: MesheryPolicy
metadata:
  name: require-gpu-limits
spec:
  match:
    components:
      - kind: Deployment
        labels:
          workload-type: inference
  rules:
    - assert:
        path: spec.template.spec.containers[*].resources.limits["nvidia.com/gpu"]
        exists: true
      message: "All inference Deployments must declare nvidia.com/gpu in resources.limits"
```

## Running Validation in CI

Integrate policy and relationship validation into your pull request pipeline:

```bash
mesheryctl design validate \
  --file designs/inference/vllm-inference-doks.yaml \
  --policy policies/require-gpu-limits.yaml \
  --policy policies/require-node-selector.yaml
```

Exit code 0 means all policies and relationships pass. A non-zero exit code with human-readable error messages blocks the PR merge:

```
ERROR: Deployment/vllm-inference in namespace inference is missing
       resources.limits["nvidia.com/gpu"] (policy: require-gpu-limits)
ERROR: Service/vllm-inference selector {app: vllm} does not match
       Deployment/vllm-inference Pod labels {app: vllm-inference}
       (relationship: Service → Deployment binding)
```

The engineer sees exactly what is wrong and where to fix it, without deploying to a cluster.

## Live Cluster Policy Evaluation

Policies can also run against live cluster state as discovered by MeshSync. From the Meshery UI, navigate to **Policies** and click **Evaluate Against Cluster**. Meshery queries the live resource inventory and reports any running Deployments that violate the GPU limits policy — useful for auditing existing workloads that predate the policy.

## Combining Policies with Promotion Gates

In the multi-cluster promotion workflow, policy validation is one of the gates that must pass before a Design is eligible for staging or production deployment. This ensures that only correctly configured, validated Designs ever reach production DOKS GPU clusters, reducing the risk of wasted GPU-hours on misconfigured workloads.

- [Meshery docs](https://docs.meshery.io/)
- [DOKS GPU Droplets docs](https://docs.digitalocean.com/products/gpu-droplets/)
