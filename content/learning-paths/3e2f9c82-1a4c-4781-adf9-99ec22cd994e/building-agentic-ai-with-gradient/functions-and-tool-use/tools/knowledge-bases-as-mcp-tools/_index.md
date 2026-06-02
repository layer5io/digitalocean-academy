---
type: "page"
id: "knowledge-bases-as-mcp-tools"
title: "Knowledge Bases as MCP Tools"
description: "Expose a Gradient knowledge base as a Model Context Protocol tool and understand what MCP enables for agent interoperability."
weight: 4
---

## What Is MCP?

The **Model Context Protocol (MCP)** is an open standard for connecting AI agents and models to external tools, data sources, and services through a uniform interface. An MCP server exposes one or more tools; an MCP client (the agent) calls those tools using a standardized request/response schema. MCP decouples the tool implementation from the agent platform, enabling interoperability across different AI frameworks and hosts.

## Knowledge Bases as MCP Tools

The Gradient AI Platform can expose a knowledge base as an MCP tool. This means:

- Any MCP-compatible agent or framework — including agents outside the Gradient platform — can query your knowledge base using the standard MCP protocol.
- The knowledge base appears as a named tool in the MCP tool list, callable with a simple query string.
- The platform handles embedding the query, running vector search, and returning relevant chunks with citations.

## Enabling MCP Exposure

To expose a knowledge base as an MCP tool, navigate to the knowledge base in the Control Panel and enable the **MCP tool** option. The platform generates an MCP endpoint URL and access credentials.

The tool is registered with a name and description that MCP clients use for routing, following the same principles as any function route description.

## Calling the Knowledge Base via MCP

A standard MCP tool call to a knowledge-base tool looks like this:

```json
{
  "tool": "search_support_docs",
  "arguments": {
    "query": "How do I reset my two-factor authentication?"
  }
}
```

The response returns the top-k chunks with document references:

```json
{
  "results": [
    {
      "chunk": "To reset 2FA, navigate to Account Settings → Security → Two-Factor Authentication and click Reset...",
      "document": "account-security-guide.pdf",
      "score": 0.94
    }
  ]
}
```

## What MCP Enables

### Cross-Platform Reuse

A knowledge base built on Gradient can be queried by agents running on other platforms or frameworks that implement the MCP client standard. You invest once in curating, indexing, and maintaining the knowledge base, and multiple agents across different systems benefit from it.

### Composable Agent Architectures

In a multi-agent system, individual agents can specialize. A billing agent and a technical-support agent can both call the same shared product-documentation knowledge base as an MCP tool, rather than each maintaining a duplicate knowledge base attachment.

### External Toolchains

Development workflows and CI/CD pipelines that use MCP-aware tooling can query knowledge bases directly — for example, a code-review agent that checks proposed changes against a compliance knowledge base.

## MCP vs. Direct Attachment

| Scenario | Use |
|----------|-----|
| Knowledge base used only by Gradient agents | Direct KB attachment |
| Knowledge base shared across platforms or frameworks | MCP tool exposure |
| Tight integration with Gradient observability and citations | Direct KB attachment |
| Interoperability with third-party agents or custom clients | MCP tool exposure |

Both approaches can be active simultaneously — a knowledge base can be attached to Gradient agents directly and also exposed as an MCP tool for external consumers.

## Security Considerations

MCP tool endpoints require authentication. Use separate access credentials for MCP clients than for internal Gradient agents. Rotate credentials on a schedule and scope each credential to the minimum set of knowledge bases required.

Learn more in the [Gradient AI Platform documentation](https://docs.digitalocean.com/products/gradient-ai-platform/).
