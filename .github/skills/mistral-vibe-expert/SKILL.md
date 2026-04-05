---
name: mistral-vibe-expert
description: "Use when you need expert use of Mistral Vibe CLI: setup, configuration, interactive and programmatic usage, agent and subagent delegation, tool permissions, local/offline models, and clear synthesis of Vibe results into actionable summaries. Do NOT use for direct Mistral API calls, SDK usage, embeddings, fine-tuning, or structured outputs — those are handled by other Mistral skills."
argument-hint: "Goal, repository path, constraints (time/cost/tools), and desired output format"
user-invocable: false
---

# Mistral Vibe Expert

End-to-end workflow for operating Mistral Vibe as a coding copilot, safely delegating work, and presenting Vibe outputs in a concise, decision-ready format.

Default operating profile for this skill: safety-first (interactive mode, explicit approvals, least-privilege tools).

## When To Use
- You want a robust Vibe workflow, not one-off commands.
- You need to delegate a scoped task to Vibe and keep control over cost, tools, and risk.
- You need to convert Vibe output into a human-readable implementation brief, PR summary, or next-step checklist.
- You need to switch between cloud and local/offline model backends.
- You want this behavior available as a workspace-scoped skill in this repository.

Do NOT use for: general Mistral API or SDK tasks, embeddings/RAG pipeline design, structured output generation, fine-tuning, or document AI — use the dedicated Mistral skills for those. Do NOT use for tasks that do not involve running the Vibe CLI.

## Inputs To Collect First
1. Objective: what deliverable is required.
2. Repo context: working directory and branch constraints.
3. Risk level: read-only analysis vs code edits vs destructive operations.
4. Budget constraints: max turns and max cost for programmatic runs.
5. Output style: text summary, JSON artifact, or streamed events.

## Procedure

### Step 1 — Verify Prerequisites

Confirm CLI availability and configuration before proceeding:

```bash
command -v vibe
vibe --version
```

Ensure the API key is set and config is readable:

```bash
echo "$MISTRAL_API_KEY"   # or check ~/.vibe/.env
cat ~/.vibe/config.toml 2>/dev/null || cat ./.vibe/config.toml
```

Ensure execution is inside a trusted working directory.

### Step 2 — Choose Execution Mode

- Interactive mode (`vibe`) for exploratory, iterative tasks with approvals.
- Programmatic mode (`vibe --prompt ...`) for deterministic CI/scripting or bounded single-task runs.

Decision rule:
- If requirements are evolving or code understanding is incomplete: use interactive mode.
- If requirements are fixed and measurable: use programmatic mode with hard caps.

### Step 3 — Apply Guardrails

For programmatic execution, always define limits:

```bash
vibe --prompt "<task>" \
  --max-turns N \
  --max-price DOLLARS \
  --output text|json|streaming
```

Narrow tool scope for sensitive work:

```bash
vibe --prompt "<task>" --enabled-tools read_file,list_dir
```

For persistent policy, define `enabled_tools` or `disabled_tools` in `config.toml` (supports exact, glob, and `re:` regex patterns).

### Step 4 — Craft a High-Quality Delegation Prompt

Use this structure:
1. Task: desired end state.
2. Context: files/modules and constraints.
3. Acceptance criteria: tests, lint, behavior checks.
4. Safety constraints: forbidden actions.
5. Output contract: exact sections required in the final answer.

Example skeleton:

```text
Goal: <deliverable>
Context: <repo path, files, stack>
Constraints: <no destructive commands, budget, time>
Acceptance: <tests/commands and expected behavior>
Return format: <summary, changed files, risks, next steps>
```

### Step 5 — Delegate to Agents or Subagents

- Prefer built-in `plan` agent for read-only exploration and planning.
- Use `default` for approval-driven execution.
- Use `accept-edits` or `auto-approve` only in controlled environments.
- For custom specializations, create `~/.vibe/agents/<name>.toml` with explicit safety label and tool permissions.

Subagent guidance:
- Delegate parallel research/discovery to subagents.
- Keep subagent prompts narrow and objective.
- Remember subagents return text and cannot ask clarifying questions.

### Step 6 — Present Vibe Results

When reporting Vibe-delivered work, always include:
1. Outcome: one-sentence result.
2. Scope: what was analyzed or changed.
3. Evidence: commands/tests/log snippets and whether they passed.
4. Risks: unresolved uncertainty or skipped checks.
5. Recommended next action: smallest safe follow-up.

Use this compact template:

```text
Vibe Outcome:
- Result: ...
- Scope: ...
- Evidence: ...
- Risks: ...
- Next step: ...
```

## Completion Checks

- [ ] CLI verified with `command -v vibe` and `vibe --version` before execution.
- [ ] Execution mode matches task volatility (interactive vs programmatic).
- [ ] `--max-turns` and `--max-price` are explicitly set for all programmatic runs.
- [ ] Tool permissions are least-privilege for the task (`--enabled-tools` or `config.toml`).
- [ ] Output includes evidence (commands/tests run) and unresolved risks, not only conclusions.
- [ ] Follow-up action is specific and executable.

## References
- [Vibe playbook and command examples](./references/vibe-playbook.md)
- [Shared Mistral cross-cutting guidance](../../references/mistral-cross-cutting-guidance.md)
