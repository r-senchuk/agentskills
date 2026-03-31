---
name: harness-engineering
description: "Use when designing the operational wrapper around an AI agent or LLM workflow — guardrails, feedback loops, state persistence, observability, orchestration, reproducibility, and error recovery. Covers any agent framework (LangChain, CrewAI, AutoGen, Mistral Agents, OpenAI Assistants, custom). Do not use for prompt engineering, RAG pipeline design, model fine-tuning, or single-shot chat completions with no tooling."
argument-hint: "Agent framework in use, current architecture (single/multi-agent), deployment target (local/cloud), and which harness components are missing or weak"
user-invocable: true
---

# Harness Engineering

Step-by-step procedure for designing and implementing the operational harness that wraps an AI agent system — the constraints, feedback loops, monitoring, safety guardrails, state management, and verification that make agents reliable in production. Platform-agnostic: works with any agent framework.

## When To Use

- You are taking an agent prototype to production and need operational reliability.
- You have an agent that works in demos but fails unpredictably in real use.
- You need to add guardrails, observability, or error recovery to an existing agent system.
- You are designing a multi-agent system and need orchestration, handoff, and state patterns.
- You are auditing an agent system for production readiness gaps.
- A stakeholder asks "how do we make sure the agent doesn't go off the rails?"

Do NOT use for:
- Prompt engineering or instruction tuning — those are upstream of the harness.
- RAG pipeline design (chunking, embedding, retrieval) — use a RAG-specific skill.
- Model fine-tuning or training workflows.
- Single-shot chat completions with no tools, state, or autonomy.
- Choosing which LLM provider or model to use.

## Inputs To Collect First

1. **Agent framework**: What SDK/framework is the agent built with? (LangChain/LangGraph, CrewAI, AutoGen, Mistral Agents API, OpenAI Assistants, custom Python, etc.)
2. **Architecture**: Single agent or multi-agent? If multi-agent, what is the current topology? (sequential pipeline, router/dispatcher, hierarchical supervisor, collaborative)
3. **Tool inventory**: What tools/functions can the agent call? Which have side effects (write, delete, send)?
4. **Deployment target**: Local development, cloud API, CI/CD pipeline, or end-user-facing product?
5. **Current gaps**: Which harness components are missing or weak? (guardrails, feedback loops, state, observability, orchestration, reproducibility, error recovery)
6. **Risk tolerance**: What happens if the agent makes a mistake? (annoying vs. costly vs. dangerous)

## Procedure

### Step 1 — Audit Current Agent Architecture

Map the agent system before adding harness components. Produce a one-page architecture doc:

**1a. Identify all agents and their roles:**

```python
# Document each agent's scope, tools, and autonomy level
AGENT_INVENTORY = {
    "research-agent": {
        "role": "Retrieve and summarize information",
        "tools": ["web_search", "document_lookup"],
        "side_effects": False,  # read-only
        "autonomy": "full",     # no human approval needed
    },
    "action-agent": {
        "role": "Execute changes in external systems",
        "tools": ["create_ticket", "send_email", "update_database"],
        "side_effects": True,   # writes to external systems
        "autonomy": "gated",    # requires approval for destructive ops
    },
}
```

**1b. Classify each tool by risk tier:**

| Tier | Description | Examples | Required harness |
|------|-------------|----------|-----------------|
| **Read** | No side effects | search, lookup, calculate | Logging only |
| **Write** | Creates or modifies data | create_file, update_record | Approval gate + audit log |
| **Delete** | Destroys data | delete_record, drop_table | Human approval + undo capability |
| **External** | Sends data outside system | send_email, post_to_api | Content review + rate limit |

**1c. Map the data flow:** trace how user input → agent reasoning → tool calls → output flows through the system. Identify every point where the agent could fail or cause harm.

### Step 2 — Design Guardrails & Safety Layer

Implement defense-in-depth: input guards → tool guards → output guards.

**2a. Input guardrails — validate before the agent sees it:**

```python
import re
from dataclasses import dataclass

@dataclass
class GuardrailResult:
    allowed: bool
    reason: str = ""

def check_input(user_input: str, config: dict) -> GuardrailResult:
    """Pre-model input validation."""
    # Length bounds
    if len(user_input) > config.get("max_input_chars", 10_000):
        return GuardrailResult(False, "Input exceeds maximum length")

    # Injection pattern detection
    injection_patterns = [
        r"ignore\s+(all\s+)?(previous|prior)\s+instructions",
        r"you\s+are\s+now\s+(a|an)\s+",
        r"(bypass|disable|override)\s+(safety|content)\s+(filter|guard)",
    ]
    for pattern in injection_patterns:
        if re.search(pattern, user_input, re.IGNORECASE):
            return GuardrailResult(False, f"Blocked: injection pattern detected")

    return GuardrailResult(True)
```

**2b. Tool-level guardrails — enforce least-privilege access:**

```python
from typing import Callable

class ToolGuard:
    """Wrap any tool with permission checks and audit logging."""

    def __init__(self, tool_fn: Callable, tier: str, allowed_args: dict | None = None):
        self.tool_fn = tool_fn
        self.tier = tier  # "read", "write", "delete", "external"
        self.allowed_args = allowed_args  # optional arg constraints

    def __call__(self, **kwargs) -> dict:
        # Enforce argument constraints
        if self.allowed_args:
            for key, validator in self.allowed_args.items():
                if key in kwargs and not validator(kwargs[key]):
                    return {"error": f"Argument '{key}' failed validation"}

        # Gate destructive operations
        if self.tier in ("delete", "external"):
            raise ApprovalRequired(
                tool=self.tool_fn.__name__,
                args=kwargs,
                reason=f"Tier '{self.tier}' requires human approval",
            )

        return self.tool_fn(**kwargs)
```

**2c. Output guardrails — validate before returning to user:**

```python
def check_output(agent_output: str, config: dict) -> GuardrailResult:
    """Post-model output validation — PII detection, length bounds."""
    pii_patterns = [r"\b\d{3}-\d{2}-\d{4}\b", r"\b\d{16}\b",  # SSN, credit card
                    r"\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b"]  # email
    for pattern in pii_patterns:
        if re.search(pattern, agent_output):
            return GuardrailResult(False, "Output contains potential PII")
    return GuardrailResult(True)
```

Load `./references/patterns-catalog.md` for the full guardrail pattern catalog including scope boundaries, allowlists, and content filtering.

### Step 3 — Implement Feedback & Verification Loops

Every agent output should pass through at least one verification layer before being acted upon.

**3a. Schema validation for structured outputs:**

```python
from pydantic import BaseModel, ValidationError

class AgentDecision(BaseModel):
    action: str          # "search", "create", "escalate"
    target: str          # what to act on
    confidence: float    # 0.0–1.0
    reasoning: str       # why this action

def validate_decision(raw_output: str) -> AgentDecision | None:
    """Parse and validate agent output against expected schema."""
    try:
        return AgentDecision.model_validate_json(raw_output)
    except ValidationError as e:
        log.warning(f"Agent output failed validation: {e}")
        return None
```

**3b. Assertion-based verification on tool results:**

```python
def verify_tool_result(tool_name: str, args: dict, result: dict) -> bool:
    """Post-execution assertions — catch silent failures."""
    checks = {
        "create_record": lambda r: "id" in r and r.get("status") == "created",
        "search":        lambda r: isinstance(r.get("results"), list),
        "calculate":     lambda r: isinstance(r.get("value"), (int, float)),
    }
    checker = checks.get(tool_name)
    if checker and not checker(result):
        log.error(f"Tool '{tool_name}' result failed assertion: {result}")
        return False
    return True
```

**3c. LLM-as-judge for critical outputs:**

```python
def llm_judge(original_input: str, agent_output: str, client) -> bool:
    """Use a second model call to verify the first model's output."""
    verdict = client.chat.complete(
        model="gpt-4o-mini",  # cheap, fast judge
        messages=[
            {"role": "system", "content": (
                "You are a QA reviewer. Check if the response correctly "
                "addresses the user's request. Reply ONLY 'PASS' or 'FAIL: <reason>'."
            )},
            {"role": "user", "content": (
                f"User request: {original_input}\n\n"
                f"Agent response: {agent_output}"
            )},
        ],
        temperature=0,
    )
    return verdict.choices[0].message.content.strip().startswith("PASS")
```

**Decision table — which verification to apply:**

| Output type | Verification method | When to use |
|-------------|-------------------|-------------|
| Structured data (JSON) | Schema validation | Always — cheapest check |
| Tool call results | Assertion checks | Always — catches silent failures |
| User-facing text | LLM-as-judge | High-stakes outputs only (adds latency + cost) |
| Code generation | Automated test execution | When generated code must run |

### Step 4 — Add State Management & Persistence

**4a. Checkpoint at each agent step:**

```python
import json
from datetime import datetime, UTC
from pathlib import Path

class CheckpointStore:
    """Persist agent state for recovery and audit."""

    def __init__(self, storage_dir: str = "checkpoints"):
        self.storage_dir = Path(storage_dir)
        self.storage_dir.mkdir(parents=True, exist_ok=True)

    def save(self, run_id: str, step: int, state: dict):
        path = self.storage_dir / f"{run_id}_step_{step:04d}.json"
        payload = {
            "run_id": run_id,
            "step": step,
            "timestamp": datetime.now(UTC).isoformat(),
            "state": state,
        }
        path.write_text(json.dumps(payload, default=str))

    def load_latest(self, run_id: str) -> dict | None:
        files = sorted(self.storage_dir.glob(f"{run_id}_step_*.json"))
        if not files:
            return None
        return json.loads(files[-1].read_text())
```

**4b. Integrate checkpointing into the agent loop:**

```python
def run_agent_with_checkpoints(
    agent, input_text: str, run_id: str, checkpoint_store: CheckpointStore
):
    """Agent loop with automatic state persistence."""
    # Try to resume from last checkpoint
    last = checkpoint_store.load_latest(run_id)
    if last:
        agent.restore_state(last["state"])
        start_step = last["step"] + 1
    else:
        start_step = 0

    for step in range(start_step, agent.max_steps):
        result = agent.execute_step(input_text)
        checkpoint_store.save(run_id, step, agent.get_state())

        if result.is_final:
            return result

    raise MaxStepsExceeded(run_id, agent.max_steps)
```

**State scope decision:**

| State type | Storage | Lifetime | Example |
|-----------|---------|----------|---------|
| Turn-level | In-memory | Single request | Current tool call args |
| Session-level | File / SQLite | User session | Conversation history |
| Persistent | Database / S3 | Cross-session | User preferences, learned facts |

### Step 5 — Wire Observability & Cost Controls

**5a. Structured logging for every agent action:**

```python
import logging
import time

logger = logging.getLogger("agent.harness")

class AgentTracer:
    """Trace agent execution with structured logs."""

    def __init__(self, run_id: str):
        self.run_id = run_id
        self.events: list[dict] = []

    def trace_tool_call(self, tool_name: str, args: dict, result: dict, duration_ms: float):
        event = {
            "run_id": self.run_id,
            "type": "tool_call",
            "tool": tool_name,
            "args": args,
            "result_keys": list(result.keys()),
            "duration_ms": round(duration_ms, 2),
            "timestamp": datetime.now(UTC).isoformat(),
        }
        self.events.append(event)
        logger.info("tool_call", extra=event)

    def trace_llm_call(self, model: str, input_tokens: int, output_tokens: int, duration_ms: float):
        event = {
            "run_id": self.run_id,
            "type": "llm_call",
            "model": model,
            "input_tokens": input_tokens,
            "output_tokens": output_tokens,
            "duration_ms": round(duration_ms, 2),
        }
        self.events.append(event)
        logger.info("llm_call", extra=event)
```

**5b. Token budget enforcement:**

```python
class TokenBudget:
    """Enforce per-request and per-session token limits."""

    def __init__(self, max_tokens: int = 50_000, max_cost_usd: float = 1.0):
        self.max_tokens = max_tokens
        self.max_cost_usd = max_cost_usd
        self.total_tokens = 0
        self.total_cost_usd = 0.0
        # Cost per 1M tokens — update as pricing changes
        self.pricing = {"gpt-4o": (2.50, 10.0), "gpt-4o-mini": (0.15, 0.60)}

    def record(self, model: str, input_tok: int, output_tok: int):
        self.total_tokens += input_tok + output_tok
        inp_price, out_price = self.pricing.get(model, (5.0, 15.0))
        self.total_cost_usd += (input_tok * inp_price + output_tok * out_price) / 1_000_000

    def check(self):
        if self.total_tokens > self.max_tokens:
            raise BudgetExceeded(f"Token limit: {self.total_tokens}/{self.max_tokens}")
        if self.total_cost_usd > self.max_cost_usd:
            raise BudgetExceeded(f"Cost: ${self.total_cost_usd:.4f}/${self.max_cost_usd}")
```

### Step 6 — Configure Orchestration & Error Recovery

**6a. Retry with exponential backoff:**

```python
import time
import random

def retry_with_backoff(
    fn, *args, max_retries: int = 3, base_delay: float = 1.0, **kwargs
):
    """Retry with jittered exponential backoff."""
    for attempt in range(max_retries + 1):
        try:
            return fn(*args, **kwargs)
        except RateLimitError:
            if attempt == max_retries:
                raise
            delay = base_delay * (2 ** attempt) + random.uniform(0, 1)
            time.sleep(delay)
        except ServerError as e:
            if attempt == max_retries:
                raise
            if e.status_code >= 500:
                time.sleep(base_delay * (2 ** attempt))
            else:
                raise  # Don't retry client errors
```

**6b. Fallback chain — degrade gracefully across models:**

```python
def call_with_fallback(messages: list, tools: list, model_chain: list[str], client):
    """Try models in order; fall back on failure."""
    for model in model_chain:
        try:
            return client.chat.complete(model=model, messages=messages, tools=tools)
        except (ServerError, TimeoutError) as e:
            logger.warning(f"Model {model} failed: {e}, trying next")
            continue
    raise AllModelsFailed(f"All models in chain failed: {model_chain}")

# Usage: try expensive model first, degrade to cheaper
response = call_with_fallback(
    messages=messages,
    tools=tools,
    model_chain=["gpt-4o", "gpt-4o-mini", "gpt-3.5-turbo"],
    client=client,
)
```

**6c. Circuit breaker for tool calls:**

```python
class CircuitBreaker:
    """Stop calling a failing tool after N consecutive failures."""

    def __init__(self, failure_threshold: int = 3, reset_timeout: float = 60.0):
        self.failure_threshold = failure_threshold
        self.reset_timeout = reset_timeout
        self.failures: dict[str, int] = {}
        self.last_failure_time: dict[str, float] = {}

    def call(self, tool_name: str, tool_fn, **kwargs):
        # Check if circuit is open
        if self.failures.get(tool_name, 0) >= self.failure_threshold:
            elapsed = time.time() - self.last_failure_time.get(tool_name, 0)
            if elapsed < self.reset_timeout:
                return {"error": f"Circuit open for '{tool_name}' — retrying in {self.reset_timeout - elapsed:.0f}s"}
            self.failures[tool_name] = 0  # Reset after timeout

        try:
            result = tool_fn(**kwargs)
            self.failures[tool_name] = 0  # Reset on success
            return result
        except Exception as e:
            self.failures[tool_name] = self.failures.get(tool_name, 0) + 1
            self.last_failure_time[tool_name] = time.time()
            return {"error": str(e)}
```

**6d. Human-in-the-loop escalation:**

```python
class EscalationPolicy:
    """Decide when to pause and involve a human."""

    def __init__(self, confidence_threshold: float = 0.7, destructive_tools: set[str] = None):
        self.confidence_threshold = confidence_threshold
        self.destructive_tools = destructive_tools or set()

    def should_escalate(self, decision: AgentDecision) -> bool:
        return (decision.confidence < self.confidence_threshold
                or decision.action in self.destructive_tools)

    def request_approval(self, decision: AgentDecision) -> bool:
        print(f"\n⚠️  APPROVAL REQUIRED — {decision.action} on {decision.target}"
              f" (confidence: {decision.confidence:.0%})")
        return input("Approve? [y/N]: ").strip().lower() == "y"
```

### Step 7 — Validate with Pre-Production Checklist

Run the full harness checklist before deploying:

1. Load `./references/harness-checklist.md` and verify every item.
2. For each harness component, confirm it is implemented and tested:
   - Guardrails: input, tool, and output guards are active
   - Feedback loops: at least one verification layer per output type
   - State: checkpointing is enabled for multi-step workflows
   - Observability: structured logging and cost tracking are wired
   - Orchestration: retry, fallback, and circuit breaker are configured
   - Reproducibility: deterministic settings documented, I/O logged
   - Error recovery: escalation policy defined, fallback chain tested
3. Run a dry-run with a representative prompt and verify the full trace.

Load `./references/patterns-catalog.md` for the complete pattern catalog with additional code examples and decision matrices.

## Completion Checks

- [ ] Agent inventory documented: each agent's role, tools, side effects, and autonomy level
- [ ] Every tool classified by risk tier (read/write/delete/external)
- [ ] Input guardrails implemented: length bounds, injection detection
- [ ] Tool guardrails implemented: least-privilege access, argument validation, approval gates for destructive operations
- [ ] Output guardrails implemented: PII detection, schema validation
- [ ] At least one feedback/verification loop active per output type (schema, assertion, or LLM-as-judge)
- [ ] State checkpointing enabled for multi-step agent workflows
- [ ] Structured logging captures every LLM call and tool call with run_id, tokens, duration
- [ ] Token budget and/or cost limit enforced per request
- [ ] Retry with backoff configured for all LLM API calls
- [ ] Fallback chain defined (at least one backup model)
- [ ] Circuit breaker active on tools with external dependencies
- [ ] Human escalation policy defined with clear confidence thresholds
- [ ] Pre-production checklist (`./references/harness-checklist.md`) fully passed
- [ ] No hardcoded API keys, personal paths, or user-specific values in harness code

## References

- [Pre-Production Harness Checklist](./references/harness-checklist.md)
- [Reusable Patterns Catalog](./references/patterns-catalog.md)
