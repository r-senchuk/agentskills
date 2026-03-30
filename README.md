# agentskills

A personal incubator for high-quality GitHub Copilot skills targeting contribution to the [**Awesome GitHub Copilot**](https://awesome-copilot.github.com/) collection.

> Skills here are developed to the quality bar required by [github/awesome-copilot](https://github.com/github/awesome-copilot) before being submitted upstream.

## What is this?

The [Awesome GitHub Copilot](https://awesome-copilot.github.com/) community collection accepts **Agent Skills** — self-contained folders with a `SKILL.md` instruction file and optional bundled assets (scripts, templates, reference data). Skills are loaded on-demand by Copilot agents for specialized, repeatable workflows.

This repository is where skills are drafted, refined, and validated before submission. The goal is to ship only well-tested, focused, high-signal contributions that address a real gap — not generic wrappers around what frontier models already handle well.

## Skills

| Skill | Description |
|-------|-------------|
| [mistral-sdk-router](.github/skills/mistral-sdk-router/SKILL.md) | Entrypoint router for Mistral API and SDK tasks; delegates to the correct specialized skill. |
| [mistral-agent-builder](.github/skills/mistral-agent-builder/SKILL.md) | Build and operate persistent Mistral Agents with tools, handoffs, and guardrails. |
| [mistral-function-calling](.github/skills/mistral-function-calling/SKILL.md) | Implement robust tool/function calling loops with schema design and safe execution patterns. |
| [mistral-embeddings-rag](.github/skills/mistral-embeddings-rag/SKILL.md) | Build embeddings and RAG pipelines with chunking, retrieval, and grounded answers. |
| [mistral-structured-outputs](.github/skills/mistral-structured-outputs/SKILL.md) | Extract guaranteed typed JSON using schema-constrained structured outputs. |
| [mistral-document-ai](.github/skills/mistral-document-ai/SKILL.md) | OCR and structured extraction from PDFs/images, including batch processing patterns. |
| [mistral-vibe-expert](.github/skills/mistral-vibe-expert/SKILL.md) | End-to-end workflow for operating Mistral Vibe CLI with safe delegation and clear result synthesis. |
| [perplexity-research-assistant](.github/skills/perplexity-research-assistant/SKILL.md) | Use Perplexity APIs for source-grounded, up-to-date web research with strong query and citation discipline. |
| [skill-builder](.github/skills/skill-builder/SKILL.md) | Create, audit, or refactor a SKILL.md: research domain, structure content, validate frontmatter and sections. |
| [agent-builder](.github/skills/agent-builder/SKILL.md) | Design and create a `.agent.md`: define scope, identify required skills, select minimal tools, write persona and constraints. |
| [shell-script-audit](.github/skills/shell-script-audit/SKILL.md) | Audit and harden shell scripts for stability, portability, error handling, and best practices. |
| [macos-homebrew-troubleshoot](.github/skills/macos-homebrew-troubleshoot/SKILL.md) | Diagnose and fix macOS environment issues, Homebrew problems, PATH conflicts, and permissions. |
| [zsh-config-expert](.github/skills/zsh-config-expert/SKILL.md) | Configure, troubleshoot, and optimize zsh: completions, startup files, prompt, glob qualifiers, performance. |

## Agents

| Agent | Description |
|-------|-------------|
| [sara](.github/agents/sara.agent.md) | Default team-lead agent. Handles trivial tasks directly; delegates complex work to specialized subagents. The only user-facing agent. |
| [mistral](.github/agents/mistral.agent.md) | Subagent: specialist for building and operating Mistral SDK apps; routes to the correct Mistral skill. |
| [skiller](.github/agents/skiller.agent.md) | Subagent: researches domains, builds skills, and designs agents. Creates all dependency skills before writing the agent file. |
| [bashar](.github/agents/bashar.agent.md) | Subagent: macOS & shell specialist — script auditing, macOS/Homebrew troubleshooting, zsh configuration, PATH debugging. |

## Global Bootstrap (Mac)

This repo can be your single source of truth for global Copilot capabilities on your Mac.

Use the one-time bootstrap script:
- [scripts/setup-copilot-globals.sh](scripts/setup-copilot-globals.sh)

What it does:
- Symlinks all skills from this repo into `~/.copilot/skills`
- Symlinks all agents from this repo into `~/.copilot/agents`
- Symlinks agents into VS Code user prompts profile (`~/Library/Application Support/Code/User/prompts/agents`)

### Usage examples

```bash
# 1) Preview only
./scripts/setup-copilot-globals.sh --dry-run

# 2) Apply links
./scripts/setup-copilot-globals.sh

# 3) Replace existing conflicting links/files
./scripts/setup-copilot-globals.sh --force

# 4) Optional: make it callable globally
mkdir -p ~/bin
ln -sf "$HOME/path/to/agentskills/scripts/setup-copilot-globals.sh" ~/bin/setup-copilot-globals.sh
```

### Troubleshooting

```bash
# Check what is currently linked
ls -la ~/.copilot/skills
ls -la ~/.copilot/agents
ls -la "$HOME/Library/Application Support/Code/User/prompts/agents"

# Re-link and replace conflicting targets
./scripts/setup-copilot-globals.sh --force

# Validate that links still point to this repo
readlink ~/.copilot/skills/mistral-sdk-router
readlink ~/.copilot/agents/mistral.agent.md
readlink "$HOME/Library/Application Support/Code/User/prompts/agents/mistral.agent.md"
```

If links look correct but capabilities do not appear, restart VS Code and run the bootstrap script again with `--force`.

After setup, any changes you make in this repository are reflected instantly everywhere those global symlinks are used.

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
