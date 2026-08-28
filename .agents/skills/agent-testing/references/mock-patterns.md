# Mock Patterns for Common LLM SDKs

Copy-paste-ready pytest fixtures for mocking LLM responses. Each section is self-contained — use only the fixtures for your provider.

## OpenAI (Chat Completions API)

### Text Response Mock

```python
import pytest
from unittest.mock import AsyncMock, MagicMock

@pytest.fixture
def make_openai_response():
    """Factory: build an OpenAI ChatCompletion response object."""
    def _make(content="Hello", tool_calls=None, finish_reason="stop"):
        return MagicMock(
            id="chatcmpl-test",
            choices=[MagicMock(
                index=0,
                message=MagicMock(
                    role="assistant",
                    content=content,
                    tool_calls=tool_calls,
                    function_call=None,
                ),
                finish_reason=finish_reason,
            )],
            usage=MagicMock(prompt_tokens=10, completion_tokens=20, total_tokens=30),
            model="gpt-4.1-mini",
        )
    return _make

@pytest.fixture
def mock_openai_client(make_openai_response):
    """OpenAI client that returns a canned text response."""
    client = MagicMock()
    client.chat.completions.create = AsyncMock(
        return_value=make_openai_response("Mocked response")
    )
    return client
```

### Tool Call Response Mock

```python
import json

@pytest.fixture
def make_openai_tool_call():
    """Factory: build an OpenAI tool call object."""
    def _make(name="get_weather", arguments=None, call_id="call_abc123"):
        if arguments is None:
            arguments = {"location": "Boston, MA"}
        return MagicMock(
            id=call_id,
            type="function",
            function=MagicMock(
                name=name,
                arguments=json.dumps(arguments),
            ),
        )
    return _make

@pytest.fixture
def mock_openai_tool_response(make_openai_response, make_openai_tool_call):
    """OpenAI client that returns a tool call then a final answer."""
    client = MagicMock()
    call_count = 0

    async def side_effect(**kwargs):
        nonlocal call_count
        call_count += 1
        if call_count == 1:
            return make_openai_response(
                content=None,
                tool_calls=[make_openai_tool_call()],
                finish_reason="tool_calls",
            )
        return make_openai_response("The weather in Boston is 72°F.")

    client.chat.completions.create = AsyncMock(side_effect=side_effect)
    return client
```

### Streaming Response Mock

```python
@pytest.fixture
def mock_openai_stream():
    """Mock streaming response (async generator)."""
    async def fake_stream(**kwargs):
        chunks = [
            MagicMock(choices=[MagicMock(delta=MagicMock(content="Hello"), finish_reason=None)]),
            MagicMock(choices=[MagicMock(delta=MagicMock(content=" world"), finish_reason=None)]),
            MagicMock(choices=[MagicMock(delta=MagicMock(content=""), finish_reason="stop")]),
        ]
        for chunk in chunks:
            yield chunk

    client = MagicMock()
    client.chat.completions.create = MagicMock(return_value=fake_stream())
    return client
```

### Usage Example

```python
@pytest.mark.unit
@pytest.mark.asyncio
async def test_agent_tool_loop(mock_openai_tool_response):
    """Agent calls get_weather then returns final answer."""
    agent = MyAgent(client=mock_openai_tool_response)
    result = await agent.run("Weather in Boston?")
    assert "72°F" in result
    assert mock_openai_tool_response.chat.completions.create.call_count == 2
```

---

## Anthropic (Messages API)

### Text Response Mock

```python
@pytest.fixture
def make_anthropic_response():
    """Factory: build an Anthropic Messages response."""
    def _make(text="Hello", stop_reason="end_turn"):
        return MagicMock(
            id="msg_test",
            type="message",
            role="assistant",
            content=[MagicMock(type="text", text=text)],
            stop_reason=stop_reason,
            usage=MagicMock(input_tokens=15, output_tokens=25),
            model="claude-sonnet-4-20250514",
        )
    return _make

@pytest.fixture
def mock_anthropic_client(make_anthropic_response):
    client = MagicMock()
    client.messages.create = AsyncMock(
        return_value=make_anthropic_response("Mocked Claude response")
    )
    return client
```

### Tool Use Response Mock

```python
@pytest.fixture
def make_anthropic_tool_use():
    """Factory: build an Anthropic tool_use content block."""
    def _make(name="get_weather", tool_input=None, tool_id="toolu_abc123"):
        if tool_input is None:
            tool_input = {"location": "Boston, MA"}
        return MagicMock(
            type="tool_use",
            id=tool_id,
            name=name,
            input=tool_input,
        )
    return _make

@pytest.fixture
def mock_anthropic_tool_response(make_anthropic_response, make_anthropic_tool_use):
    """Anthropic client: first call returns tool_use, second returns text."""
    client = MagicMock()
    call_count = 0

    async def side_effect(**kwargs):
        nonlocal call_count
        call_count += 1
        if call_count == 1:
            resp = MagicMock(
                content=[make_anthropic_tool_use()],
                stop_reason="tool_use",
                usage=MagicMock(input_tokens=15, output_tokens=25),
            )
            return resp
        return make_anthropic_response("The weather in Boston is 72°F.")

    client.messages.create = AsyncMock(side_effect=side_effect)
    return client
```

### Tool Result Injection Pattern

After receiving a `tool_use` block, inject the tool result:

```python
# Messages array after tool use:
messages = [
    {"role": "user", "content": "Weather in Boston?"},
    {
        "role": "assistant",
        "content": [
            {"type": "tool_use", "id": "toolu_abc123",
             "name": "get_weather", "input": {"location": "Boston, MA"}}
        ],
    },
    {
        "role": "user",
        "content": [
            {"type": "tool_result", "tool_use_id": "toolu_abc123",
             "content": '{"temperature": 72, "unit": "fahrenheit"}'}
        ],
    },
]
```

---

## Mistral (Chat Completions)

### Text Response Mock

```python
@pytest.fixture
def make_mistral_response():
    """Factory: build a Mistral chat completion response."""
    def _make(content="Hello", tool_calls=None, finish_reason="stop"):
        return MagicMock(
            id="cmpl-test",
            choices=[MagicMock(
                message=MagicMock(
                    role="assistant",
                    content=content,
                    tool_calls=tool_calls,
                ),
                finish_reason=finish_reason,
            )],
            usage=MagicMock(prompt_tokens=10, completion_tokens=20, total_tokens=30),
            model="mistral-large-latest",
        )
    return _make

@pytest.fixture
def mock_mistral_client(make_mistral_response):
    client = MagicMock()
    client.chat.complete = AsyncMock(
        return_value=make_mistral_response("Mocked Mistral response")
    )
    return client
```

### Tool Call Response Mock

```python
@pytest.fixture
def make_mistral_tool_call():
    """Factory: build a Mistral tool call."""
    def _make(name="get_weather", arguments=None, call_id="call_abc123"):
        if arguments is None:
            arguments = {"location": "Boston, MA"}
        return MagicMock(
            id=call_id,
            type="function",
            function=MagicMock(
                name=name,
                arguments=json.dumps(arguments),
            ),
        )
    return _make

@pytest.fixture
def mock_mistral_tool_response(make_mistral_response, make_mistral_tool_call):
    client = MagicMock()
    call_count = 0

    async def side_effect(**kwargs):
        nonlocal call_count
        call_count += 1
        if call_count == 1:
            return make_mistral_response(
                content="",
                tool_calls=[make_mistral_tool_call()],
                finish_reason="tool_calls",
            )
        return make_mistral_response("The weather in Boston is 72°F.")

    client.chat.complete = AsyncMock(side_effect=side_effect)
    return client
```

### Mistral Tool Result Message Format

```python
# After receiving tool calls, inject results:
messages.append({
    "role": "tool",
    "tool_call_id": "call_abc123",
    "name": "get_weather",
    "content": json.dumps({"temperature": 72, "unit": "fahrenheit"}),
})
```

---

## HTTP-Level Mocking (Framework-Agnostic)

When you cannot inject a mock client, intercept HTTP requests instead.

### responses Library (synchronous)

```python
import responses

@responses.activate
def test_agent_openai_call():
    responses.add(
        responses.POST,
        "https://api.openai.com/v1/chat/completions",
        json={
            "id": "chatcmpl-test",
            "choices": [{
                "message": {"role": "assistant", "content": "Hello!"},
                "finish_reason": "stop",
            }],
            "usage": {"prompt_tokens": 10, "completion_tokens": 5, "total_tokens": 15},
        },
        status=200,
    )
    result = my_agent("Say hello")
    assert result == "Hello!"

@responses.activate
def test_agent_anthropic_call():
    responses.add(
        responses.POST,
        "https://api.anthropic.com/v1/messages",
        json={
            "id": "msg_test",
            "type": "message",
            "role": "assistant",
            "content": [{"type": "text", "text": "Hello from Claude!"}],
            "stop_reason": "end_turn",
            "usage": {"input_tokens": 10, "output_tokens": 5},
        },
        status=200,
    )
    result = my_agent("Say hello")
    assert result == "Hello from Claude!"
```

### VCR.py (Record and Replay)

```python
import pytest

@pytest.fixture(scope="module")
def vcr_config():
    return {
        "cassette_library_dir": "tests/cassettes",
        "filter_headers": ["authorization", "x-api-key", "anthropic-api-key"],
        "filter_query_parameters": ["api_key"],
        "record_mode": "once",
        "match_on": ["method", "scheme", "host", "port", "path", "body"],
    }

@pytest.mark.vcr
def test_real_agent_call():
    """First run: records to cassette. Subsequent runs: replays from file."""
    result = my_agent("What is Python?")
    assert "programming language" in result.lower()
```

VCR cassette files (YAML) are committed to version control. To re-record after API changes:

```bash
# Delete the specific cassette and re-run
rm tests/cassettes/test_real_agent_call.yaml
pytest tests/integration/test_agent_e2e.py::test_real_agent_call -m integration
```

### aioresponses (async HTTP mocking)

```python
from aioresponses import aioresponses

@pytest.mark.asyncio
async def test_async_agent():
    with aioresponses() as mocked:
        mocked.post(
            "https://api.openai.com/v1/chat/completions",
            payload={
                "choices": [{
                    "message": {"role": "assistant", "content": "Async hello!"},
                    "finish_reason": "stop",
                }],
                "usage": {"prompt_tokens": 10, "completion_tokens": 5, "total_tokens": 15},
            },
        )
        result = await my_async_agent("Say hello")
        assert result == "Async hello!"
```

---

## FakeModel Pattern (SDK-Agnostic)

A reusable drop-in model replacement for deterministic multi-turn testing:

```python
from dataclasses import dataclass, field
from typing import Any

@dataclass
class FakeModel:
    """Queue deterministic outputs. Pops FIFO on each call."""
    turn_outputs: list[Any] = field(default_factory=list)
    call_log: list[dict] = field(default_factory=list)

    def set_next_output(self, output: Any):
        """Queue a single output."""
        self.turn_outputs.append(output)

    def set_next_error(self, error: Exception):
        """Queue an exception to be raised."""
        self.turn_outputs.append(error)

    async def get_response(self, **kwargs) -> dict:
        """Pop the next queued output. Records all calls for assertion."""
        self.call_log.append(kwargs)
        if not self.turn_outputs:
            raise ValueError("FakeModel: no outputs queued — did you forget set_next_output()?")
        output = self.turn_outputs.pop(0)
        if isinstance(output, Exception):
            raise output
        return output

    @property
    def total_calls(self) -> int:
        return len(self.call_log)
```

### Multi-Turn Test Example

```python
@pytest.mark.unit
@pytest.mark.asyncio
async def test_three_turn_agent():
    model = FakeModel()
    model.set_next_output({"content": "What city?", "tool_calls": []})
    model.set_next_output({
        "content": None,
        "tool_calls": [{"name": "get_weather", "arguments": '{"location": "Boston"}'}],
    })
    model.set_next_output({"content": "It's 72°F in Boston.", "tool_calls": []})

    agent = MyAgent(model=model)
    r1 = await agent.run("Weather?")
    assert "city" in r1.lower()

    r2 = await agent.run("Boston")
    # Agent should have processed the tool call
    assert model.total_calls == 3

    assert "72" in agent.last_response
```

### Error Handling Test

```python
@pytest.mark.unit
@pytest.mark.asyncio
async def test_model_error_recovery():
    model = FakeModel()
    model.set_next_error(TimeoutError("API timeout"))
    model.set_next_output({"content": "Recovered!", "tool_calls": []})

    agent = MyAgent(model=model, max_retries=2)
    result = await agent.run("Hello")
    assert result == "Recovered!"
    assert model.total_calls == 2
```
