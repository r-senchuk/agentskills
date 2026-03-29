---
name: perplexity-research-assistant
description: "Use when you want Perplexity-powered web research for up-to-date facts, source-grounded answers, and second-opinion validation before implementation decisions. Do NOT use for questions answerable from the model's training data alone or for pure code generation tasks."
argument-hint: "Research question, desired freshness window, preferred sources/domains, output format, and whether you need quick lookup or deep analysis"
user-invocable: false
---

# Perplexity Research Assistant

Structured workflow for using Perplexity APIs as a research copilot: choose the right API surface, craft high-signal queries, enforce source reliability, and return decision-ready findings.

## When To Use
- You need current or external information that may be newer than model training data.
- You want source-grounded research before technical or product decisions.
- You need a second-opinion analysis with explicit citations and confidence boundaries.
- You need search controls (domain, language, recency) that should be enforced via API parameters.

Do NOT use for:
- Questions fully answerable from the model's existing training data (no freshness or citation requirement).
- Pure code generation, debugging, or refactoring tasks.
- Internal codebase lookups — use semantic search tools instead.
- Cases where external network calls are prohibited or unavailable.

## Inputs To Collect First
1. Research objective: the exact decision or question to answer.
2. Freshness and scope: time window, geography, and depth required.
3. Source constraints: required domains, blocked domains, language requirements.
4. Output contract: bullets, table, comparison matrix, or structured JSON.
5. Risk tolerance: quick directional answer or high-confidence evidence pack.

## Procedure
1. Select API mode and effort level.
2. Design the query for search-first behavior.
3. Execute with built-in search parameters.
4. Validate sources and hallucination boundaries.
5. Synthesize findings for downstream decisions.

## Step 1 — Select API Mode and Effort Level
Pick API based on outcome:
- Agent API: best for synthesized, model-generated answers with optional tools and presets.
- Sonar chat completions: best when you want OpenAI-style chat completion flow and direct search controls.
- Search API: best for raw ranked results to process yourself.

Decision branch:
- If you need generated narrative plus grounding: use Agent API or Sonar.
- If you need raw retrieval and custom ranking pipeline: use Search API.
- If user already has OpenAI SDK wiring: use OpenAI compatibility mode with Perplexity base URL.

## Step 2 — Design the Query for Search-First Behavior
Write prompts like web searches, not like few-shot LLM tasks:
- Be specific, contextual, and time-bounded.
- Ask one focused topic per request.
- Prefer explicit constraints over vague intent.
- Avoid asking the model to print URLs in response text.

Query pattern:
- Topic + scope + timeframe + output format + fallback instruction.
- Example fallback instruction: if relevant information is not found, state that explicitly instead of guessing.

For reusable templates and anti-patterns, use [Query Playbook](./references/query-playbook.md).

## Step 3 — Execute With Built-In Search Parameters
Control retrieval through API parameters, not prompt-only instructions.

Key parameters:
- `search_domain_filter` — allowlist/denylist specific domains.
- `search_language_filter` — language-scoped retrieval.
- `search_recency_filter` — freshness control (e.g. `"month"`, `"year"`).
- `web_search_options.search_context_size` — retrieval depth where available.
- `max_results`, `max_tokens`, `max_tokens_per_page` (Search API) — retrieval budget.

Example using Sonar with domain and recency controls:

```bash
curl --request POST \
  --url https://api.perplexity.ai/v1/sonar \
  --header "Authorization: Bearer $PERPLEXITY_API_KEY" \
  --header "Content-Type: application/json" \
  --data '{
    "model": "sonar-pro",
    "messages": [{"role":"user","content":"<your query here>"}],
    "search_domain_filter": ["example.com"],
    "search_recency_filter": "month"
  }'
```

Implementation branch:
- Need rapid UX feedback: use streaming.
- Need immediate source list for UI: prefer non-streaming when source rendering is latency-critical.

For more patterns (SDK, OpenAI-compat, Search API), see [Integration Patterns](./references/integration-patterns.md).

## Step 4 — Validate Sources and Hallucination Boundaries
Source integrity rules:
- Treat `search_results` and/or `citations` fields as source-of-truth.
- Do not trust URLs generated only in free-form model text.
- Flag inaccessible-source requests (private/paywalled/closed contexts) as high hallucination risk.

Reliability checks:
- Confirm each key claim maps to at least one retrieved source.
- If data is missing or weak, return explicit uncertainty instead of speculative fill.
- For critical decisions, run at least one follow-up query with refined constraints.

## Step 5 — Synthesize Findings for Downstream Decisions
Return findings in a compact, auditable format:
1. Answer: concise conclusion.
2. Evidence: top sources with why each matters.
3. Confidence: high/medium/low with rationale.
4. Gaps: what is still unknown.
5. Next query: best follow-up question to reduce uncertainty.

For implementation examples and integration choices, see [Integration Patterns](./references/integration-patterns.md).

## Completion Checks
- [ ] API mode was chosen intentionally (Agent/Sonar/Search) based on required output.
- [ ] Search constraints are implemented via API parameters, not prompt-only instructions.
- [ ] Source links are taken from `search_results`/`citations` metadata fields, not generated text.
- [ ] Output explicitly separates confirmed findings from uncertainty and gaps.
- [ ] At least one refinement pass is done for high-stakes or ambiguous topics.
- [ ] Negative scope check: confirmed that a Perplexity call was actually needed (not a training-data question).

## References
- [Perplexity Best Practices](./references/perplexity-best-practices.md)
- [Query Playbook](./references/query-playbook.md)
- [Integration Patterns](./references/integration-patterns.md)
