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

Skills live under `.github/skills/<skill-name>/` and consist of:
- `SKILL.md` — skill definition (required); YAML frontmatter + structured Markdown body
- `references/` — optional supporting docs, scripts, or templates linked from `SKILL.md`

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

1. **When To Use** — conditions that trigger this skill
2. **Inputs To Collect First** — numbered list of required context
3. **Procedure** — numbered top-level steps, each expanded in its own `##` subsection
4. **Completion Checks** — bullet checklist verifying the skill outcome
5. **References** — relative links to files under `references/`

Use fenced code blocks with language tags for all command examples.

## Adding a New Skill

1. Create `.github/skills/<skill-name>/SKILL.md` with the frontmatter schema above.
2. Add supporting reference docs under `.github/skills/<skill-name>/references/` if needed.
3. Link references from `SKILL.md` using relative paths (`./references/<file>.md`).
4. Keep the skill body self-contained — assume no prior context from the caller.
5. Check [awesome-copilot.github.com/skills](https://awesome-copilot.github.com/skills) to confirm the skill fills a real gap before building it.

## Submitting Upstream to awesome-copilot

When a skill is ready to submit to [github/awesome-copilot](https://github.com/github/awesome-copilot):
- Copy the skill folder into the `skills/` directory of that repo.
- PRs must target the `staged` branch (not `main`).
- Run `npm run skill:validate` in the awesome-copilot repo before opening the PR.
- Include `🤖🤖🤖` in the PR title if submitting via an AI agent for fast-track review.

## Existing Skills

### mistral-vibe-expert

End-to-end workflow for operating [Mistral Vibe CLI](https://mistral.ai/vibe/). Key behavioral defaults:
- Safety-first profile: interactive mode with explicit approvals, least-privilege tools.
- Programmatic runs always require `--max-turns` and `--max-price` guards.
- All results are reported in the five-line `Vibe Outcome` format (Result / Scope / Evidence / Risks / Next step).
- Config files: `./.vibe/config.toml` (project-local) and `~/.vibe/config.toml` (global).
- API key: `MISTRAL_API_KEY` env var or `~/.vibe/.env`.

## References

- [awesome-copilot.github.com](https://awesome-copilot.github.com/) — browse the full community collection
- [Agent Skills specification](https://agentskills.io/specification)
- [awesome-copilot CONTRIBUTING.md](https://github.com/github/awesome-copilot/blob/main/CONTRIBUTING.md)
