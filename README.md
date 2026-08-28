# agentskills

A personal incubator for high-quality GitHub Copilot skills targeting contribution to the [**Awesome GitHub Copilot**](https://awesome-copilot.github.com/) collection.

> Skills here are developed to the quality bar required by [github/awesome-copilot](https://github.com/github/awesome-copilot) before being submitted upstream.

## What is this?

The [Awesome GitHub Copilot](https://awesome-copilot.github.com/) community collection accepts **Agent Skills** — self-contained folders with a `SKILL.md` instruction file and optional bundled assets (scripts, templates, reference data). Skills are loaded on-demand by Copilot agents for specialized, repeatable workflows.

This repository is where skills are drafted, refined, and validated before submission. The goal is to ship only well-tested, focused, high-signal contributions that address a real gap — not generic wrappers around what frontier models already handle well.

## Skills

| Skill | Description |
|-------|-------------|
| [agent-builder](.agents/skills/agent-builder/SKILL.md) | Design and create a `.agent.md`: define scope, identify required skills, select minimal tools, write persona and constraints. |
| [agent-testing](.agents/skills/agent-testing/SKILL.md) | Add mocked, integration, or eval-based tests for AI agents, tool calls, and multi-agent workflows. |
| [before-after-slider](.agents/skills/before-after-slider/SKILL.md) | Build accessible before/after image comparison sliders with drag, touch, and keyboard support. |
| [context-engineering](.agents/skills/context-engineering/SKILL.md) | Design token-budgeted context assembly, memory, and tool-result injection for LLM systems. |
| [cro-home-services](.agents/skills/cro-home-services/SKILL.md) | Design and audit conversion-focused UX patterns for home-services renovation websites. |
| [floating-sticky-ui](.agents/skills/floating-sticky-ui/SKILL.md) | Implement and debug sticky navigation, floating CTAs, widgets, and z-index layering. |
| [harness-engineering](.agents/skills/harness-engineering/SKILL.md) | Design guardrails, feedback loops, state, observability, and error recovery for agent workflows. |
| [imagery-art-direction](.agents/skills/imagery-art-direction/SKILL.md) | Select, optimize, and place renovation-site photography and visual assets for static Next.js export. |
| [macos-homebrew-troubleshoot](.agents/skills/macos-homebrew-troubleshoot/SKILL.md) | Diagnose and fix macOS environment issues, Homebrew problems, PATH conflicts, and permissions. |
| [mobile-first-layout](.agents/skills/mobile-first-layout/SKILL.md) | Build responsive mobile-first page layouts, grids, and section shells for Tailwind/Next.js sites. |
| [nextjs-intl](.agents/skills/nextjs-intl/SKILL.md) | Configure and troubleshoot `next-intl` internationalization in Next.js 16 App Router projects. |
| [nextjs-ssg](.agents/skills/nextjs-ssg/SKILL.md) | Scaffold and troubleshoot static-export Next.js 16 App Router projects. |
| [nextjs-tailwind-seo](.agents/skills/nextjs-tailwind-seo/SKILL.md) | Set up Tailwind CSS v4, SEO metadata, fonts, and structured data for Next.js 16 projects. |
| [photo-upload-form-ux](.agents/skills/photo-upload-form-ux/SKILL.md) | Design mobile-first quote funnels with embedded forms, photo guidance, and thank-you flows. |
| [shell-script-audit](.agents/skills/shell-script-audit/SKILL.md) | Audit and harden shell scripts for stability, portability, error handling, and best practices. |
| [skill-builder](.agents/skills/skill-builder/SKILL.md) | Create, audit, or refactor a SKILL.md with research, structure, and validation checks. |
| [tailwind-v4-theming](.agents/skills/tailwind-v4-theming/SKILL.md) | Add and debug Tailwind CSS v4 theme tokens and extracted component utilities. |
| [trust-signal-components](.agents/skills/trust-signal-components/SKILL.md) | Design trust-building UI components such as badges, guarantees, and compliance blocks. |
| [visual-design-audit](.agents/skills/visual-design-audit/SKILL.md) | Audit pages and components for brand consistency, accessibility, and CRO issues. |
| [zsh-config-expert](.agents/skills/zsh-config-expert/SKILL.md) | Configure, troubleshoot, and optimize zsh: completions, startup files, prompt, glob qualifiers, performance. |

## Agents

| Agent | Description |
|-------|-------------|
| [sara](.github/agents/sara.agent.md) | Default team-lead agent. Handles trivial tasks and bounded orchestration work directly; delegates specialist work to subagents. The only user-facing agent. |
| [bashar](.github/agents/bashar.agent.md) | Subagent: macOS and shell specialist for script audits, Homebrew troubleshooting, zsh configuration, and PATH debugging. |
| [nexter](.github/agents/nexter.agent.md) | Subagent: Next.js 16 specialist for App Router, static export, Tailwind v4, i18n, SEO, and component implementation. |
| [skiller](.github/agents/skiller.agent.md) | Subagent: researches domains, builds skills, and designs agents. Creates all dependency skills before writing the agent file. |
| [uix-designer](.github/agents/uix-designer.agent.md) | Subagent: senior UIX designer for vivid, trust-building, conversion-focused renovation website improvements. |

## Setup (All Platforms — Mac)

This repo is the single source of truth for skills and agents across Cursor, Codex, GitHub Copilot, Claude Code, Mistral Vibe, and Google Antigravity CLI on macOS.

See the [Bootstrap Guide](docs/bootstrap-guide.md) for complete setup instructions.

**Quick Start:**
```bash
# Preview changes
./scripts/setup-copilot-globals.sh --dry-run

# Apply symlinks (Codex, Cursor, Copilot, VS Code, Vibe, Claude Code, Antigravity)
./scripts/setup-copilot-globals.sh
```

After setup, any changes you make in this repository are reflected instantly everywhere via symlinks.

### Antigravity CLI

The bootstrap script symlinks this repo as a native Antigravity plugin:
```
~/.gemini/config/plugins/agentskills -> /path/to/agentskills
```
Antigravity reads `plugin.json` from the repo root to discover the `skills/` and `agents/` directories. Skills are loaded on demand — add them manually in your session when needed.

## Quality Bar

Every skill in this repo must meet the [awesome-copilot quality guidelines](https://github.com/github/awesome-copilot/blob/main/CONTRIBUTING.md) before being submitted upstream:

- **Specific and actionable** — addresses a concrete gap, not generic advice
- **Self-contained** — assume no prior context from the caller; include all needed references
- **Tested** — verified to work well with GitHub Copilot agents
- **Meaningful uplift** — goes beyond what the model handles by default

## Skill Structure

```
.agents/skills/<skill-name>/
  SKILL.md            # Required — frontmatter + structured workflow body
  references/         # Optional — supporting docs, scripts, templates
```

See [`.github/copilot-instructions.md`](.github/copilot-instructions.md) for the full authoring guide.

## Resources

- [awesome-copilot.github.com](https://awesome-copilot.github.com/) — browse the full community collection
- [Agent Skills specification](https://agentskills.io/specification)
- [awesome-copilot CONTRIBUTING.md](https://github.com/github/awesome-copilot/blob/main/CONTRIBUTING.md)
