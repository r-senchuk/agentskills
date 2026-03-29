# Tool Schema Patterns

## Minimal Schema
```python
{
    "type": "function",
    "function": {
        "name": "get_weather",
        "description": "Returns current weather for a city.",
        "parameters": {
            "type": "object",
            "properties": {
                "city": {"type": "string", "description": "City name, e.g. 'Paris'"}
            },
            "required": ["city"]
        }
    }
}
```

## Enum Parameter
```python
{
    "name": "set_priority",
    "description": "Sets task priority.",
    "parameters": {
        "type": "object",
        "properties": {
            "task_id": {"type": "string"},
            "priority": {
                "type": "string",
                "enum": ["low", "medium", "high", "critical"],
                "description": "Priority level."
            }
        },
        "required": ["task_id", "priority"]
    }
}
```

## Nested Object Parameter
```python
{
    "name": "create_order",
    "description": "Creates a new order.",
    "parameters": {
        "type": "object",
        "properties": {
            "customer_id": {"type": "string"},
            "items": {
                "type": "array",
                "items": {
                    "type": "object",
                    "properties": {
                        "sku": {"type": "string"},
                        "quantity": {"type": "integer", "minimum": 1}
                    },
                    "required": ["sku", "quantity"]
                }
            }
        },
        "required": ["customer_id", "items"]
    }
}
```

## Guarding Against Unintended Calls
Add explicit instructions in the `description` field:

```python
"description": "Deletes a record permanently. ONLY call when the user has explicitly confirmed deletion with the word 'yes'."
```

## Controlling Tool Choice
```python
# Force the model to call a specific tool
tool_choice = {"type": "function", "function": {"name": "get_weather"}}

# Force the model to call any tool
tool_choice = "any"

# Let model decide (recommended default)
tool_choice = "auto"

# Disable tools for this turn
tool_choice = "none"
```
