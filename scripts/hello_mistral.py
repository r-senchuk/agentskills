"""
hello_mistral.py — Minimal connectivity check for the Mistral API.

Sends a single chat completion ("Say hello world") using mistral-small-latest
and prints the response to stdout.

Prerequisites:
    pip install mistralai
    export MISTRAL_API_KEY="your-key-here"
"""

import os
import sys
import time

# ── 1. Confirm the SDK is importable ─────────────────────────────────────────
try:
    from mistralai import Mistral
    from mistralai import SDKError
except ModuleNotFoundError:
    print("ERROR: 'mistralai' package is not installed.")
    print("Fix:   pip install mistralai")
    sys.exit(1)

# ── 2. Validate the API key ───────────────────────────────────────────────────
api_key = os.environ.get("MISTRAL_API_KEY")
if not api_key:
    print("ERROR: MISTRAL_API_KEY environment variable is not set.")
    print("Fix:   export MISTRAL_API_KEY='<your-api-key>'")
    sys.exit(1)

# ── 3. Retry helper (exponential back-off for rate limits and 5xx errors) ────
def call_with_retry(fn, *args, max_retries: int = 3, **kwargs):
    """Call fn(*args, **kwargs) with bounded exponential back-off."""
    for attempt in range(max_retries):
        try:
            return fn(*args, **kwargs)
        except SDKError as exc:
            status = getattr(exc, "status_code", None)
            if status == 429 or (status and status >= 500):
                wait = 2 ** attempt
                print(f"  [retry {attempt + 1}/{max_retries}] HTTP {status} — waiting {wait}s…")
                time.sleep(wait)
            else:
                raise
    raise RuntimeError(f"API call failed after {max_retries} retries.")

# ── 4. Send the chat completion ───────────────────────────────────────────────
def main() -> None:
    client = Mistral(api_key=api_key)

    print("Sending request to Mistral API (model: mistral-small-latest)…\n")

    try:
        response = call_with_retry(
            client.chat.complete,
            model="mistral-small-latest",
            messages=[{"role": "user", "content": "Say hello world"}],
        )
    except SDKError as exc:
        print(f"ERROR: Mistral API returned an error: {exc}")
        sys.exit(1)
    except Exception as exc:
        print(f"ERROR: Unexpected error while contacting Mistral: {exc}")
        sys.exit(1)

    # Guard against an empty response structure
    if not response.choices or response.choices[0].message is None:
        print("ERROR: Received an empty or malformed response from the API.")
        sys.exit(1)

    content = response.choices[0].message.content
    print("─" * 50)
    print("Mistral says:", content)
    print("─" * 50)
    print(
        f"\n✅ Connectivity check passed. "
        f"(model={response.model}, "
        f"usage={response.usage})"
    )

if __name__ == "__main__":
    main()
