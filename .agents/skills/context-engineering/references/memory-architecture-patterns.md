# Memory Architecture Patterns

Catalog of memory patterns for LLM-powered agents — from simple buffers to production hybrid architectures. Each pattern includes implementation code, trade-offs, and selection criteria.

## Decision Matrix

| Pattern | Turn Limit | Recall Quality | Token Cost | Latency | Complexity | Best For |
|---------|-----------|---------------|------------|---------|------------|----------|
| **Buffer** | ~20 turns | Perfect (verbatim) | Grows unbounded | None | Trivial | Short conversations, prototyping |
| **Sliding Window** | Unlimited | Perfect for recent, none for old | Fixed ceiling | None | Low | Chatbots with recency bias |
| **Summary** | Unlimited | Lossy (gist only) | Fixed ceiling | +200–800ms per compaction | Medium | Long conversations where exact recall isn't critical |
| **Entity** | Unlimited | High for tracked entities | Very low | +100–300ms per extraction | Medium | CRM, customer support, any entity-centric domain |
| **Vector Store** | Unlimited | High for semantically relevant | Low per turn | +50–200ms for embedding + search | High | Very long history, sparse recall needs |
| **Hybrid** | Unlimited | High across all recall types | Tunable | Variable | High | Production agents |

## Pattern 1 — Conversation Buffer

Keep all turns verbatim. Simplest pattern. Works until you hit the context window.

```python
class BufferMemory:
    """Keep all conversation turns in memory. No compression."""

    def __init__(self):
        self.turns: list[dict] = []

    def add(self, role: str, content: str):
        self.turns.append({"role": role, "content": content})

    def get_messages(self) -> list[dict]:
        return list(self.turns)

    def token_count(self, model: str = "gpt-4o") -> int:
        return count_messages_tokens(self.turns, model)

    def clear(self):
        self.turns.clear()
```

**When to use**: Prototyping, testing, conversations guaranteed under ~20 turns.
**When to stop**: When `token_count()` approaches 50% of your history budget.

## Pattern 2 — Sliding Window

Keep the last N turns. Drop older turns entirely. Zero overhead.

```python
class SlidingWindowMemory:
    """Keep the last `window_size` turns. Older turns are dropped."""

    def __init__(self, window_size: int = 20):
        self.turns: list[dict] = []
        self.window_size = window_size

    def add(self, role: str, content: str):
        self.turns.append({"role": role, "content": content})
        # Always keep turns in pairs (user + assistant) to avoid orphaned messages
        if len(self.turns) > self.window_size * 2:
            self.turns = self.turns[-self.window_size * 2:]

    def get_messages(self) -> list[dict]:
        return list(self.turns)
```

**When to use**: Chat interfaces where only recent context matters.
**Limitation**: Complete amnesia for anything outside the window. No graceful degradation.

## Pattern 3 — Summary Memory

Compress older turns into a running summary. Recent turns stay verbatim.

```python
class SummaryMemory:
    """Summarize old turns, keep recent turns verbatim."""

    def __init__(
        self,
        client,
        window_size: int = 10,
        summary_model: str = "gpt-4o-mini",
        max_summary_tokens: int = 500,
    ):
        self.client = client
        self.turns: list[dict] = []
        self.summary: str = ""
        self.window_size = window_size
        self.summary_model = summary_model
        self.max_summary_tokens = max_summary_tokens

    def add(self, role: str, content: str):
        self.turns.append({"role": role, "content": content})
        if len(self.turns) > self.window_size * 2:
            self._compact()

    def _compact(self):
        """Move oldest turns into the running summary."""
        # Take the oldest half
        midpoint = len(self.turns) // 2
        to_summarize = self.turns[:midpoint]
        self.turns = self.turns[midpoint:]

        # Format old turns as text
        old_text = "\n".join(
            f"{t['role'].upper()}: {t['content']}" for t in to_summarize
        )

        # Build summarization prompt
        prompt = (
            "You are a conversation summarizer. Produce a concise factual summary "
            "that preserves:\n"
            "- All decisions made and commitments given\n"
            "- Key facts, numbers, names, and preferences stated\n"
            "- The current state of any ongoing task\n"
            "- Any corrections or clarifications the user made\n\n"
            "Drop greetings, filler, and redundant exchanges.\n\n"
        )
        if self.summary:
            prompt += f"EXISTING SUMMARY:\n{self.summary}\n\n"
        prompt += f"NEW TURNS TO INCORPORATE:\n{old_text}"

        resp = self.client.chat.complete(
            model=self.summary_model,
            messages=[{"role": "user", "content": prompt}],
            temperature=0,
            max_tokens=self.max_summary_tokens,
        )
        self.summary = resp.choices[0].message.content

    def get_messages(self) -> list[dict]:
        messages = []
        if self.summary:
            messages.append({
                "role": "system",
                "content": f"[Conversation summary]\n{self.summary}",
            })
        messages.extend(self.turns)
        return messages
```

**When to use**: Conversations that run 20–100+ turns where you need gist recall.
**Trade-off**: Each compaction costs one LLM call (~$0.001 with gpt-4o-mini). Summary is lossy — exact quotes and numbers may be paraphrased.
**Tip**: Use a cheap, fast model for summarization (gpt-4o-mini, Mistral Small). Never use the primary model.

## Pattern 4 — Entity Memory

Extract and maintain a structured record of key entities mentioned in conversation. Complements other patterns.

```python
import json

class EntityMemory:
    """Extract and maintain key entities from conversation."""

    def __init__(self, client, model: str = "gpt-4o-mini"):
        self.client = client
        self.model = model
        self.entities: dict[str, dict] = {}
        # Example: {"Project Alpha": {"status": "in progress", "deadline": "2025-03-01", "owner": "Alice"}}

    def extract_and_update(self, role: str, content: str):
        """Extract entities from a new turn and merge into memory."""
        prompt = (
            "Extract key entities and their attributes from this message. "
            "Return a JSON object where keys are entity names and values are "
            "objects with their known attributes. Only include entities with "
            "concrete facts (names, dates, numbers, statuses). "
            "Return {} if no entities found.\n\n"
            f"EXISTING ENTITIES:\n{json.dumps(self.entities, indent=2)}\n\n"
            f"NEW MESSAGE ({role}):\n{content}"
        )
        resp = self.client.chat.complete(
            model=self.model,
            messages=[{"role": "user", "content": prompt}],
            temperature=0,
            response_format={"type": "json_object"},
        )
        try:
            new_entities = json.loads(resp.choices[0].message.content)
            # Deep merge: update existing entities, add new ones
            for name, attrs in new_entities.items():
                if name in self.entities:
                    self.entities[name].update(attrs)
                else:
                    self.entities[name] = attrs
        except (json.JSONDecodeError, AttributeError):
            pass  # Extraction failed — skip silently

    def get_context_block(self) -> str:
        """Format entities as a context injection string."""
        if not self.entities:
            return ""
        lines = ["[Known entities from this conversation]"]
        for name, attrs in self.entities.items():
            attr_str = ", ".join(f"{k}: {v}" for k, v in attrs.items())
            lines.append(f"- {name} — {attr_str}")
        return "\n".join(lines)
```

**When to use**: Customer support (track customer details), project management (track tasks/milestones), any domain with recurring named entities.
**Token cost**: Very low — entity store is typically 100–500 tokens regardless of conversation length.
**Combine with**: Summary or Sliding Window (entities fill the "what" gap that summaries miss).

## Pattern 5 — Vector Store Memory

Embed each turn and retrieve semantically relevant past turns on demand.

```python
import numpy as np

class VectorStoreMemory:
    """Embed conversation turns and retrieve by semantic similarity."""

    def __init__(self, client, embed_model: str = "text-embedding-3-small"):
        self.client = client
        self.embed_model = embed_model
        self.turns: list[dict] = []       # all turns with metadata
        self.embeddings: list[list[float]] = []  # parallel array of embeddings

    def add(self, role: str, content: str, turn_index: int):
        self.turns.append({
            "role": role, "content": content, "turn_index": turn_index,
        })
        # Embed the content
        resp = self.client.embeddings.create(
            model=self.embed_model, input=content,
        )
        self.embeddings.append(resp.data[0].embedding)

    def retrieve(self, query: str, top_k: int = 5) -> list[dict]:
        """Retrieve the most semantically relevant past turns."""
        if not self.embeddings:
            return []
        # Embed the query
        query_resp = self.client.embeddings.create(
            model=self.embed_model, input=query,
        )
        query_vec = np.array(query_resp.data[0].embedding)
        stored_vecs = np.array(self.embeddings)

        # Cosine similarity
        similarities = np.dot(stored_vecs, query_vec) / (
            np.linalg.norm(stored_vecs, axis=1) * np.linalg.norm(query_vec)
        )
        top_indices = np.argsort(similarities)[-top_k:][::-1]

        return [
            {**self.turns[i], "similarity": float(similarities[i])}
            for i in top_indices
            if similarities[i] > 0.3  # relevance threshold
        ]

    def get_relevant_context(self, query: str, top_k: int = 5) -> str:
        """Format retrieved turns as a context string."""
        results = self.retrieve(query, top_k)
        if not results:
            return ""
        lines = ["[Relevant past conversation turns]"]
        for r in results:
            lines.append(
                f"- [Turn {r['turn_index']}, {r['role']}] {r['content'][:200]}"
            )
        return "\n".join(lines)
```

**When to use**: Conversations that span hundreds of turns. User asks "what did we decide about X last week?"
**Token cost**: Low per turn (only retrieved turns count). Embedding cost: ~$0.00002 per turn.
**Latency**: +50–200ms per turn (embedding + search).
**Limitation**: Requires embedding infrastructure. Not suitable for exact recall of recent context.

## Pattern 6 — Hybrid Memory (Production Pattern)

Combine multiple memory tiers for production-grade agents. This is the recommended pattern for any agent that handles more than ~20 turns.

```python
class HybridMemory:
    """Production memory combining window + summary + entity + vector retrieval."""

    def __init__(
        self,
        client,
        window_size: int = 10,
        summary_model: str = "gpt-4o-mini",
        embed_model: str = "text-embedding-3-small",
    ):
        self.window = SlidingWindowMemory(window_size=window_size)
        self.summary = SummaryMemory(
            client, window_size=window_size, summary_model=summary_model,
        )
        self.entities = EntityMemory(client, model=summary_model)
        self.vector_store = VectorStoreMemory(client, embed_model=embed_model)
        self.turn_counter = 0

    def add_turn(self, role: str, content: str):
        """Record a turn across all memory tiers."""
        self.window.add(role, content)
        self.summary.add(role, content)
        self.entities.extract_and_update(role, content)
        self.vector_store.add(role, content, self.turn_counter)
        self.turn_counter += 1

    def get_context_blocks(self, current_query: str) -> list:
        """Assemble memory context from all tiers."""
        blocks = []

        # Tier 1: Summary of old conversation (if exists)
        summary_msgs = self.summary.get_messages()
        for msg in summary_msgs:
            if msg["role"] == "system" and "[Conversation summary]" in msg.get("content", ""):
                blocks.append(ContextBlock(
                    source="memory_summary",
                    role="system",
                    content=msg["content"],
                    priority=Priority.MEDIUM,
                ))

        # Tier 2: Entity facts
        entity_context = self.entities.get_context_block()
        if entity_context:
            blocks.append(ContextBlock(
                source="entity_memory",
                role="system",
                content=entity_context,
                priority=Priority.HIGH,
            ))

        # Tier 3: Semantically retrieved old turns (not in current window)
        relevant = self.vector_store.get_relevant_context(current_query, top_k=3)
        if relevant:
            blocks.append(ContextBlock(
                source="vector_recall",
                role="system",
                content=relevant,
                priority=Priority.MEDIUM,
            ))

        # Tier 4: Recent turns (sliding window — verbatim)
        for turn in self.window.get_messages():
            blocks.append(ContextBlock(
                source="recent_history",
                role=turn["role"],
                content=turn["content"],
                priority=Priority.LOW,
            ))

        return blocks
```

### Hybrid Memory — Data Flow

```
New turn arrives
    │
    ├──► Sliding Window (keeps last N verbatim)
    ├──► Summary Memory (compacts overflow into running summary)
    ├──► Entity Memory (extracts/updates named entities)
    └──► Vector Store (embeds for future semantic retrieval)

At assembly time:
    1. Summary block (gist of old conversation)    → Priority MEDIUM
    2. Entity block (key facts and attributes)      → Priority HIGH
    3. Vector recall (relevant old turns for query)  → Priority MEDIUM
    4. Recent window (last N turns verbatim)         → Priority LOW
    5. ─► Feed all into assemble_context() from SKILL.md Step 3
```

## Pattern 7 — Working Memory / Scratchpad

A mutable scratchpad the agent reads and writes between steps. Useful for multi-step reasoning tasks.

```python
class WorkingMemory:
    """Mutable scratchpad for intermediate agent reasoning."""

    def __init__(self, max_tokens: int = 1000):
        self.entries: dict[str, str] = {}
        self.max_tokens = max_tokens

    def write(self, key: str, value: str):
        """Write or update a named scratchpad entry."""
        self.entries[key] = value
        self._enforce_budget()

    def read(self, key: str) -> str | None:
        return self.entries.get(key)

    def delete(self, key: str):
        self.entries.pop(key, None)

    def _enforce_budget(self):
        """Drop oldest entries if over token budget."""
        while self._total_tokens() > self.max_tokens and self.entries:
            oldest_key = next(iter(self.entries))
            del self.entries[oldest_key]

    def _total_tokens(self) -> int:
        text = "\n".join(f"{k}: {v}" for k, v in self.entries.items())
        return count_tokens(text)

    def get_context_block(self) -> ContextBlock | None:
        if not self.entries:
            return None
        text = "[Agent working memory]\n" + "\n".join(
            f"- {k}: {v}" for k, v in self.entries.items()
        )
        return ContextBlock(
            source="working_memory",
            role="system",
            content=text,
            priority=Priority.MEDIUM,
        )
```

**When to use**: Multi-step agent tasks (research → plan → execute → verify). The agent writes intermediate results to the scratchpad and reads them in later steps.
**Example entries**: `"plan": "1. Search docs 2. Extract prices 3. Compare"`, `"search_results_summary": "Found 3 relevant products..."`, `"current_step": "3 of 4"`.

## Choosing the Right Pattern

```
How many turns per conversation?
│
├── < 20 turns ─────────────► Buffer Memory (Pattern 1)
│
├── 20–100 turns
│   ├── Need exact recent recall? ──► Sliding Window (Pattern 2)
│   └── Need gist of everything? ───► Summary Memory (Pattern 3)
│
├── 100+ turns
│   ├── Entity-centric domain? ─────► Entity + Window (Patterns 4+2)
│   ├── Sparse recall ("what did we say about X?") ──► Vector Store (Pattern 5)
│   └── Production agent? ──────────► Hybrid (Pattern 6)
│
└── Multi-step reasoning task? ─────► Add Working Memory (Pattern 7) to any above
```

## Memory Anti-Patterns

| Anti-Pattern | Symptom | Fix |
|-------------|---------|-----|
| **Unbounded buffer** | Context overflow at turn ~30–50 | Switch to sliding window or summary |
| **Summarize too aggressively** | Agent loses critical details (numbers, names) | Combine with entity memory to preserve facts |
| **Summarize too frequently** | High latency, high cost from constant LLM calls | Batch summarization (every 10 turns, not every turn) |
| **Vector-only memory** | Agent has no awareness of recent turns | Always combine vector with a sliding window |
| **Same model for summary + main task** | Expensive, slow | Use cheap model (gpt-4o-mini) for summarization |
| **No relevance threshold on vector recall** | Irrelevant old turns injected as noise | Set similarity threshold (e.g., >0.3) |
| **Orphaned messages** | Window cuts mid-exchange (keeps assistant reply, drops user question) | Always keep user+assistant pairs together |
