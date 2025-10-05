---
type: "page"
id: "pod-disruption-budget-support"
description: ""
title: "PodDisruptionBudget Support "
weight: 5
---

A `PodDisruptionBudget` (PDB) specifies the minimum number of replicas that an application can tolerate having during a voluntary disruption, relative to how many it is intended to have. For example, if you set the `replicas` value for a pod to `5`, and set the PDB to `1`, potentially disruptive actions like cluster upgrades and resizes occur with no fewer than four pods running.

When scaling down a cluster, the DOKS autoscaler respects this setting, and follows [the documented Kubernetes procedure for draining and deleting nodes when a PDB has been specified](https://github.com/kubernetes/autoscaler/blob/master/cluster-autoscaler/FAQ.md#does-ca-work-with-poddisruptionbudget-in-scale-down).

We recommend you set a PDB for your workloads to ensure graceful scale down. For more information, see [Specifying a Disruption Budget for your Application](https://kubernetes.io/docs/tasks/run-application/configure-pdb/) in the Kubernetes documentation.
