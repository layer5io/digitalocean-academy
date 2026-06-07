---
type: "page"
id: "workspaces-teams-and-rbac"
title: "Workspaces, Teams & RBAC"
description: "Organize AI platform teams in Meshery Cloud using Workspaces and role-based access control to scope cluster access, Designs, and Performance Profiles by team."
weight: 1
---

## Overview

As the number of DOKS GPU clusters, AI workload Designs, and Performance Profiles grows, you need a way to organize access so teams can work independently without stepping on each other. Meshery Cloud provides **Workspaces**, **Teams**, and **RBAC** (role-based access control) to structure this access. This lesson explains how to set them up for a multi-team AI platform.

## Workspaces

A **Workspace** in Meshery Cloud is an isolated namespace for a team or project. It contains:

- Connected cluster environments (your DOKS GPU clusters)
- Designs belonging to that workspace
- Performance Profiles and their run history
- Team members and their roles

Workspaces prevent accidental cross-team access. An AI research team's Workspace cannot see the production inference team's cluster connections or Designs unless explicitly shared.

## Creating a Workspace

In the Meshery UI, navigate to **Cloud → Workspaces** and click **Create Workspace**. Provide a name (e.g., `inference-platform-prod`) and a description. Invite team members by email or by team name.

Assign cluster connections to the Workspace by linking the DOKS cluster environments you imported earlier. Each cluster connection can belong to multiple Workspaces if needed — for example, a shared staging cluster is accessible to both the development team and the QA team.

## Teams

**Teams** group users who share the same role within a Workspace. Typical team structures for an AI platform:

| Team | Members | Role in Workspace |
|---|---|---|
| Platform Engineering | Infrastructure engineers | Admin — manage clusters, deploy Designs |
| AI Engineering | Model developers | Editor — author Designs, run Performance Profiles |
| Data Science | Researchers | Viewer — read-only access to dashboards and results |

Add a team to a Workspace and assign its permission level. Team members inherit the permissions without individual per-user configuration.

## RBAC Roles

Meshery Cloud RBAC defines roles at the Workspace level:

- **Admin** — full control: connect clusters, delete Designs, manage members.
- **Editor** — create and deploy Designs, run Performance Profiles, manage catalog entries.
- **Viewer** — read-only: view cluster state, browse Designs, read Performance Profile results.

The Viewer role is appropriate for stakeholders who need visibility into AI workload health without the ability to make changes — useful for data science teams who want to see inference latency trends without risking an accidental redeploy.

## Practical RBAC Patterns for AI Platforms

**Pattern 1: Environment-scoped Workspaces.** Create three Workspaces: `ai-dev`, `ai-staging`, `ai-prod`. Platform engineers are Admin in all three. AI engineers are Editor in `ai-dev` and `ai-staging` but only Viewer in `ai-prod`. Production changes require a platform engineer's involvement.

**Pattern 2: Team-scoped Workspaces.** Each AI product team has its own Workspace containing only its DOKS cluster and Designs. Teams are fully autonomous within their scope. A cross-team Platform Engineering team is Admin in all Workspaces for break-glass access.

## Connecting Meshery Cloud RBAC to DOKS

DOKS itself uses Kubernetes RBAC for in-cluster permissions. Meshery RBAC and DOKS RBAC are complementary layers:

- Meshery RBAC controls who can deploy Designs and run tests *through Meshery*.
- DOKS RBAC controls what the Meshery Operator's service account is permitted to do in the cluster.

For production clusters, scope the Meshery Operator's ClusterRole to only the namespaces and resource types it needs — avoid `cluster-admin` unless required for Meshery's full feature set.

## Audit and Compliance

Meshery Cloud logs all Workspace actions: who deployed which Design, who ran a Performance Profile, who connected or disconnected a cluster. These logs are accessible under **Cloud → Audit** and can be exported for compliance review — useful for organizations with change management requirements around production AI infrastructure.

- [Meshery docs](https://docs.meshery.io/)
- [DOKS Kubernetes docs](https://docs.digitalocean.com/products/kubernetes/)
