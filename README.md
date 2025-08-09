
# Digital Ocean Academy 
This repository is a starter template for creating custom learning paths and courses on the [Layer5 Academy](https://cloud.layer5.io/academy/overview). It provides the necessary file structure and a working example to help you get started quickly.

This guide will walk you through setting up your own content repository, creating courses, and previewing them locally.

> For more in-depth documentation, see the official [Layer5 Academy docs](https://docs.layer5.io/cloud/academy/).

## Prerequisites

Before you begin, ensure you have the following installed on your system:

  * [**Hugo**](https://gohugo.io/getting-started/installing/) (extended version) （version 0.147.9）
  * [**Go**](https://go.dev/doc/install) （version 1.12）

## Getting Started

Follow these steps to create your own learning path using this template.

### 1. Fork & Clone the Repository

First, create a copy of this repository under your own GitHub account.

  - **Fork** this [academy-example](https://github.com/layer5io/academy-example) repository.
  - Clone your forked repository:
    ```bash
    # Replace <your-username> with your GitHub username
    git clone https://github.com/<your-username>/academy-example.git
    cd academy-example
    ```

### 2. Update the Go Module Path

  - Open the `go.mod` file at the root of the project.
  - Change the first line from:
    ```go
    module github.com/layer5io/academy-example
    ```
  - To match your repository's path:
    ```go
    module github.com/<your-username>/academy-example
    ```
  - Save the file, then commit and push the change.

### 3. Configure Your Organization Directories

The Academy platform uses an **Organization UID** to keep content separate and secure. You must get this ID from the Layer5 CLoud before proceeding.

Once you have your UID, rename the placeholder directories:

  - Rename `content/learning-paths/your-org-uid` to `content/learning-paths/<your-organization-uid>`
  - Rename `static/your-org-uuid` to `static/<your-organization-uid>`
  - Rename `layouts/shortcodes/your-org-uuid` to `layouts/shortcodes/<your-organization-uid>`

### 4. Add Your Content

Now you're ready to create your learning path. The structure is: **Learning Path → Course → Chapter → Lesson**.

A high-level view of the structure looks like this:
  ```text
  content/
  └── learning-paths/
      ├── _index.md
      └── <your-organization-uid>/
          └── <your-learning-path>/
              ├── _index.md
              └── <your-course-1>/
              └── <your-course-2>/
                  ├── _index.md
                  └── content/
                      └── your-lesson-1.md
                      └── your-lesson-2.md
  ```

  - **Delete the example content** inside `content/learning-paths/<your-organization-uid>/`.
  - **Create your folder structure** following the example's hierarchy.
  - **Add your lessons** as Markdown (`.md`) files inside the `content` directory of a course.
  - **Use frontmatter** at the top of your `_index.md` and lesson files to define titles, descriptions, and weights.

### 5. Add Assets (Images & Videos)

Enhance your course with images and other visual aids. To ensure compatibility with the multi-tenant Academy platform, **do not use standard Markdown image links**. Instead, use the `usestatic` shortcode, which generates the correct, tenant-aware path for your assets.

**How to Add an Image**

1.  Place your image file (e.g., `hugo-logo.png`) in your scoped static directory:

    ```text
    static/<your-organization-uid>/images/hugo-logo.png
    ```
2.  In your `lesson-1.md` file, embed the image using the `usestatic` shortcode. The `path` is relative to your scoped static folder: 

    ```text
    ![The Hugo Logo]({{</* usestatic path="images/hugo-logo.png" */>}})
    ```

Then the system will automatically convert this into the correct URL when building the site.

**How to Add a Video**

```text
{{</* card 
title="Video: Example" */>}}
<video width="100%" height="100%" controls>
    <source src="https://exmaple.mp4" type="video/mp4">
    Your browser does not support the video tag.
</video>
{{</* /card */>}}
```

### 6. Local Development

To preview your content locally, run the Hugo server from the project root:

```bash
hugo server
```

This will start a local server. You can view your content and check for formatting issues before publishing.

> The local preview uses basic styling. Full Academy branding and styles will be applied after your content is integrated into the cloud platform.

### 7. Going Live

Once your content is complete and tested locally:

1.  Push all your changes to your forked repository on GitHub.
2.  **[Connect](https://layer5.io/company/contact) the Layer5 Team** via Slack, email, or by opening a GitHub issue.
3.  Provide the URL to your content repository.

A Layer5 administrator will then integrate your repository into the main Academy platform. After integration, your learning paths will be visible on the official [Layer5 Cloud site](https://cloud.layer5.io/academy/overview).

