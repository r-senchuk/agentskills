---
name: mistral-structured-outputs
description: "Use when you need Mistral models to return guaranteed JSON-conformant responses: define Pydantic or JSON schemas, use response_format to enforce structure, handle validation errors, and extract typed data from unstructured text. Do NOT use for plain text generation, conversational responses, or tasks where free-form output is acceptable."
argument-hint: "Target data shape (field names and types), model to use, and the text or prompt to extract from"
user-invocable: false
---

# Mistral Structured Outputs

Workflow for extracting guaranteed, schema-conformant JSON from Mistral models using structured output mode. Covers schema design, `response_format` usage, Pydantic integration, and validation error handling.

## When To Use
- You need to extract structured data from free-form text (receipts, emails, reports).
- Your downstream code requires a guaranteed JSON shape — no ad-hoc parsing.
- You are building pipelines where model output feeds directly into typed data structures.
- You want to avoid prompt-engineering JSON formatting and handle it at the API level.

Do NOT use for:
- Plain text generation or conversational tasks where no downstream schema consumption occurs.
- Streaming responses — `response_format` with schema enforcement requires non-streaming calls.
- Models that do not support structured output mode (check the Mistral model docs for compatibility).

## Inputs To Collect First
1. Target schema: field names, types, optional vs required, and nested structures.
2. Model: any Mistral model supporting structured outputs (see note below).
3. Input text or prompt: the content to extract data from.
4. Validation strategy: fail-fast on schema violation vs. retry with error feedback.

## Procedure
1. Define the schema.
2. Call the API with `response_format`.
3. Parse and validate the response.
4. Handle validation errors.

### Step 1 — Define the Schema

**Option A — Pydantic (recommended for Python)**

```python
from pydantic import BaseModel, Field
from typing import Optional, List

class LineItem(BaseModel):
    description: str
    quantity: int
    unit_price: float

class Invoice(BaseModel):
    vendor: str
    invoice_number: str
    date: str = Field(description="ISO 8601 date string, e.g. 2025-04-01")
    line_items: List[LineItem]
    total_amount: float
    currency: str = "USD"
    notes: Optional[str] = None
```

**Option B — Raw JSON Schema**

```python
schema = {
    "type": "object",
    "properties": {
        "vendor": {"type": "string"},
        "invoice_number": {"type": "string"},
        "total_amount": {"type": "number"},
        "line_items": {
            "type": "array",
            "items": {
                "type": "object",
                "properties": {
                    "description": {"type": "string"},
                    "quantity": {"type": "integer"},
                    "unit_price": {"type": "number"},
                },
                "required": ["description", "quantity", "unit_price"]
            }
        }
    },
    "required": ["vendor", "invoice_number", "total_amount", "line_items"]
}
```

Schema design rules:
- All fields that must be present go in `required`.
- Use `description` on ambiguous fields — the model uses them for alignment.
- Keep nesting shallow when possible; deep schemas increase error rates.
- Use `enum` for fields with a fixed set of values.

### Step 2 — Call the API With `response_format`

**Using Pydantic:**

```python
import os
from mistralai import Mistral

client = Mistral(api_key=os.environ["MISTRAL_API_KEY"])

raw_text = """
ACME Corp · Invoice #INV-0042 · 2025-03-15
2x Widget Pro @ $49.99 each
1x Shipping @ $9.99
Total: $109.97 USD
"""

response = client.chat.parse(
    model="mistral-large-latest",
    messages=[
        {"role": "system", "content": "Extract invoice data from the provided text."},
        {"role": "user", "content": raw_text},
    ],
    response_format=Invoice,  # pass Pydantic class directly
)

invoice: Invoice = response.choices[0].message.parsed
print(invoice.model_dump_json(indent=2))
```

**Using raw JSON schema:**

```python
response = client.chat.complete(
    model="mistral-large-latest",
    messages=[
        {"role": "system", "content": "Extract invoice data. Return valid JSON only."},
        {"role": "user", "content": raw_text},
    ],
    response_format={"type": "json_object"},
)

import json
data = json.loads(response.choices[0].message.content)
```

Note: `response_format={"type": "json_object"}` guarantees valid JSON but does NOT enforce a specific schema. Use Pydantic or `client.chat.parse()` for schema enforcement.

### Step 3 — Parse and Validate the Response

```python
from pydantic import ValidationError

def extract_invoice(text: str) -> Invoice | None:
    response = client.chat.parse(
        model="mistral-large-latest",
        messages=[
            {"role": "system", "content": "Extract invoice data from the provided text."},
            {"role": "user", "content": text},
        ],
        response_format=Invoice,
    )
    return response.choices[0].message.parsed
```

The `.parsed` attribute is `None` if parsing failed — always check before use.

### Step 4 — Handle Validation Errors

Retry with the validation error as feedback:

```python
def extract_with_retry(text: str, model: str = "mistral-large-latest", max_retries: int = 2) -> Invoice:
    messages = [
        {"role": "system", "content": "Extract invoice data. Return a valid JSON object matching the schema."},
        {"role": "user", "content": text},
    ]

    for attempt in range(max_retries + 1):
        response = client.chat.parse(
            model=model,
            messages=messages,
            response_format=Invoice,
        )
        result = response.choices[0].message.parsed
        if result is not None:
            return result

        # Feed the raw content back as an error for retry
        raw = response.choices[0].message.content
        messages.append({"role": "assistant", "content": raw})
        messages.append({
            "role": "user",
            "content": "The previous response did not match the required schema. Please try again and return valid JSON.",
        })

    raise ValueError(f"Failed to extract structured output after {max_retries + 1} attempts.")
```

## Completion Checks
- [ ] Schema has `description` on any ambiguous field.
- [ ] Required vs optional fields correctly reflect what the model might not find in source text.
- [ ] `.parsed` result checked for `None` before use downstream.
- [ ] Retry logic has a bounded attempt count (`max_retries`).
- [ ] Tested with: well-formed input (should extract cleanly), partial input (missing optional fields handled), and malformed input (retry or raise gracefully).

## References
- [Shared Mistral cross-cutting guidance](../../references/mistral-cross-cutting-guidance.md)
