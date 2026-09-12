# AGENTS.md

## What This Repo Is

A personal incubator for AI agent skills targeting contribution to [github/awesome-copilot](https://github.com/github/awesome-copilot). Skills are drafted, refined, and validated here before being submitted upstream.

**Primary platforms: OpenCode and Cursor.** Copilot compatibility is retained through
the Agent Skills standard; Mistral Vibe and Antigravity are legacy integrations.

## No Build / Lint / Test / CI

This is a content repo — Markdown, shell scripts, and YAML frontmatter. There is no `package.json`, no build step, no linter, no type-checker, no CI workflows, and no test runner. Do not search for them.

## Directory Layout

**Canonical skill holder:** `.agents/skills/<name>/SKILL.md`

Compat symlinks (same content, different paths):

```
.agents/skills/          # canonical — edit here
.github/skills -> ../.agents/skills
skills -> .agents/skills
agents -> .github/agents
```

**Agents:**
- `.github/agents/<name>.agent.md` — canonical Copilot-format agent briefings
- `.opencode/agents/<name>.md` — OpenCode subagents and thin workflow adapters
- `.cursor/agents/<name>.md` — generated Cursor/cursor-agent subagents (do not edit directly)

After changing `.github/agents/*.agent.md`, run `./scripts/generate-cursor-agents.zsh`.

## OpenCode

- **`opencode.json`** — declares `skills.paths: [".agents/skills"]` and `instructions: ["AGENTS.md"]`
- **`.opencode/agents/` and `.opencode/commands/`** — OpenCode project adapters; the bootstrap can link them to the global OpenCode home
- **`.agents/skills/edd-loop/`** — canonical EDD skill; the bootstrap links it independently to `~/.config/opencode/skills/edd-loop/`
- **`.opencode/agents/nexter.md`** — canonical Nexter definition for OpenCode

After editing `opencode.json`, any agent file, or any skill, **quit and restart OpenCode** for changes to take effect.

After changing `.github/agents/nexter.agent.md`, run
`./scripts/generate-codex-agent.zsh` for the Codex artifact. The OpenCode
`nexter` file is a thin adapter, not the source of the full role instructions.

## Cursor + cursor-agent CLI

Cursor discovers skills from `.agents/skills/` and subagents from `.cursor/agents/` automatically in both the IDE and `cursor-agent`.

- **Skills** — all folders under `.agents/skills/`. `user-invocable: false` hides a
  background skill from the slash menu but keeps it available to the model.
- **Subagents** — `bashar`, `nexter`, `skiller`, `uix-designer`, `sara` in `.cursor/agents/`
- **Orchestration** — invoke `/sara` (Custom Mode) for team-lead routing; otherwise use specialist subagents directly
- **Global install** — `./scripts/setup-copilot-globals.sh` links to `~/.agents/skills/` and `~/.cursor/agents/`; OpenCode EDD adapters and the canonical skill are linked independently under `~/.config/opencode/`

This file (`AGENTS.md`) is loaded as project instructions by Cursor and cursor-agent.

## Where the Rules Live

- **`.github/copilot-instructions.md`** — skill/agent schema, structure rules, quality bar, upstream submission
- **`CLAUDE.md`** — validation script, token budget conventions

## Agent Conventions (OpenCode)

Agents live at `.opencode/agents/<name>.md`. OpenCode format:

```yaml
---
name: <name>
description: "Use when ... Do NOT use for ..."
mode: subagent   # subagent | primary | all
---
```

OpenCode adapters include `nexter` plus the hidden `edd-luna-worker` and
`edd-sol-verifier` EDD helpers. `.github/agents/*.agent.md` files are the
canonical role briefings and feed both the Cursor and Codex generators. The
canonical EDD skill remains `.agents/skills/edd-loop/`.

## Skill Validation

Use the inline shell snippet from `CLAUDE.md` (Validating a Skill section). Canonical path: `.agents/skills/<skill-name>/SKILL.md`.

## Skill Body Conventions

Every `SKILL.md` must have YAML frontmatter (`name`, `description`) and these sections in order:
1. `## When To Use` — triggers + `Do NOT use for` negative clause
2. `## Inputs To Collect First` — numbered list
3. `## Procedure` — `### Step N — Title` subsections
4. `## Completion Checks` — `- [ ]` checkboxes
5. `## References` — relative links

Use the invocation fields deliberately:

- Omit both for a normal, discoverable skill.
- Set `user-invocable: false` for background knowledge that should auto-load but
  not appear in the slash menu.
- Set `disable-model-invocation: true` only for an explicitly invoked workflow.
- Never set both to `true`/`false` respectively: that disables the skill entirely.

See `.github/copilot-instructions.md` for the full schema.

## Upstream Submission Checklist

When a skill is ready for awesome-copilot:
1. Copy the skill folder from `.agents/skills/` into the `skills/` directory of the upstream repo.
2. PR must target `staged` branch (not `main`).
3. Run `npm run skill:validate` **in the awesome-copilot repo** (that repo has the command; this one doesn't).
4. Include `🤖🤖🤖` in the PR title if submitting via an AI agent.
