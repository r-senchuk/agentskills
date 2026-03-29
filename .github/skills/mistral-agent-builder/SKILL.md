---
name: mistral-agent-builder
description: "Use when you need to create, configure, and orchestrate Mistral Agents via the Agents & Conversations API: persistent state, built-in tools (websearch, code interpreter, image generation, document library), handoffs between agents, MCP integration, and guardrails. Do not use for stateless one-off chat completions, fine-tuning jobs, or embeddings/RAG pipelines."
argument-hint: "Agent purpose, required tools (websearch/code_interpreter/image_generation/document_library/function), handoff topology, and model preference"
user-invocable: false
---

# Mistral Agent Builder

End-to-end workflow for creating and operating Mistral Agents using the Agents & Conversations API. Covers agent design, tool wiring, multi-agent handoff topology, and safe conversation management.

## When To Use
- You need a persistent, stateful assistant that remembers prior conversation turns.
- You want built-in tools (websearch, code interpreter, image generation, document library) without managing tool execution yourself.
- You are designing a multi-agent workflow with handoffs between specialized agents.
- You need a reusable agent configuration (model + instructions + tools) deployed once and called many times.
- You want to use MCP servers as tool sources inside an agent.

Do NOT use for:
- Stateless one-off chat completions (use `client.chat.complete()` directly).
- Fine-tuning jobs (use the Fine-tuning API).
- Embeddings or RAG pipelines (use `mistral-embeddings-rag` skill).
- Function-calling-only workflows with no persistent state (use `mistral-function-calling` skill).

## Inputs To Collect First
1. Agent purpose: what task or domain this agent covers.
2. Model: which Mistral model to use (e.g. `mistral-large-latest`, `devstral-latest`, `mistral-small-latest`).
3. Tools required: list of built-in tools and/or function schemas needed.
4. Handoff topology: other agent IDs this agent can delegate to (if any).
5. Guardrail requirements: topics or behaviors to block.
6. Storage preference: server-side persistence (`store=True`, default) or ephemeral (`store=False`).

## Procedure

### Step 1 — Design Agent Configuration

Choose built-in tools from this set:

| Tool type | Use case |
|---|---|
| `web_search` | Live web lookups |
| `web_search_premium` | Higher-quality web search |
| `code_interpreter` | Execute Python in a sandbox |
| `image_generation` | Generate images |
| `document_library` | RAG over uploaded documents |

For custom logic, add `function` tools with a JSON schema (see `mistral-function-calling` skill).

For MCP-based tools, configure via `mcp` tool type pointing at a registered MCP server.

### Step 2 — Create the Agent

```python
import os
from mistralai import Mistral

client = Mistral(api_key=os.environ["MISTRAL_API_KEY"])

agent = client.beta.agents.create(
    model="mistral-large-latest",
    name="research-agent",
    description="Answers questions using live web search.",
    instructions="You are a research assistant. Always cite your sources.",
    tools=[{"type": "web_search"}],
    completion_args={"temperature": 0.3, "max_tokens": 2048},
)
agent_id = agent.id  # save this — reuse without recreating
```

Key parameters:
- `instructions`: system prompt — be specific about scope, tone, and limitations.
- `completion_args`: any chat completion sampling parameters.
- `guardrails`: list of guardrail configs to apply to all conversations.

### Step 3 — Start a Conversation

```python
conversation = client.beta.conversations.start(
    agent_id=agent_id,
    inputs="What were the top AI research papers in Q1 2025?",
)
conversation_id = conversation.id
print(conversation.outputs[-1].content)
```

To start without a pre-created agent, use `model` instead of `agent_id`:

```python
conversation = client.beta.conversations.start(
    model="mistral-large-latest",
    inputs="Hello!",
)
```

### Step 4 — Continue a Conversation

```python
response = client.beta.conversations.append(
    conversation_id=conversation_id,
    inputs="Summarize only the ones related to multimodal models.",
)
print(response.outputs[-1].content)
```

To opt out of server-side storage:

```python
conversation = client.beta.conversations.start(
    agent_id=agent_id,
    inputs="...",
    store=False,
)
```

### Step 5 — Wire Handoffs for Multi-Agent Workflows

Design: each agent handles one domain; pass control via `handoffs`.

```python
# Create specialist agents first
search_agent = client.beta.agents.create(
    model="mistral-small-latest",
    name="search-specialist",
    tools=[{"type": "web_search"}],
    instructions="You retrieve facts from the web.",
)

calc_agent = client.beta.agents.create(
    model="mistral-small-latest",
    name="calculator",
    tools=[{"type": "code_interpreter"}],
    instructions="You perform numerical calculations.",
)

# Create orchestrator with handoffs
orchestrator = client.beta.agents.create(
    model="mistral-large-latest",
    name="orchestrator",
    instructions="Route tasks to the right specialist.",
    handoffs=[search_agent.id, calc_agent.id],
)
```

Handoff execution modes:
- `server` (default): handoff runs automatically on Mistral's cloud.
- `client`: you receive a handoff event and control execution yourself.

```python
conversation = client.beta.conversations.start(
    agent_id=orchestrator.id,
    inputs="What is the GDP of France and how much is 5% of it?",
    handoff_execution="server",
)
```

### Step 6 — Validate the Agent

Completion checks before relying on the agent in production:

- [ ] Agent ID is persisted — do not recreate the same agent on every call.
- [ ] Tool list is minimal — only tools actually needed for the agent's task.
- [ ] `instructions` scopes the agent tightly — avoids scope creep across turns.
- [ ] Handoff topology is acyclic unless you intend a loop.
- [ ] Tested with at least one happy-path and one edge-case conversation.
- [ ] `store=False` used for sensitive or ephemeral workloads.

## Completion Checks
- [ ] Agent created once and ID stored for reuse.
- [ ] Tools match the agent's stated purpose (least-privilege).
- [ ] Conversation state is handled server-side or explicitly managed.
- [ ] Multi-agent handoffs tested end-to-end with a real prompt.
- [ ] Guardrails applied for production agents handling user input.

## References
- [Agent topology patterns](./references/agent-topologies.md)
- [Built-in tool reference](./references/builtin-tools.md)
- [Shared Mistral cross-cutting guidance](../../references/mistral-cross-cutting-guidance.md)
