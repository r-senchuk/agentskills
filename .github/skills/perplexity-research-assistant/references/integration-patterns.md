# Integration Patterns

## Pattern A: Perplexity SDK (recommended)

```python
from perplexity import Perplexity

client = Perplexity()

response = client.responses.create(
    preset="pro-search",
    input="What changed in Python packaging best practices in the last 12 months?",
)

print(response.output_text)
```

Use when:
- You want direct Perplexity features and cleaner preset usage.

## Pattern B: OpenAI SDK Compatibility

```python
import os
from openai import OpenAI

client = OpenAI(
    api_key=os.environ.get("PERPLEXITY_API_KEY"),
    base_url="https://api.perplexity.ai/v1",
)

response = client.responses.create(
    model="openai/gpt-5.4",
    input="Compare REST and GraphQL for internal platform APIs.",
)

print(response.output_text)
```

Use when:
- Existing codebase already standardizes on OpenAI SDK clients.

## Pattern C: Sonar Chat Completions with Search Controls

```bash
curl --request POST \
  --url https://api.perplexity.ai/v1/sonar \
  --header "Authorization: Bearer $PERPLEXITY_API_KEY" \
  --header "Content-Type: application/json" \
  --data '{
    "model": "sonar-pro",
    "messages": [{"role":"user","content":"Latest SOC2 changes in 2026"}],
    "search_domain_filter": ["aicpa.org"],
    "search_recency_filter": "year"
  }'
```

Use when:
- You need explicit low-level control over request fields.

## Pattern D: Search API for Retrieval-First Pipelines

```python
from perplexity import Perplexity

client = Perplexity()
search = client.search.create(
    query="zero-downtime postgres migration",
    max_results=8,
    max_tokens_per_page=2048,
)

for r in search.results:
    print(r.title, r.url)
```

Use when:
- You need raw ranked results and custom post-processing.

## External Skill Baselines Reviewed
- `xpepper/perplexity-agent-skill`: practical model-selection and query-refinement patterns for agentic research workflows.
- `nyldn/claude-octopus`: optional Perplexity provider usage inside multi-agent research orchestration.

Adopted ideas:
- Start-simple model strategy, then upgrade depth only if needed.
- Explicit "when NOT to use" to prevent unnecessary external calls.
- Iterative query refinement with a quality gate on evidence.
