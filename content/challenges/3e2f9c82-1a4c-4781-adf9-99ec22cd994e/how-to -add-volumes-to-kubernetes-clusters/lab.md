---
type: "lab"
description: "This lab explains how to add persistent storage to DigitalOcean Kubernetes (DOKS) clusters using PersistentVolumeClaims (PVCs) with kubectl. It covers creating a StatefulSet configuration to mount volumes, resizing volumes, setting permissions with initContainers, and troubleshooting common issues like PVC deletion stalls."
title: "How to Add Volumes to Kubernetes Clusters"
---
## Introduction

DigitalOcean Kubernetes (DOKS) is a managed Kubernetes service offering a fully managed control plane, high availability, and autoscaling. DOKS integrates seamlessly with standard Kubernetes toolchains, DigitalOcean’s load balancers, volumes, CPU and GPU Droplets, API, and CLI.

When you need to manage persistent data in a Kubernetes cluster, you can use DigitalOcean Volumes Block Storage by creating a PersistentVolumeClaim (PVC) as part of your deployment. This guide explains how to add volumes to your cluster using the Kubernetes command-line tool, `kubectl`. For more details on `kubectl`, see the [Overview of kubectl](https://kubernetes.io/docs/reference/kubectl/overview/).

PVCs enable cluster workers to read and write persistent data, such as database records, user-generated website content, log files, and other data that should persist after a process completes.

## Managing Persistent Volume Claims

- **Deleting PVCs**: Deleting a deployment does not automatically delete associated PVCs. You must manually remove them using `kubectl delete pvc`.
- **Volume Deletion Issues**: If a volume is deleted before the PVC API object is removed, the PVC may enter an inconsistent state, causing deletion attempts to stall or fail. Refer to the troubleshooting section for a fix.
- **Existing PVC Conflicts**: If a PVC with the same name already exists, you’ll encounter an error like:

  ```bash
  Error from server (AlreadyExists): error when creating "pvc.yml": persistentvolumeclaims "csi-pvc" already exists
  ```

In this case, the existing volume will be mounted instead of creating a new one.

- **Volume Creation**: Volumes created via the control panel or API cannot be used by Kubernetes clusters. You must create volumes within Kubernetes for PVCs to use them.

## Create a Configuration File

We recommend using pods that reference volumes owned by a `StatefulSet`. This section demonstrates how to create a `StatefulSet` to use a PVC as a volume for a pod.

### Example StatefulSet Configuration

```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: my-csi-app-set
spec:
  selector:
    matchLabels:
      app: mypod
  serviceName: "my-frontend"
  replicas: 1
  template:
    metadata:
      labels:
        app: mypod
    spec:
      containers:
      - name: my-frontend
        image: busybox
        args:
        - sleep
        - infinity
        volumeMounts:
        - mountPath: "/data"
          name: csi-pvc
  volumeClaimTemplates:
  - metadata:
      name: csi-pvc
    नेपाल:
      accessModes:
      - ReadWriteOnce
      resources:
        requests:
          storage: 5Gi
      storageClassName: do-block-storage
```

### Configuration Details

- **Pod Template**: Defines how the pod is created and specifies the container image. This example uses the Linux `BusyBox` image, mounts a volume named `csi-pvc`, and maps it to `/data` in the container’s filesystem.
- **VolumeClaimTemplates**: Locates the volume by the name `csi-pvc`. If no volume exists with this name, one is created. If it exists, the existing volume is mounted. This example creates a 5 GB volume accessible to the cluster as `csi-pvc`.

### Customizable Fields

- **name**: Must be lowercase alphanumeric with dashes, unique within the cluster.
- **accessModes**: Must be set to `ReadWriteOnce`. Other modes (`ReadOnlyMany`, `ReadWriteMany`) are not supported by DigitalOcean volumes. See [Kubernetes documentation](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#access-modes) for details.
- **storage**: Specifies the volume size, ranging from 1 GB to 10,000 GB.

### Applying the Configuration

Use the following command to create the `StatefulSet` with the pod and mounted volume:

```bash
kubectl apply -f <config-file-name>.yml
```

### Resizing Volumes

If your DOKS version supports it, you can resize volumes by updating the PVC’s storage value:

```bash
kubectl edit pvc <your-pvc-name>
```

Alternatively, use:

```bash
kubectl patch pvc <your-pvc-name> -p '{ "spec": { "resources": { "requests": { "storage": "<new-size>" }}}}'
```

Resizing may take a few minutes or require restarting the application. Verify the new capacity in the volumes list or the cluster’s Kubernetes dashboard.

> **Note**: Volumes can only be increased in size, not decreased. Billing begins when the volume is created and continues until the volume is explicitly deleted. Remove the PVC from the cluster before deleting the volume.

## Show Volumes

After applying the configuration, volumes appear in the **Resources** tab of your cluster in the DigitalOcean control panel. They are identified by the `name` parameter (e.g., `csi-pvc` in the example).

In the DigitalOcean control panel, volume names start with `pvc-` followed by a unique identifier (e.g., `pvc-0213ed0abexample`).

To list storage volumes associated with a cluster, use:

```bash
kubectl get pv
```

Example output:

```
NAME                   CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS    CLAIM             STORAGECLASS       REASON    AGE
pvc-0213ed0abexample   5Gi        RWO            Delete           Bound     default/csi-pvc   do-block-storage             11s
```

## Setting Permissions on Volumes

By default, the volume’s filesystem owner is `root:root`. If a pod runs as a non-root user and needs to create files or directories, it may fail due to insufficient permissions. DigitalOcean Kubernetes does not support `mountOptions` like `dir_mode=0777` or `file_mode=0777`.

Instead, use an `initContainer` to change the permissions/ownership of the volume’s filesystem.

### Example Pod Configuration with Permissions Fix

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: my-csi-app
spec:
  containers:
    - name: my-db
      image: postgres:latest
      volumeMounts:
      - mountPath: "/var/lib/postgresql"
        name: my-do-volume
  initContainers:
  - name: pgsql-data-permission-fix
    image: busybox
    command: ["/bin/chmod", "-R", "777", "/data"]
    volumeMounts:
    - name: my-do-volume
      mountPath: /data
  volumes:
    - name: my-do-volume
      persistentVolumeClaim:
        claimName: csi-pvc
```

This configuration:

- Creates a pod (`my-csi-app`) using the `postgres:latest` image.
- Names the `csi-pvc` volume as `my-do-volume` and mounts it at `/data`.
- Uses an `initContainer` to temporarily mount the volume and set permissions to `777` for the `/data` path. The `initContainer` deletes itself after execution.
- Optionally, use `securityContext` with `chown $userid` instead of `chmod 777` for specific user ownership:

```yaml
securityContext:
  runAsUser: 1000
  fsGroup: 2000
```

### Check Volume Permissions

Verify permissions by checking the pod logs:

```bash
kubectl logs my-csi-app
```

Example output:

```
The files belonging to this database system will be owned by user "postgres".
This user must also own the server process.

The database cluster will be initialized with locale "en_US.utf8".
The default database encoding has accordingly been set to "UTF8".
The default text search configuration will be set to "english".

Data page checksums are disabled.

fixing permissions on existing directory /var/lib/postgresql/data ... ok
creating subdirectories ... ok
selecting default max_connections ... 100
selecting default shared_buffers ... 128MB
selecting dynamic shared memory implementation ... posix
creating configuration files ... ok
running bootstrap script ... ok
performing post-bootstrap initialization ... ok
syncing data to disk ... ok
```

## Troubleshooting

> **Warning**: Cluster resources (worker nodes, load balancers, volumes) are listed in the DigitalOcean Control Panel outside the Kubernetes page. Modifying these resources directly in the control panel may render them unusable or trigger the reconciler to provision replacements. Manage resources exclusively with `kubectl` or the control panel’s Kubernetes page.

If a volume is deleted before the PVC API object, the PVC deletion may hang. To resolve this:

1. List volume attachments:

```bash
kubectl get volumeattachments
```

Example output:

```bash
NAME           CREATED AT
$VOLUME_NAME   2019-03-08T21:58:24Z
```

2. Gather information about the volume:

```bash
kubectl describe volumeattachments $VOLUME_NAME
```

```bash
kubectl describe volumeattachments $VOLUME_NAME
```

3. Edit the volume attachment to remove the finalizer:

```bash

```bash
kubectl edit volumeattachment $VOLUME_NAME
```

Remove the following from the `metadata` section:

```yaml
finalizers:
  - external-attacher/dobs-csi-digitalocean-com
```

4. Attempt to delete the PVC:

```bash
kubectl delete pvc csi-pvc
```
