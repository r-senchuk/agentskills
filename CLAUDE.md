# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Repo Is

A personal incubator for GitHub Copilot skills and agents targeting contribution to [github/awesome-copilot](https://github.com/github/awesome-copilot). Skills are drafted, refined, and validated here before being submitted upstream.

## Bootstrap & Sync

After cloning, run the one-time bootstrap to symlink all skills and agents into global Copilot/Vibe directories:

```bash
# Preview changes (no writes)
./scripts/setup-copilot-globals.sh --dry-run

# Apply symlinks (Copilot, VS Code, Mistral Vibe)
./scripts/setup-copilot-globals.sh

# Re-link and replace conflicts
./scripts/setup-copilot-globals.sh --force
```

The script targets `~/.copilot/skills/`, `~/.copilot/agents/`, `~/Library/Application Support/Code/User/prompts/agents/`, `~/.vibe/skills/`, and `~/.vibe/agents/`. After setup, edits in this repo are reflected everywhere immediately via symlinks.

Optional shell alias — source from `~/.zshrc` to get `agent-sync` as a global command:
```bash
source "/path/to/agentskills/scripts/agent-sync.zsh"
```

## Validating a Skill

Run this inline validation script before committing any new or edited `SKILL.md`:

```bash
SKILL=".github/skills/<skill-name>/SKILL.md"
ROOT=$(git rev-parse --show-toplevel)
SKILL_ABS="$ROOT/$SKILL"
FOLDER=$(basename $(dirname "$SKILL_ABS"))
NAME=$(grep -m1 "^name:" "$SKILL_ABS" | sed 's/name: *//')

[ "$FOLDER" = "$NAME" ] && echo "✅ name match" || echo "❌ mismatch: folder=$FOLDER name=$NAME"
for F in name description argument-hint user-invocable; do
  grep -q "^$F:" "$SKILL_ABS" && echo "✅ $F" || echo "❌ missing: $F"
done
FM=$(sed -n '/^---$/,/^---$/p' "$SKILL_ABS" | head -20)
echo "$FM" | grep -q '[<>]' && echo "❌ XML tags in frontmatter" || echo "✅ no XML tags"
grep -m1 "^description:" "$SKILL_ABS" | grep -qi "use when\|when user\|use for" \
  && echo "✅ description has trigger phrase" || echo "❌ description missing trigger phrase"
for S in "When To Use" "Inputs To Collect First" "Procedure" "Completion Checks" "References"; do
  grep -q "^## $S" "$SKILL_ABS" && echo "✅ $S" || echo "❌ missing section: $S"
done
WC=$(wc -w < "$SKILL_ABS")
[ "$WC" -le 5000 ] && echo "✅ $WC words" || echo "❌ $WC words (limit 5000)"
```

## Skill Structure

Every skill lives under `.github/skills/<skill-name>/SKILL.md`. The folder name must exactly match the `name:` frontmatter field.

**Required frontmatter:**
```yaml
---
name: <kebab-case-name>        # max 64 chars; must match directory name
description: "One sentence..."  # must contain a trigger phrase ("Use when" / "Do NOT use for")
argument-hint: "Comma-separated inputs the skill expects."
user-invocable: true|false
---
```

**Required body sections (in order):**
1. `## When To Use` — trigger conditions + at least one explicit `Do NOT use for` negative case
2. `## Inputs To Collect First` — numbered list
3. `## Procedure` — each step as `### Step N — Title`
4. `## Completion Checks` — `- [ ]` checkbox format, verifiable not subjective
5. `## References` — relative `./references/` links only

If any section would push the body over 500 lines, extract it to `./references/<topic>.md`.

## Agent Structure

Every agent lives at `.github/agents/<name>.agent.md`. The `name` frontmatter must match the filename without `.agent.md`.

**Required frontmatter:**
```yaml
---
name: <name>
description: "Use when ... Do NOT use for ... (≥3 keywords)"
tools: [minimal set]
user-invocable: true|false  # only sara is true; all subagents are false
---
```

**Required body sections (in order):**
1. Identity statement — bounded role definition
2. Task Complexity Rubric (orchestrator agents only)
3. Skill Routing table — task type → `SKILL.md` path
4. Core Workflow — numbered steps
5. Constraints — explicit `DO NOT` rules
6. Output Format

## Agent Hierarchy

`sara` is the only user-facing agent. All others are subagents invoked by Sara:

| Subagent | Domain |
|---|---|
| `skiller` | Skill/agent authoring and audit — routes `skill-builder`, `agent-builder` |
| `mistral` | Mistral SDK — routes all `mistral-*` skills via `mistral-sdk-router` |
| `bashar` | macOS & shell — routes `shell-script-audit`, `macos-homebrew-troubleshoot`, `zsh-config-expert` |
| `nexter` | Next.js App Router — routes `nextjs-ssg`, `nextjs-intl`, `nextjs-tailwind-seo` |
| `uix-designer` | Garnebo visual UI — routes design/CRO/component skills |

When adding a new specialist domain, create the required skills first (`skiller` / `skill-builder`), then create the agent (`skiller` / `agent-builder`), then register it in Sara's routing table.

## Submitting Upstream

When a skill is ready for [github/awesome-copilot](https://github.com/github/awesome-copilot):

1. Copy the skill folder into the `skills/` directory of the upstream repo.
2. PRs must target the `staged` branch (not `main`).
3. Run `npm run skill:validate` in the awesome-copilot repo before opening the PR.
4. Include `🤖🤖🤖` in the PR title if submitting via an AI agent.

## Claude Code Usage

### Slash Commands

Skills in `.claude/skills/` are available as slash commands in Claude Code CLI:

| Command | Purpose |
|---|---|
| `/sara` | Activate Sara's team-lead routing mode — delegates to specialist agents |
| `/skill-builder` | Create or audit a `SKILL.md` |
| `/agent-builder` | Create or audit a `.agent.md` |
| `/validate-skill` | Run the 8-point validation checklist against a named skill |
| `/sync` | Refresh all symlinks via `setup-copilot-globals.sh` |

### Agent Delegation in Claude Code

Sara's orchestration model works natively in Claude Code via the `Agent` tool. When a task requires a specialist:

1. Read the relevant briefing: `Read(".github/agents/<name>.agent.md")`
2. Spawn the agent: pass briefing content + user task to the `Agent` tool
3. Review the agent's output before delivering to the user

**Domain → agent file mapping:**

| Domain | Briefing file |
|---|---|
| Skill/agent authoring | `.github/agents/skiller.agent.md` |
| Mistral SDK/CLI | `.github/agents/mistral.agent.md` |
| macOS & shell | `.github/agents/bashar.agent.md` |
| Next.js frontend | `.github/agents/nexter.agent.md` |
| Garnebo UI/design | `.github/agents/uix-designer.agent.md` |

**Note on tool name differences:** The `tools:` field in `.agent.md` files uses Copilot aliases (`read`, `edit`, `search`, `execute`, `web`, `agent`). The Claude Code equivalents are `Read`, `Edit`/`Write`, `Bash`, `WebSearch`/`WebFetch`, `Agent`. Interpret agent briefings accordingly.

## Token Efficiency

These rules apply to all agents in this repo. They prevent context bloat and keep multi-agent chains fast.

### Skill Loading — Two Tiers

| Tier | File | Lines | When to use |
|---|---|---|---|
| 1 — Quick reference | `.claude/skills/<name>.md` | ≤150 | Trivial tasks, scope check, procedure overview |
| 2 — Full procedure | `.github/skills/<name>/SKILL.md` | 150–500+ | Full create/audit/refactor cycle |

Always check Tier 1 first. For Tier 2, load lazily — read headers to locate the step, then load only that section:

```bash
# Locate the step without loading the full file
grep -n "^##\|^###" .github/skills/<name>/SKILL.md
# Then Read with offset + limit for just that step
```

Trivial tasks (defined in each agent's Task Complexity Rubric): skip skill file loading entirely.

### Brief Budget

Delegation briefs must stay ≤400 tokens. Assign budget by priority:

| Priority | Content | Budget |
|---|---|---|
| P0 — always | Role identity · Task · Done condition | ~60 tok |
| P0 — always | DO NOT constraints (max 5 rules) | ~80 tok |
| P1 — always | Expected output format | ~40 tok |
| P2 — include if fits | File paths · Prior agent key findings (≤3 bullets) | ~120 tok |
| P3 — omit | Background context · Verbatim file content >100 tok | Pass path instead |

### Session Hygiene

- Run `/compact` before starting a new multi-agent task in a long session.
- Pass file paths, not file content, whenever the subagent can read the file itself.
- Subagent responses over ~500 tokens: extract key findings before passing to the next agent or delivering to the user (see Sara's Delegation Harness → Orchestration).

## Shared References

`.github/references/mistral-cross-cutting-guidance.md` — shared API key, model selection, retry, and cost policies for all `mistral-*` skills. Link as `../../references/mistral-cross-cutting-guidance.md` from inside a skill subdirectory.
