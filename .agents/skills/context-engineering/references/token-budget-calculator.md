# Token Budget Calculator

Formulas, code, and per-model reference data for budgeting tokens across context sources.

## Per-Model Context Windows

| Model | Context Window | Max Output | Effective Input Budget |
|-------|---------------|------------|----------------------|
| GPT-4o | 128,000 | 16,384 | 111,616 |
| GPT-4o-mini | 128,000 | 16,384 | 111,616 |
| GPT-4.1 | 1,047,576 | 32,768 | 1,014,808 |
| Claude Sonnet 4 | 200,000 | 16,000 | 184,000 |
| Claude Opus 4 | 200,000 | 32,000 | 168,000 |
| Claude Haiku 3.5 | 200,000 | 8,192 | 191,808 |
| Mistral Large | 128,000 | 8,192 | 119,808 |
| Mistral Small | 32,000 | 8,192 | 23,808 |
| Llama 3.1 405B | 128,000 | 4,096 | 123,904 |
| Gemini 2.5 Pro | 1,048,576 | 65,536 | 983,040 |

**Rule of thumb**: reserve 15–25% of the window for the response, or the model's `max_output_tokens`, whichever is larger.

## Precise Token Counting with tiktoken

`tiktoken` is the reference tokenizer for OpenAI models. For other providers, use their SDK's token counting or fall back to `cl100k_base` (a reasonable approximation for most modern models).

### Installation

```bash
pip install tiktoken
```

### Counting tokens for a string

```python
import tiktoken

def count_tokens(text: str, model: str = "gpt-4o") -> int:
    """Precise token count for a given model."""
    try:
        enc = tiktoken.encoding_for_model(model)
    except KeyError:
        # Fallback for models not in tiktoken's registry
        enc = tiktoken.get_encoding("cl100k_base")
    return len(enc.encode(text))
```

### Counting tokens for a chat messages array

OpenAI chat format adds per-message overhead tokens. This varies slightly by model but is consistent within a model family.

```python
def count_messages_tokens(
    messages: list[dict], model: str = "gpt-4o"
) -> int:
    """Count tokens for a full chat messages array including overhead.

    Overhead per message: ~4 tokens (im_start, role, im_sep, im_end).
    Every reply is primed with: <|im_start|>assistant<|im_sep|> = 3 tokens.
    """
    try:
        enc = tiktoken.encoding_for_model(model)
    except KeyError:
        enc = tiktoken.get_encoding("cl100k_base")

    # Per-message overhead varies by model family
    if model.startswith("gpt-4") or model.startswith("gpt-3.5"):
        tokens_per_message = 3  # <|im_start|>{role}\n ... <|im_end|>\n
        tokens_per_name = 1     # if "name" field is present
    else:
        tokens_per_message = 4  # safe default for unknown models

    total = 3  # reply priming
    for msg in messages:
        total += tokens_per_message
        for key, value in msg.items():
            if isinstance(value, str):
                total += len(enc.encode(value))
            if key == "name":
                total += tokens_per_name
    return total
```

### Counting tokens for tool/function definitions

Tool schemas count against your input budget. This is often forgotten.

```python
import json

def count_tools_tokens(tools: list[dict], model: str = "gpt-4o") -> int:
    """Estimate tokens consumed by tool/function definitions in the request."""
    enc = tiktoken.encoding_for_model(model)
    # OpenAI serializes tool schemas as part of the system context
    tools_text = json.dumps(tools, separators=(",", ":"))
    return len(enc.encode(tools_text)) + 10  # small overhead for framing
```

## Non-tiktoken Models — Approximation Strategies

For models without a public tokenizer (Claude, Mistral, Gemini), use these approaches in order of preference:

1. **Provider SDK token counting** — e.g., `anthropic.count_tokens()`, Mistral usage object in response
2. **`cl100k_base` encoding** — within ~5–10% for most modern models
3. **Character-based estimate** — `len(text) * 0.3` for English (1 token ≈ 3.3 chars on average). **Use only as a last resort.**

```python
def estimate_tokens_fallback(text: str) -> int:
    """Conservative estimate when no tokenizer is available.
    Uses 1 token per 3.3 characters (slightly over-estimates for safety)."""
    return int(len(text) / 3.3) + 1
```

## The Budget Formula

```
total_input = system + user + history + rag + tools_schema + tool_results + working_memory
effective_limit = model_window - response_reserve
assert total_input <= effective_limit
```

### Adaptive Budget Rebalancing

When total input exceeds the effective limit, compress in priority order (lowest priority first):

```python
from dataclasses import dataclass, field

@dataclass
class TokenBudgetManager:
    """Manage and rebalance token budgets across context sources."""

    model_window: int
    response_reserve: int
    allocations: dict[str, int]       # source → max tokens
    priorities: dict[str, int]        # source → priority (0 = highest)
    usage: dict[str, int] = field(default_factory=dict)

    @property
    def effective_limit(self) -> int:
        return self.model_window - self.response_reserve

    def record(self, source: str, tokens: int):
        self.usage[source] = tokens

    @property
    def total_used(self) -> int:
        return sum(self.usage.values())

    @property
    def overflow(self) -> int:
        return max(0, self.total_used - self.effective_limit)

    def rebalance(self) -> dict[str, int]:
        """Return adjusted allocations, cutting lowest-priority sources first."""
        if self.overflow <= 0:
            return dict(self.usage)

        to_cut = self.overflow
        adjusted = dict(self.usage)
        # Sort sources by priority descending (cut lowest priority = highest number first)
        by_priority = sorted(
            self.usage.keys(),
            key=lambda s: self.priorities.get(s, 99),
            reverse=True,
        )

        for source in by_priority:
            if to_cut <= 0:
                break
            # Never cut critical sources (priority 0) below 50% of allocation
            min_keep = 0
            if self.priorities.get(source, 99) == 0:
                min_keep = self.allocations.get(source, 0) // 2

            available_to_cut = adjusted[source] - min_keep
            cut = min(to_cut, available_to_cut)
            if cut > 0:
                adjusted[source] -= cut
                to_cut -= cut

        return adjusted
```

### Usage Example — Full Budget Cycle

```python
# 1. Configure budget for GPT-4o
budget = TokenBudgetManager(
    model_window=128_000,
    response_reserve=4_096,
    allocations={
        "system_prompt": 2_000,
        "tools_schema": 1_500,
        "user_message": 1_000,
        "rag_context": 8_000,
        "tool_results": 4_000,
        "working_memory": 1_000,
        "history": 107_404,
    },
    priorities={
        "system_prompt": 0,   # never cut
        "user_message": 0,    # never cut
        "tools_schema": 0,    # never cut (model needs them)
        "rag_context": 1,     # cut reluctantly
        "tool_results": 2,    # cut by truncation
        "working_memory": 2,  # compact between steps
        "history": 3,         # cut first (summarize)
    },
)

# 2. Measure actual usage this turn
budget.record("system_prompt", count_tokens(system_prompt))
budget.record("tools_schema", count_tools_tokens(tools))
budget.record("user_message", count_tokens(user_msg))
budget.record("rag_context", count_tokens(rag_text))
budget.record("tool_results", count_tokens(tool_output))
budget.record("working_memory", count_tokens(scratchpad))
budget.record("history", count_messages_tokens(history_msgs))

# 3. Check and rebalance
if budget.overflow > 0:
    adjusted = budget.rebalance()
    # Truncate each source to its adjusted allocation
    for source, target_tokens in adjusted.items():
        if budget.usage[source] > target_tokens:
            # Apply source-specific compression:
            # - history → summarize old turns
            # - tool_results → truncate or summarize
            # - rag_context → reduce k
            pass
```

## Tokenizer Comparison

How the same text tokenizes across encodings:

| Text | cl100k_base (GPT-4o) | o200k_base (GPT-4.1) | Chars/Token |
|------|--------------------|--------------------|-------------|
| "Hello, world!" | 4 | 4 | 3.5 |
| Python function (50 lines) | ~380 | ~350 | ~3.3 |
| JSON API response (1KB) | ~280 | ~260 | ~3.6 |
| English prose (1000 words) | ~1,300 | ~1,200 | ~3.8 |
| Code with comments | ~400/KB | ~370/KB | ~2.5 |

**Key takeaway**: Code tokenizes less efficiently than prose (more tokens per character). Budget 20–30% more tokens for code-heavy context.

## Common Budgeting Mistakes

| Mistake | Impact | Fix |
|---------|--------|-----|
| Forgetting tool schema tokens | 500–2,000 ghost tokens per request | Count `tools` parameter with `count_tools_tokens()` |
| Using `len(text) / 4` | 15–40% error vs. actual count | Use `tiktoken` or provider SDK |
| No response reserve | Model output cut off mid-sentence | Always reserve `max_tokens` you plan to request |
| Static budget, dynamic content | Overflow on large tool results | Use adaptive rebalancing (see above) |
| Counting only text, not message overhead | Off by 3–5 tokens per message | Use `count_messages_tokens()` which includes overhead |
| Same budget for all models | Wastes capacity on large-window models | Set budget per model using the window table above |
