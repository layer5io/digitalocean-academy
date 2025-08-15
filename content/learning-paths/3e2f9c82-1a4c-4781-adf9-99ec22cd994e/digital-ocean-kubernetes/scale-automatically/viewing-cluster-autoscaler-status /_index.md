---
type: "page"
id: "viewing-cluster-autoscaler-status"
description: ""
title: "Viewing Cluster Autoscaler Status "
weight: 3
---

You can check the status of the Cluster Autoscaler to view recent events or for debugging purposes.

Check `kube-system/cluster-autoscaler-status` config map by running the following command:
```bash
kubectl get configmap cluster-autoscaler-status -o yaml -n kube-system
```

The command returns results such as this:
```bash
apiVersion: v1
data:
  status: |+
    Cluster-autoscaler status at 2021-01-27 21:57:30.462764772 +0000 UTC:
    Cluster-wide:
      Health:      Healthy (ready=5 unready=0 notStarted=0 longNotStarted=0 registered=5 longUnregistered=0)
                   LastProbeTime:      2021-01-27 21:57:30.27867919 +0000 UTC m=+499650.735961122
                   LastTransitionTime: 2021-01-22 03:11:00.371995979 +0000 UTC m=+60.829277965
      ScaleUp:     NoActivity (ready=5 registered=5)
                   LastProbeTime:      2021-01-27 21:57:30.27867919 +0000 UTC m=+499650.735961122
                   LastTransitionTime: 2021-01-22 19:09:20.360421664 +0000 UTC m=+57560.817703589
      ScaleDown:   NoCandidates (candidates=0)
                   LastProbeTime:      2021-01-27 21:57:30.27867919 +0000 UTC m=+499650.735961122
                   LastTransitionTime: 2021-01-22 19:09:20.360421664 +0000 UTC m=+57560.817703589
...
```

To learn more about what is published in the config map, see [What events are emitted by CA?](https://github.com/kubernetes/autoscaler/blob/master/cluster-autoscaler/FAQ.md#what-events-are-emitted-by-ca).

In the case of an error, you can troubleshoot by using `kubectl get events -A` or `kubectl describe <resource-name>` to check for any events on the Kubernetes resources.

