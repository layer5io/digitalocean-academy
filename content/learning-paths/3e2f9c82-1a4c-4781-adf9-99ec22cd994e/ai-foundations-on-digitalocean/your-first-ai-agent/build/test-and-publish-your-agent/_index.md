---
type: "page"
id: "test-and-publish-your-agent"
title: "Test & Publish Your Agent"
description: "Use the Gradient agent playground to iterate on instructions, then publish your agent to a live endpoint secured with an agent access key."
weight: 3
---

## Overview

Before exposing your agent to real users you need to verify it behaves correctly. The Gradient AI Platform provides a built-in **playground** for interactive testing. Once satisfied, you publish the agent to create a stable HTTPS endpoint that your application can call.

## Testing in the Playground

The playground is available on any saved draft agent:

1. Open the agent in the Control Panel (**AI → Gradient Agents → select your agent**).
2. Click the **Playground** tab.
3. Type test messages in the chat input and observe the responses.

Effective testing in the playground:

- Try the **happy path** — questions squarely within the agent's domain.
- Try **edge cases** — ambiguous questions, very short messages, and very long messages.
- Try **adversarial inputs** — questions designed to push the agent outside its instructions (prompt injection attempts, out-of-scope requests).
- If knowledge bases are attached, ask questions whose answers appear in the documents and verify citations are returned.

When the agent fails a test case, edit the **Instructions** field, save, and re-test immediately. The playground reflects the latest saved draft without publishing.

## Creating a Version

Versioning lets you manage the agent lifecycle without breaking existing callers:

1. When you are satisfied with playground results, click **Create Version**.
2. Give the version a label (e.g., `v1`, `2026-06-02`).
3. Versions are immutable snapshots. Future instruction edits create a new draft; previous versions remain accessible.

Keep a version per meaningful change to instructions, model, or knowledge base configuration. This makes rollback straightforward.

## Creating an Agent Access Key

Agent access keys authenticate callers to your published endpoint:

1. Navigate to **AI → Gradient Agents → select your agent → Access Keys**.
2. Click **Generate New Key**.
3. Name the key after the calling application (e.g., `web-app-prod`).
4. Copy the key — it is shown once.

Store it as an environment variable:

```bash
export DO_AGENT_KEY="doagent_your_key_here"
```

Create separate keys for each environment (dev, staging, prod) so you can rotate or revoke them independently.

## Publishing the Agent

Publishing makes the current version live on its endpoint:

1. On the **Versions** tab, select the version to publish.
2. Click **Publish**.
3. The Control Panel confirms the endpoint URL:

   ```
   https://<agent-id>.agents.do-ai.run
   ```

The agent is now live. Verify it is responding by sending a quick curl test:

```bash
curl -s "https://<agent-id>.agents.do-ai.run/v1/chat/completions" \
  -H "Authorization: Bearer $DO_AGENT_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "messages": [{"role": "user", "content": "Hello, what can you help me with?"}]
  }' | jq '.choices[0].message.content'
```

## Monitoring with Agent Insights

After publishing, the **Agent Insights** tab shows:

- Request volume over time
- Average latency per request
- Token usage (prompt and completion)
- Knowledge base retrieval hit rate (if knowledge bases are attached)
- Error rates by type

Review Insights after the first 100 real requests to identify patterns — high token usage in prompts often signals an opportunity to tighten instructions.

Full publishing reference: [docs.digitalocean.com/products/gradient-ai-platform/](https://docs.digitalocean.com/products/gradient-ai-platform/).
