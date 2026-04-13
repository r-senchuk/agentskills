# Copilot Instructions

This repository is a personal incubator for GitHub Copilot skills targeting contribution to [github/awesome-copilot](https://github.com/github/awesome-copilot). Skills are developed and refined here before being submitted upstream.

## Purpose and Quality Bar

Every skill must meet the [awesome-copilot quality guidelines](https://github.com/github/awesome-copilot/blob/main/CONTRIBUTING.md) before being submitted:

- **Specific and actionable** — addresses a concrete gap, not generic advice the model handles by default
- **Self-contained** — assume no prior context from the caller; all needed references are bundled
- **Tested** — verified to work with GitHub Copilot agents in real workflows
- **Meaningful uplift** — goes beyond what frontier models handle well on their own

Do not create skills that duplicate existing model strengths without adding specialized workflow, domain-specific constraints, or bundled assets that justify the skill.

## Repository Structure

```
.github/
├── skills/<skill-name>/          # One folder per skill
│   ├── SKILL.md                  # Required. Frontmatter + procedure body.
│   └── references/               # Optional. Loaded on-demand by the skill.
├── agents/<name>.agent.md        # Custom agent personas
├── references/                   # Shared cross-skill guidance (e.g. mistral-cross-cutting-guidance.md)
└── copilot-instructions.md       # This file. Workspace-wide always-on instructions.
scripts/
└── setup-copilot-globals.sh     # Symlinks skills + agents to ~/.copilot/ and VS Code profile
```

## Skill Frontmatter Schema

Every `SKILL.md` must start with a YAML frontmatter block between `---` delimiters:

```yaml
---
name: <kebab-case-name>          # max 64 chars; must match the directory name exactly
description: "One sentence shown to Copilot when selecting the skill."  # 10–1024 chars
argument-hint: "Comma-separated list of inputs the skill expects."
user-invocable: true             # false if the skill is internal/non-interactive
---
```

- `name` must match the directory name exactly.
- `description` drives skill selection — make it specific and action-oriented.
- `argument-hint` is surfaced as a prompt to the user; list concrete inputs.

## Skill Body Conventions

Structure the Markdown body with these sections (in order):

1. **When To Use** — trigger conditions AND at least one explicit `Do NOT use for` negative case
2. **Inputs To Collect First** — numbered list of required context
3. **Procedure** — top-level `## Procedure` header; each step as its own `### Step N — Title` subsection
4. **Completion Checks** — `- [ ]` checkbox format; verifiable, not subjective
5. **References** — relative `./references/` links only

Use fenced code blocks with language tags (`bash`, `python`, etc.) for all command examples.

## Agent Body Conventions

Structure the Markdown body with these sections:

1. **Identity statement** — "You are a specialist at X. Your job is Y." — specific bounded role
2. **Task Complexity Rubric** (for orchestrator agents) — define what counts as trivial vs non-trivial so the agent knows when to act directly vs delegate
3. **Skill Routing** (when multiple skills apply) — table: task type → `SKILL.md` path to read
4. **Core Workflow** — numbered steps for how the agent operates
5. **Constraints** — explicit `DO NOT` rules defining the safety boundary
6. **Output Format** — exactly what the agent returns

Frontmatter rules for agents:
- `tools`: use minimal set; document rationale in identity if all 6 tools are used
- Only `sara` is `user-invocable: true` — all other agents are subagents (`user-invocable: false`)
- `description` must contain "Use when" trigger, `Do NOT use for` negative clause, and ≥3 keywords
- `name` must match filename (kebab-case, no `.agent.md` extension)

## Adding a New Skill

1. Create `.github/skills/<skill-name>/SKILL.md` with the frontmatter schema above.
2. Add supporting reference docs under `.github/skills/<skill-name>/references/` if needed.
3. Link references from `SKILL.md` using relative paths (`./references/<file>.md`).
4. Keep the skill body self-contained — assume no prior context from the caller.
5. Check [awesome-copilot.github.com/skills](https://awesome-copilot.github.com/skills) to confirm the skill fills a real gap before building it.

Use the **`skiller`** agent (or the `skill-builder` skill directly) to research, author, and validate new skills. Always run the validation script in `skill-builder/references/quality-checklist.md` before committing.

## Adding a New Agent

1. Create `.github/agents/<name>.agent.md`.
2. List all required skills first — create any that don't exist.
3. Set `tools:` to the minimal set needed for the agent's role.
4. Use `user-invocable: false` for subagents; `true` for top-level picker agents.
5. Include `## Constraints` with explicit `DO NOT` rules.

## Submitting Upstream to awesome-copilot

When a skill is ready to submit to [github/awesome-copilot](https://github.com/github/awesome-copilot):
- Copy the skill folder into the `skills/` directory of that repo.
- PRs must target the `staged` branch (not `main`).
- Run `npm run skill:validate` in the awesome-copilot repo before opening the PR.
- Include `🤖🤖🤖` in the PR title if submitting via an AI agent for fast-track review.

## Skill and Agent Inventory

See [README.md](../README.md) for the full current skill and agent table.

### Skill Groups

**Mistral SDK** (`mistral-*`)  
Routed through the `mistral` subagent (via Sara). Covers: agent builder, function calling, embeddings/RAG, structured outputs, document AI, and Vibe CLI. The `mistral-sdk-router` skill is the entrypoint for ambiguous multi-surface tasks.

**Research & Meta** (`skill-builder`, `agent-builder`)  
Routed through the `skiller` subagent (via Sara). Covers: web-powered research, SKILL.md authoring/auditing, and `.agent.md` design.

**Shell & macOS** (`shell-script-audit`, `macos-homebrew-troubleshoot`, `zsh-config-expert`)  
Routed through the `bashar` subagent (via Sara). Covers: shell script auditing/hardening, macOS environment troubleshooting, Homebrew diagnostics, and zsh configuration.

### Agent Hierarchy

`sara` is the sole user-facing agent (team lead). She handles trivial tasks directly and may do bounded orchestration work such as classification, decomposition, comparison, and status synthesis. For non-trivial specialist work she delegates to `mistral`, `skiller`, or `bashar` based on domain. When no existing agent can handle a non-trivial task, Sara informs the user and immediately delegates to `skiller` to create the required agent — no manual approval gate.

### Shared References

`.github/references/mistral-cross-cutting-guidance.md` — shared API key, model selection, retry, and cost policies for all Mistral skills. Link as `../../references/mistral-cross-cutting-guidance.md` from inside a skill subdirectory.

## References

- [awesome-copilot.github.com](https://awesome-copilot.github.com/) — browse the full community collection
- [Agent Skills specification](https://agentskills.io/specification)
- [awesome-copilot CONTRIBUTING.md](https://github.com/github/awesome-copilot/blob/main/CONTRIBUTING.md)
