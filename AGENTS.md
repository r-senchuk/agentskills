# AGENTS.md

## What This Repo Is

A personal incubator for AI agent skills targeting contribution to [github/awesome-copilot](https://github.com/github/awesome-copilot). Skills are drafted, refined, and validated here before being submitted upstream.

**Primary platform: OpenCode.** Skills and agents are configured for OpenCode. Copilot, Mistral Vibe, and Antigravity support is paused (deprecated but not deleted — see `plugin.json` and `scripts/setup-copilot-globals.sh`).

## No Build / Lint / Test / CI

This is a content repo — Markdown, shell scripts, and YAML frontmatter. There is no `package.json`, no build step, no linter, no type-checker, no CI workflows, and no test runner. Do not search for them.

## OpenCode Config

- **`opencode.json`** — root-level config. Declares `$schema`, `skills.paths`, and `instructions`.
- **`.opencode/agents/nexter.md`** — the nexter subagent definition.
- **Skills** live at `.github/skills/<name>/SKILL.md` and are discovered via `skills.paths: [".github/skills"]` in `opencode.json`.

After editing `opencode.json`, any agent file, or any skill, **quit and restart OpenCode** for changes to take effect. OpenCode loads config once at startup and does not hot-reload.

`.opencode/agents/nexter.md` is the canonical Nexter definition. After changing it, run `./scripts/generate-codex-agent.zsh`; the generated `.codex/agents/nexter.toml` is the Codex-specific artifact and must not be edited directly.

## Directory Surface

The root-level `skills/` and `agents/` directories are **symlinks** to `.github/skills/` and `.github/agents/`:

```
agents -> .github/agents
skills -> .github/skills
```

Editing files under either path updates both. These symlinks were originally for Copilot/Antigravity integration via `plugin.json`; they're kept for backward compatibility.

## Where the Rules Live

- **`.github/copilot-instructions.md`** — skill/agent schema, structure rules, quality bar, upstream submission. Still the authoritative reference for SKILL.md structure.
- **`CLAUDE.md`** — validation script, token budget conventions. Still useful for quick validation.

## Agent Conventions (OpenCode)

Agents live at `.opencode/agents/<name>.md`. OpenCode format:

```yaml
---
name: <name>
description: "Use when ... Do NOT use for ..."
mode: subagent   # subagent | primary | all
---

# Identity and instructions...
```

- `mode: subagent` — invoked via the Task tool by another agent or the user. Not visible in the agent picker.
- `mode: primary` — user-facing, selectable agent.
- No `tools` or `user-invocable` fields — tool access is controlled via `permission` in `opencode.json`.

Currently only `nexter` (mode: subagent) is defined for OpenCode. The legacy `.github/agents/*.agent.md` files (Copilot format) are kept for reference.

## Skill Validation

Use the inline shell snippet from `CLAUDE.md` (Validating a Skill section). Checks: name/folder match, required frontmatter fields, required body sections, word count ≤5000, no XML tags in frontmatter.

## Skill Body Conventions

Every `SKILL.md` must have YAML frontmatter (`name`, `description`) and these sections in order:
1. `## When To Use` — triggers + `Do NOT use for` negative clause
2. `## Inputs To Collect First` — numbered list
3. `## Procedure` — `### Step N — Title` subsections
4. `## Completion Checks` — `- [ ]` checkboxes
5. `## References` — relative links

See `.github/copilot-instructions.md` for the full schema.

## Upstream Submission Checklist

When a skill is ready for awesome-copilot:
1. Copy the skill folder into the `skills/` directory of the upstream repo.
2. PR must target `staged` branch (not `main`).
3. Run `npm run skill:validate` **in the awesome-copilot repo** (that repo has the command; this one doesn't).
4. Include `🤖🤖🤖` in the PR title if submitting via an AI agent.
