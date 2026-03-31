# Eval Framework Comparison

Side-by-side comparison of the four major agent evaluation frameworks. Each section includes a working setup example.

## Decision Matrix

| Criterion | promptfoo | DeepEval | Braintrust | LangSmith |
|---|---|---|---|---|
| **Config format** | YAML + CLI | Python (pytest) | Python | Python + UI |
| **Install** | `npx promptfoo` (zero-install) | `pip install deepeval` | `pip install braintrust autoevals` | `pip install langsmith` |
| **LLM-as-judge** | ✅ `llm-rubric` | ✅ GEval, all metrics | ✅ Factuality, ClosedQA | ✅ custom evaluators |
| **Tool call assertions** | ✅ `is-valid-openai-tools-call`, JS | ✅ `ToolCorrectnessMetric` | ❌ (manual) | ❌ (manual) |
| **Multi-provider** | ✅ native (test same prompt across providers) | ⚠️ provider-agnostic test cases | ❌ single provider | ❌ single provider |
| **RAG metrics** | ⚠️ via `similar`, rubric | ✅ Faithfulness, ContextualPrecision, etc. | ✅ RAGAS scorers | ✅ custom evaluators |
| **Agentic metrics** | ⚠️ via custom JS/Python assertions | ✅ TaskCompletion, ToolCorrectness, GoalAccuracy | ⚠️ via custom scorers | ⚠️ via custom evaluators |
| **CI integration** | ✅ CLI-first, JSON output | ✅ pytest plugin, CI-friendly | ✅ CLI + Python | ✅ Python SDK |
| **Dashboard** | ✅ local web UI + cloud | ✅ Confident AI cloud | ✅ Braintrust cloud | ✅ LangSmith cloud |
| **Cost** | Free (OSS) + provider costs | Free (OSS) + provider costs | Free tier + paid cloud | Free tier + paid cloud |
| **Best for** | CI assertion matrices, multi-provider comparison | Python-native agentic/RAG metrics | Custom scoring functions, experiment tracking | Dataset management, production tracing |

## Recommendation

- **Start with promptfoo** if you want a YAML config, multi-provider testing, and CI-friendly output.
- **Start with DeepEval** if you want Python-native pytest integration and rich agentic metrics.
- **Add Braintrust** when you need custom scoring functions and experiment tracking.
- **Add LangSmith** when you need dataset management and production trace analysis.

---

## promptfoo — Setup and Examples

### Installation

```bash
# Zero-install via npx (recommended)
npx promptfoo init

# Or install globally
npm install -g promptfoo
```

### Basic Config

```yaml
# promptfoo.yaml
description: "Agent quality eval"

providers:
  - openai:gpt-4.1-mini
  - anthropic:messages:claude-haiku-4-20250514

prompts:
  - |
    You are a helpful customer service agent.
    User: {{query}}

tests:
  - vars: { query: "What's your return policy?" }
    assert:
      - type: contains
        value: "30 days"
      - type: llm-rubric
        value: "Response should be helpful and mention the return window."
      - type: similar
        value: "We offer a 30-day return policy with full refund."
        threshold: 0.7

  - vars: { query: "I want to speak to a manager" }
    assert:
      - type: not-contains
        value: "I can't help"
      - type: llm-rubric
        value: "Response should acknowledge the request and offer to escalate."
```

### Tool Call Testing Config

```yaml
description: "Tool call validation"

providers:
  - id: openai:gpt-4.1-mini
    config:
      tools:
        - type: function
          function:
            name: get_weather
            description: Get current weather for a location
            parameters:
              type: object
              properties:
                location: { type: string, description: "City and state" }
                unit: { type: string, enum: [celsius, fahrenheit] }
              required: [location]
        - type: function
          function:
            name: search_flights
            description: Search for available flights
            parameters:
              type: object
              properties:
                origin: { type: string }
                destination: { type: string }
                date: { type: string, format: date }
              required: [origin, destination]

prompts:
  - "You are a travel assistant. Help with: {{query}}"

tests:
  - vars: { query: "What's the weather in Tokyo?" }
    assert:
      - type: is-valid-openai-tools-call
      - type: javascript
        value: "output[0].function.name === 'get_weather'"
      - type: javascript
        value: "JSON.parse(output[0].function.arguments).location.includes('Tokyo')"

  - vars: { query: "Find flights from NYC to London on Dec 25" }
    assert:
      - type: is-valid-openai-tools-call
      - type: javascript
        value: "output[0].function.name === 'search_flights'"
      - type: javascript
        value: |
          const args = JSON.parse(output[0].function.arguments);
          args.destination.includes('London') && args.origin.includes('NYC')

  - vars: { query: "Tell me a joke" }
    assert:
      - type: finish-reason
        value: stop  # No tool call — just a text response
```

### Custom Python Assertion

```yaml
tests:
  - vars: { query: "Summarize this document" }
    assert:
      - type: python
        value: |
          import json
          # output is the raw model response string
          def get_assert(output, context):
              words = output.split()
              if len(words) < 20:
                  return {"pass": False, "score": 0, "reason": "Summary too short"}
              if len(words) > 200:
                  return {"pass": False, "score": 0.5, "reason": "Summary too long"}
              return {"pass": True, "score": 1.0, "reason": "Good length"}
```

### Running and CI

```bash
# Run evaluation
npx promptfoo eval

# Output as JSON for CI
npx promptfoo eval --output results.json

# View results in browser
npx promptfoo view

# Compare two runs
npx promptfoo eval --output run2.json
npx promptfoo diff run1.json run2.json
```

### Key Assertion Types Reference

| Type | Description | Example |
|---|---|---|
| `contains` | Substring match | `value: "30 days"` |
| `icontains` | Case-insensitive substring | `value: "refund"` |
| `not-contains` | Must NOT contain | `value: "error"` |
| `equals` | Exact match | `value: "Paris"` |
| `regex` | Regex match | `value: "\\d{3}-\\d{4}"` |
| `is-json` | Valid JSON output | (no value needed) |
| `is-valid-openai-tools-call` | Valid tool call array | (no value needed) |
| `is-valid-openai-function-call` | Valid function call | (no value needed) |
| `finish-reason` | Check stop reason | `value: tool_calls` |
| `similar` | Semantic similarity | `value: "expected text"` + `threshold: 0.8` |
| `llm-rubric` | LLM-as-judge with rubric | `value: "Rate helpfulness 1-5"` |
| `javascript` | Custom JS assertion | `value: "output.length > 50"` |
| `python` | Custom Python assertion | `value: "def get_assert(output, context): ..."` |
| `cost` | Max cost per request | `threshold: 0.01` |
| `latency` | Max latency in ms | `threshold: 5000` |

---

## DeepEval — Setup and Examples

### Installation

```bash
pip install -U deepeval
# Optional: connect to Confident AI dashboard
deepeval login
```

### Agentic Metrics

#### ToolCorrectnessMetric

Verifies the agent called the right tools:

```python
import pytest
from deepeval import assert_test
from deepeval.test_case import LLMTestCase, ToolCall
from deepeval.metrics import ToolCorrectnessMetric

@pytest.mark.eval
def test_tool_selection():
    metric = ToolCorrectnessMetric()
    test_case = LLMTestCase(
        input="Book a flight from NYC to London",
        actual_output="Flight booked: NYC → London, Dec 25.",
        tools_called=[
            ToolCall(name="search_flights"),
            ToolCall(name="book_flight"),
        ],
        expected_tools=[
            ToolCall(name="search_flights"),
            ToolCall(name="book_flight"),
        ],
    )
    assert_test(test_case, [metric])
    # Score: Number of Correctly Used Tools / Total Number of Tools Called
```

#### TaskCompletionMetric

Verifies the agent completed the user's task:

```python
from deepeval.metrics import TaskCompletionMetric

@pytest.mark.eval
def test_task_completion():
    metric = TaskCompletionMetric(threshold=0.7, model="gpt-4.1-mini")
    test_case = LLMTestCase(
        input="Find me a restaurant in Paris for 4 people tonight",
        actual_output="I found Le Jules Verne. Table for 4 tonight at 8 PM. Shall I book?",
    )
    assert_test(test_case, [metric])
```

#### GEval (Custom Criteria)

Define any evaluation criteria as natural language:

```python
from deepeval.metrics import GEval
from deepeval.test_case import LLMTestCaseParams

@pytest.mark.eval
def test_tone_and_helpfulness():
    metric = GEval(
        name="Professional Tone",
        criteria="The response should be professional, empathetic, and actionable.",
        evaluation_params=[
            LLMTestCaseParams.INPUT,
            LLMTestCaseParams.ACTUAL_OUTPUT,
        ],
        threshold=0.7,
    )
    test_case = LLMTestCase(
        input="My order arrived damaged",
        actual_output="I'm sorry about that. I'll process a replacement immediately.",
    )
    assert_test(test_case, [metric])
```

### RAG Metrics

```python
from deepeval.metrics import (
    FaithfulnessMetric,
    AnswerRelevancyMetric,
    ContextualPrecisionMetric,
    ContextualRecallMetric,
    HallucinationMetric,
)

@pytest.mark.eval
def test_rag_quality():
    """Run all RAG metrics on one test case."""
    test_case = LLMTestCase(
        input="What is our refund policy?",
        actual_output="We offer a 30-day full refund at no extra cost.",
        expected_output="Customers get a 30-day full refund.",
        retrieval_context=[
            "All customers are eligible for a 30-day full refund at no extra cost.",
            "Refunds are processed within 5 business days.",
        ],
    )
    metrics = [
        FaithfulnessMetric(threshold=0.7, model="gpt-4.1-mini"),
        AnswerRelevancyMetric(threshold=0.7, model="gpt-4.1-mini"),
        ContextualPrecisionMetric(threshold=0.7, model="gpt-4.1-mini"),
        ContextualRecallMetric(threshold=0.7, model="gpt-4.1-mini"),
        HallucinationMetric(threshold=0.5, model="gpt-4.1-mini"),
    ]
    for metric in metrics:
        assert_test(test_case, [metric])
```

### Running DeepEval

```bash
# Run all eval tests
deepeval test run tests/eval/

# Run with specific metrics
deepeval test run tests/eval/test_quality.py -k "test_tool_selection"

# Generate report
deepeval test run tests/eval/ --verbose
```

### DeepEval Metric Inventory

| Category | Metrics |
|---|---|
| **Agentic** | TaskCompletion, ToolCorrectness, GoalAccuracy, StepEfficiency, PlanAdherence |
| **RAG** | Faithfulness, AnswerRelevancy, ContextualPrecision, ContextualRecall, Hallucination |
| **Conversation** | KnowledgeRetention, ConversationCompleteness, TurnRelevancy, RoleAdherence |
| **General** | GEval (custom criteria), DAG |

---

## Braintrust — Setup and Examples

### Installation

```bash
pip install braintrust autoevals
```

### Basic Eval

```python
from braintrust import Eval
from autoevals import LevenshteinScorer, Factuality

def my_agent(input: str) -> str:
    # Your agent logic here
    return f"Answer to: {input}"

Eval(
    "customer-service-agent",
    data=lambda: [
        {
            "input": "What is your return policy?",
            "expected": "We offer a 30-day full refund.",
        },
        {
            "input": "How do I track my order?",
            "expected": "You can track your order in the Orders section of your account.",
        },
    ],
    task=lambda input: my_agent(input),
    scores=[LevenshteinScorer, Factuality],
)
```

Run:

```bash
BRAINTRUST_API_KEY=<key> braintrust eval eval_agent.py
```

### RAG Scoring

```python
from autoevals.ragas import (
    Faithfulness,
    AnswerRelevancy,
    ContextRelevancy,
    ContextRecall,
    AnswerCorrectness,
)

# Use individual scorers
faithfulness = Faithfulness()
result = faithfulness(
    input="What is photosynthesis?",
    output="Plants convert sunlight to energy using chlorophyll.",
    context=["Photosynthesis is the process by which plants use sunlight to synthesize food."],
)
print(f"Faithfulness: {result.score}")  # 0.0 to 1.0
```

### Custom LLM Evaluator

```python
from autoevals import LLMClassifier

tone_evaluator = LLMClassifier(
    name="ProfessionalTone",
    prompt_template="""Rate whether this customer service response is professional:

    Customer question: {{input}}
    Agent response: {{output}}

    Choose:
    (A) Professional and helpful
    (B) Unprofessional or unhelpful""",
    choice_scores={"A": 1.0, "B": 0.0},
    use_cot=True,
)
```

### Available Scorers

| Category | Scorers |
|---|---|
| **LLM-as-Judge** | Factuality, Battle, ClosedQA, Humor, Security, Moderation, Summary, Translation |
| **RAG** | Faithfulness, AnswerRelevancy, ContextRelevancy, ContextRecall, ContextPrecision, AnswerCorrectness |
| **Heuristic** | LevenshteinScorer, ExactMatch, NumericDiff, JSONDiff |

---

## LangSmith — Setup and Examples

### Installation

```bash
pip install langsmith
export LANGCHAIN_API_KEY="..."
export LANGCHAIN_TRACING_V2="true"
```

### Create Dataset and Evaluate

```python
from langsmith import Client, evaluate

client = Client()

# Create a reusable dataset
dataset = client.create_dataset("agent-eval-v1")
client.create_examples(
    inputs=[
        {"input": "What is the capital of France?"},
        {"input": "How do I reset my password?"},
    ],
    outputs=[
        {"output": "Paris"},
        {"output": "Go to Settings > Security > Reset Password."},
    ],
    dataset_id=dataset.id,
)

# Define evaluator
def correctness(run, example):
    prediction = run.outputs.get("output", "").lower()
    reference = example.outputs.get("output", "").lower()
    score = 1.0 if reference in prediction else 0.0
    return {"score": score, "key": "correctness"}

# Run evaluation
results = evaluate(
    lambda inputs: {"output": my_agent(inputs["input"])},
    data="agent-eval-v1",
    evaluators=[correctness],
    experiment_prefix="agent-v1",
)
```

### Evaluate Agent Tool Selection

```python
def tool_accuracy(run, example):
    """Check if agent used the expected tools."""
    expected = set(example.outputs.get("expected_tools", []))
    actual = set(
        step["tool"] for step in run.outputs.get("intermediate_steps", [])
    )
    precision = len(expected & actual) / len(actual) if actual else 0
    recall = len(expected & actual) / len(expected) if expected else 0
    f1 = 2 * precision * recall / (precision + recall) if (precision + recall) else 0
    return {"score": f1, "key": "tool_f1"}
```

### Key Patterns

- **Backtesting**: Convert production traces into test datasets for regression testing.
- **Simulated users**: Use an LLM-powered user simulator to evaluate multi-turn chatbots.
- **Post-hoc evaluation**: Apply new evaluators to existing experiment results without re-running.
- **Annotation queues**: Set up human review queues for cases where automated metrics are insufficient.

---

## Cost Comparison

Approximate costs per 100 test cases (using GPT-4.1 mini as the judge model where applicable):

| Framework | Setup Cost | Per-Run Cost (100 tests) | Notes |
|---|---|---|---|
| **promptfoo** | Free (OSS) | ~$0.50–2.00 | Depends on assertion types; `llm-rubric` costs more |
| **DeepEval** | Free (OSS) | ~$1.00–3.00 | Each metric makes 1–3 judge calls |
| **Braintrust** | Free tier | ~$0.50–2.00 | Similar to promptfoo; cloud dashboard is paid |
| **LangSmith** | Free tier (5k traces/mo) | ~$0.50–2.00 | Cloud tracing and dataset management is paid tier |

All frameworks support `gpt-4.1-mini` as judge to reduce costs. Heuristic-only assertions (contains, regex, JSON validation) are free.
