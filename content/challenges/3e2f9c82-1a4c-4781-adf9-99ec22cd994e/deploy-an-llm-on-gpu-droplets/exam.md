---
title: "Deploy an LLM on GPU Droplets — Exam"
pass_percentage: 70
type: "test"
questions:
  - id: "q1"
    text: "What is the purpose of running `nvidia-smi` on a GPU Droplet?"
    type: "single-answer"
    marks: 2
    options:
      - id: "a"
        text: "To install the NVIDIA driver"
      - id: "b"
        text: "To verify the GPU, driver, and CUDA version are visible and report utilization"
        is_correct: true
      - id: "c"
        text: "To deploy a model from Hugging Face"
      - id: "d"
        text: "To create a Cloud Firewall rule"
    correct_answer: "b"

  - id: "q2"
    text: "Which of the following are valid GPU options for DigitalOcean GPU Droplets? (Select all that apply.)"
    type: "multiple-answers"
    marks: 3
    options:
      - id: "a"
        text: "NVIDIA H100"
        is_correct: true
      - id: "b"
        text: "AMD MI300X"
        is_correct: true
      - id: "c"
        text: "NVIDIA L40S"
        is_correct: true
      - id: "d"
        text: "Google TPU v5"
    correct_answer: "a,b,c"

  - id: "q3"
    text: "When migrating code written for the OpenAI SDK to call a model served on a GPU Droplet, what is the minimum change required?"
    type: "single-answer"
    marks: 2
    options:
      - id: "a"
        text: "Rewrite the client to use a DigitalOcean-specific protocol"
        is_correct: false
      - id: "b"
        text: "Change the SDK's base_url and api_key; the endpoint is OpenAI-compatible"
        is_correct: true
      - id: "c"
        text: "Convert all requests to gRPC"
        is_correct: false
      - id: "d"
        text: "Switch from JSON to Protocol Buffers"
        is_correct: false
    correct_answer: "b"

  - id: "q4"
    text: "1-Click Models on DigitalOcean are powered by which partner and require zero serving configuration."
    type: "true-false"
    marks: 1
    options:
      - id: "true"
        text: "True — they are powered by Hugging Face and the serving stack is auto-installed"
        is_correct: true
      - id: "false"
        text: "False"
    correct_answer: "true"

  - id: "q5"
    text: "Which command serves a model with vLLM's OpenAI-compatible API server on port 8000?"
    type: "single-answer"
    marks: 2
    options:
      - id: "a"
        text: "python -m vllm.entrypoints.openai.api_server --model <model> --host 0.0.0.0 --port 8000"
        is_correct: true
      - id: "b"
        text: "vllm download --model <model>"
      - id: "c"
        text: "doctl compute droplet serve <model>"
      - id: "d"
        text: "nvidia-smi --serve <model>"
    correct_answer: "a"

  - id: "q6"
    text: "Why should you destroy a GPU Droplet when you finish a lab?"
    type: "single-answer"
    marks: 2
    options:
      - id: "a"
        text: "GPU Droplets bill per hour while they exist, so destroying them stops charges"
        is_correct: true
      - id: "b"
        text: "Because the model is automatically deleted after one hour"
      - id: "c"
        text: "Because nvidia-smi stops working after 24 hours"
      - id: "d"
        text: "There is no cost reason; it is purely optional cleanup"
    correct_answer: "a"

  - id: "q7"
    text: "Why are AI/ML-ready GPU Droplet images recommended for serving models?"
    type: "single-answer"
    marks: 2
    options:
      - id: "a"
        text: "They include a paid license for every Hugging Face model"
      - id: "b"
        text: "They ship with NVIDIA/AMD drivers and CUDA/ROCm preinstalled, so the GPU works out of the box"
        is_correct: true
      - id: "c"
        text: "They disable billing while in use"
      - id: "d"
        text: "They are the only images that can run Python"
    correct_answer: "b"

  - id: "q8"
    text: "What path do vLLM and TGI expose for OpenAI-compatible chat completions?"
    type: "short-answer"
    marks: 2
    correct_answer: "/v1/chat/completions"

  - id: "q9"
    text: "Which two serving approaches in this challenge both result in an OpenAI-compatible endpoint? (Select all that apply.)"
    type: "multiple-answers"
    marks: 2
    options:
      - id: "a"
        text: "1-Click Models powered by Hugging Face"
        is_correct: true
      - id: "b"
        text: "Self-hosting with vLLM"
        is_correct: true
      - id: "c"
        text: "Editing /etc/hosts on the Droplet"
      - id: "d"
        text: "Uploading the model to Spaces only"
    correct_answer: "a,b"

  - id: "q10"
    text: "In one short phrase, what should you use to restrict network access to a self-hosted inference port like 8000 in production?"
    type: "short-answer"
    marks: 2
    correct_answer: "Cloud Firewall"
---
