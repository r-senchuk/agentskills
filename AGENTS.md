# AGENTS.md

## What This Repo Is

A personal incubator for AI agent skills targeting contribution to [github/awesome-copilot](https://github.com/github/awesome-copilot). Skills are drafted, refined, and validated here before being submitted upstream.

**Primary platforms: OpenCode and Cursor.** Copilot, Mistral Vibe, and Antigravity support is paused (deprecated but not deleted — see `plugin.json` and `scripts/setup-copilot-globals.sh`).

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
- `.opencode/agents/<name>.md` — OpenCode subagents (nexter only today)
- `.cursor/agents/<name>.md` — generated Cursor/cursor-agent subagents (do not edit directly)

After changing `.github/agents/*.agent.md`, run `./scripts/generate-cursor-agents.zsh`.

## OpenCode

- **`opencode.json`** — declares `skills.paths: [".agents/skills"]` and `instructions: ["AGENTS.md"]`
- **`.opencode/agents/nexter.md`** — canonical Nexter definition for OpenCode

After editing `opencode.json`, any agent file, or any skill, **quit and restart OpenCode** for changes to take effect.

After changing `.opencode/agents/nexter.md`, run `./scripts/generate-codex-agent.zsh` for the Codex artifact.

## Cursor + cursor-agent CLI

Cursor discovers skills from `.agents/skills/` and subagents from `.cursor/agents/` automatically in both the IDE and `cursor-agent`.

- **Skills** — all folders under `.agents/skills/`; internal skills use `disable-model-invocation: true`
- **Subagents** — `bashar`, `nexter`, `skiller`, `uix-designer`, `sara` in `.cursor/agents/`
- **Orchestration** — invoke `/sara` (Custom Mode) for team-lead routing; otherwise use specialist subagents directly
- **Global install** — `./scripts/setup-copilot-globals.sh` links to `~/.agents/skills/` and `~/.cursor/agents/`

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

Currently only `nexter` (mode: subagent) is defined for OpenCode. Legacy `.github/agents/*.agent.md` files are the canonical source for Copilot-format briefings and feed the Cursor generator.

## Skill Validation

Use the inline shell snippet from `CLAUDE.md` (Validating a Skill section). Canonical path: `.agents/skills/<skill-name>/SKILL.md`.

## Skill Body Conventions

Every `SKILL.md` must have YAML frontmatter (`name`, `description`) and these sections in order:
1. `## When To Use` — triggers + `Do NOT use for` negative clause
2. `## Inputs To Collect First` — numbered list
3. `## Procedure` — `### Step N — Title` subsections
4. `## Completion Checks` — `- [ ]` checkboxes
5. `## References` — relative links

Add `disable-model-invocation: true` when `user-invocable: false` (Cursor slash-only skills).

See `.github/copilot-instructions.md` for the full schema.

## Upstream Submission Checklist

When a skill is ready for awesome-copilot:
1. Copy the skill folder from `.agents/skills/` into the `skills/` directory of the upstream repo.
2. PR must target `staged` branch (not `main`).
3. Run `npm run skill:validate` **in the awesome-copilot repo** (that repo has the command; this one doesn't).
4. Include `🤖🤖🤖` in the PR title if submitting via an AI agent.
