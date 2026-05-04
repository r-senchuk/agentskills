# Agent Builder

Create a new `.agent.md` file or improve an existing agent definition.

Full procedure: `.github/skills/agent-builder/SKILL.md`

## Quick Reference

**Inputs required before starting:**
1. Agent name (kebab-case, maps to `<name>.agent.md`)
2. Purpose — one sentence: what job does this agent do that the default agent cannot?
3. User-facing or subagent? (`user-invocable: true/false`)
4. Tool requirements
5. Skills to assign (verify each exists first: `ls .github/skills/`)

**Dependency rule:** Never write the `.agent.md` until all required skills exist and are validated.

## Required `.agent.md` Structure

```yaml
---
name: <name>
description: "Use when ... Do NOT use for ... (≥3 keywords)"
tools: [minimal set]
user-invocable: false
---
```

Body sections (in order):
1. Identity statement — "You are a specialist at X. Your job is Y."
2. Task Complexity Rubric (for orchestrators: trivial vs non-trivial)
3. Skill Routing table — task type → SKILL.md path
4. Core Workflow — numbered steps
5. Constraints — explicit `DO NOT` rules
6. Output Format

**Tool selection for Copilot `.agent.md`:**
`read` | `edit` | `search` | `execute` | `web` | `agent`

**Equivalent Claude Code tools:**
`Read` | `Edit`/`Write` | `Bash` (search) | `Bash` | `WebSearch`/`WebFetch` | `Agent`

## Validation

```bash
AGENT=".github/agents/<name>.agent.md"
FILENAME=$(basename "$AGENT" .agent.md)
NAME_FIELD=$(grep -m1 '^name:' "$AGENT" | sed 's/name: *"\?//;s/"$//')
[ "$FILENAME" = "$NAME_FIELD" ] && echo "✅ name match" || echo "❌ mismatch"
for F in description tools user-invocable; do
  grep -q "^$F:" "$AGENT" && echo "✅ $F" || echo "❌ missing: $F"
done
grep -oE '\.github/skills/[^/]+/SKILL\.md' "$AGENT" | while read F; do
  [ -f "$F" ] && echo "✅ $F" || echo "❌ missing skill: $F"
done
for S in "Constraints" "Output Format"; do
  grep -q "^## $S" "$AGENT" && echo "✅ $S" || echo "❌ missing: $S"
done
```

After creating, run: `./scripts/setup-copilot-globals.sh --force`

If also creating a Claude Code variant skill file in `.claude/skills/`, run sync to link it to `~/.claude/skills/` as well.

## Claude Code Agent Briefing Pattern

When an agent is invoked via Claude Code's `Agent` tool, the caller reads the `.agent.md` file and passes its body as the `prompt`. The subagent receives this briefing as its full context. For this to work well:

1. **Self-contained briefing** — the body must work without prior conversation context. Include everything needed.
2. **Claude Code tool names** — the subagent will use `Read`, `Edit`, `Write`, `Bash`, `WebSearch`, `WebFetch`, `Agent`. Reference these, not Copilot aliases.
3. **Explicit output format** — the `## Output Format` section drives what the subagent returns to its caller. Be exact: structure, length, required fields.
4. **Skill routing at runtime** — the subagent reads skill files using `Read`. List the exact file paths in the routing table so the subagent can `Read(".github/skills/<name>/SKILL.md")` at runtime.
5. **Scope bound tightly** — the `## Constraints` section prevents scope drift. Write `DO NOT` rules for the most likely failure modes of that specific agent.

**Delegation pattern (Claude Code caller side):**
```
1. Read(".github/agents/<name>.agent.md")  → get briefing
2. Agent({ prompt: briefing + "\n\n---\n\nTask: " + user_task })  → spawn
3. Review output, retry with specific feedback if incomplete
4. Deliver synthesized result to user
```

**Agent file size:** Keep `.agent.md` body under 300 lines. Agents loaded as briefings should be dense with intent, not exhaustive tutorials. Move reference material to `.github/skills/<name>/references/`.
