---
name: context-engineering
description: "Use when designing what information an LLM sees at each step — token budgeting, dynamic prompt assembly, memory architecture, RAG positioning, tool result injection, multi-turn strategies, and context debugging. Covers any model and any agent framework. Do not use for prompt wording/tone, model fine-tuning, RAG pipeline infrastructure (chunking, embedding, indexing), or operational guardrails (use harness-engineering instead)."
argument-hint: "Target model and context window size, agent framework in use, current context pain points (overflow, stale history, lost instructions), and which components need design (budget, memory, assembly, debugging)"
user-invocable: true
---

# Context Engineering

Step-by-step procedure for designing and implementing the context layer of an LLM-powered system — the dynamic assembly of system prompts, conversation history, retrieved documents, tool results, and memory into a token-budgeted window. Platform-agnostic: works with any model and any agent framework.

## When To Use

- You are building an agent and need to decide what goes into the context window at each turn.
- Your agent loses instructions, forgets earlier context, or runs out of tokens mid-conversation.
- You need to budget tokens across system prompt, history, RAG chunks, and tool results.
- You are designing memory for an agent — choosing between buffer, summary, vector, or hybrid.
- Tool results are too large and you need truncation or summarization before injection.
- You need to debug what the model actually sees at inference time.

Do NOT use for:
- Prompt wording, tone, or persona design — that is prompt engineering, not context engineering.
- RAG infrastructure (chunking strategies, embedding models, vector store setup) — use a RAG-specific skill.
- Operational guardrails, retry logic, or error recovery — use `harness-engineering`.
- Model selection or fine-tuning decisions.

## Inputs To Collect First

1. **Model and window size**: Which model? What is its context window (e.g., 128K, 200K)? What is the practical ceiling after accounting for output tokens?
2. **Agent framework**: LangChain, LlamaIndex, Mistral Agents API, OpenAI Assistants, custom Python, etc.
3. **Context sources**: What goes into the window? (system prompt, user message, conversation history, RAG chunks, tool results, scratchpad/working memory)
4. **Current pain points**: Token overflow? Lost instructions? Stale history? Hallucinated context?
5. **Turn volume**: How many turns does a typical conversation last? How large are typical tool results?

## Procedure

### Step 1 — Map Context Sources and Set Token Budget

Before writing any code, enumerate every source that competes for tokens in your window, then allocate a budget.

**1a. Enumerate context sources with priority:**

| Priority | Source | Typical Size | Compressible? |
|----------|--------|-------------|---------------|
| P0 (never cut) | System prompt + instructions | 500–2,000 tok | No — rewrite to shorten |
| P0 (never cut) | Current user message | 50–500 tok | No |
| P1 (cut last) | Retrieved RAG chunks | 500–4,000 tok | Yes — reduce k or truncate |
| P2 (cut early) | Tool results | 200–10,000 tok | Yes — summarize or truncate |
| P2 (cut early) | Working memory / scratchpad | 200–1,000 tok | Yes — compact between steps |
| P3 (cut first) | Conversation history | 500–50,000 tok | Yes — summarize old turns |

**1b. Apply the budget formula:**

The total context sent to the model must satisfy:

```
system_tokens + user_tokens + history_tokens + rag_tokens + tool_tokens + working_memory_tokens + response_reserve ≤ model_context_window
```

Reserve at least 15–25% of the window for the model's response. For a 128K window targeting a 4K response:

```python
MODEL_WINDOW = 128_000
RESPONSE_RESERVE = 4_096

BUDGET = {
    "system_prompt":   2_000,   # P0 — fixed
    "user_message":    1_000,   # P0 — variable, measured per-turn
    "rag_context":     8_000,   # P1 — adjust k and chunk size
    "tool_results":    4_000,   # P2 — truncate if over
    "working_memory":  1_000,   # P2 — compact between steps
    "history":         None,    # P3 — gets whatever remains
}

allocated = sum(v for v in BUDGET.values() if v is not None) + RESPONSE_RESERVE
BUDGET["history"] = MODEL_WINDOW - allocated  # ~107,904 tokens for history
```

Load [Token Budget Calculator](./references/token-budget-calculator.md) for precise token counting with `tiktoken`, per-model window sizes, and adaptive budget rebalancing.

### Step 2 — Implement Token Accounting

Use a real tokenizer — not `len(text) / 4`. Different models use different tokenizers.

**2a. Count tokens accurately:**

```python
import tiktoken

def count_tokens(text: str, model: str = "gpt-4o") -> int:
    """Count tokens for a given model's tokenizer."""
    try:
        enc = tiktoken.encoding_for_model(model)
    except KeyError:
        enc = tiktoken.get_encoding("cl100k_base")  # fallback
    return len(enc.encode(text))

def count_messages_tokens(messages: list[dict], model: str = "gpt-4o") -> int:
    """Count tokens for a chat messages array (OpenAI format).
    Each message has overhead: <|im_start|>role\ncontent<|im_end|>\n = ~4 tokens."""
    enc = tiktoken.encoding_for_model(model)
    total = 3  # every reply is primed with <|im_start|>assistant<|im_sep|>
    for msg in messages:
        total += 4  # per-message overhead
        for key, value in msg.items():
            if isinstance(value, str):
                total += len(enc.encode(value))
    return total
```

**2b. Build a token ledger to track usage per source:**

```python
from dataclasses import dataclass, field

@dataclass
class TokenLedger:
    """Track token allocation across context sources."""
    budget: dict[str, int]
    usage: dict[str, int] = field(default_factory=dict)
    model: str = "gpt-4o"

    def record(self, source: str, text: str) -> int:
        tokens = count_tokens(text, self.model)
        self.usage[source] = self.usage.get(source, 0) + tokens
        return tokens

    def remaining(self, source: str) -> int:
        return self.budget.get(source, 0) - self.usage.get(source, 0)

    def over_budget(self) -> list[str]:
        return [s for s in self.budget if self.usage.get(s, 0) > self.budget[s]]

    def report(self) -> str:
        lines = []
        for source, limit in self.budget.items():
            used = self.usage.get(source, 0)
            pct = (used / limit * 100) if limit else 0
            lines.append(f"  {source}: {used}/{limit} ({pct:.0f}%)")
        return "\n".join(lines)
```

### Step 3 — Build Dynamic Prompt Assembly

Assemble the context window from modular components, not a single static string. Each component is measured, truncated if needed, and placed in priority order.

**3a. Define context components as typed blocks:**

```python
from dataclasses import dataclass
from enum import IntEnum

class Priority(IntEnum):
    CRITICAL = 0   # system prompt, user message — never cut
    HIGH = 1       # RAG context — reduce k before dropping
    MEDIUM = 2     # tool results, working memory — truncate
    LOW = 3        # old conversation history — summarize or drop

@dataclass
class ContextBlock:
    source: str          # "system_prompt", "rag_context", "history", etc.
    role: str            # "system", "user", "assistant", "tool"
    content: str
    priority: Priority
    token_count: int = 0 # filled during assembly

    def __post_init__(self):
        if not self.token_count:
            self.token_count = count_tokens(self.content)
```

**3b. Assemble with priority-based truncation:**

```python
def assemble_context(
    blocks: list[ContextBlock],
    max_tokens: int,
    reserve: int = 4096,
) -> list[dict]:
    """Assemble context blocks into a messages array, fitting within budget.
    Drops lowest-priority blocks first when over budget."""
    budget = max_tokens - reserve
    # Sort: critical first, low last
    sorted_blocks = sorted(blocks, key=lambda b: b.priority)

    included = []
    used = 0
    for block in sorted_blocks:
        if used + block.token_count <= budget:
            included.append(block)
            used += block.token_count
        elif block.priority == Priority.CRITICAL:
            # Critical blocks always included — truncate content if needed
            remaining = budget - used
            if remaining > 100:
                block.content = truncate_to_tokens(block.content, remaining)
                block.token_count = remaining
                included.append(block)
                used += remaining
        # else: skip this block (over budget, non-critical)

    # Re-sort into message order: system → history → rag → tool → user
    order = {"system": 0, "assistant": 1, "tool": 2, "user": 3}
    included.sort(key=lambda b: (order.get(b.role, 99), b.priority))

    return [{"role": b.role, "content": b.content} for b in included]
```

**3c. Truncation helper:**

```python
def truncate_to_tokens(text: str, max_tokens: int, model: str = "gpt-4o") -> str:
    """Truncate text to fit within a token budget."""
    enc = tiktoken.encoding_for_model(model)
    tokens = enc.encode(text)
    if len(tokens) <= max_tokens:
        return text
    truncated = enc.decode(tokens[:max_tokens - 20])  # leave room for marker
    return truncated + "\n\n[... truncated — original was {len(tokens)} tokens]"
```

### Step 4 — Design Memory Architecture

Choose a memory strategy based on conversation length, importance of recall, and token budget.

**4a. Decision matrix:**

| Pattern | Best For | Token Cost | Implementation Complexity |
|---------|----------|------------|--------------------------|
| **Buffer** (keep all) | Short conversations (<20 turns) | Grows linearly | Trivial |
| **Sliding window** (keep last N) | Medium conversations, recent context matters most | Fixed ceiling | Low |
| **Summary** (compress old turns) | Long conversations, gist is enough | Fixed ceiling | Medium — needs LLM call |
| **Entity memory** (extract key facts) | Conversations about specific entities/objects | Very low | Medium — needs extraction |
| **Vector store** (embed + retrieve) | Very long history, sparse recall needs | Low per-turn | High — needs embedding infra |
| **Hybrid** (window + summary + vector) | Production agents with unpredictable turn counts | Tunable | High |

**4b. Sliding window with summary spillover:**

```python
class SlidingWindowMemory:
    """Keep recent N turns verbatim; summarize anything older."""

    def __init__(self, window_size: int = 10, summary_model: str = "gpt-4o-mini"):
        self.turns: list[dict] = []
        self.summary: str = ""
        self.window_size = window_size
        self.summary_model = summary_model

    def add_turn(self, role: str, content: str):
        self.turns.append({"role": role, "content": content})
        if len(self.turns) > self.window_size:
            self._compact()

    def _compact(self):
        """Move oldest turns into running summary."""
        overflow = self.turns[:-self.window_size]
        self.turns = self.turns[-self.window_size:]
        overflow_text = "\n".join(f"{t['role']}: {t['content']}" for t in overflow)
        self.summary = self._summarize(self.summary, overflow_text)

    def _summarize(self, existing_summary: str, new_text: str) -> str:
        prompt = (
            "Compress this conversation into a concise factual summary. "
            "Preserve all decisions, commitments, key facts, and user preferences. "
            "Drop pleasantries and redundant back-and-forth.\n\n"
        )
        if existing_summary:
            prompt += f"Previous summary:\n{existing_summary}\n\n"
        prompt += f"New turns to incorporate:\n{new_text}"
        # Call cheap model for summarization
        resp = client.chat.complete(
            model=self.summary_model,
            messages=[{"role": "user", "content": prompt}],
            temperature=0,
            max_tokens=500,
        )
        return resp.choices[0].message.content

    def get_context_blocks(self) -> list[ContextBlock]:
        blocks = []
        if self.summary:
            blocks.append(ContextBlock(
                source="memory_summary", role="system",
                content=f"Summary of earlier conversation:\n{self.summary}",
                priority=Priority.MEDIUM,
            ))
        for turn in self.turns:
            blocks.append(ContextBlock(
                source="history", role=turn["role"],
                content=turn["content"], priority=Priority.LOW,
            ))
        return blocks
```

Load [Memory Architecture Patterns](./references/memory-architecture-patterns.md) for entity memory, vector-backed memory, hybrid implementations, and the full decision matrix.

### Step 5 — Position RAG Context and Tool Results

Where you place content in the context window affects model attention. Apply these positioning rules:

**5a. RAG chunk positioning:**

- **Place retrieved context BEFORE the user question** — models attend more reliably to context that precedes the query.
- **Use explicit delimiters** between chunks — `---` or XML-style tags (`<context>`, `<source>`).
- **Include source metadata** inline so the model can cite.
- **Order chunks by relevance score** — most relevant first (takes advantage of primacy bias).

```python
def format_rag_context(chunks: list[dict], max_tokens: int = 8000) -> ContextBlock:
    """Format retrieved chunks into a context block with citation metadata."""
    formatted_parts = []
    total_tokens = 0
    for i, chunk in enumerate(chunks):
        entry = f"[Source {i+1}: {chunk['metadata'].get('source', 'unknown')}]\n{chunk['text']}"
        entry_tokens = count_tokens(entry)
        if total_tokens + entry_tokens > max_tokens:
            break  # stop adding chunks when budget exhausted
        formatted_parts.append(entry)
        total_tokens += entry_tokens

    content = (
        "Use the following retrieved context to answer. "
        "Cite sources by number [Source N]. "
        "If the context does not contain the answer, say so.\n\n"
        + "\n\n---\n\n".join(formatted_parts)
    )
    return ContextBlock(
        source="rag_context", role="system",
        content=content, priority=Priority.HIGH,
    )
```

**5b. Tool result injection — truncate before inserting:**

```python
def format_tool_result(
    tool_name: str, result: dict, max_tokens: int = 2000
) -> ContextBlock:
    """Format a tool result for injection, with truncation."""
    import json
    raw = json.dumps(result, indent=2, default=str)
    raw_tokens = count_tokens(raw)

    if raw_tokens <= max_tokens:
        content = raw
    elif isinstance(result, dict) and "items" in result:
        # Structured result — truncate the list, keep metadata
        truncated = {k: v for k, v in result.items() if k != "items"}
        truncated["items"] = result["items"][:20]  # keep first 20
        truncated["_truncated"] = f"{len(result['items'])} total, showing first 20"
        content = json.dumps(truncated, indent=2, default=str)
    else:
        content = truncate_to_tokens(raw, max_tokens)

    return ContextBlock(
        source=f"tool:{tool_name}", role="tool",
        content=content, priority=Priority.MEDIUM,
    )
```

### Step 6 — Implement Multi-Turn Context Strategy

As conversations grow, apply these strategies to manage context pressure:

**6a. Turn-level lifecycle:**

```
Each turn:
1. Measure token usage of all current context sources
2. If over budget → trigger compression cascade:
   a. Truncate tool results from older turns (P2)
   b. Summarize conversation history beyond window (P3)
   c. Reduce RAG k (P1) — only as last resort
3. Assemble context with priority-based packing (Step 3)
4. Send to model
5. Record response, update memory, update token ledger
```

**6b. Importance-weighted history retention:**

Not all turns are equal. Tag turns with importance and prefer retaining high-importance turns:

```python
@dataclass
class Turn:
    role: str
    content: str
    importance: float = 0.5  # 0.0–1.0

    def compute_importance(self) -> float:
        """Heuristic importance scoring."""
        score = 0.5
        # User corrections and clarifications are high-value
        if self.role == "user" and any(w in self.content.lower()
            for w in ["actually", "no,", "correction", "instead", "wrong"]):
            score += 0.3
        # Tool results that were referenced in follow-up are high-value
        if self.role == "tool":
            score += 0.1
        # Short acknowledgments are low-value
        if len(self.content) < 20:
            score -= 0.2
        return min(1.0, max(0.0, score))
```

**6c. Progressive summarization** — summarize in tiers: >10 turns old → 1-line per turn; >30 turns → paragraph per 10 turns; >100 turns → single running summary.

### Step 7 — Add Context Debugging

Build visibility into what the model sees at each step.

**7a. Context snapshot logger:**

```python
def log_context_snapshot(
    messages: list[dict], model: str, run_id: str, turn: int
):
    """Log the exact context sent to the model for debugging."""
    total_tokens = count_messages_tokens(messages, model)
    snapshot = {
        "run_id": run_id,
        "turn": turn,
        "model": model,
        "total_tokens": total_tokens,
        "message_count": len(messages),
        "breakdown": [],
    }
    for i, msg in enumerate(messages):
        tok = count_tokens(msg.get("content", ""), model)
        snapshot["breakdown"].append({
            "index": i,
            "role": msg["role"],
            "tokens": tok,
            "preview": msg.get("content", "")[:120] + "..." if len(msg.get("content", "")) > 120 else msg.get("content", ""),
        })
    import json, logging
    logging.getLogger("context.debug").info(json.dumps(snapshot, indent=2))
    return snapshot
```

**7b. Context diff between turns** — see what changed:

```python
def diff_context(prev_snapshot: dict, curr_snapshot: dict) -> dict:
    """Compare two context snapshots to see what was added/removed/changed."""
    prev_previews = {m["index"]: m for m in prev_snapshot.get("breakdown", [])}
    curr_previews = {m["index"]: m for m in curr_snapshot.get("breakdown", [])}
    return {
        "token_delta": curr_snapshot["total_tokens"] - prev_snapshot["total_tokens"],
        "messages_added": len(curr_previews) - len(prev_previews),
        "new_messages": [
            curr_previews[i] for i in curr_previews if i not in prev_previews
        ],
    }
```

**7c. Validation assertions — catch context bugs before they reach the model:**

```python
def validate_context(messages: list[dict], budget: dict, model: str) -> list[str]:
    """Run assertions on assembled context. Returns list of warnings."""
    warnings = []
    total = count_messages_tokens(messages, model)
    max_allowed = budget.get("model_window", 128_000) - budget.get("response_reserve", 4096)
    if total > max_allowed:
        warnings.append(f"OVER BUDGET: {total} tokens > {max_allowed} limit")
    if not messages or messages[0]["role"] != "system":
        warnings.append("NO SYSTEM PROMPT: first message should be role=system")
    if messages[-1]["role"] != "user":
        warnings.append("LAST MESSAGE NOT USER: model expects user message last")
    # Check for duplicate content (copy-paste context pollution)
    contents = [m.get("content", "") for m in messages]
    for i, c in enumerate(contents):
        for j, other in enumerate(contents[i+1:], i+1):
            if c and other and c == other:
                warnings.append(f"DUPLICATE CONTENT: messages[{i}] == messages[{j}]")
    return warnings
```

## Completion Checks

- [ ] Token budget defined with explicit allocations per source (system, history, RAG, tools, response reserve)
- [ ] Token counting uses a real tokenizer (e.g., `tiktoken`), not `len(text) / 4`
- [ ] Context assembly uses priority-based truncation — critical blocks never dropped
- [ ] Memory strategy chosen from decision matrix and implemented (buffer, window, summary, vector, or hybrid)
- [ ] RAG chunks positioned before user query with source metadata for citation
- [ ] Tool results truncated or summarized before injection — no unbounded insertion
- [ ] Multi-turn strategy handles conversations exceeding the token budget gracefully
- [ ] Context snapshot logging implemented — can inspect exact tokens sent per turn
- [ ] Validation assertions catch overflow, missing system prompt, and duplicate content
- [ ] No hardcoded API keys, personal paths, or model-specific assumptions without fallback

## References

- [Token Budget Calculator](./references/token-budget-calculator.md)
- [Memory Architecture Patterns](./references/memory-architecture-patterns.md)
