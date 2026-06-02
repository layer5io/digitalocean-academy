---
title: "Manage a DOKS GPU Cluster with Meshery — Exam"
pass_percentage: 70
type: "test"
questions:
  - id: "q1"
    text: "What is Meshery, in the context of this challenge?"
    type: "single-answer"
    marks: 2
    options:
      - id: "a"
        text: "A managed LLM hosting service from DigitalOcean"
      - id: "b"
        text: "An open-source cloud native manager for designing and operating Kubernetes infrastructure across clusters"
        is_correct: true
      - id: "c"
        text: "A Python package for fine-tuning models"
      - id: "d"
        text: "A replacement for kubectl that removes the need for Kubernetes"
    correct_answer: "b"

  - id: "q2"
    text: "Which Meshery component provides real-time discovery and state sync of cluster resources?"
    type: "single-answer"
    marks: 2
    options:
      - id: "a"
        text: "MeshSync"
        is_correct: true
      - id: "b"
        text: "Grafana"
      - id: "c"
        text: "fortio"
      - id: "d"
        text: "kubelet"
    correct_answer: "a"

  - id: "q3"
    text: "In a Kubernetes Deployment, how does a pod request a single GPU on a DOKS GPU node pool?"
    type: "single-answer"
    marks: 2
    options:
      - id: "a"
        text: "resources.limits: nvidia.com/gpu: 1"
        is_correct: true
      - id: "b"
        text: "spec.gpu: true"
      - id: "c"
        text: "annotations: gpu/enabled: yes"
      - id: "d"
        text: "nodeName: gpu"
    correct_answer: "a"

  - id: "q4"
    text: "Which doctl command writes a DOKS cluster's kubeconfig locally so Meshery and kubectl can reach it?"
    type: "short-answer"
    marks: 2
    correct_answer: "doctl kubernetes cluster kubeconfig save"

  - id: "q5"
    text: "Which load generators can a Meshery Performance Profile use? (Select all that apply.)"
    type: "multiple-answers"
    marks: 3
    options:
      - id: "a"
        text: "fortio"
        is_correct: true
      - id: "b"
        text: "wrk2"
        is_correct: true
      - id: "c"
        text: "nighthawk"
        is_correct: true
      - id: "d"
        text: "nvidia-smi"
    correct_answer: "a,b,c"

  - id: "q6"
    text: "A Meshery Design exported and saved for reuse with configuration best practices is stored in the Meshery ___."
    type: "short-answer"
    marks: 2
    correct_answer: "Catalog"

  - id: "q7"
    text: "Why run Meshery relationship/policy validation before deploying an inference Design?"
    type: "single-answer"
    marks: 2
    options:
      - id: "a"
        text: "To compress the container image"
      - id: "b"
        text: "To catch misconfigurations (e.g., a missing nvidia.com/gpu limit) before they reach the cluster"
        is_correct: true
      - id: "c"
        text: "To bill the GPU by the second"
      - id: "d"
        text: "To convert YAML to JSON"
    correct_answer: "b"

  - id: "q8"
    text: "Saving Performance Profiles lets you compare runs over time and detect performance regressions after design changes."
    type: "true-false"
    marks: 1
    options:
      - id: "true"
        text: "True"
        is_correct: true
      - id: "false"
        text: "False"
    correct_answer: "true"

  - id: "q9"
    text: "Which exporter exposes GPU utilization and memory metrics to Prometheus for Meshery/Grafana dashboards?"
    type: "single-answer"
    marks: 2
    options:
      - id: "a"
        text: "The NVIDIA DCGM exporter"
        is_correct: true
      - id: "b"
        text: "node-exporter only"
      - id: "c"
        text: "kube-proxy"
      - id: "d"
        text: "The vLLM tokenizer"
    correct_answer: "a"

  - id: "q10"
    text: "Which capabilities does Meshery provide for operating AI workloads on DOKS? (Select all that apply.)"
    type: "multiple-answers"
    marks: 3
    options:
      - id: "a"
        text: "Visualizing GPU node pools and workloads in Kanvas"
        is_correct: true
      - id: "b"
        text: "Capturing serving stacks as reusable Designs"
        is_correct: true
      - id: "c"
        text: "Performance testing inference endpoints"
        is_correct: true
      - id: "d"
        text: "Physically installing GPUs into the data center racks"
    correct_answer: "a,b,c"

  - id: "q11"
    text: "Briefly describe the cloud native operating loop for AI workloads demonstrated in this challenge (import, design, deploy, test, observe)."
    type: "essay"
    marks: 4
    correct_answer: "Import the DOKS GPU cluster into Meshery so MeshSync discovers nodes and workloads; capture the serving stack as a validated, versioned Design that requests nvidia.com/gpu; deploy the Design to the cluster; run a Performance Profile to measure latency and throughput of the inference endpoint; and observe GPU and latency metrics via Prometheus and Grafana, feeding findings back into the Design."
---
