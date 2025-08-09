---
type: "page"
id: "create-clusters"
description: ""
title: "Create Clusters"
weight: 2
---

To create a Kubernetes cluster:

1. From the Create menu in the [control panel](https://cloud.digitalocean.com/), click Kubernetes.
2. Select a Kubernetes version. The latest version is selected by default and is the best choice if you have no specific need for an earlier version.
3. Choose a [datacenter region](https://docs.digitalocean.com/products/kubernetes/details/availability/).
4. Choose a VPC network you’ve created or use your default network for the datacenter region.
5. New clusters use [VPC-native cluster networking](https://docs.digitalocean.com/products/kubernetes/details/features/#vpc-native-networking). Choose Size network subnets for me to use the default /16 (512 nodes) pod network and /19 (8192 services) service network. To customize the pod and service network sizes, choose Configure my own network subnet sizes.
6. Customize the default node pool, choose the machine type and node pool names, and add additional node pools. Specify whether the node pool should [autoscale](https://docs.digitalocean.com/products/kubernetes/how-to/autoscale/) and set the minimum and maximum number of nodes.
7. Optionally, enable [high availability](https://docs.digitalocean.com/products/kubernetes/details/managed/#managed-elements-of-the-control-plane) to increase the uptime of your cluster.
8. Name the cluster, select the project you want the cluster to belong to, and optionally add a tag. Any tags you choose are applied to the cluster and its worker nodes.
9. Click Create Kubernetes cluster. Provisioning the cluster takes several minutes.
10. Download the cluster configuration file by clicking Actions, then Download Config from the cluster home page.

Once the cluster is created, use [kubectl to manage it](https://docs.digitalocean.com/products/kubernetes/how-to/connect-to-cluster/).

To get started with DigitalOcean Kubernetes, see our [Build and Deploy Your First Image to Your First Cluster](https://docs.digitalocean.com/products/kubernetes/getting-started/deploy-image-to-cluster/) 
