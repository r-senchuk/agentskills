# Perplexity Best Practices

Grounded summary of recurring guidance from Perplexity docs.

## API and Auth
- Use `PERPLEXITY_API_KEY` via environment variable.
- Prefer official Perplexity SDK for native features and cleaner preset usage.
- OpenAI SDK compatibility is supported by setting base URL to `https://api.perplexity.ai/v1`.

## Query Design for Web-Search Models
- Be specific and contextual; include scope and timeframe.
- Avoid few-shot examples that can distract search intent.
- Keep requests focused; split unrelated questions.
- Add explicit fallback language: state when relevant information is not found.

## Search Controls
- Use built-in filters and search options to enforce behavior.
- Prefer API params over prompt-only requests for domain/language/recency control.
- Tune retrieval budget (`max_results`, `max_tokens`, `max_tokens_per_page`) to balance quality and speed.

## Source Integrity
- Use `search_results` and `citations` as canonical source metadata.
- Do not rely on model-generated links in free-form output.
- For structured outputs, still attach sources from metadata fields, not JSON text links.

## Streaming and UX
- Streaming improves perceived latency and interaction quality.
- For use cases where source lists are needed immediately, non-streaming may simplify rendering.
- Handle network/rate-limit/API-status errors explicitly.

## Hallucination Risk Controls
- Watch for inaccessible-source requests (private/paywalled/closed data).
- Require explicit uncertainty when evidence is missing.
- For critical decisions, run follow-up verification queries with tighter constraints.

## Relevant Docs
- https://docs.perplexity.ai/docs/getting-started/quickstart
- https://docs.perplexity.ai/api-reference/chat-completions-post
- https://docs.perplexity.ai/docs/agent-api/prompt-guide
- https://docs.perplexity.ai/docs/agent-api/openai-compatibility
- https://docs.perplexity.ai/docs/search/quickstart
- https://docs.perplexity.ai/docs/agent-api/output-control/streaming-responses
