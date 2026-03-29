# Agent Topology Patterns

## Single Specialist Agent
One agent, one domain. Simplest pattern — use when the task is well-scoped.

```
User → Agent (websearch) → Response
```

## Orchestrator + Specialists
One routing agent delegates to specialist agents via handoffs.

```
User → Orchestrator → search-agent
                    → calc-agent
                    → code-agent
```

Create specialists first, then create the orchestrator with `handoffs=[specialist_id_1, ...]`.

## Sequential Pipeline
Agent A's output becomes Agent B's input. Use `handoff_execution="server"` for automatic chaining.

```
User → ingestion-agent → analysis-agent → report-agent → Response
```

## Parallel Research (Client-Side Handoff)
Use `handoff_execution="client"` to receive handoff events and dispatch to multiple agents simultaneously.

```
User → orchestrator
         ↓ handoff event (client handles)
         ├── research-agent-A
         └── research-agent-B
         ↓ merge results
       final-agent → Response
```

## Decision Rules
- Use `server` handoffs for linear workflows (simpler, less code).
- Use `client` handoffs when you need parallelism or custom routing logic.
- Keep specialist agents narrow — one domain per agent reduces prompt conflicts.
- Avoid cycles unless you are explicitly building a loop with a termination condition.
