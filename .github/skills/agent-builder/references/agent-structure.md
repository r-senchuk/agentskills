# Agent Structure Reference

## Canonical `.agent.md` Frontmatter

```yaml
---
name: "Agent Display Name"        # Optional. Human-readable. Shown in picker.
description: "Use when..."        # Required. Keyword-rich. Primary discovery surface.
tools: [read, edit, search]       # Optional (omit = defaults). See tool aliases below.
user-invocable: false             # false = subagent only; true = appears in agent picker
argument-hint: "Task, context"    # Optional. Shown as input prompt for slash invocation.
model: "Claude Sonnet 4"          # Optional. Use for model-specific routing.
agents: [agent1, agent2]          # Optional. Restrict which subagents this agent can invoke.
handoffs: [agent-name]            # Optional. Define transitions to other agents.
---
```

## Tool Aliases

| Alias | What it lets the agent do |
|---|---|
| `read` | Read file contents from workspace |
| `edit` | Create and modify files |
| `search` | Search workspace files (grep, file patterns) |
| `execute` | Run shell commands in terminal |
| `web` | Fetch URLs and run web searches |
| `agent` | Invoke subagents by name |
| `todo` | Manage task lists |
| `mcp/<server>/*` | Access all tools from a specific MCP server |

## Body Structure Template

```markdown
You are a specialist at {specific role}. Your job is to {clear outcome}.

## Skill Routing

Before taking action, load the relevant skill based on the task type and read it fully:

| Task Type | Skill to Load |
|---|---|
| {task description} | `.github/skills/{skill-name}/SKILL.md` |

Read the skill file first. Follow its procedure exactly.

## Core Workflow

1. {First action — gather context or research}
2. {Second action — analysis or planning}
3. {Third action — execution}
4. {Fourth action — validation}
5. {Fifth action — report results}

## Constraints

- DO NOT {critical prohibition — what the agent must never do}
- DO NOT {another hard rule}
- ONLY {what this agent does; nothing else}
- Always {invariant behavior}

## Output Format

{Describe exactly what the agent returns: format, fields, length, tone}
```

## Invocation Control Reference

| `user-invocable` | `disable-model-invocation` | Effect |
|---|---|---|
| `true` (default) | `false` (default) | Appears in picker + model can auto-invoke |
| `false` | `false` | Hidden from picker; model-invoked subagent only |
| `true` | `true` | Picker only; model cannot auto-invoke |
| `false` | `true` | Neither — agent is unreachable |

## Skill Assignment Pattern

Skills are NOT assigned in frontmatter — they are loaded when the agent body explicitly references them. In the agent body, tell the agent when and how to load each skill:

```markdown
## Skill Routing

| Task | Skill |
|---|---|
| Creating or auditing a SKILL.md | `.github/skills/skill-builder/SKILL.md` |
| Designing a new .agent.md | `.github/skills/agent-builder/SKILL.md` |
```

The agent reads the skill file when the task matches the trigger in the left column.

## Tool Selection Rules

Follow these rules strictly. Every tool you add broadens the attack surface — include only what the agent's core job requires.

| Tool | Include when | Exclude when |
|---|---|---|
| `read` | Agent reads workspace files | Agent produces output from inline knowledge only |
| `edit` | Agent writes or modifies files | Agent is read-only (analysis, reporting, summarisation) |
| `search` | Agent must locate files or code patterns in the workspace | Agent works only with fully-known, hardcoded paths |
| `execute` | Agent runs shell commands: validation, tests, build steps | Agent is pure authoring — no terminal interaction needed |
| `web` | Agent fetches external docs, APIs, or searches the web | Agent works exclusively within the local workspace |
| `agent` | Agent delegates subtasks to specialised subagents | Agent is a leaf node — it completes work itself |
| `todo` | Agent explicitly manages multi-step task lists | Agent workflow is sequential and needs no tracking |

**Swiss-army smell**: If the list includes `execute`, `web`, AND `agent` at the same time, the agent is likely doing too many things — split the responsibilities.

Validation check:
```bash
TOOL_COUNT=$(grep '^tools:' "$AGENT" | grep -oE '\b(read|edit|search|execute|web|agent)\b' | wc -l | tr -d ' ')
[ "$TOOL_COUNT" -lt 6 ] && echo "✅ tools=$TOOL_COUNT (focused)" || echo "⚠️  tools=$TOOL_COUNT — verify each is essential"
```

## Common Anti-Patterns

| Anti-pattern | Fix |
|---|---|
| `tools: [read, edit, search, execute, web, agent]` for a non-orchestrator | Trim to ≤3 tools; use the Tool Selection Rules table above |
| `description: "A helpful agent for everything"` | Be specific: "Use when creating SKILL.md files from domain research" |
| Body has no DO NOT rules | Add constraints — what the agent refuses to do defines its safety boundary |
| Agent writing `.agent.md` before dependency skills exist | Always create and validate all required skills first |
| Circular delegation: A→B→A | Add `agents:` list in frontmatter to restrict delegation targets |
| Skill references in body that don't exist | Run validation step to check all skill paths resolve |

## Subagent vs Picker Agent Decision

Use `user-invocable: false` when:
- Agent is a specialist invoked by a parent orchestrator
- User would not know when to invoke it — the parent agent decides
- Agent's description is written for machines (trigger conditions)

Use `user-invocable: true` when:
- User switches to this agent mode intentionally
- Agent has a stable persona the user wants to stay in (e.g., "my Terraform agent")
- It's the top-level entry point for a workflow
