---
name: agent-builder
description: "Use when creating a new .agent.md file or improving an existing agent: define scope and persona, identify and create required skills, select minimal tools, write constraints and workflow. Use for: agent creation, agent design, custom agent, subagent, agent.md, tool restrictions, persona, handoffs, agent improvement."
argument-hint: "Agent name, purpose, tool preferences, and known skills to assign."
user-invocable: false
---

# Agent Builder

## When To Use

- **Create**: Designing a new `.agent.md` for a specialized workflow, subagent role, or tool-restricted persona.
- **Improve**: Auditing an existing agent for vague description, Swiss-army tool list, missing constraints, or weak persona.
- **Orchestration design**: Planning a multi-agent system where one agent delegates to others.

Do NOT use for general coding tasks. Use when the output is an `.agent.md` file.

## Inputs To Collect First

1. **Agent name** (kebab-case, maps to `<name>.agent.md`)
2. **Purpose** — one sentence: what job does this agent do that the default agent cannot?
3. **Invocability** — user-facing picker agent or behind-the-scenes subagent (`user-invocable: true/false`)?
4. **Tool requirements** — what operations must it perform? (`read`, `edit`, `execute`, `web`, `search`, `agent`)
5. **Skills to assign** — which `SKILL.md` skills does this agent rely on?
6. **Location** — workspace (`.github/agents/`) or user profile?

## Procedure

### Step 1 — Define Agent Scope

Answer these before writing anything:
- **Single role**: What is the ONE thing this agent is best at?
- **Exclusions**: What should it never do? (prevents scope creep)
- **Delegation**: Which tasks should it hand off to subagents or invoke via skills?
- **Output**: What exactly does it return to the caller?

If the scope is unclear, narrow it — broad agents underperform specialists.

### Step 2 — Identify Required Skills

List the skills this agent needs. For each skill:
1. Check if it already exists: `ls .github/skills/`
2. If missing, create it first using the `skill-builder` skill before proceeding
3. Document the trigger condition that tells the agent when to load each skill

**Dependency rule**: Never write the `.agent.md` until all required skills exist and are validated.

### Step 3 — Select Tools (Minimal Set)

Use only the tools the agent's role requires. Each extra tool broadens the attack surface and dilutes focus:

| Tool alias | Include when | Exclude when |
|---|---|---|
| `read` | Agent reads files from the workspace | Agent output is text-only with no file access |
| `edit` | Agent writes or modifies files | Agent is read-only (research, reporting) |
| `search` | Agent must locate code or config in the workspace | Agent works only with known, hardcoded paths |
| `execute` | Agent runs shell validation, tests, or build commands | Agent is pure authoring — no terminal needed |
| `web` | Agent fetches external docs or searches the web | Agent works exclusively within the local workspace |
| `agent` | Agent delegates tasks to specialised subagents | Agent is a leaf node that never delegates |
| `todo` | Agent manages multi-step work items explicitly | Agent workflow is simple and fully sequential |

**Red flag**: If your list includes `execute`, `web`, AND `agent` simultaneously, ask whether the agent is doing too much — split it.

Common minimal sets:
- **Read-only research**: `[read, search, web]`
- **File authoring**: `[read, edit, search]`
- **Full orchestration**: `[read, edit, search, execute, web, agent]` — only valid for top-level orchestrators

### Step 4 — Write `.agent.md`

Place at: `.github/agents/<name>.agent.md`

Required frontmatter:
```yaml
---
name: "Agent Display Name"
description: "Use when..."    # Keyword-rich; critical for subagent discovery
tools: [read, edit, search]   # Minimal set from Step 3
user-invocable: false         # false for subagents, true for picker agents
---
```

Body structure:
1. **Identity statement** — "You are a specialist at X. Your job is to Y."
2. **Skill Routing** (if multiple skills) — table mapping task type → skill file path to read
3. **Core Workflow** — numbered steps for how the agent operates
4. **Constraints** — explicit DO NOT rules
5. **Output Format** — exactly what the agent returns

Load `./references/agent-structure.md` for the full annotated template with tool aliases, invocation control, and anti-patterns.

### Step 5 — Validate

```bash
AGENT=".github/agents/<name>.agent.md"

# 1. Filename / name-field match
FILENAME=$(basename "$AGENT" .agent.md)
NAME_FIELD=$(grep -m1 '^name:' "$AGENT" | sed 's/name: *"\?//;s/"$//')
if [ -z "$NAME_FIELD" ]; then
  echo "⚠️  name: field absent (optional but recommended)"
elif [ "$FILENAME" = "$NAME_FIELD" ]; then
  echo "✅ filename matches name: $NAME_FIELD"
else
  echo "❌ filename '$FILENAME' != name: '$NAME_FIELD'"
fi

# 2. Required frontmatter fields
for F in description tools user-invocable; do
  grep -q "^$F:" "$AGENT" && echo "✅ $F" || echo "❌ missing: $F"
done

# 3. Description contains trigger words
grep -c "Use when\|Use for\|specialist\|expert" "$AGENT"

# 4. All referenced skill files exist
grep -oE '\.github/skills/[^/]+/SKILL\.md' "$AGENT" | while read F; do
  [ -f "$F" ] && echo "✅ $F" || echo "❌ missing skill: $F"
done

# 5. Required body sections
for S in "Constraints" "Output Format"; do
  grep -q "^## $S" "$AGENT" && echo "✅ $S" || echo "❌ missing section: $S"
done

# 6. Swiss-army tool guard — warn if all 6 major tools present
TOOL_COUNT=$(grep '^tools:' "$AGENT" | grep -oE '\b(read|edit|search|execute|web|agent)\b' | wc -l | tr -d ' ')
[ "$TOOL_COUNT" -lt 6 ] && echo "✅ tools=$TOOL_COUNT (focused)" || echo "⚠️  tools=$TOOL_COUNT — verify each is essential"
```

### Step 6 — Sync to Active Environment

After creating the `.agent.md` and all dependency skills, run `agent-sync` to symlink the new files into `~/.copilot/` and VS Code's prompts directory. Without this step, the new agent and skills won't be available to Copilot in the current session.

```bash
source "$(git rev-parse --show-toplevel)/scripts/agent-sync.zsh" && agent-sync
```

Flags:
- `--dry-run` — preview what will be linked without making changes (use first to verify)
- `--force` — replace existing symlinks if they already exist

The sync script creates symlinks from:
- `~/.copilot/agents/` → agent source files
- `~/.copilot/skills/` → skill source files
- `~/Library/Application Support/Code/User/prompts/agents/` → VS Code prompts directory

**Always run sync after creating or modifying any agent or skill file.**

## Completion Checks

- [ ] Agent name is kebab-case and matches the filename (without `.agent.md`)
- [ ] `description` contains ≥3 trigger keywords for subagent discovery
- [ ] `tools` list is minimal — no tools included "just in case"
- [ ] `user-invocable` is set explicitly
- [ ] All referenced skills exist in `.github/skills/`
- [ ] Body has: identity statement, constraints (DO NOT rules), output format
- [ ] Identity statement names a specific, bounded role (not "helpful assistant", "assistant", or "agent")
- [ ] At least one adjacent task is explicitly excluded in the Constraints section (scope boundary is documented)
- [ ] `agent-sync` was run and new agent/skills are symlinked in `~/.copilot/`

## References

- [Agent Structure Template](./references/agent-structure.md)
