---
type: "page"
id: "use-the-kubernetes-dashboard-for-your-cluster"
description: ""
title: "Use the Kubernetes Dashboard for Your Cluster "
weight: 2
---
The Kubernetes Dashboard provides a web-based user interface where you can deploy containerized applications, troubleshoot your application, manage your cluster resources (such as Deployments, Jobs, DaemonSets, etc), get an overview of applications running on your cluster, initiate a rolling update, restart a pod, and more.

1. Navigate to the Marketplace tab of your cluster in the Kubernetes section of the control panel.
2. Search for the Kubernetes Dashboard 1-Click App and install it.
3. Download the kubeconfig file for the cluster from the control panel. In the Configuration section of the Overview tab of the cluster, click Download Config File. The kubeconfig file is required for authenticating access to the dashboard.
4. Port-forward the Kubernetes Dashboard to your local machine:
```bash
export POD_NAME=$(kubectl get pods -n kubernetes-dashboard -l "app.kubernetes.io/name=kubernetes-dashboard,app.kubernetes.io/instance=kubernetes-dashboard" -o jsonpath="{.items[0].metadata.name}")
kubectl -n kubernetes-dashboard port-forward $POD_NAME 8443:8443
```
5. Log in to the dashboard. In your local web browser, access `https://127.0.0.1:8443/` and provide your Kubernetes cluster credentials.

You can explore your cluster’s resources, view pod details, manage deployments, and monitor the health of your cluster using the dashboard. For more details, see [Web UI (Dashboard) in the Kubernetes documentation](https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/).