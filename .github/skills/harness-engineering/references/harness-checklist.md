# Pre-Production Harness Checklist

Complete this checklist before deploying any AI agent system to production. Items are grouped by harness component. Every item must be explicitly verified — "N/A" is acceptable only with written justification.

## 1. Guardrails & Safety

### Input Layer
- [ ] Maximum input length enforced (chars and/or tokens)
- [ ] Prompt injection detection active with pattern matching or classifier
- [ ] Input sanitization strips or escapes control characters
- [ ] Rate limiting applied per user/session (requests per minute)
- [ ] Content policy violations detected before reaching the model

### Tool Layer
- [ ] Every tool classified by risk tier (read / write / delete / external)
- [ ] Tool allowlist enforced — agent cannot call tools not in its registry
- [ ] Argument validation runs before tool execution (type checks, range checks)
- [ ] Destructive tools (delete, send, post) require human approval gate
- [ ] Tool call frequency limited (max calls per step, max calls per session)
- [ ] No tool can access credentials directly — use environment variables or secret managers

### Output Layer
- [ ] PII detection active (SSN, credit card, email, phone — use regex or a dedicated library)
- [ ] Output length bounded (prevent runaway generation)
- [ ] Sensitive content filtering active for user-facing outputs
- [ ] Structured outputs validated against schema before delivery

### Scope Boundaries
- [ ] Agent's scope explicitly documented — what it CAN and CANNOT do
- [ ] Scope enforced in system prompt AND in harness code (defense-in-depth)
- [ ] Agent cannot modify its own instructions or system prompt
- [ ] Agent cannot access other agents' tools unless explicitly authorized via handoff

## 2. Feedback & Verification Loops

- [ ] Structured outputs pass Pydantic or JSON Schema validation before use
- [ ] Tool call results verified with assertion checks (expected keys, types, status codes)
- [ ] Critical user-facing outputs pass LLM-as-judge or human review
- [ ] Failed validations trigger retry with error feedback (not silent failure)
- [ ] Retry loop has bounded max attempts (recommended: 2–3)
- [ ] Validation failures are logged with full context for debugging

## 3. State & Persistence

- [ ] State scope defined for each data type (turn / session / persistent)
- [ ] Checkpointing enabled for multi-step agent workflows
- [ ] Checkpoint includes: messages, tool call history, current step, metadata
- [ ] Recovery tested: agent can resume from last checkpoint after crash
- [ ] Session state has a TTL — stale sessions expire automatically
- [ ] State storage is encrypted at rest for sensitive workloads
- [ ] Conversation history has a token window — old turns summarized or truncated

## 4. Observability

### Logging
- [ ] Every LLM call logged: model, input tokens, output tokens, latency, run_id
- [ ] Every tool call logged: tool name, args (redacted if sensitive), result summary, duration
- [ ] Every guardrail trigger logged: type (input/tool/output), reason, action taken
- [ ] Logs use structured format (JSON) with consistent field names
- [ ] Run ID propagated through all log entries for end-to-end tracing

### Cost Tracking
- [ ] Token usage tracked per request and per session
- [ ] Cost estimated using current model pricing table
- [ ] Budget ceiling enforced — request rejected if budget exceeded
- [ ] Pricing table reviewed and updated at least monthly
- [ ] Cost alerts configured for anomalous spend spikes

### Drift Detection
- [ ] Baseline agent behavior recorded (success rate, avg tokens, avg latency)
- [ ] Weekly or daily comparison against baseline
- [ ] Alert threshold defined for significant drift (e.g., >20% change in success rate)
- [ ] Model version pinned — do NOT use `latest` aliases in production

## 5. Orchestration

### Retry & Backoff
- [ ] All LLM API calls wrapped in retry with exponential backoff + jitter
- [ ] Rate limit errors (429) always retried
- [ ] Server errors (5xx) retried; client errors (4xx) fail fast
- [ ] Maximum retry count bounded (recommended: 3)
- [ ] Retry budget does not exceed token budget for the request

### Fallback Chain
- [ ] At least one fallback model configured (e.g., GPT-4o → GPT-4o-mini)
- [ ] Fallback triggered on timeout, server error, or budget constraints
- [ ] Fallback behavior documented — what degrades when using cheaper model
- [ ] Fallback events logged for later analysis

### Circuit Breaker
- [ ] Circuit breaker active on tools with external dependencies (APIs, databases)
- [ ] Failure threshold defined (recommended: 3 consecutive failures to open circuit)
- [ ] Reset timeout defined (recommended: 60 seconds)
- [ ] Open circuit returns structured error to agent (not exception)

### Multi-Agent Topology
- [ ] Agent roles documented — one primary responsibility per agent
- [ ] Handoff rules explicit — which agent can delegate to which
- [ ] Handoff topology is acyclic unless loop has explicit termination condition
- [ ] Orchestrator has a maximum step/handoff limit to prevent infinite delegation
- [ ] Each agent's tools are scoped to its role (no shared tool registries)

## 6. Reproducibility

- [ ] Model version pinned (e.g., `gpt-4o-2024-08-06`, not `gpt-4o`)
- [ ] Temperature and seed set for deterministic workflows where appropriate
- [ ] All inputs and outputs logged for replay capability
- [ ] Agent configuration (system prompt, tools, parameters) stored in version control
- [ ] Environment dependencies pinned (Python version, library versions)
- [ ] Snapshot tests exist for critical agent behaviors (input → expected output pattern)

## 7. Error Recovery

- [ ] Escalation policy defined: what triggers human involvement
- [ ] Confidence threshold set — below X%, escalate to human
- [ ] Destructive actions require explicit human approval
- [ ] Async approval workflow available for non-blocking escalation
- [ ] Graceful degradation path documented — what the system does when the agent fails completely
- [ ] Dead letter queue or error log captures unrecoverable failures for manual review
- [ ] Rollback procedure documented for agent-initiated changes that need reversal

## How To Use This Checklist

1. Copy this file into your project or reference it from your harness code review template.
2. For each item, mark `[x]` when verified, or `[N/A]` with a justification comment.
3. Items marked `[ ]` (unchecked) are blockers for production deployment.
4. Re-run this checklist after any significant change to agent configuration, tools, or models.
5. Keep a dated copy of completed checklists for audit trail purposes.
