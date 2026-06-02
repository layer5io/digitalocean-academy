---
type: "page"
id: "attaching-knowledge-bases-and-citations"
title: "Attaching Knowledge Bases & Citations"
description: "Attach and detach knowledge bases to an agent, verify that retrieval is working, and read citation metadata in API responses."
weight: 4
---

## Attaching a Knowledge Base to an Agent

A knowledge base only affects an agent's responses after it is explicitly attached. You can attach multiple knowledge bases to a single agent — for example, one for product documentation and one for support policies — and detach them independently without recreating the agent.

### Via the Control Panel

1. Open your agent and select the **Knowledge Bases** tab.
2. Click **Attach knowledge base**.
3. Select the knowledge base from the dropdown. The platform lists all knowledge bases in your account.
4. Click **Save**. The attachment takes effect immediately; no redeployment is required.

### Via the API

```bash
curl -X POST \
  https://api.digitalocean.com/v2/gen-ai/agents/{agent_uuid}/knowledge_bases \
  -H "Authorization: Bearer $DIGITALOCEAN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"knowledge_base_uuid": "<kb-uuid>"}'
```

To detach:

```bash
curl -X DELETE \
  https://api.digitalocean.com/v2/gen-ai/agents/{agent_uuid}/knowledge_bases/{kb_uuid} \
  -H "Authorization: Bearer $DIGITALOCEAN_TOKEN"
```

## Verifying Retrieval in the Playground

After attaching a knowledge base, always verify retrieval before promoting to production:

1. Open the agent in the playground.
2. Send a question that should be answered by content in the knowledge base.
3. Inspect the response for:
   - Accurate facts drawn from the indexed documents.
   - Citation metadata indicating which document(s) were used.
   - No hallucinated details not present in the source.

If the agent answers correctly but without citations, confirm that citation output is enabled in your agent configuration. If the answer is wrong, check retrieval by examining which chunks were returned — this is visible in the playground's debug panel.

## Reading Citations in API Responses

When the Gradient endpoint returns a response that used knowledge-base content, the response includes citation objects alongside the generated text. The structure follows a pattern similar to:

```json
{
  "id": "chatcmpl-abc123",
  "choices": [
    {
      "message": {
        "role": "assistant",
        "content": "Refunds are processed within 5 business days [1].",
        "citations": [
          {
            "index": 1,
            "document_name": "refund-policy-2025.pdf",
            "page": 3,
            "chunk": "Refunds initiated before the 30-day window are processed within 5 business days..."
          }
        ]
      }
    }
  ]
}
```

Check the [Gradient API reference](https://docs.digitalocean.com/products/gradient-ai-platform/) for the exact citation field names in the current API version.

## Displaying Citations in Your Front End

A minimal Python example that prints the answer and its sources:

```python
import openai

client = openai.OpenAI(
    base_url="https://<agent-id>.agents.do-ai.run/api/v1",
    api_key="<agent-access-key>"
)

response = client.chat.completions.create(
    model="n/a",
    messages=[{"role": "user", "content": "What is the refund window?"}]
)

choice = response.choices[0].message
print(choice.content)

citations = getattr(choice, "citations", [])
for c in citations:
    print(f"  Source: {c.get('document_name')} p.{c.get('page')}")
```

Replace `<agent-id>` and `<agent-access-key>` with the values shown in your agent's endpoint settings.

## Multiple Knowledge Bases

When multiple knowledge bases are attached, the platform searches all of them at query time and merges the top-k results before injecting them into context. Citations indicate the source knowledge base and document for each retrieved chunk, so users and developers can trace answers back to specific sources.

Keep attached knowledge bases focused and non-overlapping where possible. Overlapping content does not break retrieval but can reduce precision — the model may receive near-duplicate chunks that add noise without adding information.

Learn more in the [knowledge-base documentation](https://docs.digitalocean.com/products/gradient-ai-platform/how-to/create-manage-agent-knowledge-bases/).
