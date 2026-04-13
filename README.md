# agentskills

A personal incubator for high-quality GitHub Copilot skills targeting contribution to the [**Awesome GitHub Copilot**](https://awesome-copilot.github.com/) collection.

> Skills here are developed to the quality bar required by [github/awesome-copilot](https://github.com/github/awesome-copilot) before being submitted upstream.

## What is this?

The [Awesome GitHub Copilot](https://awesome-copilot.github.com/) community collection accepts **Agent Skills** — self-contained folders with a `SKILL.md` instruction file and optional bundled assets (scripts, templates, reference data). Skills are loaded on-demand by Copilot agents for specialized, repeatable workflows.

This repository is where skills are drafted, refined, and validated before submission. The goal is to ship only well-tested, focused, high-signal contributions that address a real gap — not generic wrappers around what frontier models already handle well.

## Skills

| Skill | Description |
|-------|-------------|
| [agent-builder](.github/skills/agent-builder/SKILL.md) | Design and create a `.agent.md`: define scope, identify required skills, select minimal tools, write persona and constraints. |
| [agent-testing](.github/skills/agent-testing/SKILL.md) | Add mocked, integration, or eval-based tests for AI agents, tool calls, and multi-agent workflows. |
| [before-after-slider](.github/skills/before-after-slider/SKILL.md) | Build accessible before/after image comparison sliders with drag, touch, and keyboard support. |
| [context-engineering](.github/skills/context-engineering/SKILL.md) | Design token-budgeted context assembly, memory, and tool-result injection for LLM systems. |
| [cro-home-services](.github/skills/cro-home-services/SKILL.md) | Design and audit conversion-focused UX patterns for home-services renovation websites. |
| [floating-sticky-ui](.github/skills/floating-sticky-ui/SKILL.md) | Implement and debug sticky navigation, floating CTAs, widgets, and z-index layering. |
| [harness-engineering](.github/skills/harness-engineering/SKILL.md) | Design guardrails, feedback loops, state, observability, and error recovery for agent workflows. |
| [imagery-art-direction](.github/skills/imagery-art-direction/SKILL.md) | Select, optimize, and place renovation-site photography and visual assets for static Next.js export. |
| [macos-homebrew-troubleshoot](.github/skills/macos-homebrew-troubleshoot/SKILL.md) | Diagnose and fix macOS environment issues, Homebrew problems, PATH conflicts, and permissions. |
| [mistral-agent-builder](.github/skills/mistral-agent-builder/SKILL.md) | Build and operate persistent Mistral Agents with tools, handoffs, and guardrails. |
| [mistral-document-ai](.github/skills/mistral-document-ai/SKILL.md) | Extract text, tables, and structure from PDFs and images with Mistral OCR workflows. |
| [mistral-embeddings-rag](.github/skills/mistral-embeddings-rag/SKILL.md) | Build embeddings and RAG pipelines with chunking, retrieval, and grounded answers. |
| [mistral-function-calling](.github/skills/mistral-function-calling/SKILL.md) | Implement robust Mistral tool/function-calling loops with safe execution patterns. |
| [mistral-sdk-router](.github/skills/mistral-sdk-router/SKILL.md) | Route any Mistral API or SDK task to the correct specialized skill. |
| [mistral-structured-outputs](.github/skills/mistral-structured-outputs/SKILL.md) | Extract guaranteed typed JSON using schema-constrained structured outputs. |
| [mistral-vibe-expert](.github/skills/mistral-vibe-expert/SKILL.md) | Operate Mistral Vibe CLI with safe delegation, tool permissions, and clear result synthesis. |
| [mobile-first-layout](.github/skills/mobile-first-layout/SKILL.md) | Build responsive mobile-first page layouts, grids, and section shells for Tailwind/Next.js sites. |
| [nextjs-intl](.github/skills/nextjs-intl/SKILL.md) | Configure and troubleshoot `next-intl` internationalization in Next.js App Router projects. |
| [nextjs-ssg](.github/skills/nextjs-ssg/SKILL.md) | Scaffold and troubleshoot static-export Next.js App Router projects. |
| [nextjs-tailwind-seo](.github/skills/nextjs-tailwind-seo/SKILL.md) | Set up Tailwind CSS, SEO metadata, fonts, and structured data for Next.js projects. |
| [photo-upload-form-ux](.github/skills/photo-upload-form-ux/SKILL.md) | Design mobile-first quote funnels with embedded forms, photo guidance, and thank-you flows. |
| [shell-script-audit](.github/skills/shell-script-audit/SKILL.md) | Audit and harden shell scripts for stability, portability, error handling, and best practices. |
| [skill-builder](.github/skills/skill-builder/SKILL.md) | Create, audit, or refactor a SKILL.md with research, structure, and validation checks. |
| [tailwind-v4-theming](.github/skills/tailwind-v4-theming/SKILL.md) | Add and debug Tailwind CSS v4 theme tokens and extracted component utilities. |
| [trust-signal-components](.github/skills/trust-signal-components/SKILL.md) | Design trust-building UI components such as badges, guarantees, and compliance blocks. |
| [typography-color-tokens](.github/skills/typography-color-tokens/SKILL.md) | Design and audit visual identity tokens for color, typography, and spacing systems. |
| [visual-design-audit](.github/skills/visual-design-audit/SKILL.md) | Audit pages and components for brand consistency, accessibility, and CRO issues. |
| [zsh-config-expert](.github/skills/zsh-config-expert/SKILL.md) | Configure, troubleshoot, and optimize zsh: completions, startup files, prompt, glob qualifiers, performance. |

## Agents

| Agent | Description |
|-------|-------------|
| [sara](.github/agents/sara.agent.md) | Default team-lead agent. Handles trivial tasks and bounded orchestration work directly; delegates specialist work to subagents. The only user-facing agent. |
| [bashar](.github/agents/bashar.agent.md) | Subagent: macOS and shell specialist for script audits, Homebrew troubleshooting, zsh configuration, and PATH debugging. |
| [mistral](.github/agents/mistral.agent.md) | Subagent: specialist for building and operating Mistral SDK apps; routes to the correct Mistral skill. |
| [nexter](.github/agents/nexter.agent.md) | Subagent: Next.js specialist for App Router, static export, Tailwind, i18n, SEO, and component implementation. |
| [skiller](.github/agents/skiller.agent.md) | Subagent: researches domains, builds skills, and designs agents. Creates all dependency skills before writing the agent file. |
| [uix-designer](.github/agents/uix-designer.agent.md) | Subagent: senior UIX designer for vivid, trust-building, conversion-focused renovation website improvements. |

## Global Bootstrap (Mac)

This repo can be your single source of truth for global Copilot and Mistral Vibe capabilities on your Mac.

Use the one-time bootstrap script:
- [scripts/setup-copilot-globals.sh](scripts/setup-copilot-globals.sh)

What it does:
- Symlinks all skills from this repo into `~/.copilot/skills`
- Symlinks all agents from this repo into `~/.copilot/agents`
- Symlinks agents into VS Code user prompts profile (`~/Library/Application Support/Code/User/prompts/agents`)
- Symlinks all skills and agents into Mistral Vibe directories (`~/.vibe/skills` and `~/.vibe/agents`)

### Usage examples

```bash
# 1) Preview only
./scripts/setup-copilot-globals.sh --dry-run

# 2) Apply links (includes Mistral Vibe by default)
./scripts/setup-copilot-globals.sh

# 3) Skip Mistral Vibe linking
./scripts/setup-copilot-globals.sh --no-vibe

# 4) Use a custom Mistral Vibe home
./scripts/setup-copilot-globals.sh --vibe-home /path/to/custom/vibe

# 5) Replace existing conflicting links/files
./scripts/setup-copilot-globals.sh --force

# 6) Optional: make it callable globally
mkdir -p ~/bin
ln -sf "$HOME/path/to/agentskills/scripts/setup-copilot-globals.sh" ~/bin/setup-copilot-globals.sh
```

### Troubleshooting

```bash
# Check what is currently linked
ls -la ~/.copilot/skills
ls -la ~/.copilot/agents
ls -la "$HOME/Library/Application Support/Code/User/prompts/agents"
ls -la ~/.vibe/skills
ls -la ~/.vibe/agents

# Re-link and replace conflicting targets
./scripts/setup-copilot-globals.sh --force

# Validate that links still point to this repo
readlink ~/.copilot/skills/mistral-sdk-router
readlink ~/.copilot/agents/mistral.agent.md
readlink "$HOME/Library/Application Support/Code/User/prompts/agents/mistral.agent.md"
readlink ~/.vibe/skills/mistral-sdk-router
readlink ~/.vibe/agents/mistral.agent.md
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
