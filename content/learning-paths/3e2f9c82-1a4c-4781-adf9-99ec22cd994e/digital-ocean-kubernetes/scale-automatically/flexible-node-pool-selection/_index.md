---
type: "page"
id: "flexible-node-pool-selection"
description: ""
title: "Flexible Node Pool Selection"
weight: 6
---

In clusters with multiple nodes pools, you can specify how the autoscaler chooses which pool to scale up when an additional node is required. The autoscaler defaults to choosing node pools randomly, which is not always optimal. CA [expanders](https://github.com/kubernetes/autoscaler/blob/master/cluster-autoscaler/FAQ.md#what-are-expanders) are strategies for selecting the best node pool to scale up.

You can customize the expanders in your clusters using one of the following options:

- Random: Selects a node pool to scale at random. This is the default expander.
- Priority: Selects the node pool with the highest priority according to the [customer-provided configuration](https://docs.digitalocean.com/products/kubernetes/how-to/autoscale/#configuring-priority-expander). This expander is useful in case of capacity constraints limiting the ability to scale a specific node pool.
- Least-waste: Selects the node pool which minimizes the amount of idle resources.

# Configuring Custom Expanders

You can specify expanders using [`doctl`](https://docs.digitalocean.com/reference/doctl/) version v1.128`.0` or higher with the `--expanders` flag. The flag expects a comma-separated list with the following values: `random`, `priority`, or `least-waste`.

The following example specifies to use the priority and random expanders. The autoscaler uses each of the expanders from the list to narrow down the selection of node pools to scale up, until a single best node pool remains. If applying custom expanders still results in multiple node pools to choose from, it selects from the remaining node pools randomly.

```bash
doctl kubernetes cluster create cluster-with-custom-expanders --region nyc1 --version latest --node-pool "name=pool1;size=s-2vcpu-2gb;count=3" --expanders priority,random
```

You can also update an existing cluster to use flexible node pool selection for autoscaling:

```bash
doctl kubernetes cluster update cluster-with-custom-expanders --expanders priority,random 
```

To remove any expander customizations and reset to the default random selection, pass an empty list of expanders:

```bash
doctl kubernetes cluster update cluster-with-custom-expanders --expanders ""
```

# Configuring Priority Expander 

Once you [enable the priority expander](https://docs.digitalocean.com/products/kubernetes/how-to/autoscale/#configuring-custom-expanders), DOKS creates a starter ConfigMap named cluster-autoscaler-priority-expander in the kube-system namespace with the following content:

```bash
apiVersion: v1
kind: ConfigMap
metadata:
  labels:
    c3.doks.digitalocean.com/component: cluster-autoscaler
    c3.doks.digitalocean.com/plane: data
    doks.digitalocean.com/managed: "true"
  name: cluster-autoscaler-priority-expander
  namespace: kube-system
data:
  priorities: |2 

    1:
      - .*
```

You need to provide a priority list of node pools in this ConfigMap. To do this, update the `.data.priorities` field to reflect the priorities of the node pools in your cluster. The priorities configuration is a YAML object with keys and values:

- Keys are the integer priority numbers.

- Values are the lists of node pools assigned this priority. You can provide the node pools using their IDs and can also specify regular expressions.

For example, the configuration below selects pool ID `11aa5b5c-817e-4213-a303-b65b4d47ad84` as the best option, pool ID `72da2c27-14a3-434e-9db1-2d405cbc24d5` as the next best option, and all remaining pools using regex `.*` to match any string as the lowest-priority, fallback option:

```bash
100:
  - 11aa5b5c-817e-4213-a303-b65b4d47ad84
90:
  - 72da2c27-14a3-434e-9db1-2d405cbc24d5
1:
  - .*
```

To find the IDs of your node pools, use `doctl`:

```bash
doctl kubernetes clusters node-pool list cluster-with-custom-expanders
```

The command returns the following output:

```bash
ID                                      Name                  Size               Count    Tags                                                       Labels    Taints    Nodes
11aa5b5c-817e-4213-a303-b65b4d47ad84    s-2vcpu-2gb-amd       s-2vcpu-2gb-amd    1        k8s,k8s:08011cad-c5c1-430e-8082-5392b02149a4,k8s:worker    map[]     []        [s-2vcpu-2gb-amd-f9un]
72da2c27-14a3-434e-9db1-2d405cbc24d5    s-2vcpu-2gb           s-2vcpu-2gb        0        k8s,k8s:08011cad-c5c1-430e-8082-5392b02149a4,k8s:worker    map[]     []        []
```

# Priority Expander Example 

One of the biggest use-cases for priority expansion is to prepare a cluster for possible capacity constraints, which is especially relevant for very large clusters (100 nodes and more) with large nodes. Suppose your preferred node type is c-8, CPU-optimized Droplet with 8 vCPUs. You can find similar Droplet sizes from the output of doctl compute size list, and create additional, fallback node pools. Suitable alternatives for c-8 might be, for example, s-8vcpu-16gb-amd, s-8vcpu-16gb-intel.

Note
Choose node pools with Droplets that are not on the same fleet as fallback for capacity constraints. For example, c-16 is not a good fallback for c-8 as both c-8 and c-16 Droplets belong to the same fleet, which means they reside on the same hypervisors and the available amounts of c-8 and c-16 Droplets change in tandem.
You can create a cluster with 3 node pools having one preferred size and two fallback sizes. You can scale the fallback pools to zero nodes until needed.

doctl kubernetes clusters create `cluster-with-priority-expander` --version latest --node-pool "name=primary;size=c-8;auto-scale=true;count=3;min-nodes=1;max-nodes=10;" --node-pool "name=fallback1;size=s-8vcpu-16gb-amd;auto-scale=true;count=0;min-nodes=0;max-nodes=10;" --node-pool "name=fallback2;size=s-8vcpu-16gb-intel;auto-scale=true;count=0;min-nodes=0;max-nodes=10" --region nyc1 --expanders priority
Next, to see the list of node pools, use the following command:

doctl kubernetes clusters node-pool list cluster-with-priority-expander
The output looks similar to the following:

```bash
ID                                      Name         Size                  Count    Tags                                                       Labels    Taints    Nodes
5421e5fb-7fb1-4893-b65f-1887ab6c3ea6    primary      c-8                   3        k8s,k8s:2faf374d-5040-4c05-a285-f18d92a4e90c,k8s:worker    map[]     []        [primary-t0p2t primary-t0p2l primary-t0p22]
0255d0cc-a010-4eef-a3bc-38dc784b5888    fallback1    s-8vcpu-16gb-amd      0        k8s,k8s:2faf374d-5040-4c05-a285-f18d92a4e90c,k8s:worker    map[]     []        []
635eb7c0-c3db-4d22-b883-b771f07c239b    fallback2    s-8vcpu-16gb-intel    0        k8s,k8s:2faf374d-5040-4c05-a285-f18d92a4e90c,k8s:worker    map[]     []        []
```

Next, in the `cluster-autoscaler-priority-expander` ConfigMap, specify the priority list for this cluster to look similar to the following:

```bash
100:
  - 5421e5fb-7fb1-4893-b65f-1887ab6c3ea6
50:
  - 0255d0cc-a010-4eef-a3bc-38dc784b5888
  - 635eb7c0-c3db-4d22-b883-b771f07c239b
```

Upon a scale-up event, CA first attempts to create a node in the primary pool. If it encounters an error, such as an insufficient capacity error, it moves on to the next priority node pools, `fallback1` and `fallback2`, choosing randomly between the two.

