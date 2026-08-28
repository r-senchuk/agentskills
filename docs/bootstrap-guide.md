# Global Bootstrap Guide

This repository can serve as your single source of truth for global Codex, Cursor, Copilot, and Mistral Vibe capabilities on macOS.

## Bootstrap Script

Use the one-time bootstrap script to symlink all skills and agents:
- Location: [`scripts/setup-copilot-globals.sh`](scripts/setup-copilot-globals.sh)

### What It Does

The script creates symlinks from this repository to:
- `~/.agents/skills/` - Cursor/cursor-agent global skills (vendor-neutral)
- `~/.cursor/agents/` - Cursor subagents (generated from `.github/agents/`)
- `~/.codex/skills/` - Nexter's four reusable Next.js workflow skills
- `~/.codex/agents/` - Codex Nexter custom agent
- `~/.copilot/skills/` - Global Copilot skills directory
- `~/.copilot/agents/` - Global Copilot agents directory  
- `~/Library/Application Support/Code/User/prompts/agents/` - VS Code prompts profile
- `~/.vibe/skills/` - Mistral Vibe skills directory
- `~/.vibe/agents/` - Mistral Vibe agents directory

### Usage Examples

```bash
# 1) Preview only (dry run)
./scripts/setup-copilot-globals.sh --dry-run

# 2) Apply links (includes Codex and Mistral Vibe by default)
./scripts/setup-copilot-globals.sh

# 3) Skip Mistral Vibe linking
./scripts/setup-copilot-globals.sh --no-vibe

# 4) Use a custom Mistral Vibe home
./scripts/setup-copilot-globals.sh --vibe-home /path/to/custom/vibe

# 5) Use a custom Codex home or skip Codex / Cursor
./scripts/setup-copilot-globals.sh --codex-home /path/to/custom/codex
./scripts/setup-copilot-globals.sh --no-codex
./scripts/setup-copilot-globals.sh --no-cursor

# 6) Replace existing conflicting links/files
./scripts/setup-copilot-globals.sh --force

# 7) Optional: make it callable globally
mkdir -p ~/bin
ln -sf "$HOME/path/to/agentskills/scripts/setup-copilot-globals.sh" ~/bin/setup-copilot-globals.sh
```

### Troubleshooting

```bash
# Check what is currently linked
ls -la ~/.agents/skills
ls -la ~/.cursor/agents
ls -la ~/.copilot/skills
ls -la ~/.codex/skills
ls -la ~/.codex/agents
ls -la ~/.copilot/agents
ls -la "$HOME/Library/Application Support/Code/User/prompts/agents"
ls -la ~/.vibe/skills
ls -la ~/.vibe/agents

# Re-link and replace conflicting targets
./scripts/setup-copilot-globals.sh --force

# Validate that links still point to this repo
readlink ~/.copilot/skills/mistral-sdk-router
readlink ~/.codex/agents/nexter.toml
readlink ~/.copilot/agents/mistral.agent.md
readlink "$HOME/Library/Application Support/Code/User/prompts/agents/mistral.agent.md"
readlink ~/.vibe/skills/mistral-sdk-router
readlink ~/.vibe/agents/mistral.agent.md
```

If links look correct but capabilities do not appear:
1. Restart VS Code
2. Run the bootstrap script again with `--force`

After setup, any changes you make in this repository are reflected instantly everywhere those global symlinks are used.

### Updating Generated Agents

`.opencode/agents/nexter.md` is the canonical Nexter definition for OpenCode/Codex. `.github/agents/*.agent.md` files feed Cursor subagents. Regenerate before bootstrap:

```bash
./scripts/generate-codex-agent.zsh
./scripts/generate-cursor-agents.zsh
./scripts/setup-copilot-globals.sh
```

## Configuration Files

- `~/.vibe/config.toml` - Mistral Vibe configuration
- `~/.vibe/.env` - API keys and credentials
- `~/.vibe/trusted_folders.toml` - Trusted folder settings

## Model Configuration

Example model preset for Mistral Vibe:

```toml
[[providers]]
name = "openrouter"
api_base = "https://openrouter.ai/api/v1"
api_key_env_var = "OPENROUTER_API_KEY"
api_style = "openai"
backend = "generic"

[[models]]
name = "mistralai/devstral-2512:free"
provider = "openrouter"
alias = "devstral-openrouter"
temperature = 0.2
input_price = 0.0
output_price = 0.0

active_model = "devstral-openrouter"
```

## Local/Offline Model Workflow

For local model serving with vLLM:

```bash
vllm serve mistralai/Devstral-Small-2-24B-Instruct-2512 \
  --tool-call-parser mistral \
  --enable-auto-tool-choice \
  --port 8080
```

Then configure Vibe to use the local model via `/config` or update `config.toml`.
