---
title: "Build a RAG Agent with Knowledge Bases — Exam"
pass_percentage: 70
type: "test"
questions:
  - id: "q1"
    text: "What does a knowledge base provide to a Gradient AI Platform agent?"
    type: "single-answer"
    marks: 2
    options:
      - id: "a"
        text: "The ability to call external APIs as tools"
      - id: "b"
        text: "Retrieval-augmented grounding on private data, with citations"
        is_correct: true
      - id: "c"
        text: "A larger GPU for the base model"
      - id: "d"
        text: "Automatic fine-tuning of the base model's weights"
    correct_answer: "b"

  - id: "q2"
    text: "Which steps make up the RAG pipeline behind a knowledge base? (Select all that apply.)"
    type: "multiple-answers"
    marks: 3
    options:
      - id: "a"
        text: "Chunking the source content"
        is_correct: true
      - id: "b"
        text: "Generating embeddings"
        is_correct: true
      - id: "c"
        text: "Vector search / retrieval at query time"
        is_correct: true
      - id: "d"
        text: "Retraining the base model on every request"
    correct_answer: "a,b,c"

  - id: "q3"
    text: "Which of the following are valid knowledge base data sources? (Select all that apply.)"
    type: "multiple-answers"
    marks: 3
    options:
      - id: "a"
        text: "Uploaded files"
        is_correct: true
      - id: "b"
        text: "Spaces folders"
        is_correct: true
      - id: "c"
        text: "Web crawling of public pages"
        is_correct: true
      - id: "d"
        text: "Connectors such as AWS S3, Dropbox, and Google Drive"
        is_correct: true
    correct_answer: "a,b,c,d"

  - id: "q4"
    text: "After updating the underlying source documents, what must you do so the agent retrieves the new content?"
    type: "short-answer"
    marks: 2
    correct_answer: "re-index"

  - id: "q5"
    text: "A user asks the agent something that is NOT in the knowledge base. With good grounding instructions, what is the desired behavior?"
    type: "single-answer"
    marks: 2
    options:
      - id: "a"
        text: "Invent a plausible-sounding answer"
      - id: "b"
        text: "State that it does not know and suggest where to look, rather than hallucinate"
        is_correct: true
      - id: "c"
        text: "Silently return an empty response"
      - id: "d"
        text: "Switch to a different base model automatically"
    correct_answer: "b"

  - id: "q6"
    text: "Knowledge base citations are useful primarily because they make answers auditable and traceable to sources."
    type: "true-false"
    marks: 1
    options:
      - id: "true"
        text: "True"
        is_correct: true
      - id: "false"
        text: "False"
    correct_answer: "true"

  - id: "q7"
    text: "You need the agent to take an action by calling an internal order-status API. Which capability is correct?"
    type: "single-answer"
    marks: 2
    options:
      - id: "a"
        text: "Add another knowledge base"
      - id: "b"
        text: "Add a function route (tool) with a typed input/output schema"
        is_correct: true
      - id: "c"
        text: "Increase the temperature"
      - id: "d"
        text: "Re-crawl the website"
    correct_answer: "b"

  - id: "q8"
    text: "Which two changes most directly improve retrieval quality when relevant content is being missed? (Select all that apply.)"
    type: "multiple-answers"
    marks: 2
    options:
      - id: "a"
        text: "Tuning chunk size and overlap"
        is_correct: true
      - id: "b"
        text: "Choosing a more appropriate embedding model"
        is_correct: true
      - id: "c"
        text: "Raising max_tokens"
      - id: "d"
        text: "Removing all data sources"
    correct_answer: "a,b"

  - id: "q9"
    text: "When calling a published agent from the OpenAI SDK, which fields change versus calling OpenAI directly?"
    type: "single-answer"
    marks: 2
    options:
      - id: "a"
        text: "base_url and api_key"
        is_correct: true
      - id: "b"
        text: "The HTTP method only"
      - id: "c"
        text: "Nothing changes"
      - id: "d"
        text: "You must switch to a SOAP client"
    correct_answer: "a"

  - id: "q10"
    text: "Explain, in one or two sentences, the difference between giving an agent a knowledge base versus a function route."
    type: "essay"
    marks: 3
    correct_answer: "A knowledge base supplies retrieved knowledge (grounding the agent's answers on private data via RAG with citations), while a function route gives the agent a tool to take an action by calling external code or an API with a defined input/output schema. Knowledge bases inform answers; function routes perform actions."
---
