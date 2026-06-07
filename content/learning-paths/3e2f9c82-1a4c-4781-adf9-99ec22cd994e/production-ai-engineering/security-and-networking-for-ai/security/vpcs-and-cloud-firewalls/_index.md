---
type: "page"
id: "vpcs-and-cloud-firewalls"
title: "VPCs & Cloud Firewalls"
description: "Isolate AI inference services with DigitalOcean VPCs and Cloud Firewalls to keep traffic private and attack surfaces minimal."
weight: 1
---

## Defense in Depth for AI Services

AI inference services often handle sensitive data — customer queries, internal documents, PII. A public-internet endpoint with only an API key for protection is a single point of failure. VPCs and Cloud Firewalls add network-layer controls that complement application-layer authentication.

## Virtual Private Cloud (VPC)

A DigitalOcean VPC is a private, isolated layer-3 network within a datacenter region. Resources inside a VPC communicate over private IP addresses that are never exposed to the public internet. Placing your DOKS cluster, Managed PostgreSQL database, and any other backend services inside the same VPC means:

- Traffic between your inference application and its database never traverses the public internet.
- No public IP is required on the database cluster.
- An attacker who compromises a single component cannot reach others without also bypassing VPC routing.

```
[Public Internet]
       |
  [Load Balancer / Inference Endpoint]
       |
  [VPC: 10.110.0.0/20]
    ├── DOKS worker nodes (inference service pods)
    ├── Managed PostgreSQL (pgvector)
    └── Vector DB (Qdrant on DOKS)
```

All intra-VPC traffic uses private RFC 1918 addresses. Only the load balancer or ingress controller has a public IP.

## Creating a VPC

```bash
# Using the DigitalOcean CLI (doctl)
doctl vpcs create \
  --name ai-production-vpc \
  --region nyc3 \
  --ip-range 10.110.0.0/20
```

Attach your DOKS cluster to this VPC at creation time — you cannot move an existing cluster into a different VPC without rebuilding it.

## Cloud Firewalls

Cloud Firewalls are stateful packet filters applied at the hypervisor level, outside your Droplets and nodes. They enforce inbound and outbound rules before traffic reaches your application.

Define the minimum required rules:

```bash
# Allow HTTPS from anywhere to the inference load balancer
doctl compute firewall create \
  --name ai-lb-firewall \
  --inbound-rules "protocol:tcp,ports:443,address:0.0.0.0/0" \
  --outbound-rules "protocol:tcp,ports:all,address:0.0.0.0/0"

# Restrict database access to DOKS node private IPs only
doctl compute firewall create \
  --name db-firewall \
  --inbound-rules "protocol:tcp,ports:25060,address:10.110.0.0/20" \
  --outbound-rules "protocol:tcp,ports:all,address:0.0.0.0/0"
```

Port 25060 is the DigitalOcean Managed PostgreSQL private port. Accepting connections only from the VPC CIDR block means a public-facing compromise cannot reach the database directly.

## Kubernetes NetworkPolicies

For additional isolation within DOKS, apply NetworkPolicies to restrict pod-to-pod communication:

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-inference-to-vectordb
  namespace: production
spec:
  podSelector:
    matchLabels:
      app: vector-db
  ingress:
    - from:
        - podSelector:
            matchLabels:
              app: inference-service
      ports:
        - port: 6333
```

This allows only pods labeled `app: inference-service` to reach the Qdrant port. All other inbound connections to the vector database pods are dropped.

## Summary

Layer VPCs, Cloud Firewalls, and Kubernetes NetworkPolicies to create defense in depth. Each layer independently enforces least-privilege network access, so a misconfiguration or compromise at one layer does not expose the entire system.

For VPC and firewall configuration details, see the [DigitalOcean VPC docs](https://docs.digitalocean.com/products/networking/vpc/).
