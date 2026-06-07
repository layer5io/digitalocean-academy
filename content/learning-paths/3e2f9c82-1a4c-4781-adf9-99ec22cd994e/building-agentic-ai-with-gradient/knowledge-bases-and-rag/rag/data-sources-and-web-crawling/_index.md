---
type: "page"
id: "data-sources-and-web-crawling"
title: "Data Sources & Web Crawling"
description: "Connect uploaded files, Spaces folders, websites, and cloud-storage providers to a Gradient knowledge base, and understand how re-indexing keeps content current."
weight: 3
---

## Supported Data Sources

The Gradient AI Platform knowledge base accepts content from multiple source types. You can mix sources within a single knowledge base, and you can add or remove sources after creation.

| Source type | Description |
|-------------|-------------|
| Uploaded files | PDFs, plain text, Markdown, and other document formats uploaded directly |
| DigitalOcean Spaces folder | A Spaces bucket or folder; new files added to the bucket can be re-indexed |
| Web crawling | Provide a starting URL; the crawler follows links to index public pages |
| AWS S3 | Connect an S3 bucket with read credentials |
| Dropbox | Connect a Dropbox folder via the connector |
| Google Drive | Connect a Drive folder or shared drive |

## Uploading Files

File upload is the simplest option for static document sets such as product manuals, legal agreements, or internal wikis exported to PDF.

Steps:
1. Navigate to your knowledge base in the Control Panel.
2. Click **Add data source → File upload**.
3. Drag in or browse to your files. Multiple files can be uploaded in a single batch.
4. Click **Index**. The platform parses, chunks, and embeds each file.

For PDFs with scanned pages or complex tables, the platform applies GPU-accelerated OCR and layout analysis to accurately extract text from structured content. This leads to significantly better answers on table-heavy documents compared to basic text extraction.

## DigitalOcean Spaces

Connecting a Spaces folder is useful for large document libraries maintained by other systems:

```bash
curl -X POST https://api.digitalocean.com/v2/gen-ai/knowledge_bases/{kb_uuid}/datasources \
  -H "Authorization: Bearer $DIGITALOCEAN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "type": "spaces_bucket",
    "config": {
      "bucket": "my-docs-bucket",
      "region": "nyc3",
      "prefix": "support/"
    }
  }'
```

When you add new files to the Spaces prefix, trigger a re-index to pick up the changes.

## Web Crawling

Web crawling lets you index public documentation sites, marketing pages, or any publicly reachable content:

1. Click **Add data source → Web crawl**.
2. Enter the **starting URL** (e.g., `https://docs.example.com`).
3. Set the **crawl depth** — how many link-hops from the starting URL the crawler should follow.
4. Optionally set **URL path filters** to restrict crawling to specific sections.

The crawler fetches pages, strips navigation and boilerplate, and indexes the main content. JavaScript-rendered pages may require the crawler to be configured to wait for rendering.

## Cloud Storage Connectors

For S3, Dropbox, and Google Drive, the platform uses OAuth or access-key credentials to read files. Configuration is done in the Control Panel under the connector settings. The connector periodically checks for new or modified files based on the re-index schedule you configure.

## Re-indexing

Content in a knowledge base becomes stale when the underlying sources change. Re-indexing refreshes the vector store:

```
On-demand re-index
    ↓
Platform fetches current files from each data source
    ↓
Changed or new documents are re-chunked and re-embedded
    ↓
Deleted files are removed from the index
    ↓
Index is updated in place (no downtime)
```

Trigger re-indexing from the Control Panel or via API:

```bash
curl -X POST https://api.digitalocean.com/v2/gen-ai/knowledge_bases/{kb_uuid}/reindex \
  -H "Authorization: Bearer $DIGITALOCEAN_TOKEN"
```

For connectors, you can also configure a scheduled re-index (daily, weekly) so the knowledge base stays current without manual intervention.

## Best Practices

- Keep individual files under a few MB where possible; very large files can slow indexing.
- Use descriptive file names — they appear in citations and help users verify sources.
- Remove outdated documents rather than leaving them in the index; stale content confuses retrieval.
- After any re-index, test a sample of queries in the playground to confirm retrieval quality.

Learn more in the [knowledge-base documentation](https://docs.digitalocean.com/products/gradient-ai-platform/how-to/create-manage-agent-knowledge-bases/).
