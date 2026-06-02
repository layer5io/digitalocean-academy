---
type: "page"
id: "tooling-doctl-api-sdk-and-mcp"
title: "Tooling: doctl, API, SDKs & MCP"
description: "Install and authenticate doctl, use the DigitalOcean API, and get started with the Python and Go SDKs and the DigitalOcean MCP server."
weight: 4
---

## Overview

DigitalOcean exposes every capability through a public REST API. Everything the Control Panel does, you can do programmatically. Four tooling layers sit on top of that API: the `doctl` CLI, the Python `pydo` SDK, the Go `godo` SDK, and the DigitalOcean MCP server for AI IDE integrations.

## doctl — The CLI

`doctl` is the official command-line interface. Install it with your package manager:

```bash
# macOS
brew install doctl

# Linux (snap)
snap install doctl

# Linux (binary)
curl -sL https://github.com/digitalocean/doctl/releases/latest/download/doctl-linux-amd64.tar.gz | tar xz
sudo mv doctl /usr/local/bin
```

Authenticate with a Personal Access Token (PAT) from **API → Tokens** in the Control Panel:

```bash
doctl auth init
# Paste your PAT when prompted
```

Verify the connection and list your current projects:

```bash
doctl account get
doctl projects list
```

`doctl` covers the full API surface — Droplets, Kubernetes, Spaces, Databases, and AI services. For a complete reference see the [doctl docs](https://docs.digitalocean.com/reference/doctl/).

## REST API

Every `doctl` command maps to a REST call. Use the API directly when you need fine-grained control or are building automation:

```bash
# List GPU Droplet sizes using the API directly
curl -s -X GET "https://api.digitalocean.com/v2/sizes" \
  -H "Authorization: Bearer $DIGITALOCEAN_TOKEN" | jq '.sizes[] | select(.description | test("GPU"))'
```

Set `DIGITALOCEAN_TOKEN` to your PAT in your shell environment or `.env` file.

## Python SDK — pydo

`pydo` is the official Python client, auto-generated from the OpenAPI spec:

```bash
pip install pydo
```

```python
import os
import pydo

client = pydo.Client(token=os.environ["DIGITALOCEAN_TOKEN"])

# List all Droplets in your account
response = client.droplets.list()
for droplet in response["droplets"]:
    print(droplet["name"], droplet["status"])
```

`pydo` covers the full v2 API, including Spaces, Managed Databases, and Kubernetes. It is the right choice for Python automation scripts and CI/CD pipelines.

## Go SDK — godo

`godo` is the official Go client used internally by `doctl`:

```bash
go get github.com/digitalocean/godo
```

```go
package main

import (
    "context"
    "fmt"
    "os"

    "github.com/digitalocean/godo"
)

func main() {
    client := godo.NewFromToken(os.Getenv("DIGITALOCEAN_TOKEN"))
    account, _, err := client.Account.Get(context.Background())
    if err != nil {
        panic(err)
    }
    fmt.Println("Account email:", account.Email)
}
```

## DigitalOcean MCP Server

The **DigitalOcean MCP server** exposes DigitalOcean resources as tools inside AI-enabled IDEs and agents that support the Model Context Protocol (e.g., Cursor, Claude Desktop, VS Code with Copilot). This lets an AI assistant create Droplets, query databases, or inspect Kubernetes clusters on your behalf during a development session.

Configure it by adding the server to your MCP client settings with your PAT:

```json
{
  "mcpServers": {
    "digitalocean": {
      "command": "npx",
      "args": ["-y", "@digitalocean/mcp"],
      "env": {
        "DIGITALOCEAN_TOKEN": "<your-pat>"
      }
    }
  }
}
```

Once connected, your AI IDE can call DigitalOcean tools directly — for example: "spin up an H100 GPU Droplet in NYC3 and return its IP address."

All four tools share the same PAT-based authentication model. Rotate your token regularly and restrict its scopes to only the permissions your automation needs.
