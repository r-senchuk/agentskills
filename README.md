# agentskills

A personal incubator for high-quality GitHub Copilot skills targeting contribution to the [**Awesome GitHub Copilot**](https://awesome-copilot.github.com/) collection.

> Skills here are developed to the quality bar required by [github/awesome-copilot](https://github.com/github/awesome-copilot) before being submitted upstream.

## What is this?

The [Awesome GitHub Copilot](https://awesome-copilot.github.com/) community collection accepts **Agent Skills** — self-contained folders with a `SKILL.md` instruction file and optional bundled assets (scripts, templates, reference data). Skills are loaded on-demand by Copilot agents for specialized, repeatable workflows.

This repository is where skills are drafted, refined, and validated before submission. The goal is to ship only well-tested, focused, high-signal contributions that address a real gap — not generic wrappers around what frontier models already handle well.

## Skills

| Skill | Description |
|-------|-------------|
| [mistral-vibe-expert](.github/skills/mistral-vibe-expert/SKILL.md) | End-to-end workflow for operating Mistral Vibe CLI: setup, safe delegation, guardrails, and synthesizing results. |

## Quality Bar

Every skill in this repo must meet the [awesome-copilot quality guidelines](https://github.com/github/awesome-copilot/blob/main/CONTRIBUTING.md) before being submitted upstream:

- **Specific and actionable** — addresses a concrete gap, not generic advice
- **Self-contained** — assume no prior context from the caller; include all needed references
- **Tested** — verified to work well with GitHub Copilot agents
- **Meaningful uplift** — goes beyond what the model handles by default

## Skill Structure

```
.github/skills/<skill-name>/
  SKILL.md            # Required — frontmatter + structured workflow body
  references/         # Optional — supporting docs, scripts, templates
```

See [`.github/copilot-instructions.md`](.github/copilot-instructions.md) for the full authoring guide.

## Resources

- [awesome-copilot.github.com](https://awesome-copilot.github.com/) — browse the full community collection
- [Agent Skills specification](https://agentskills.io/specification)
- [awesome-copilot CONTRIBUTING.md](https://github.com/github/awesome-copilot/blob/main/CONTRIBUTING.md)
