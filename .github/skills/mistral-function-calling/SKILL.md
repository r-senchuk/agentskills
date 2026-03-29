---
name: mistral-function-calling
description: "Use when you need to wire Mistral models to external functions or APIs: define tool schemas, run the agentic tool-call loop, handle parallel and successive calls, and safely execute tool results back into the model. Do not use for Mistral Agents with built-in tools or for chat flows with no external function calls."
argument-hint: "List of functions to expose (name, description, parameters), model to use, and whether parallel calling is needed"
user-invocable: false
---

# Mistral Function Calling

Complete workflow for integrating Mistral models with external functions. Covers JSON schema definition, the five-step agentic loop, parallel and successive tool calls, and result injection patterns.

## When To Use
- You need the model to call a real function (database, API, calculation) based on user intent.
- You are building an agentic loop where the model decides which tool to invoke.
- You need parallel tool calls for efficiency (model requests multiple tools in one turn).
- You want to add custom tools to a Mistral Agent (complement to `mistral-agent-builder`).

Do NOT use for:
- Pure chat completions with no external function calls — the model handles those without tooling.
- Mistral Agents using built-in tools (web search, code interpreter, document library) — use `mistral-agent-builder` instead.
- Retrieval-augmented generation pipelines — use `mistral-embeddings-rag` instead.

## Inputs To Collect First
1. Functions to expose: name, description, parameter names, types, and which are required.
2. Model: must support function calling. Compatible models (non-exhaustive):
   - General: `mistral-large-latest`, `mistral-medium-latest`, `mistral-small-latest`
   - Code: `devstral-latest`, `codestral-latest`
   - Specialized: `ministral-8b-latest`, `ministral-14b-latest`
   - Reasoning: `magistral-medium-latest`, `magistral-small-latest`
3. System prompt: context and instructions on when to call which tool.
4. Loop strategy: single call, successive (serial), or parallel.

## Procedure

### Step 1 — Define Function Schemas

Every function needs a JSON schema object:

```python
tools = [
    {
        "type": "function",
        "function": {
            "name": "get_order_status",
            "description": "Returns the current status of an order given its ID.",
            "parameters": {
                "type": "object",
                "properties": {
                    "order_id": {
                        "type": "string",
                        "description": "The unique order identifier."
                    }
                },
                "required": ["order_id"]
            }
        }
    },
    {
        "type": "function",
        "function": {
            "name": "cancel_order",
            "description": "Cancels an order. Only call if the user explicitly requests cancellation.",
            "parameters": {
                "type": "object",
                "properties": {
                    "order_id": {"type": "string"},
                    "reason": {"type": "string", "description": "Reason for cancellation."}
                },
                "required": ["order_id"]
            }
        }
    }
]
```

Schema best practices:
- `description` fields drive model accuracy — be specific about when NOT to call.
- Mark only truly required parameters as `required`.
- Use `enum` for parameters with a fixed set of valid values.

### Step 2 — Build the Tool Registry

Map function names to callables so you can dispatch dynamically:

```python
def get_order_status(order_id: str) -> dict:
    # Replace with real lookup
    return {"order_id": order_id, "status": "shipped", "eta": "2025-04-01"}

def cancel_order(order_id: str, reason: str = "") -> dict:
    return {"order_id": order_id, "cancelled": True}

TOOL_REGISTRY = {
    "get_order_status": get_order_status,
    "cancel_order": cancel_order,
}
```

### Step 3 — Send the Initial Request

```python
import json
import os
from mistralai import Mistral

client = Mistral(api_key=os.environ["MISTRAL_API_KEY"])

messages = [
    {"role": "system", "content": "You help customers manage orders. Use tools to answer factual questions."},
    {"role": "user", "content": "What's the status of order #1234?"},
]

response = client.chat.complete(
    model="mistral-large-latest",
    messages=messages,
    tools=tools,
    tool_choice="auto",  # "auto" | "any" | "none" | specific tool name
)
```

`tool_choice` options:
- `"auto"` — model decides whether to call a tool (default, recommended).
- `"any"` — model must call at least one tool.
- `"none"` — disable tool calling for this request.

### Step 4 — Detect and Execute Tool Calls

The agentic loop handles both single and parallel tool calls:

```python
def run_tool_loop(client, model, messages, tools, max_rounds=10):
    for _ in range(max_rounds):
        response = client.chat.complete(
            model=model,
            messages=messages,
            tools=tools,
            tool_choice="auto",
        )
        msg = response.choices[0].message

        # No tool call — final answer reached
        if not msg.tool_calls:
            return msg.content

        # Append assistant message with tool call(s)
        messages.append(msg)

        # Execute each tool call (handles parallel calls)
        for tc in msg.tool_calls:
            fn_name = tc.function.name
            fn_args = json.loads(tc.function.arguments)

            if fn_name not in TOOL_REGISTRY:
                result = {"error": f"Unknown function: {fn_name}"}
            else:
                try:
                    result = TOOL_REGISTRY[fn_name](**fn_args)
                except Exception as e:
                    result = {"error": str(e)}

            # Inject each result as a tool message
            messages.append({
                "role": "tool",
                "tool_call_id": tc.id,
                "name": fn_name,
                "content": json.dumps(result),
            })

    return "Max tool rounds reached without a final answer."
```

### Step 5 — Inject Results and Get Final Answer

```python
answer = run_tool_loop(
    client=client,
    model="mistral-large-latest",
    messages=messages,
    tools=tools,
)
print(answer)
```

Message sequence for parallel calls:

```
system → user → assistant [fc.1, fc.2] → tool r.1 → tool r.2 → assistant (final)
```

## Completion Checks
- [ ] All tool schemas have clear `description` fields — not just name.
- [ ] `TOOL_REGISTRY` maps every defined tool name to a callable.
- [ ] Loop has a `max_rounds` cap — prevents infinite tool chains.
- [ ] Each tool call `id` is preserved in the matching `tool` message.
- [ ] Error paths in tool execution return structured JSON, not raw exceptions.
- [ ] Tested with: single call, parallel calls, and a prompt that should NOT trigger any tool.

## References
- [Tool schema patterns](./references/tool-schema-patterns.md)
- [Shared Mistral cross-cutting guidance](../../references/mistral-cross-cutting-guidance.md)
