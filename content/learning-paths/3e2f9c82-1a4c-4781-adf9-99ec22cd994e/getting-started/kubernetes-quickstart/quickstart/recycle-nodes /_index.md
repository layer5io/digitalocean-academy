---
type: "page"
id: "recycle-nodes"
description: ""
title: "Recycle Nodes"
weight: 5
---

If a worker node isn’t functioning properly, you can destroy and replace it with a new node of the same type with the Recycle option.

1. Open the cluster’s … menu and select View Nodes.

2. Click the name of the node pool with the problem node.

3. Open the … menu next to the problem node and select Recycle.

4. Optionally, if you want to skip draining the node before removing it, uncheck the Drain node when replacing checkbox.

By default, the workloads are drained from the node before the node is removed. Skipping node draining is useful when you know that a drain will fail because the workload is broken or cannot gracefully terminate.

5. Click Recycle to confirm the action.

Recycling a worker node replaces the underlying Droplet with a newly provisioned one. Attached volumes are detached and reattached to the new Droplet, but any data stored locally on the original Droplet’s disk will be lost.

