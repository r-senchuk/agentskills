# Reusable Harness Patterns Catalog

A catalog of copy-paste-ready patterns for building production agent harnesses. Each pattern includes: problem statement, solution, Python implementation, and integration notes.

---

## Pattern 1: Tool Permission Registry

**Problem:** Agents call tools without constraint — any tool in the registry is callable with any arguments.

**Solution:** Wrap every tool in a permission layer that enforces allowlists, argument constraints, and tier-based approval gates.

```python
from typing import Callable, Any
from dataclasses import dataclass, field

@dataclass
class ToolPermission:
    """Defines constraints for a single tool."""
    name: str
    tier: str                           # "read", "write", "delete", "external"
    requires_approval: bool = False
    max_calls_per_session: int = 100
    allowed_arg_values: dict = field(default_factory=dict)  # {"arg_name": [valid_values]}

class ToolRegistry:
    """Registry with permission enforcement."""

    def __init__(self):
        self._tools: dict[str, Callable] = {}
        self._permissions: dict[str, ToolPermission] = {}
        self._call_counts: dict[str, int] = {}

    def register(self, fn: Callable, permission: ToolPermission):
        self._tools[permission.name] = fn
        self._permissions[permission.name] = permission
        self._call_counts[permission.name] = 0

    def call(self, tool_name: str, **kwargs) -> dict:
        if tool_name not in self._tools:
            return {"error": f"Tool '{tool_name}' not registered"}

        perm = self._permissions[tool_name]

        # Check call frequency
        if self._call_counts[tool_name] >= perm.max_calls_per_session:
            return {"error": f"Tool '{tool_name}' exceeded {perm.max_calls_per_session} calls"}

        # Check argument constraints
        for arg_name, valid_values in perm.allowed_arg_values.items():
            if arg_name in kwargs and kwargs[arg_name] not in valid_values:
                return {"error": f"Invalid value for '{arg_name}': {kwargs[arg_name]}"}

        # Gate destructive operations
        if perm.requires_approval:
            if not self._request_approval(tool_name, kwargs):
                return {"error": "Human denied approval"}

        # Execute
        try:
            result = self._tools[tool_name](**kwargs)
            self._call_counts[tool_name] += 1
            return result
        except Exception as e:
            return {"error": f"Tool execution failed: {str(e)}"}

    def _request_approval(self, tool_name: str, args: dict) -> bool:
        print(f"\n⚠️  Tool '{tool_name}' requires approval. Args: {args}")
        return input("Approve? [y/N]: ").strip().lower() == "y"

# Registration example
registry = ToolRegistry()

registry.register(
    fn=search_web,
    permission=ToolPermission(name="search_web", tier="read"),
)
registry.register(
    fn=delete_record,
    permission=ToolPermission(
        name="delete_record",
        tier="delete",
        requires_approval=True,
        max_calls_per_session=5,
    ),
)
```

---

## Pattern 2: Agentic Loop with Full Harness

**Problem:** The basic tool loop has no guardrails, no budget tracking, no checkpointing, and no circuit breaking.

**Solution:** Wrap the loop with all harness components integrated.

```python
import json
import time
from uuid import uuid4

def harnessed_agent_loop(
    client,
    model: str,
    messages: list,
    tools: list,
    tool_registry: ToolRegistry,
    budget: "TokenBudget",
    tracer: "AgentTracer",
    checkpoint_store: "CheckpointStore",
    circuit_breaker: "CircuitBreaker",
    escalation_policy: "EscalationPolicy",
    max_rounds: int = 10,
) -> str:
    """Agent loop with all harness components active."""
    run_id = str(uuid4())

    for step in range(max_rounds):
        # --- LLM call with retry ---
        start = time.time()
        response = retry_with_backoff(
            client.chat.complete,
            model=model,
            messages=messages,
            tools=tools,
            tool_choice="auto",
        )
        duration_ms = (time.time() - start) * 1000

        msg = response.choices[0].message
        usage = response.usage

        # --- Track tokens and cost ---
        budget.record(model, usage.prompt_tokens, usage.completion_tokens)
        budget.check()  # raises BudgetExceeded if over limit

        tracer.trace_llm_call(model, usage.prompt_tokens, usage.completion_tokens, duration_ms)

        # --- No tool calls: final answer ---
        if not msg.tool_calls:
            # Output guardrail
            output_check = check_output(msg.content, {"max_length": 10_000})
            if not output_check.allowed:
                tracer.trace_event("output_blocked", {"reason": output_check.reason})
                return f"[Output blocked: {output_check.reason}]"
            return msg.content

        messages.append(msg)

        # --- Execute each tool call ---
        for tc in msg.tool_calls:
            fn_name = tc.function.name
            fn_args = json.loads(tc.function.arguments)

            # Circuit breaker check
            start = time.time()
            result = circuit_breaker.call(fn_name, tool_registry.call, tool_name=fn_name, **fn_args)
            tool_duration = (time.time() - start) * 1000

            # Verify tool result
            if not verify_tool_result(fn_name, fn_args, result):
                result = {"error": f"Tool '{fn_name}' result failed verification"}

            tracer.trace_tool_call(fn_name, fn_args, result, tool_duration)

            messages.append({
                "role": "tool",
                "tool_call_id": tc.id,
                "name": fn_name,
                "content": json.dumps(result),
            })

        # --- Checkpoint after each round ---
        checkpoint_store.save(run_id, step, {
            "messages_count": len(messages),
            "tools_called": [tc.function.name for tc in msg.tool_calls],
            "total_tokens": budget.total_tokens,
        })

    return "Max rounds reached without a final answer."
```

---

## Pattern 3: Model Router (Cost-Optimized)

**Problem:** Using the most expensive model for every request wastes budget. Simple queries don't need GPT-4o.

**Solution:** Route requests to models based on estimated complexity.

```python
from dataclasses import dataclass

@dataclass
class ModelTier:
    name: str
    model_id: str
    max_tokens: int
    cost_per_1m_input: float
    cost_per_1m_output: float

MODEL_TIERS = {
    "simple": ModelTier("simple", "gpt-4o-mini", 4096, 0.15, 0.60),
    "standard": ModelTier("standard", "gpt-4o", 8192, 2.50, 10.00),
    "complex": ModelTier("complex", "claude-sonnet-4-20250514", 16384, 3.00, 15.00),
}

def classify_complexity(user_input: str, tools: list) -> str:
    """Heuristic complexity classifier."""
    # Simple: short input, no tools needed
    if len(user_input) < 200 and not tools:
        return "simple"

    # Complex: long input, multiple tools, or reasoning keywords
    reasoning_signals = ["analyze", "compare", "design", "architect", "debug", "refactor"]
    if any(signal in user_input.lower() for signal in reasoning_signals):
        return "complex"
    if len(tools) > 3:
        return "complex"

    return "standard"

def route_to_model(user_input: str, tools: list) -> ModelTier:
    """Select model tier based on request complexity."""
    tier_name = classify_complexity(user_input, tools)
    return MODEL_TIERS[tier_name]
```

---

## Pattern 4: Structured Retry with Error Feedback

**Problem:** Blind retries waste tokens. The model makes the same mistake on retry without knowing what went wrong.

**Solution:** Feed the validation error back to the model as context for the retry attempt.

```python
from pydantic import BaseModel, ValidationError

def extract_with_feedback_retry(
    client, model: str, messages: list, response_schema: type[BaseModel], max_retries: int = 2
) -> BaseModel:
    """Retry with error context injected into conversation."""
    attempt_messages = messages.copy()

    for attempt in range(max_retries + 1):
        response = client.chat.complete(
            model=model,
            messages=attempt_messages,
            response_format={"type": "json_object"},
        )
        raw = response.choices[0].message.content

        try:
            return response_schema.model_validate_json(raw)
        except ValidationError as e:
            if attempt == max_retries:
                raise ValueError(f"Failed after {max_retries + 1} attempts. Last error: {e}")

            # Feed error back as context
            attempt_messages.append({"role": "assistant", "content": raw})
            attempt_messages.append({
                "role": "user",
                "content": (
                    f"Your response didn't match the required schema. "
                    f"Validation errors:\n{e}\n\n"
                    f"Please fix and return valid JSON."
                ),
            })
```

---

## Pattern 5: Conversation Memory with Summarization

**Problem:** Long conversations exceed the context window. Naive truncation loses important context.

**Solution:** Summarize older turns while keeping recent turns verbatim.

```python
class SummarizingMemory:
    """Keep recent turns verbatim; summarize older turns."""

    def __init__(self, client, model: str, max_recent_tokens: int = 4000):
        self.client = client
        self.model = model
        self.max_recent_tokens = max_recent_tokens
        self.summary: str = ""
        self.recent_messages: list[dict] = []

    def add(self, message: dict):
        self.recent_messages.append(message)
        self._compact_if_needed()

    def get_messages(self) -> list[dict]:
        """Return system summary + recent messages."""
        messages = []
        if self.summary:
            messages.append({
                "role": "system",
                "content": f"Summary of earlier conversation:\n{self.summary}",
            })
        messages.extend(self.recent_messages)
        return messages

    def _compact_if_needed(self):
        """Summarize old messages when recent window is too large."""
        total_chars = sum(len(m.get("content", "")) for m in self.recent_messages)
        # Rough estimate: 4 chars ≈ 1 token
        if total_chars / 4 <= self.max_recent_tokens:
            return

        # Split: oldest half → summarize, newest half → keep
        midpoint = len(self.recent_messages) // 2
        to_summarize = self.recent_messages[:midpoint]
        self.recent_messages = self.recent_messages[midpoint:]

        # Summarize
        summary_input = "\n".join(
            f"{m['role']}: {m.get('content', '')}" for m in to_summarize
        )
        response = self.client.chat.complete(
            model=self.model,
            messages=[{
                "role": "user",
                "content": f"Summarize this conversation concisely:\n\n{summary_input}",
            }],
            temperature=0,
            max_tokens=500,
        )
        new_summary = response.choices[0].message.content
        self.summary = f"{self.summary}\n{new_summary}".strip() if self.summary else new_summary
```

---

## Pattern 6: Idempotent Tool Execution

**Problem:** Agent retries may execute the same tool call twice. Without idempotency, this causes duplicate side effects.

**Solution:** Track tool call IDs and skip duplicate executions.

```python
class IdempotentExecutor:
    """Ensure each tool call executes at most once."""

    def __init__(self):
        self._executed: dict[str, dict] = {}  # tool_call_id → result

    def execute(self, tool_call_id: str, tool_fn: Callable, **kwargs) -> dict:
        # Return cached result if already executed
        if tool_call_id in self._executed:
            return self._executed[tool_call_id]

        result = tool_fn(**kwargs)
        self._executed[tool_call_id] = result
        return result
```

---

## Pattern 7: Async Approval Workflow

**Problem:** Blocking on human approval stalls the agent. In production, approvers may not be immediately available.

**Solution:** Queue approval requests and let the agent continue with non-destructive tasks while waiting.

```python
import asyncio
from dataclasses import dataclass, field
from enum import Enum

class ApprovalStatus(Enum):
    PENDING = "pending"
    APPROVED = "approved"
    DENIED = "denied"

@dataclass
class ApprovalRequest:
    request_id: str
    tool_name: str
    args: dict
    reason: str
    status: ApprovalStatus = ApprovalStatus.PENDING
    reviewer: str | None = None
    reviewed_at: str | None = None

class ApprovalQueue:
    """Non-blocking approval workflow."""

    def __init__(self):
        self._queue: dict[str, ApprovalRequest] = {}
        self._events: dict[str, asyncio.Event] = {}

    async def request_approval(self, request: ApprovalRequest) -> ApprovalStatus:
        """Submit request and wait for reviewer decision."""
        self._queue[request.request_id] = request
        self._events[request.request_id] = asyncio.Event()

        # Notify reviewers (webhook, Slack, email, etc.)
        await self._notify_reviewers(request)

        # Wait for decision (with timeout)
        try:
            await asyncio.wait_for(
                self._events[request.request_id].wait(),
                timeout=300,  # 5 minute timeout
            )
        except asyncio.TimeoutError:
            request.status = ApprovalStatus.DENIED
            request.reason = "Approval timed out"

        return request.status

    def resolve(self, request_id: str, approved: bool, reviewer: str):
        """Reviewer resolves the request."""
        req = self._queue[request_id]
        req.status = ApprovalStatus.APPROVED if approved else ApprovalStatus.DENIED
        req.reviewer = reviewer
        self._events[request_id].set()

    async def _notify_reviewers(self, request: ApprovalRequest):
        """Send notification to approval channel."""
        # Implement: Slack webhook, email, PagerDuty, etc.
        pass
```

---

## Pattern 8: Trace-Replay for Debugging

**Problem:** Agent failures are hard to reproduce. By the time you investigate, the model may behave differently.

**Solution:** Log every interaction as a replayable trace, then replay deterministically for debugging.

```python
import json
from pathlib import Path
from datetime import datetime, UTC

class TraceRecorder:
    """Record agent interactions for replay."""

    def __init__(self, trace_dir: str = "traces"):
        self.trace_dir = Path(trace_dir)
        self.trace_dir.mkdir(parents=True, exist_ok=True)
        self.events: list[dict] = []

    def record(self, event_type: str, data: dict):
        self.events.append({
            "type": event_type,
            "timestamp": datetime.now(UTC).isoformat(),
            "data": data,
        })

    def save(self, run_id: str):
        path = self.trace_dir / f"{run_id}.jsonl"
        with path.open("w") as f:
            for event in self.events:
                f.write(json.dumps(event, default=str) + "\n")

class TraceReplayer:
    """Replay a recorded trace for debugging."""

    def __init__(self, trace_path: str):
        self.events = []
        with open(trace_path) as f:
            for line in f:
                self.events.append(json.loads(line))

    def get_llm_calls(self) -> list[dict]:
        return [e for e in self.events if e["type"] == "llm_call"]

    def get_tool_calls(self) -> list[dict]:
        return [e for e in self.events if e["type"] == "tool_call"]

    def get_guardrail_triggers(self) -> list[dict]:
        return [e for e in self.events if e["type"] == "guardrail_trigger"]

    def replay_with_mocked_tools(self, agent, tool_mocks: dict):
        """Re-run agent with recorded inputs but mocked tool responses."""
        for event in self.events:
            if event["type"] == "tool_call":
                tool_name = event["data"]["tool"]
                if tool_name in tool_mocks:
                    tool_mocks[tool_name](event["data"]["args"])
```

---

## Pattern 9: Multi-Layer Output Validation Pipeline

**Problem:** A single validation check isn't enough. Different output types need different checks, and some checks are expensive.

**Solution:** Run validators in order from cheapest to most expensive, short-circuiting on failure.

```python
from typing import Protocol

class Validator(Protocol):
    """Interface for output validators."""
    def validate(self, output: str, context: dict) -> "ValidationResult": ...

@dataclass
class ValidationResult:
    passed: bool
    validator_name: str
    reason: str = ""

class ValidationPipeline:
    """Run validators cheapest-first, stop on first failure."""

    def __init__(self):
        self.validators: list[Validator] = []

    def add(self, validator: Validator):
        self.validators.append(validator)
        return self  # chainable

    def run(self, output: str, context: dict) -> list[ValidationResult]:
        results = []
        for v in self.validators:
            result = v.validate(output, context)
            results.append(result)
            if not result.passed:
                break  # stop on first failure — don't waste expensive checks
        return results

# Usage: cheapest → most expensive
pipeline = (
    ValidationPipeline()
    .add(LengthValidator(max_chars=10_000))       # ~0ms, $0
    .add(SchemaValidator(schema=OutputSchema))      # ~1ms, $0
    .add(PIIDetector())                             # ~5ms, $0
    .add(LLMJudge(client=client, model="gpt-4o-mini"))  # ~500ms, ~$0.001
)

results = pipeline.run(agent_output, context={"user_input": user_input})
all_passed = all(r.passed for r in results)
```

---

## Decision Matrices

### When to apply each pattern

| Pattern | Apply when | Skip when |
|---------|-----------|-----------|
| Tool Permission Registry | Agent has 2+ tools OR any tool with side effects | Single read-only tool |
| Harnessed Agent Loop | Any multi-step agent in production | One-shot prototypes |
| Model Router | Monthly LLM spend > $100 OR high request volume | Low volume, single model |
| Retry with Feedback | Agent produces structured output (JSON, code) | Free-form text generation |
| Summarizing Memory | Conversations exceed 10 turns regularly | Short, single-turn interactions |
| Idempotent Execution | Any tool with write/delete/external side effects | Pure read-only tools |
| Async Approval | Approvers not always available in real-time | Interactive CLI tools |
| Trace-Replay | Debugging production incidents or regression testing | Early prototyping |
| Validation Pipeline | User-facing output OR output feeds into downstream systems | Internal logging only |

### Harness component priority by deployment stage

| Stage | Must have | Should have | Nice to have |
|-------|-----------|-------------|--------------|
| **Prototype** | Max-rounds cap, basic logging | Input length check | — |
| **Internal tool** | + Retry/backoff, structured errors | + Checkpointing, cost tracking | Trace recording |
| **User-facing** | + All guardrails, approval gates, budget limits | + Circuit breaker, fallback chain | Model router |
| **Mission-critical** | All of the above + validation pipeline | + Async approval, trace-replay | Drift detection |
