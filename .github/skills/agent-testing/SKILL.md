---
name: agent-testing
description: "Use when adding tests to an AI agent: mocked unit tests, integration tests with real LLMs, snapshot regression tests, eval frameworks (promptfoo, DeepEval, Braintrust), tool-call verification, multi-agent handoff testing, and cost-aware CI configuration. Do not use for testing non-agent applications, general pytest guidance, or production monitoring/observability."
argument-hint: "Agent framework (LangChain, CrewAI, OpenAI Agents SDK, Mistral, custom), test goal (unit|integration|eval|snapshot|full-suite), existing test infrastructure if any."
user-invocable: true
---

# Agent Testing

Step-by-step procedure for building a comprehensive test suite for AI agents — from free deterministic unit tests through expensive nightly evals. Framework-agnostic: works with any Python agent using OpenAI, Anthropic, Mistral, LangChain, CrewAI, or custom loops.

## When To Use

- Adding the first test suite to an agent project that has no tests.
- Extending existing tests with a new tier (e.g., adding eval framework to a project that only has unit tests).
- Setting up CI that separates free/fast tests from expensive LLM-calling tests.
- Verifying an agent calls the right tools with the right arguments after refactoring.
- Detecting regressions in agent output quality after prompt or model changes.
- Evaluating agent quality at scale with metrics (faithfulness, tool correctness, task completion).
- Testing multi-agent handoffs, routing, and orchestration logic.

Do NOT use for:
- Testing non-agent applications (standard web apps, CLIs, libraries) — use standard pytest patterns.
- General pytest tutorials — the model handles those by default.
- Production monitoring, alerting, or observability — that is a separate domain.
- Load testing or performance benchmarking of LLM APIs.

## Inputs To Collect First

1. **Agent framework**: OpenAI Agents SDK, LangChain, CrewAI, Mistral SDK, or custom loop.
2. **LLM providers used**: OpenAI, Anthropic, Mistral, local models — determines mock structure.
3. **Tools the agent can call**: list of function names and their schemas.
4. **Test goal**: `unit` (mocked, free), `integration` (real API, cheap model), `eval` (quality metrics), `snapshot` (regression), or `full-suite` (all tiers).
5. **Existing infrastructure**: any existing `conftest.py`, test directories, CI pipelines.
6. **Budget sensitivity**: whether nightly eval runs are acceptable or all tests must be free.

## Procedure

### Step 1 — Design the Test Pyramid

Agent test suites follow a three-tier pyramid. Define which tiers you need before writing any code:

| Tier | What It Tests | LLM Calls | Cost | Run Frequency |
|---|---|---|---|---|
| **Unit** | Tool schemas, argument parsing, routing logic, mock agent loops | None — fully mocked | Free | Every commit |
| **Integration** | Full agent loop with a real but cheap model (`gpt-4.1-mini`) | Real, cheap model | ~$0.01/test | Every PR |
| **Eval** | Output quality at scale — accuracy, faithfulness, tool correctness | Real, production model | ~$0.10–1.00/test | Nightly or weekly |

**Decision**: If budget is zero, implement Unit only. If budget allows cheap CI, add Integration. Add Eval tier when you need quality metrics for prompt/model changes.

### Step 2 — Set Up Test Infrastructure

Create the directory structure and shared configuration:

```
tests/
├── conftest.py          # Shared fixtures, markers, mock factories
├── unit/
│   ├── test_tools.py    # Tool schema and invocation tests
│   ├── test_routing.py  # Agent routing / handoff logic
│   └── test_agent.py    # Mocked agent loop tests
├── integration/
│   └── test_agent_e2e.py
├── eval/
│   ├── test_quality.py  # DeepEval or custom metrics
│   └── promptfoo.yaml   # promptfoo eval config
├── snapshots/           # Stored known-good outputs
└── cassettes/           # VCR.py recorded API responses
```

Install dependencies:

```bash
pip install pytest pytest-asyncio pytest-recording syrupy deepeval
# Optional: pip install promptfoo vcrpy braintrust
```

Configure markers in `conftest.py`:

```python
import pytest

def pytest_configure(config):
    config.addinivalue_line("markers", "unit: no LLM calls, fully mocked")
    config.addinivalue_line("markers", "integration: real API calls with cheap model")
    config.addinivalue_line("markers", "eval: expensive quality evaluation")
```

Add `pyproject.toml` test config:

```toml
[tool.pytest.ini_options]
asyncio_mode = "auto"
markers = [
    "unit: no LLM calls, fully mocked",
    "integration: real API calls with cheap model",
    "eval: expensive quality evaluation",
]
```

### Step 3 — Write Unit Tests with Mocked LLMs

Unit tests must be **deterministic** — zero LLM calls. Two patterns:

**Pattern A — Mock the SDK client directly** (works with any framework):

```python
import json
import pytest
from unittest.mock import AsyncMock, MagicMock

@pytest.fixture
def mock_openai_response():
    """Factory for OpenAI chat completion responses."""
    def _make(content: str = "Hello", tool_calls=None, finish_reason="stop"):
        return MagicMock(
            choices=[MagicMock(
                message=MagicMock(content=content, tool_calls=tool_calls),
                finish_reason=finish_reason,
            )],
            usage=MagicMock(prompt_tokens=10, completion_tokens=20, total_tokens=30),
        )
    return _make

@pytest.fixture
def mock_openai_client(mock_openai_response):
    """Mock OpenAI client that returns a canned response."""
    client = MagicMock()
    client.chat.completions.create = AsyncMock(
        return_value=mock_openai_response("Mocked agent answer")
    )
    return client

@pytest.mark.unit
@pytest.mark.asyncio
async def test_agent_returns_answer(mock_openai_client):
    from myagent import Agent
    agent = Agent(client=mock_openai_client)
    result = await agent.run("What is Python?")
    assert result == "Mocked agent answer"
    mock_openai_client.chat.completions.create.assert_called_once()
```

**Pattern B — FakeModel (for SDKs that support model injection)**:

Queue deterministic outputs that pop FIFO on each model call — zero LLM traffic, full control over multi-turn flows. See `./references/mock-patterns.md` for the complete `FakeModel` class, Anthropic/Mistral mocks, VCR.py recording, and HTTP-level interception.

### Step 4 — Test Tool Calls and Arguments

Verify your agent calls the right tools with the right arguments — without calling the LLM:

**4a — Test tool schemas in isolation:**

```python
import jsonschema

WEATHER_SCHEMA = {
    "type": "object",
    "properties": {
        "location": {"type": "string"},
        "unit": {"type": "string", "enum": ["celsius", "fahrenheit"]},
    },
    "required": ["location"],
}

@pytest.mark.unit
def test_tool_schema_validates_good_args():
    jsonschema.validate({"location": "Boston", "unit": "fahrenheit"}, WEATHER_SCHEMA)

@pytest.mark.unit
def test_tool_schema_rejects_missing_required():
    with pytest.raises(jsonschema.ValidationError):
        jsonschema.validate({"unit": "celsius"}, WEATHER_SCHEMA)
```

**4b — Test that the agent selects the correct tool:**

```python
@pytest.fixture
def mock_tool_call_response(mock_openai_response):
    """Response where the model calls get_weather."""
    return mock_openai_response(
        content=None,
        finish_reason="tool_calls",
        tool_calls=[MagicMock(
            id="call_abc123",
            type="function",
            function=MagicMock(
                name="get_weather",
                arguments='{"location": "Boston, MA"}',
            ),
        )],
    )

@pytest.mark.unit
@pytest.mark.asyncio
async def test_agent_selects_weather_tool(mock_openai_client, mock_tool_call_response):
    mock_openai_client.chat.completions.create = AsyncMock(
        return_value=mock_tool_call_response
    )
    agent = Agent(client=mock_openai_client)
    result = await agent.step("What's the weather in Boston?")

    tool_call = result.tool_calls[0]
    assert tool_call.function.name == "get_weather"
    args = json.loads(tool_call.function.arguments)
    assert args["location"] == "Boston, MA"
```

**4c — Test tool execution directly (no LLM):**

```python
@pytest.mark.unit
@pytest.mark.asyncio
async def test_tool_execution():
    """Test the tool function itself, separate from the LLM."""
    result = await get_weather(location="Boston, MA", unit="fahrenheit")
    assert "temperature" in result
    assert result["unit"] == "fahrenheit"
```

### Step 5 — Add Snapshot and Regression Tests

Capture known-good agent outputs and detect regressions:

**5a — syrupy snapshots** (recommended for structured outputs):

```python
import pytest

@pytest.mark.unit
def test_agent_output_snapshot(snapshot, mock_openai_client):
    agent = Agent(client=mock_openai_client)
    result = agent.run_sync("Summarize our refund policy")
    # First run creates snapshot; subsequent runs compare
    assert result == snapshot
```

Run `pytest --snapshot-update` to accept new baselines after intentional changes.

**5b — VCR.py cassettes** (record real API calls, replay for free):

```python
import pytest

@pytest.fixture(scope="module")
def vcr_config():
    return {
        "filter_headers": ["authorization", "x-api-key"],
        "record_mode": "once",  # record first time, replay after
    }

@pytest.mark.vcr  # requires pytest-recording
@pytest.mark.integration
def test_agent_weather_query():
    """First run records HTTP traffic to cassettes/. Subsequent runs replay."""
    agent = Agent()  # real client
    result = agent.run_sync("What's the weather in Boston?")
    assert "Boston" in result
```

Re-record after API changes: delete the cassette YAML file and re-run the test.

### Step 6 — Set Up an Eval Framework

Choose one eval framework based on your needs. See `./references/eval-framework-comparison.md` for a full comparison.

**6a — promptfoo** (YAML-first, CI-friendly, multi-provider):

Create `tests/eval/promptfoo.yaml`:

```yaml
description: "Agent quality evaluation"
providers:
  - id: openai:gpt-4.1-mini
    config:
      tools:
        - type: function
          function:
            name: get_weather
            description: Get weather for a location
            parameters:
              type: object
              properties:
                location: { type: string }
              required: [location]

prompts:
  - "You are a helpful assistant. Answer: {{query}}"

tests:
  - vars: { query: "What's the weather in Boston?" }
    assert:
      - type: is-valid-openai-tools-call
      - type: javascript
        value: "output[0].function.name === 'get_weather'"
      - type: javascript
        value: "JSON.parse(output[0].function.arguments).location.includes('Boston')"

  - vars: { query: "Tell me a joke" }
    assert:
      - type: finish-reason
        value: stop
      - type: contains
        value: ""
      - type: llm-rubric
        value: "Response should be a clean, family-friendly joke."

  - vars: { query: "What's our refund policy?" }
    assert:
      - type: similar
        value: "We offer a 30-day full refund at no extra cost."
        threshold: 0.8
```

Run: `npx promptfoo eval -c tests/eval/promptfoo.yaml`

**6b — DeepEval** (Python-native, rich agentic metrics):

```python
import pytest
from deepeval import assert_test
from deepeval.metrics import ToolCorrectnessMetric, GEval
from deepeval.test_case import LLMTestCase, LLMTestCaseParams, ToolCall

@pytest.mark.eval
def test_tool_correctness():
    metric = ToolCorrectnessMetric()
    test_case = LLMTestCase(
        input="What's the weather in Boston?",
        actual_output="It's 72°F in Boston.",
        tools_called=[ToolCall(name="get_weather")],
        expected_tools=[ToolCall(name="get_weather")],
    )
    assert_test(test_case, [metric])

@pytest.mark.eval
def test_custom_quality():
    metric = GEval(
        name="Helpfulness",
        criteria="Rate whether the response fully addresses the user's question.",
        evaluation_params=[LLMTestCaseParams.INPUT, LLMTestCaseParams.ACTUAL_OUTPUT],
        threshold=0.6,
    )
    test_case = LLMTestCase(
        input="How do I reset my password?",
        actual_output="Go to Settings > Security > Reset Password.",
    )
    assert_test(test_case, [metric])
```

Run: `deepeval test run tests/eval/test_quality.py`

DeepEval also provides `FaithfulnessMetric`, `AnswerRelevancyMetric`, `TaskCompletionMetric`, and `HallucinationMetric`. See `./references/eval-framework-comparison.md` for full examples of each.

### Step 7 — Test Multi-Agent Workflows

For agents that hand off to other agents, test routing decisions and context preservation:

**7a — Test routing with FakeModel:**

```python
ROUTING_CASES = [
    ("What's your baggage policy?", "faq_agent"),
    ("I want to change my seat", "seat_booking_agent"),
    ("Cancel my flight", "cancellation_agent"),
]

@pytest.mark.unit
@pytest.mark.parametrize("query,expected_agent", ROUTING_CASES)
@pytest.mark.asyncio
async def test_triage_routing(query, expected_agent):
    model = FakeModel()
    # Queue a handoff tool call, then a final answer from the target agent
    model.set_next_output({"tool_calls": [{"name": f"transfer_to_{expected_agent}"}]})
    model.set_next_output({"content": "Handled by target agent."})

    result = await run_triage(model=model, query=query)
    assert result.routed_to == expected_agent
```

**7b — Test context preservation across handoffs:**

```python
@pytest.mark.unit
@pytest.mark.asyncio
async def test_context_survives_handoff():
    """Verify shared state is preserved when triage hands off."""
    context = {"passenger_name": "Alice", "booking_ref": "ABC123"}
    model = FakeModel()
    model.set_next_output({"tool_calls": [{"name": "transfer_to_seat_booking"}]})
    model.set_next_output({"content": "Seat updated for Alice."})

    result = await run_triage(model=model, query="Change my seat", context=context)
    assert result.context["passenger_name"] == "Alice"
    assert result.context["booking_ref"] == "ABC123"
```

Multi-agent flows can also be tested end-to-end with promptfoo — use `file://agent_provider.py:call_triage` as a custom provider and assert on the final output. See `./references/eval-framework-comparison.md` for the promptfoo multi-provider config pattern.

### Step 8 — Configure Cost-Aware CI

Separate test tiers so free tests run on every commit and expensive tests run only when needed:

```yaml
# .github/workflows/agent-tests.yml
name: Agent Tests
on:
  push:
    branches: [main]
  pull_request:
  schedule:
    - cron: "0 3 * * *"  # nightly eval

jobs:
  unit:
    name: Unit (free)
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with: { python-version: "3.12" }
      - run: pip install -e ".[test]"
      - run: pytest -m unit --tb=short

  integration:
    name: Integration (cheap model)
    runs-on: ubuntu-latest
    if: github.event_name == 'pull_request'
    env:
      OPENAI_API_KEY: ${{ secrets.OPENAI_API_KEY }}
      TEST_MODEL: gpt-4.1-mini
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with: { python-version: "3.12" }
      - run: pip install -e ".[test]"
      - run: pytest -m integration --tb=short

  nightly-eval:
    name: Eval (expensive, nightly only)
    runs-on: ubuntu-latest
    if: github.event_name == 'schedule'
    env:
      OPENAI_API_KEY: ${{ secrets.OPENAI_API_KEY }}
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with: { python-version: "3.12" }
      - run: pip install -e ".[test]"
      - run: pytest -m eval
      - run: npx promptfoo eval -c tests/eval/promptfoo.yaml
```

**Cost control strategies:**

| Strategy | Savings | Trade-off |
|---|---|---|
| Mock all LLM calls in unit tests | 100% | No coverage of real model behavior |
| Use `gpt-4.1-mini` for integration | ~95% vs `gpt-4o` | Slightly less capable |
| VCR.py cassettes for recorded replay | 100% after first run | Stale if API changes |
| LLM response caching (`diskcache`) | ~80% on repeated prompts | Cache invalidation |
| Run evals nightly, not per-commit | ~90% fewer eval runs | Delayed regression detection |

## Completion Checks

- [ ] Test directory structure created with `unit/`, `integration/`, `eval/` subdirectories
- [ ] `conftest.py` defines `unit`, `integration`, and `eval` markers
- [ ] At least one unit test runs with zero LLM API calls (fully mocked)
- [ ] Tool schema validation tests exist for each tool the agent exposes
- [ ] Tool selection tests verify the agent picks the right tool for each intent
- [ ] Snapshot or VCR cassette tests exist for at least one key agent flow
- [ ] Eval framework (promptfoo or DeepEval) configured with at least 3 test cases
- [ ] Multi-agent routing tested if the agent uses handoffs
- [ ] CI config separates free unit tests from paid integration/eval tests
- [ ] `pytest -m unit` passes with no API keys set
- [ ] No hardcoded API keys, model names, or personal paths in test files

## References

- [Mock Patterns for Common LLM SDKs](./references/mock-patterns.md)
- [Eval Framework Comparison](./references/eval-framework-comparison.md)
