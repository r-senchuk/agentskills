# Built-In Tool Reference

## web_search / web_search_premium
- Triggers on: questions requiring current information, news, live data.
- Returns: web search results with citations.
- Use `web_search_premium` for higher-quality, more comprehensive results.

```python
tools=[{"type": "web_search"}]
# or
tools=[{"type": "web_search_premium"}]
```

## code_interpreter
- Triggers on: numerical computation, data analysis, charting, file manipulation.
- Runs Python in a sandboxed environment.
- Can generate and return files (plots, CSVs).

```python
tools=[{"type": "code_interpreter"}]
```

## image_generation
- Triggers on: requests to create, draw, or visualize images.
- Returns: generated image URL or base64.

```python
tools=[{"type": "image_generation"}]
```

## document_library
- Triggers on: questions answerable from a pre-uploaded document corpus.
- Acts as a built-in RAG tool — no vector store management needed.
- Upload documents via the Files API first, then reference file IDs in the tool config.

```python
tools=[{
    "type": "document_library",
    "document_library": {
        "file_ids": ["file-abc123", "file-def456"]
    }
}]
```

## Combining Tools
You can combine any built-in tools with function tools:

```python
tools=[
    {"type": "web_search"},
    {"type": "code_interpreter"},
    {
        "type": "function",
        "function": {
            "name": "get_portfolio_value",
            "description": "Returns current portfolio value from internal database.",
            "parameters": {
                "type": "object",
                "properties": {"account_id": {"type": "string"}},
                "required": ["account_id"]
            }
        }
    }
]
```
