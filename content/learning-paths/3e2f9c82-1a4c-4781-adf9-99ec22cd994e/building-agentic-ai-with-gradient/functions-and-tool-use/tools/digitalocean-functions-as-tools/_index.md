---
type: "page"
id: "digitalocean-functions-as-tools"
title: "DigitalOcean Functions as Tools"
description: "Write a serverless DigitalOcean Function and wire it as an agent tool through a Gradient function route."
weight: 2
---

## Why Use DigitalOcean Functions

DigitalOcean Functions is a serverless compute platform that runs code on demand with no server management. It is a natural fit for agent tools: you deploy a small function, it exposes an HTTPS endpoint, and the Gradient agent calls it whenever the tool is needed. Functions scale automatically, cost nothing when idle, and can be written in JavaScript (Node.js), Python, PHP, or Go.

## Step 1 — Write the Function

The following example implements a tool that looks up the current weather for a city by calling a public weather API.

**JavaScript (Node.js):**

```js
// packages/weather/lookup/index.js
async function main(args) {
  const city = args.city;
  if (!city) {
    return { body: { error: "Missing required parameter: city" }, statusCode: 400 };
  }

  // Replace with a real weather API call in production
  const mockData = {
    city,
    temperature_c: 22,
    condition: "Partly cloudy",
    humidity_pct: 58
  };

  return { body: mockData, statusCode: 200 };
}

module.exports.main = main;
```

**Python:**

```python
# packages/weather/lookup/__main__.py
def main(args):
    city = args.get("city")
    if not city:
        return {"body": {"error": "Missing required parameter: city"}, "statusCode": 400}

    # Replace with a real weather API call in production
    mock_data = {
        "city": city,
        "temperature_c": 22,
        "condition": "Partly cloudy",
        "humidity_pct": 58
    }
    return {"body": mock_data, "statusCode": 200}
```

## Step 2 — Deploy the Function

Install the `doctl` CLI and the serverless plugin, then deploy:

```bash
doctl serverless deploy . --remote-build
```

After deployment, retrieve the function's URL:

```bash
doctl serverless functions get weather/lookup --url
```

This returns a URL like `https://faas-nyc1-XXXXXXXX.doserverless.co/api/v1/web/<namespace>/weather/lookup`. See the [Functions documentation](https://docs.digitalocean.com/products/functions/) for setup details.

## Step 3 — Register the Function as a Tool

Create a function route in your Gradient agent that points to the deployed URL:

```json
{
  "name": "get_current_weather",
  "description": "Returns the current temperature, weather condition, and humidity for a given city name.",
  "endpoint_url": "https://faas-nyc1-XXXXXXXX.doserverless.co/api/v1/web/<namespace>/weather/lookup",
  "http_method": "POST",
  "input_schema": {
    "type": "object",
    "properties": {
      "city": {
        "type": "string",
        "description": "The name of the city, e.g. 'New York'."
      }
    },
    "required": ["city"]
  }
}
```

Add this route to your agent through the Control Panel under **Function Routes → Add route**, or via the API.

## Step 4 — Test the Integration

Open the playground and send: "What's the weather like in Amsterdam right now?"

The agent should:
1. Identify that `get_current_weather` is relevant.
2. Emit a tool call with `{"city": "Amsterdam"}`.
3. Receive the function's JSON response.
4. Incorporate the data into a natural-language reply.

If the tool is not called, review the function description — it is the primary signal the model uses for routing.

## Error Handling

Functions should always return a structured error body rather than an HTTP 500 with an empty body. The agent passes the response body (including error messages) back to the model, which can then respond gracefully:

```json
{ "error": "City not found", "code": "UNKNOWN_CITY" }
```

The model will typically reply: "I wasn't able to find weather data for that city. Could you check the spelling?"

Learn more about DigitalOcean Functions in the [Functions documentation](https://docs.digitalocean.com/products/functions/).
