---
type: "page"
id: "submission-process"
title: "Submission Process"
description: "How to package, submit, and track your DO-CAIE capstone for review."
weight: 3
---

Once your project meets the requirements and you have self-assessed against the rubric, follow this
process to submit.

## 1. Package your submission

Your Git repository should be self-contained and reproducible:

```text
docaie-capstone/
├── README.md                 # architecture, services, decisions, demo link
├── agent/                    # agent config/code, function route(s)
├── serving/                  # Dockerfile / manifests for the self-hosted model
├── meshery/
│   ├── inference-design.yaml # exported Meshery Design
│   └── performance-profile/  # exported profile + run results
├── k8s/                      # any extra Kubernetes manifests
├── evaluations/              # evaluation dataset + results summary
└── .github/workflows/ci.yml  # build/test (+ evaluation gate, if used)
```

Make sure no secrets are committed. Reference keys via environment variables and document which
ones are needed.

## 2. Record the demo

Capture a short (5–8 minute) walkthrough showing:

- the agent answering a grounded question **with a citation**,
- the agent invoking its **function route** tool,
- the **Meshery Performance Profile** results against the inference endpoint,
- the **Grafana** GPU/latency dashboard.

## 3. Self-assessment

Add a `SELF-ASSESSMENT.md` mapping each rubric category to where it is satisfied (file paths and
demo timestamps). This speeds review and helps you catch gaps before submitting.

## 4. Submit

From the certification page, choose **Submit capstone** and provide:

- the repository URL (public, or grant reviewer access),
- the demo link,
- your self-assessment.

## 5. Review and result

- Reviewers grade against the rubric and return results within **5 business days**.
- If you pass and have also passed the written exam, your **DO-CAIE badge** is issued.
- If revisions are requested, address the feedback and resubmit once per review cycle.

## After you certify

- Share your badge and add it to your profile.
- Keep the project alive: re-run Evaluations and Performance Profiles against newer models to stay
  sharp for **recertification**.

Congratulations — completing the capstone is the final step toward becoming a **DigitalOcean
Certified AI Engineer**.
