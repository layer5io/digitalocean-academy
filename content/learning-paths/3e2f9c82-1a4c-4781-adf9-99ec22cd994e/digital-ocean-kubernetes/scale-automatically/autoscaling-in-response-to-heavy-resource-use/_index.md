---
type: "page"
id: "autoscaling-in-response-to-heavy-resource-use"
description: ""
title: "Autoscaling in Response to Heavy Resource Use "
weight: 4
---

Pod creation and destruction can be automated by a Horizontal Pod Autoscaler (HPA), which monitors the resource use of nodes and generates pods when certain events occur, such as sustained CPU spikes, or memory use surpassing a certain threshold. This, combined with a CA, gives you powerful tools to configure your cluster’s responsiveness to resource demands — an HPA that ensures synchronicity between resource use and the number of pods, and a CA that ensures synchronicity between the number of pods and the cluster’s size.

For a walk-through that builds an autoscaling cluster and demonstrates the interplay between an HPA and a CA, see [Example of Kubernetes Cluster Autoscaling Working With Horizontal Pod Autoscaling](https://docs.digitalocean.com/products/kubernetes/how-to/set-up-autoscaling/).

