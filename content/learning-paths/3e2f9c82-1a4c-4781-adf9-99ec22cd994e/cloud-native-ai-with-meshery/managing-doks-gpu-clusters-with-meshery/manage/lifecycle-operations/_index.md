---
type: "page"
id: "lifecycle-operations"
title: "Lifecycle Operations"
description: "Deploy, undeploy, scale, and detect drift on AI workloads running on DOKS GPU clusters using Meshery Designs and the mesheryctl CLI."
weight: 3
---

## Overview

Lifecycle management is one of Meshery's core capabilities. Rather than applying individual YAML files with `kubectl`, you express your AI workload as a Meshery **Design** and let Meshery handle the full lifecycle: initial deploy, updates, scale events, and clean undeploy. This approach gives you an auditable history and a single entry point for operating AI workloads across one or many DOKS clusters.

## Deploy a Design

Once you have authored a Design in Kanvas (covered in the Designing AI Stacks course), deploying it to a DOKS GPU cluster is a single action. In the Meshery UI open the Design, select the target cluster from the Environment picker, and click **Deploy**.

Meshery translates the Design into Kubernetes API calls. For an inference serving Design, this typically creates a Namespace, a ConfigMap for model parameters, a Deployment requesting GPU resources, and a Service.

From the CLI:

```bash
mesheryctl design import -f vllm-inference.yaml
mesheryctl design deploy --name vllm-inference --context doks-gpu-cluster
```

The `--context` flag maps to the Meshery environment connection for your DOKS cluster.

## Undeploy and Clean Up

Undeploy removes the resources created by a Design from the cluster without deleting the Design itself. The Design remains in Meshery for redeployment or comparison.

```bash
mesheryctl design undeploy --name vllm-inference --context doks-gpu-cluster
```

In the UI, open the Design and click **Undeploy**. Meshery issues delete calls for every resource in the Design and reports success or failure per resource.

## Scaling Inference Workloads

To scale the replica count of a vLLM Deployment, update the Design's replica field and redeploy. Meshery applies a diff — only the changed fields are sent to the Kubernetes API, equivalent to a `kubectl apply` with a patched spec.

```yaml
spec:
  replicas: 3   # updated from 1
  template:
    spec:
      containers:
        - name: vllm
          resources:
            limits:
              nvidia.com/gpu: "1"
```

After saving the Design and redeploying, MeshSync reports the updated replica count in real time. Each replica lands on a separate GPU node if the DOKS GPU node pool has sufficient capacity.

## Detecting and Reconciling Drift

Configuration drift occurs when someone changes a live resource outside of Meshery — for example, using `kubectl edit` to reduce GPU memory limits during an incident. MeshSync detects the change immediately and marks the resource as drifted in the Meshery UI.

The drift indicator shows:

- The **desired state** from the last deployed Design
- The **live state** as reported by MeshSync
- A diff highlighting the changed fields

To reconcile, redeploy the Design from Meshery. Meshery applies the canonical desired state, overwriting the drift.

## Rollback

Meshery stores Design versions in its history. If a new deployment causes regressions in inference latency (visible in Performance Profiles, covered later), you can select a previous Design version and redeploy it, effectively rolling back the AI workload to a known-good configuration without hunting through Git blame or `kubectl rollout` history.

## Practical Tips for GPU Workloads

- Always set `resources.requests` equal to `resources.limits` for `nvidia.com/gpu`. Kubernetes does not support fractional GPU sharing in the standard device plugin, so an unset request can cause scheduling issues.
- Use a `nodeSelector` or a `nodeSelectorTerms` in the Design to pin inference Pods to the GPU node pool rather than CPU nodes.
- Meshery will flag a missing GPU limit as a policy violation if you have configured the relevant Policy — covered in the Policy and Relationship Validation lesson.

- [Meshery docs](https://docs.meshery.io/)
- [DOKS Kubernetes docs](https://docs.digitalocean.com/products/kubernetes/)
