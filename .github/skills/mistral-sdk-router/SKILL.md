---
name: mistral-sdk-router
description: "Use when you need a single entry point for any Mistral API or SDK task: routes to the correct specialized skill (agent builder, function calling, embeddings/RAG, structured outputs, document AI, or Vibe CLI) based on your goal. Do NOT use for tasks unrelated to the Mistral ecosystem or for pure code generation that has nothing to do with Mistral APIs."
argument-hint: "What you want to build or accomplish with Mistral (describe your goal, not the API surface)"
user-invocable: false
---

# Mistral SDK Agent

Meta-agent that triages any Mistral API or SDK task and delegates to the correct specialized skill. Start here when the right skill is not obvious.

## When To Use

- You have a Mistral-related task but are unsure which API surface or skill applies.
- You want a single entry point that covers the full Mistral SDK.
- You are starting a new integration and need a structured checklist before diving into specifics.
- A task spans multiple Mistral capabilities (e.g., document extraction + RAG + structured output).

**Do NOT use for:**
- Tasks unrelated to Mistral (use a general coding or research skill instead).
- When you already know the right specialized skill — invoke it directly.
- Non-Mistral LLM providers (OpenAI, Anthropic, etc.).

## Inputs To Collect First
1. Goal: what outcome you need (in plain language, not API terminology).
2. Input data: what you have (documents, text, code, function list, etc.).
3. Output needed: text answer, structured JSON, embedded vectors, generated image, etc.
4. Environment: Python SDK, REST API, or CLI (`vibe`).

## Procedure

### Step 1 — Task Triage

Use this decision table to select the correct skill:

| Your goal | Skill to use |
|---|---|
| Build a persistent assistant with tools, handoffs, or managed conversation history | [`mistral-agent-builder`](../mistral-agent-builder/SKILL.md) |
| Connect the model to your own functions, APIs, or databases | [`mistral-function-calling`](../mistral-function-calling/SKILL.md) |
| Build search or Q&A over your documents using semantic retrieval | [`mistral-embeddings-rag`](../mistral-embeddings-rag/SKILL.md) |
| Extract structured/typed data (JSON) from free-form text | [`mistral-structured-outputs`](../mistral-structured-outputs/SKILL.md) |
| Extract text, tables, or structure from PDFs or images | [`mistral-document-ai`](../mistral-document-ai/SKILL.md) |
| Delegate a coding or agentic task to Mistral Vibe CLI | [`mistral-vibe-expert`](../mistral-vibe-expert/SKILL.md) |

**Combination patterns:**

| Combined task | Primary skill → secondary skill |
|---|---|
| Extract data from a PDF, then answer questions | `mistral-document-ai` → `mistral-embeddings-rag` |
| Parse a PDF invoice into a typed object | `mistral-document-ai` → `mistral-structured-outputs` |
| Agent that searches the web and stores structured results | `mistral-agent-builder` (websearch tool) → `mistral-structured-outputs` |
| RAG over code with function-powered lookups | `mistral-embeddings-rag` (codestral-embed) → `mistral-function-calling` |

### Step 2 — Verify SDK Prerequisites

Before calling any Mistral API, confirm:

```bash
# Install the SDK
pip install mistralai

# Verify API key is set
python -c "import os; assert os.environ.get('MISTRAL_API_KEY'), 'MISTRAL_API_KEY not set'"

# Test connectivity
python -c "
from mistralai import Mistral
import os
client = Mistral(api_key=os.environ['MISTRAL_API_KEY'])
r = client.models.list()
print('Connected. Available models:', len(r.data))
"
```

SDK version check (use `>=1.0.0` for the current unified client):
```bash
pip show mistralai | grep Version
```

### Step 3 — Delegate to the Specialized Skill

Once the triage table identifies the right skill, invoke it with the following context bundle:

```text
Goal: <specific deliverable>
Input data: <what you have>
Constraints: <budget, latency, data sensitivity>
Environment: <Python version, whether running in CI or interactive>
Expected output: <format and schema if applicable>
```

If the task spans multiple skills, complete the primary skill first, then pass its output as the input to the secondary skill.

### Step 4 — Apply Cross-Cutting Concerns

Apply these regardless of which skill handles the task by following the shared policy in:

- [Shared Mistral cross-cutting guidance](../../references/mistral-cross-cutting-guidance.md)

## Completion Checks

- [ ] Correct specialized skill identified from the triage table and invoked.
- [ ] API key validated before any API call.
- [ ] Model selected matches task complexity and cost constraints.
- [ ] For combination tasks: primary skill completed first; its output used as input to secondary skill.
- [ ] SDK version confirmed as `>=1.0.0` (unified client).
- [ ] Cross-cutting guidance reviewed and applied (auth, error handling, rate limits).
- [ ] No hardcoded API keys or personal paths in any generated code.
- [ ] Error handling and retry logic in place for any production code.
- [ ] No API keys written to source code or logs.

## References

- [Shared Mistral Cross-Cutting Guidance](../../references/mistral-cross-cutting-guidance.md)
- [`mistral-agent-builder` skill](../mistral-agent-builder/SKILL.md)
- [`mistral-function-calling` skill](../mistral-function-calling/SKILL.md)
- [`mistral-embeddings-rag` skill](../mistral-embeddings-rag/SKILL.md)
- [`mistral-structured-outputs` skill](../mistral-structured-outputs/SKILL.md)
- [`mistral-document-ai` skill](../mistral-document-ai/SKILL.md)
- [`mistral-vibe-expert` skill](../mistral-vibe-expert/SKILL.md)
