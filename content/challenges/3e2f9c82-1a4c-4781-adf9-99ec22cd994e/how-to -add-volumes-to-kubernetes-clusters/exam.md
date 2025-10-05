---
title: "Kubernetes Volumes Challenge Exam"
pass_percentage: 70
type: "test"
questions:
  - id: "q1"
    text: "What is the purpose of a PersistentVolumeClaim (PVC) in a Kubernetes cluster?"
    type: "single-answer"
    marks: 2
    options:
      - id: "a"
        text: "To manage the control plane of the cluster"
      - id: "b"
        text: "To create and access persistent storage for reading and writing data"
        is_correct: true
      - id: "c"
        text: "To automatically scale the cluster's worker nodes"
      - id: "d"
        text: "To configure load balancers for the cluster"
    
  - id: "q2"
    text: "Which of the following are true about the accessModes field in a PVC configuration for DigitalOcean Kubernetes?"
    type: "multiple-answers"
    marks: 2
    options:
      - id: "a"
        text: "ReadWriteOnce is supported by DigitalOcean volumes."
        is_correct: true
      - id: "b"
        text: "ReadOnlyMany is supported by DigitalOcean volumes."
      - id: "c"
        text: "ReadWriteMany is supported by DigitalOcean volumes."
      - id: "d"
        text: "The accessModes field must be set to ReadWriteOnce for DigitalOcean volumes."
        is_correct: true
   
  - id: "q3"
    text: "What happens if you try to create a PVC with a name that already exists in the cluster?"
    type: "single-answer"
    marks: 2
    options:
      - id: "a"
        text: "The existing volume is deleted, and a new one is created."
      - id: "b"
        text: "An error message is returned, and the existing volume is mounted instead."
        is_correct: true
      - id: "c"
        text: "The cluster automatically scales to accommodate the new PVC."
      - id: "d"
        text: "The PVC creation proceeds without any issues."
    
  - id: "q4"
    text: "Which of the following can be customized in the volumeClaimTemplates section of a StatefulSet configuration? (Select all that apply)"
    type: "multiple-answers"
    marks: 2
    options:
      - id: "a"
        text: "The name of the volume"
        is_correct: true
      - id: "b"
        text: "The accessModes of the volume"
        is_correct: true
      - id: "c"
        text: "The storage size of the volume"
        is_correct: true
      - id: "d"
        text: "The image used by the container"

  - id: "q5"
    text: "What is the primary purpose of a PersistentVolumeClaim (PVC) in a Kubernetes cluster?"
    type: "single-answer"
    marks: 2
    options:
      - id: "o1"
        text: "To manage network policies"
        is_correct: false
      - id: "o2"
        text: "To create and access persistent storage"
        is_correct: true
      - id: "o3"
        text: "To configure load balancers"
        is_correct: false
      - id: "o4"
        text: "To deploy container images"
        is_correct: false
    correct_answer: "o2"

  - id: "q6"
    text: "Which Kubernetes command-line tool is used to create and manage volumes in a cluster?"
    type: "single-answer"
    marks: 1
    options:
      - id: "o1"
        text: "kubeadm"
        is_correct: false
      - id: "o2"
        text: "kubectl"
        is_correct: true
      - id: "o3"
        text: "kubelet"
        is_correct: false
      - id: "o4"
        text: "kubectx"
        is_correct: false
    correct_answer: "o2"

  - id: "q7"
    text: "Which of the following are valid `accessModes` for DigitalOcean volumes in a Kubernetes cluster? (Select all that apply)"
    type: "multiple-answers"
    marks: 3
    multiple_answers: true
    options:
      - id: "o1"
        text: "ReadWriteOnce"
        is_correct: true
      - id: "o2"
        text: "ReadOnlyMany"
        is_correct: false
      - id: "o3"
        text: "ReadWriteMany"
        is_correct: false
      - id: "o4"
        text: "WriteOnlyOnce"
        is_correct: false
    correct_answer: "o1"

  - id: "q8"
    text: "What happens if you delete a deployment in Kubernetes without removing its associated PVCs? Will the data in your volume be **preserved** or **deleted**? (Instructions: Provide a brief explanation, including one and only one of the bold keywords.)"
    type: "short-answer"
    marks: 2
    #correct_answer: "The PVCs remain and must be manually deleted using `kubectl delete pvc`."
    correct_answer: "preserved"

  - id: "q9"
    text: "Explain the role of a `StatefulSet` in managing volumes for pods in a Kubernetes cluster."
    type: "essay"
    marks: 5
    correct_answer: "A StatefulSet ensures stable, unique network identifiers and persistent storage for pods, making it ideal for applications requiring consistent data persistence. It manages the lifecycle of pods and their associated volumes, ensuring that each pod retains its identity and storage (via PVCs) even after restarts or rescheduling. In the context of volumes, a StatefulSet uses `volumeClaimTemplates` to automatically create and associate PVCs with each pod, simplifying the process of provisioning persistent storage."

  - id: "q10"
    text: "Which storage class is specified in the example configuration for a DigitalOcean volume?"
    type: "single-answer"
    marks: 1
    options:
      - id: "o1"
        text: "do-block-storage"
        is_correct: true
      - id: "o2"
        text: "standard"
        is_correct: false
      - id: "o3"
        text: "premium"
        is_correct: false
      - id: "o4"
        text: "local-storage"
        is_correct: false
    correct_answer: "o1"

  - id: "q11"
    text: "What is the valid range for the storage size of a DigitalOcean volume in a Kubernetes cluster?"
    type: "short-answer"
    marks: 2
    correct_answer: "1 GB to 10,000 GB"

  - id: "q12"
    text: "Which of the following components in the example `StatefulSet` configuration mounts the volume at `/data`? (Select all that apply)"
    type: "multiple-answers"
    marks: 3
    multiple_answers: true
    options:
      - id: "o1"
        text: "volumeMounts"
        is_correct: true
      - id: "o2"
        text: "volumeClaimTemplates"
        is_correct: false
      - id: "o3"
        text: "spec.template.spec.containers"
        is_correct: true
      - id: "o4"
        text: "serviceName"
        is_correct: false
    correct_answer: "o1,o3"

  - id: "q13"
    text: "What command can you use to resize a volume by editing its PVC?"
    type: "short-answer"
    marks: 2
    correct_answer: "kubectl edit pvc <pvc-name>"

  - id: "q14"
    text: "Why might a PVC deletion stall or fail in a Kubernetes cluster?"
    type: "short-answer"
    marks: 5
    correct_answer: "fail"
    #correct_answer: "A PVC deletion may stall or fail if the associated volume is deleted manually before the PVC API object is removed using `kubectl`. This creates an inconsistent state where the PVC is still referenced but the underlying volume no longer exists. To resolve this, you can list volume attachments with `kubectl get volumeattachments`, describe the attachment with `kubectl describe volumeattachments <volume-name>`, edit it to remove the `external-attacher` finalizer, and then delete the PVC with `kubectl delete pvc <pvc-name>`."

  - id: "q15"
    text: "Which container image is used in the example `StatefulSet` configuration?"
    type: "single-answer"
    marks: 1
    options:
      - id: "o1"
        text: "nginx"
        is_correct: false
      - id: "o2"
        text: "busybox"
        is_correct: true
      - id: "o3"
        text: "postgres"
        is_correct: false
      - id: "o4"
        text: "redis"
        is_correct: false
    correct_answer: "o2"

  - id: "q16"
    text: "What is the default filesystem owner of a volume in DigitalOcean Kubernetes?"
    type: "short-answer"
    marks: 2
    correct_answer: "root"

  - id: "q17"
    text: "Which of the following `mountOptions` are supported by DigitalOcean Kubernetes for setting volume permissions? (Select all that apply)"
    type: "multiple-answers"
    marks: 3
    multiple_answers: true
    options:
      - id: "o1"
        text: "dir_mode=0777"
        is_correct: false
      - id: "o2"
        text: "file_mode=0777"
        is_correct: false
      - id: "o3"
        text: "chmod 777 via initContainer"
        is_correct: true
      - id: "o4"
        text: "chown via securityContext"
        is_correct: true
    correct_answer: "o3,o4"

  - id: "q18"
    text: "What command lists the persistent volumes associated with a Kubernetes cluster?"
    type: "short-answer"
    marks: 2
    correct_answer: "kubectl get pv"

  
  - id: "q19"
    text: "What is the consequence of modifying cluster resources like volumes directly in the DigitalOcean Control Panel?"
    type: "single-answer"
    marks: 2
    options:
      - id: "o1"
        text: "It improves cluster performance"
        is_correct: false
      - id: "o2"
        text: "It may render resources unusable or trigger replacement"
        is_correct: true
      - id: "o3"
        text: "It automatically updates the PVC"
        is_correct: false
      - id: "o4"
        text: "It has no impact on the cluster"
        is_correct: false
    correct_answer: "o2"
---