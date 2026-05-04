# Skill Builder

Create a new `SKILL.md`, audit an existing one for quality gaps, or refactor one to meet standards.

Full procedure: `.github/skills/skill-builder/SKILL.md`

## Quick Reference

**Modes:** `create` | `audit` | `refactor`

**Inputs required before starting:**
1. Skill name (kebab-case, matches directory name exactly)
2. Mode: create, audit, or refactor
3. Domain summary (one sentence)
4. Target quality bar: this repo or upstream awesome-copilot

## Required SKILL.md Structure

```yaml
---
name: <kebab-case>
description: "Use when ... Do NOT use for ..."
argument-hint: "Comma-separated inputs"
user-invocable: true|false
---
```

Body sections (required, in order):
1. `## When To Use` — triggers + at least one `Do NOT use for` negative case
2. `## Inputs To Collect First` — numbered list
3. `## Procedure` — each step as `### Step N — Title`
4. `## Completion Checks` — `- [ ]` checkboxes, verifiable not subjective
5. `## References` — relative `./references/` links only

Body ≤ 500 lines. Extract larger content to `./references/<topic>.md`.

## Validation

After writing, run the validation script from `CLAUDE.md` (Validating a Skill section):

```bash
SKILL=".github/skills/<skill-name>/SKILL.md"
ROOT=$(git rev-parse --show-toplevel)
SKILL_ABS="$ROOT/$SKILL"
FOLDER=$(basename $(dirname "$SKILL_ABS"))
NAME=$(grep -m1 "^name:" "$SKILL_ABS" | sed 's/name: *//')
[ "$FOLDER" = "$NAME" ] && echo "✅ name match" || echo "❌ mismatch"
for F in name description argument-hint user-invocable; do
  grep -q "^$F:" "$SKILL_ABS" && echo "✅ $F" || echo "❌ missing: $F"
done
for S in "When To Use" "Inputs To Collect First" "Procedure" "Completion Checks" "References"; do
  grep -q "^## $S" "$SKILL_ABS" && echo "✅ $S" || echo "❌ missing: $S"
done
WC=$(wc -w < "$SKILL_ABS"); [ "$WC" -le 5000 ] && echo "✅ $WC words" || echo "❌ $WC words"
```

After creating the file, run the sync script: `./scripts/setup-copilot-globals.sh --force`

## Creating Claude Code-Native Skills

When the output is a `.claude/skills/<name>.md` file (not a Copilot SKILL.md), use this format:

```markdown
# Skill Name

One-line summary of what happens when this skill is invoked.

## Steps

1. Concrete action step using Claude Code tool names (Read, Bash, Edit, Write, Agent)
2. ...

## Done when

Verifiable condition or exact output that confirms success.
```

**Rules for Claude Code skills:**
- No YAML frontmatter — the file name IS the slash command (`/name`)
- Imperative voice: "Read...", "Run...", "Check..." — instructions, not descriptions
- Reference exact Claude Code tool names, not Copilot aliases
- Include commands and code inline — no deferred lookups
- Aim for ≤ 150 lines; extract detail to referenced files only when unavoidable
- State required inputs upfront and ask for any that are missing

**When to create a companion `.claude/skills/` file alongside a Copilot SKILL.md:**
- The skill is a workflow the user would explicitly invoke in Claude Code CLI (`/validate-skill`, `/sync`, `/sara`)
- The skill is a meta-workflow for managing this repo itself
- Do NOT create a companion for domain implementation skills loaded automatically by specialist subagents (e.g., `nextjs-ssg`, `mistral-function-calling`) — those are Copilot-only
