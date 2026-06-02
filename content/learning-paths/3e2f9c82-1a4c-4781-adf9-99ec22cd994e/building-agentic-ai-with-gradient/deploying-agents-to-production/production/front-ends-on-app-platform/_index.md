---
type: "page"
id: "front-ends-on-app-platform"
title: "Front Ends on App Platform"
description: "Deploy a chat UI on DigitalOcean App Platform that calls your Gradient agent endpoint and serves users through a production-ready web application."
weight: 2
---

## Why App Platform

DigitalOcean App Platform is a managed platform-as-a-service that builds, deploys, and scales web applications from source code without infrastructure management. It pairs naturally with Gradient agents: your agent handles the AI logic; App Platform hosts the front end that users interact with.

App Platform supports Node.js, Python, Go, Ruby, PHP, and static sites. It provides automatic TLS, custom domains, horizontal scaling, and built-in deployment pipelines from GitHub.

## Architecture

```
Browser / mobile client
         ↓
App Platform (chat UI)
         ↓
Gradient agent endpoint
https://<agent-id>.agents.do-ai.run/api/v1/chat/completions
```

The front end communicates with the Gradient endpoint server-side (from a back-end route) to keep the agent access key out of client-side code.

## Minimal Node.js Chat Server

The following Express.js server proxies requests from the browser to the agent endpoint using the OpenAI-compatible SDK:

```js
// server.js
const express = require("express");
const OpenAI = require("openai");

const app = express();
app.use(express.json());
app.use(express.static("public")); // serve the chat UI

const client = new OpenAI({
  baseURL: process.env.AGENT_BASE_URL,   // e.g. https://<agent-id>.agents.do-ai.run/api/v1
  apiKey: process.env.AGENT_ACCESS_KEY
});

app.post("/chat", async (req, res) => {
  const { messages } = req.body;
  try {
    const completion = await client.chat.completions.create({
      model: "n/a",
      messages
    });
    res.json({ reply: completion.choices[0].message.content });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.listen(process.env.PORT || 8080);
```

The `AGENT_BASE_URL` and `AGENT_ACCESS_KEY` values are injected as environment variables in App Platform, never hardcoded.

## Deploying to App Platform

1. Push the project to a GitHub repository.
2. In the [App Platform console](https://cloud.digitalocean.com/apps), click **Create App**.
3. Connect the GitHub repository.
4. App Platform auto-detects Node.js. Set the **run command** to `node server.js`.
5. Under **Environment Variables**, add:
   - `AGENT_BASE_URL` — the agent's base URL (found in the agent's endpoint settings).
   - `AGENT_ACCESS_KEY` — the agent access key (mark as **encrypted**).
6. Click **Deploy**.

App Platform builds the application, provisions a managed instance, and returns a live HTTPS URL within a few minutes. See the [App Platform documentation](https://docs.digitalocean.com/products/app-platform/) for details on custom domains, scaling, and deployment settings.

## Streaming Responses

For a better user experience, stream the agent's response token-by-token instead of waiting for the full reply:

```js
app.post("/chat/stream", async (req, res) => {
  res.setHeader("Content-Type", "text/event-stream");
  const { messages } = req.body;
  const stream = await client.chat.completions.create({
    model: "n/a",
    messages,
    stream: true
  });
  for await (const chunk of stream) {
    const token = chunk.choices[0]?.delta?.content ?? "";
    if (token) res.write(`data: ${JSON.stringify({ token })}\n\n`);
  }
  res.write("data: [DONE]\n\n");
  res.end();
});
```

The browser reads the event stream and appends tokens to the chat bubble as they arrive.

## Securing the Front End

- Store the agent access key in App Platform's encrypted environment variables, never in client-side JavaScript.
- Add authentication to the `/chat` route so only your users can call the agent.
- Rate-limit the `/chat` endpoint to prevent abuse.

Learn more in the [App Platform documentation](https://docs.digitalocean.com/products/app-platform/).
