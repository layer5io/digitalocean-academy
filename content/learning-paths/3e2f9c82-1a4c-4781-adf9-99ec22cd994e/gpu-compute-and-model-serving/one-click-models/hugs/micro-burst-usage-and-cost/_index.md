---
type: "page"
id: "micro-burst-usage-and-cost"
title: "Micro-Burst Usage & Cost"
description: "Manage cost for bursty GPU workloads by understanding when to start, stop, or destroy a 1-Click Model Droplet."
weight: 3
---

## What Is Micro-Burst Usage?

Many real-world AI workloads are not steady-state. A batch enrichment job runs for two hours each night. A demo runs during a conference for three days. A developer iterates on prompts for 90 minutes then stops for the day. These are bursty workloads: short, intense periods of GPU demand separated by extended idle periods.

1-Click Models are well-suited to this pattern because GPU Droplets bill by the hour with no minimum commitment. You pay only for the time the hardware is running.

## Starting and Stopping vs Destroying

Understanding the billing difference is critical:

| Action | Billing | Data preserved |
|--------|---------|---------------|
| Droplet running | Charged per GPU-hour | Yes |
| Droplet powered off (not destroyed) | Still charged — hardware remains reserved | Yes |
| Droplet destroyed | Billing stops immediately | Boot disk deleted |

**Key insight**: powering off a Droplet does not stop billing. You must destroy the Droplet to stop all charges. Save any outputs (model responses, logs, artifacts) before destroying.

## Patterns for Cost Control

**Destroy after each job.** For nightly batch jobs, script the workflow end-to-end: create the Droplet, run the workload, write results to Spaces or a database, destroy the Droplet.

```bash
# Create
DROPLET_ID=$(doctl compute droplet create llm-burst \
  --region nyc3 --size gpu-h100x1-80gb \
  --image gpu-h100x1-base --ssh-keys <key> \
  --format ID --no-header --wait)

# ... run your workload via SSH or a user-data script ...

# Destroy when done
doctl compute droplet delete "$DROPLET_ID" --force
```

**Use Droplet snapshots for fast restart.** If setup takes 10 minutes (installing dependencies, loading the model), snapshot the configured Droplet. On the next burst, restore from the snapshot in seconds rather than re-configuring from scratch.

```bash
doctl compute droplet-action snapshot "$DROPLET_ID" \
  --snapshot-name llm-burst-ready
```

**Estimate burst cost upfront.** Multiply expected hours by the GPU hourly rate. A 2-hour nightly job on a single H100 at approximately $4.50/GPU-hour costs about $9 per night, or roughly $275/month—far less than a reserved instance running 24/7.

## When Continuous Availability Matters

If your application requires the model to respond at any time (for example, a customer-facing chatbot), continuous uptime may justify a dedicated Droplet running around the clock. In that case, compare the accumulated on-demand cost against Reserved Droplet pricing available in the DigitalOcean Control Panel.

For workloads that must be always-on but have variable load, consider the production patterns covered in the next lesson, including load balancing across multiple Droplet instances.

## Avoiding Accidental Cost

Set up a DigitalOcean billing alert so you receive an email or Slack notification if spend exceeds a threshold you define. This catches Droplets left running by accident.

To see all running GPU Droplets at any time:

```bash
doctl compute droplet list --format Name,Status,PublicIPv4 | grep -i gpu
```

For full pricing and Reserved Droplet options, see the [GPU Droplets documentation](https://docs.digitalocean.com/products/gpu-droplets/).
