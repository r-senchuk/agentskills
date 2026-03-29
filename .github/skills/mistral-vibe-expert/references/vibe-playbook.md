# Mistral Vibe Playbook

This reference complements the skill workflow with practical command examples and best-practice defaults.

## Core Commands

Install and verify:
```bash
curl -LsSf https://mistral.ai/vibe/install.sh | bash
vibe --version
command -v vibe
```

First-time setup:
```bash
vibe --setup
```

Interactive session:
```bash
cd /path/to/repo
vibe
```

Programmatic execution:
```bash
vibe --prompt "Analyze flaky tests in src/ and propose fixes." \
  --max-turns 6 \
  --max-price 1.50 \
  --output json
```

Continue/resume session:
```bash
vibe --continue
vibe --resume abc123
```

Run in specific directory:
```bash
vibe --workdir /path/to/repo
```

## Prompt Engineering Defaults

Use explicit contracts:
- State objective and definition of done.
- Name exact files or folders to inspect.
- Specify hard constraints (forbidden commands, budget caps, no rewrites).
- Require proof: tests run, command output, or diff-level evidence.
- Require uncertainty reporting: what remains unverified.

Recommended mini-template:
```text
Goal:
Context:
Constraints:
Acceptance checks:
Return format:
```

## Delegation Patterns

Read-only discovery:
- Use `plan` agent.
- Restrict tools to read-only where possible.
- Ask for a ranked hypothesis list and verification plan.

Scoped implementation:
- Use `default` for approval checkpoints.
- Ask for smallest safe patch first.
- Require post-change validation commands.

High-throughput scripted tasks:
- Use `--prompt` with `--max-turns` and `--max-price`.
- Use `--enabled-tools` to minimize unnecessary capability.
- Prefer `--output json` for machine processing.

## Agents, Subagents, and Skill Discovery

Built-in agents include `default`, `plan`, `accept-edits`, and `auto-approve`.
Subagents can be used for isolated research and return text-only results.

Skill discovery locations:
- Global: `~/.vibe/skills/`
- Project: `.vibe/skills/`
- Extra paths: `skill_paths` in `config.toml`

## Configuration Highlights

Primary files:
- `./.vibe/config.toml` (project-local, preferred when project-specific behavior is needed)
- `~/.vibe/config.toml` (global defaults)
- `~/.vibe/.env` (API keys and provider credentials)

Key controls:
```toml
active_model = "devstral-2"
enabled_tools = ["read_file", "grep", "bash"]
disabled_tools = ["re:^mcp_.*$"]
enable_auto_update = true
```

Provider/model preset pattern:
```toml
[[providers]]
name = "openrouter"
api_base = "https://openrouter.ai/api/v1"
api_key_env_var = "OPENROUTER_API_KEY"
api_style = "openai"
backend = "generic"

[[models]]
name = "mistralai/devstral-2512:free"
provider = "openrouter"
alias = "devstral-openrouter"
temperature = 0.2
input_price = 0.0
output_price = 0.0

active_model = "devstral-openrouter"
```

## Local/Offline Model Workflow

Recommended server stack is vLLM with OpenAI-compatible API.

Example:
```bash
vllm serve mistralai/Devstral-Small-2-24B-Instruct-2512 \
  --tool-call-parser mistral \
  --enable-auto-tool-choice \
  --port 8080
```

Then switch model in Vibe via `/config` to local, or define a model preset in `config.toml`.

## Safety and Quality Checklist

Before run:
- Trusted folder confirmed.
- Mode selected intentionally (interactive vs programmatic).
- Budget and turn limits defined for long tasks.
- Tool scope minimized.

After run:
- Evidence captured (tests, logs, command output).
- Risks and unknowns documented.
- Next action is concrete and low-risk.

## Presenting Vibe Results to Stakeholders

Use a five-line summary:
```text
Vibe Outcome:
- Result: What was accomplished.
- Scope: Files/modules touched or analyzed.
- Evidence: Validation commands and key outputs.
- Risks: Remaining uncertainty.
- Next step: Single recommended action.
```

This format keeps technical depth while remaining decision-friendly.
