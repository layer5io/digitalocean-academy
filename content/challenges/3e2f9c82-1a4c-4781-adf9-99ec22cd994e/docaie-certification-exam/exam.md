---
title: "DigitalOcean Certified AI Engineer (DO-CAIE) Exam"
pass_percentage: 70
type: "test"
questions:
  - id: "q1"
    text: "The DigitalOcean AI-Native Cloud is described as spanning five layers. Which of the following are among them? (Select all that apply.)"
    type: "multiple-answers"
    marks: 3
    options:
      - id: "a"
        text: "Infrastructure"
        is_correct: true
      - id: "b"
        text: "Inference"
        is_correct: true
      - id: "c"
        text: "Managed agents"
        is_correct: true
      - id: "d"
        text: "On-premises mainframe"
    correct_answer: "a,b,c"

  - id: "q2"
    text: "A low-volume feature needs occasional model calls with no idle cost and minimal ops. Which service is the best fit?"
    type: "single-answer"
    marks: 2
    options:
      - id: "a"
        text: "A dedicated 8x H100 GPU Droplet"
      - id: "b"
        text: "Serverless inference"
        is_correct: true
      - id: "c"
        text: "Bare Metal GPUs"
      - id: "d"
        text: "A self-managed Kubernetes cluster on Droplets"
    correct_answer: "b"

  - id: "q3"
    text: "What is the minimum change to call a DigitalOcean catalog model from code already written for the OpenAI SDK?"
    type: "single-answer"
    marks: 2
    options:
      - id: "a"
        text: "Set base_url to the DigitalOcean inference endpoint and api_key to a model access key"
        is_correct: true
      - id: "b"
        text: "Rewrite the client to use gRPC"
      - id: "c"
        text: "Switch the transport to WebSockets"
      - id: "d"
        text: "Re-encode all payloads as XML"
    correct_answer: "a"

  - id: "q4"
    text: "The Gradient AI Platform was previously known by what name?"
    type: "short-answer"
    marks: 2
    correct_answer: "GenAI Platform"

  - id: "q5"
    text: "Which agent capability lets an agent take an action by calling external code or an API?"
    type: "single-answer"
    marks: 2
    options:
      - id: "a"
        text: "A knowledge base"
      - id: "b"
        text: "A function route"
        is_correct: true
      - id: "c"
        text: "A higher temperature"
      - id: "d"
        text: "A larger context window"
    correct_answer: "b"

  - id: "q6"
    text: "Which are real Gradient AI Platform features for safe, measurable, production agents? (Select all that apply.)"
    type: "multiple-answers"
    marks: 3
    options:
      - id: "a"
        text: "Guardrails (content moderation, sensitive-data and jailbreak protection)"
        is_correct: true
      - id: "b"
        text: "Evaluations with LLM-as-a-judge"
        is_correct: true
      - id: "c"
        text: "Agent versioning and insights"
        is_correct: true
      - id: "d"
        text: "Automatic deletion of all logs after each request"
    correct_answer: "a,b,c"

  - id: "q7"
    text: "In a knowledge base, what must happen after the source documents change so retrieval reflects the new content?"
    type: "short-answer"
    marks: 2
    correct_answer: "re-index"

  - id: "q8"
    text: "Which steps are part of the RAG pipeline a knowledge base performs? (Select all that apply.)"
    type: "multiple-answers"
    marks: 3
    options:
      - id: "a"
        text: "Chunking"
        is_correct: true
      - id: "b"
        text: "Embedding"
        is_correct: true
      - id: "c"
        text: "Retrieval / vector search"
        is_correct: true
      - id: "d"
        text: "Retraining the base model weights per query"
    correct_answer: "a,b,c"

  - id: "q9"
    text: "On DOKS, which field schedules a pod onto a GPU from a GPU node pool?"
    type: "single-answer"
    marks: 2
    options:
      - id: "a"
        text: "resources.limits: nvidia.com/gpu: 1"
        is_correct: true
      - id: "b"
        text: "spec.useGPU: true"
      - id: "c"
        text: "metadata.gpu: enabled"
      - id: "d"
        text: "status.gpu: ready"
    correct_answer: "a"

  - id: "q10"
    text: "1-Click Models are powered by Hugging Face and expose OpenAI-compatible endpoints with zero serving configuration."
    type: "true-false"
    marks: 1
    options:
      - id: "true"
        text: "True"
        is_correct: true
      - id: "false"
        text: "False"
    correct_answer: "true"

  - id: "q11"
    text: "Which open-source serving stacks expose an OpenAI-compatible API for self-hosted models? (Select all that apply.)"
    type: "multiple-answers"
    marks: 2
    options:
      - id: "a"
        text: "vLLM"
        is_correct: true
      - id: "b"
        text: "Hugging Face TGI"
        is_correct: true
      - id: "c"
        text: "Microsoft Word"
      - id: "d"
        text: "Ollama"
        is_correct: true
    correct_answer: "a,b,d"

  - id: "q12"
    text: "Which Meshery component discovers and syncs cluster state in real time?"
    type: "single-answer"
    marks: 2
    options:
      - id: "a"
        text: "MeshSync"
        is_correct: true
      - id: "b"
        text: "Kanvas"
      - id: "c"
        text: "fortio"
      - id: "d"
        text: "The Inference Router"
    correct_answer: "a"

  - id: "q13"
    text: "You captured a vLLM serving stack as a Meshery Design and want to catch a missing GPU limit before deploying. Which capability helps?"
    type: "single-answer"
    marks: 2
    options:
      - id: "a"
        text: "Relationship and policy validation"
        is_correct: true
      - id: "b"
        text: "Increasing replicas"
      - id: "c"
        text: "Raising the model temperature"
      - id: "d"
        text: "Deleting MeshSync"
    correct_answer: "a"

  - id: "q14"
    text: "Which Meshery capability measures latency and throughput of an inference endpoint and can compare runs over time?"
    type: "single-answer"
    marks: 2
    options:
      - id: "a"
        text: "Performance Profiles"
        is_correct: true
      - id: "b"
        text: "Knowledge bases"
      - id: "c"
        text: "Guardrails"
      - id: "d"
        text: "Model access keys"
    correct_answer: "a"

  - id: "q15"
    text: "The Inference Engine unifies which three inference modes under one OpenAI/Anthropic-compatible endpoint? (Select all that apply.)"
    type: "multiple-answers"
    marks: 3
    options:
      - id: "a"
        text: "Serverless"
        is_correct: true
      - id: "b"
        text: "Batch"
        is_correct: true
      - id: "c"
        text: "Dedicated"
        is_correct: true
      - id: "d"
        text: "Telegraph"
    correct_answer: "a,b,c"

  - id: "q16"
    text: "You must cap cost while keeping p95 latency acceptable, choosing a cheaper model when quality allows. Which control fits best?"
    type: "single-answer"
    marks: 2
    options:
      - id: "a"
        text: "The Inference Router with a cost/latency policy and fallbacks"
        is_correct: true
      - id: "b"
        text: "Hardcoding the most expensive model everywhere"
      - id: "c"
        text: "Disabling guardrails"
      - id: "d"
        text: "Setting temperature to 2.0"
    correct_answer: "a"

  - id: "q17"
    text: "Which DigitalOcean managed database extension enables vector similarity search for RAG?"
    type: "short-answer"
    marks: 2
    correct_answer: "pgvector"

  - id: "q18"
    text: "Which practices belong to securing AI services on DigitalOcean? (Select all that apply.)"
    type: "multiple-answers"
    marks: 3
    options:
      - id: "a"
        text: "Use VPCs and Cloud Firewalls for private networking"
        is_correct: true
      - id: "b"
        text: "Use least-privilege model/agent access keys and rotate them"
        is_correct: true
      - id: "c"
        text: "Apply guardrails for PII and unsafe content"
        is_correct: true
      - id: "d"
        text: "Commit access keys directly to a public Git repository"
    correct_answer: "a,b,c"

  - id: "q19"
    text: "In CI/CD for AI, what is the role of Evaluations?"
    type: "single-answer"
    marks: 2
    options:
      - id: "a"
        text: "To act as a quality gate that can fail the build on regressions in quality/latency/cost/safety"
        is_correct: true
      - id: "b"
        text: "To physically provision GPUs"
      - id: "c"
        text: "To replace version control"
      - id: "d"
        text: "To encrypt the container registry"
    correct_answer: "a"

  - id: "q20"
    text: "Describe the end-to-end architecture you would build for the DO-CAIE capstone, naming the DigitalOcean services and how Meshery is used to operate the GPU serving layer."
    type: "essay"
    marks: 5
    correct_answer: "A Gradient AI Platform agent with custom instructions and a base model, grounded by a knowledge base (RAG) built from multiple data sources with citations, and extended with a function route tool. A model is served on GPU infrastructure (a GPU Droplet or a DOKS GPU node pool) behind an OpenAI-compatible endpoint using vLLM/TGI/Ollama or a 1-Click Model. Meshery imports the DOKS cluster (MeshSync), captures the serving stack as a validated, versioned Design requesting nvidia.com/gpu, deploys it, runs Performance Profiles to measure latency/throughput, and observes GPU and latency metrics via Prometheus and Grafana. Guardrails and Evaluations provide safety and quality, Spaces and PostgreSQL/pgvector provide the data layer, VPCs/firewalls and least-privilege keys secure it, and GitHub Actions plus Meshery handle CI/CD with evaluations as a gate."
---
