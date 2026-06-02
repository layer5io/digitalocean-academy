---
type: "page"
id: "models-components-and-relationships"
title: "Models, Components & Relationships"
description: "Learn how Meshery describes infrastructure through Models, Components, and Relationships, and why typed validation matters for GPU AI stacks on DOKS."
weight: 4
---

## Overview

Before you can build a Meshery Design for a GPU inference stack, you need to understand the three concepts that underpin Meshery's data model: **Models**, **Components**, and **Relationships**. Together they allow Meshery to represent any cloud native infrastructure as a validated, composable artifact — not just a bag of YAML files.

## Models

A **Model** in Meshery represents a capability or integration — essentially a package that brings support for a particular technology into Meshery. Each Model contains a set of Components and the Relationships between them.

Examples relevant to AI workloads on DOKS:

| Model | What It Provides |
|---|---|
| Kubernetes | Core resources: Deployment, Service, ConfigMap, PersistentVolumeClaim, etc. |
| NVIDIA GPU Operator | GPU node labeling, device plugin, DCGM exporter components |
| Prometheus | ServiceMonitor, PrometheusRule, Alertmanager components |
| Grafana | Dashboard, DataSource components |
| Ingress-NGINX | IngressClass, Ingress components |

Meshery ships with hundreds of Models. When you add a component to a Kanvas canvas, Meshery draws it from the appropriate Model.

## Components

A **Component** is a specific resource type defined within a Model — the Kubernetes `Deployment` kind, for example, or the `ServiceMonitor` kind from the Prometheus Model. Components carry a schema that defines their configurable properties.

When you drag a `Deployment` component onto the Kanvas canvas and configure it to request `nvidia.com/gpu: 1`, Meshery validates that field against the Component schema before letting you deploy. This catches typos and missing fields at design time rather than at `kubectl apply` time.

## Relationships

**Relationships** express typed, validated connections between Components. They are not just visual lines — they carry semantic meaning and trigger validation rules.

For an AI inference stack, common Relationships include:

- **Deployment → Service** (binding): the Service selector must match the Deployment's Pod labels.
- **Service → Ingress** (routing): the Ingress backend service name and port must match the Service spec.
- **Deployment → ConfigMap** (envFrom / volumeMount): the ConfigMap must exist in the same namespace.

When you wire two Components together in Kanvas, Meshery evaluates the Relationship type and flags mismatches. For example, if you connect an Ingress to a Service but the backend port number does not match any named port on the Service, Meshery highlights the error before you deploy.

## Why This Matters for GPU AI Stacks

A vLLM inference stack on DOKS involves at least four connected resources: a `Deployment` requesting GPU resources, a `Service` exposing the OpenAI-compatible endpoint, an `Ingress` routing external traffic, and a `ConfigMap` holding model parameters. Without validated Relationships, any one of these connections can silently break — a mismatched label selector means the Service sends traffic nowhere; a wrong port in the Ingress means external callers get a 502.

Meshery's typed Relationships mean the canvas itself acts as a linter. You compose the stack, Meshery validates every connection, and you deploy with confidence that the wiring is correct.

## Policies

Meshery also supports **Policies** — evaluation rules that run against Designs or live cluster state. A Policy can enforce that every Deployment in a GPU namespace includes a `resources.limits` stanza with `nvidia.com/gpu`, or that no Deployment in the inference namespace runs with more than a defined replica count. Policies are covered in depth in the Policy and Relationship Validation lesson.

## Summary

| Concept | Analogy | Role |
|---|---|---|
| Model | A library or plugin | Packages a technology's resources into Meshery |
| Component | A class or schema | Describes one resource type and its configurable fields |
| Relationship | A typed edge | Validates connections between resource instances |
| Policy | A rule or constraint | Enforces conventions across Designs and live clusters |

- [Meshery concepts documentation](https://docs.meshery.io/concepts/logical/designs)
- [DigitalOcean GPU Droplets](https://docs.digitalocean.com/products/gpu-droplets/)
