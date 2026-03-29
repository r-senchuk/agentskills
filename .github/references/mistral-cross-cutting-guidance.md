# Mistral Cross-Cutting Guidance

Shared policy for all Mistral skills in this repository. Keep model, security, retry, and cost guidance centralized here to reduce drift.

## API Key Security
- Use `MISTRAL_API_KEY` from environment variables.
- Never hardcode or commit credentials.
- For Vibe CLI, prefer `~/.vibe/.env` when environment export is not practical.

## Model Selection Quick Guide
- Complex orchestration and deep reasoning: `mistral-large-latest`
- Code-heavy tasks: `devstral-latest` or `codestral-latest`
- Fast and cost-sensitive extraction/classification: `mistral-small-latest` or `ministral-8b-latest`
- OCR: `mistral-ocr-latest`
- Text embeddings: `mistral-embed`
- Code embeddings: `codestral-embed`
- Step-by-step reasoning: `magistral-medium-latest`

## Retry and Error Handling
Use bounded retries with exponential backoff for transient failures.

```python
import time
from mistralai import APIError, RateLimitError

def call_with_retry(fn, *args, max_retries=3, **kwargs):
    for attempt in range(max_retries):
        try:
            return fn(*args, **kwargs)
        except RateLimitError:
            time.sleep(2 ** attempt)
        except APIError as e:
            if getattr(e, "status_code", 0) >= 500:
                time.sleep(2 ** attempt)
            else:
                raise
    raise RuntimeError(f"Failed after {max_retries} retries")
```

## Context and Token Budgeting
- Keep retrieved or extracted content within model context limits.
- Prefer chunking and staged summarization when source data is large.
- Validate that prompts reserve enough output tokens for completion.

## Cost Controls
- Use smaller models for routing, extraction, and straightforward transforms.
- Reserve larger models for reasoning-heavy paths.
- Prefer batch APIs for large multi-item jobs.
