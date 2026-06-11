[![Meshery Academy](https://img.shields.io/badge/Meshery-Academy-00B39F?style=flat-square&logo=meshery&logoColor=white)](https://cloud.meshery.io/academy)

![Meshery-Logo](.github/assets/images/meshery-logo-dark-text-side.svg)

# DigitalOcean Academy

DigitalOcean Academy is the official learning-content repository for DigitalOcean on the [Meshery Academy](https://cloud.meshery.io/academy) platform. It hosts structured learning paths, challenges, certifications, and Meshery infrastructure designs — helping engineers learn how to manage cloud-native infrastructure with Meshery on DigitalOcean.

🔗 **Live site:** <https://digitalocean.layer5.io/academy>

---

## 📚 Overview

| | |
|---|---|
| **Purpose** | Primary source of DigitalOcean-specific Meshery learning content |
| **Platform** | Runs on the shared [Layer5 Academy](https://cloud.meshery.io/academy) platform |
| **Authoring** | Markdown-based content with live local preview via Hugo |
| **Content types** | Learning paths · Challenges · Certifications · Infrastructure designs |
| **Org ID** | `3e2f9c82-1a4c-4781-adf9-99ec22cd994e` |

---

## 🛠️ Prerequisites

Before you begin, ensure you have the following installed:

| Tool | Version | Link |
|------|---------|------|
| **Hugo** (extended) | ≥ 0.156.0 | [Install Hugo](https://gohugo.io/getting-started/installing/) |
| **Go** | ≥ 1.24 | [Install Go](https://go.dev/doc/install) |
| **Node.js / npm** | LTS | [Install Node.js](https://nodejs.org/) |
| **Git** | Latest | [Install Git](https://git-scm.com/) |

---

## 🚀 Getting Started

### 1. Fork & Clone

```bash
# Fork this repository on GitHub, then clone your fork
git clone https://github.com/<your-username>/digitalocean-academy.git
cd digitalocean-academy
```

### 2. Install Dependencies

```bash
npm install
```

### 3. Run the Site Locally

Start the Hugo development server with drafts and future content enabled:

```bash
hugo server -D
```

Or use the Makefile target (includes draft **and** future content):

```bash
make site
```

The site will be available at `http://localhost:1313/academy/` (or the port shown in your terminal).

> **Note:** The local preview uses basic styling. Full Academy branding is applied after content is integrated into the cloud platform.

### 4. Other Useful Commands

| Command | Description |
|---------|-------------|
| `make setup` | Install npm dependencies |
| `make build` | Build the site for production |
| `make clean` | Clear build cache and restart the dev server |
| `make theme-update` | Update the `academy-theme` Hugo module to the latest version |

---

## 📁 Repository Structure

```text
digitalocean-academy/
├── .github/                  # GitHub workflows, issue templates, PR templates
│   ├── build/                # Makefile includes
│   ├── readme/images/        # README assets
│   ├── workflows/            # CI/CD pipelines
│   └── PULL_REQUEST_TEMPLATE.md
├── assets/json/              # JSON data assets
├── content/                  # 📝 All learning content lives here
│   ├── _index.md             # Site root page
│   ├── learning-paths/       # Learning paths scoped by org ID
│   ├── certifications/       # Certification content
│   └── challenges/           # Challenge content
├── designs/                  # Meshery infrastructure designs (YAML)
├── layouts/                  # Hugo layout overrides & shortcodes
│   ├── _partials/            # Partial templates
│   └── shortcodes/           # Custom Hugo shortcodes
├── public/                   # Generated site output (git-ignored)
├── resources/                # Hugo resource cache
├── go.mod / go.sum           # Go module (pulls academy-theme)
├── hugo.yaml                 # Hugo configuration
├── Makefile                  # Build & dev targets
├── package.json              # Node.js dependencies
└── README.md                 # ← You are here
```

---

## ✍️ Content Authoring

### Content Hierarchy

The Academy content follows this structure: **Learning Path → Course → Chapter → Lesson**.

```text
content/
└── learning-paths/
    ├── _index.md
    └── 3e2f9c82-1a4c-4781-adf9-99ec22cd994e/   # DigitalOcean org UID
        └── <your-learning-path>/
            ├── _index.md
            └── <your-course>/
                ├── _index.md
                └── content/
                    ├── lesson-1.md
                    └── lesson-2.md
```

### Adding Images

Use the `usestatic` shortcode (not standard Markdown image links) for tenant-aware asset paths:

1. Place your image in `static/3e2f9c82-1a4c-4781-adf9-99ec22cd994e/images/`
2. Reference it in your lesson:
   ```text
   ![Alt text]({{< usestatic path="images/your-image.png" >}})
   ```

### Adding Videos

```text
{{< card title="Video: Example" >}}
<video width="100%" height="100%" controls>
    <source src="https://example.com/video.mp4" type="video/mp4">
    Your browser does not support the video tag.
</video>
{{< /card >}}
```

### Adding Assessments

Assessment files use the Academy test layout. Question and option IDs must be unique within their scope.

```yaml
---
title: "Assessment Example"
id: "assessment-example"
type: "test"
layout: "test"
passPercentage: 70
maxAttempts: 3
timeLimit: 30
numberOfQuestions: 1
questions:
  - id: "q1"
    text: "DigitalOcean Academy content is authored in Markdown."
    type: "true-false"
    marks: 1
    options:
      - id: "true"
        text: "True"
        isCorrect: true
      - id: "false"
        text: "False"
---
```

---

## 🤝 Contribution Workflow

We welcome contributions! Please follow the **fork → branch → commit → push → pull request** workflow:

### Step-by-Step

1. **Fork** this repository on GitHub.
2. **Clone** your fork locally:
   ```bash
   git clone https://github.com/<your-username>/digitalocean-academy.git
   cd digitalocean-academy
   ```
3. **Create a branch** for your changes:
   ```bash
   git checkout -b feature/<your-username>/<issue-number>
   ```
4. **Make your changes** — add or edit content in `content/`, fix bugs, improve docs.
5. **Preview locally** to verify:
   ```bash
   hugo server -D
   ```
6. **Commit** with a sign-off (required by DCO):
   ```bash
   git commit -s -m "docs: describe your change"
   ```
7. **Push** to your fork:
   ```bash
   git push origin feature/<your-username>/<issue-number>
   ```
8. **Open a Pull Request** against the `master` branch of this repository.

> For a detailed guide on the fork-and-pull workflow, see [CONTRIBUTING-gitflow.md](./CONTRIBUTING-gitflow.md).

### Important Guidelines

- All commits must be **signed-off** ([Developer Certificate of Origin](https://developercertificate.org/)).
- Pull requests should reference an open issue.
- See [CONTRIBUTING.md](./CONTRIBUTING.md) for the full contribution guide.
- See [CODE_OF_CONDUCT.md](./CODE_OF_CONDUCT.md) for community standards.

---

## 🔗 Related Repositories

| Repository | Description |
|---|---|
| [meshery/meshery](https://github.com/meshery/meshery) | Meshery core project |
| [meshery-extensions/meshery-academy](https://github.com/meshery-extensions/meshery-academy) | Meshery Academy content |
| [meshery-extensions/digitalocean-academy](https://github.com/meshery-extensions/digitalocean-academy) | This repository (upstream) |
| [layer5io/academy-theme](https://github.com/layer5io/academy-theme) | Academy Hugo theme — styles, shortcodes, layouts |
| [layer5io/academy-build](https://github.com/layer5io/academy-build) | Build pipeline that aggregates academies for publishing |

---

## 📄 License

This repository is available as open source under the terms of the [Apache 2.0 License](./LICENSE).
