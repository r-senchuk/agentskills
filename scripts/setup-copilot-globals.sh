#!/bin/zsh
# Global bootstrap for Codex, OpenCode, Cursor/cursor-agent, and legacy
# Copilot, VS Code, Mistral Vibe, Claude Code, and Antigravity integrations.
set -euo pipefail
setopt null_glob

# One-time bootstrap for global skills/agents via symlinks.
# After linking, updates in this repo are reflected everywhere immediately.

# Use zsh path expansion for macOS/BSD portability (avoids GNU-only dirname flags).
SCRIPT_DIR="${0:A:h}"
DEFAULT_REPO_ROOT="${SCRIPT_DIR:h}"

REPO_ROOT="$DEFAULT_REPO_ROOT"
COPILOT_HOME="${COPILOT_HOME:-$HOME/.copilot}"
VSCODE_PROMPTS_DIR="${VSCODE_PROMPTS_DIR:-$HOME/Library/Application Support/Code/User/prompts}"
VIBE_HOME="${VIBE_HOME:-$HOME/.vibe}"
CLAUDE_HOME="${CLAUDE_HOME:-$HOME/.claude}"
CODEX_GLOBAL_HOME="${CODEX_GLOBAL_HOME:-$HOME/.codex}"
OPENCODE_HOME="${OPENCODE_HOME:-$HOME/.config/opencode}"
ANTIGRAVITY_PLUGIN_DIR="${ANTIGRAVITY_PLUGIN_DIR:-$HOME/.gemini/config/plugins/agentskills}"
AGENTS_GLOBAL_HOME="${AGENTS_GLOBAL_HOME:-$HOME/.agents}"
CURSOR_HOME="${CURSOR_HOME:-$HOME/.cursor}"
LINK_VSCODE_AGENTS=1
LINK_VIBE=1
LINK_CLAUDE=1
LINK_CODEX=1
LINK_OPENCODE=1
LINK_CURSOR=1
LINK_ANTIGRAVITY=1
FORCE=0
DRY_RUN=0
EDD_ONLY=0

usage() {
  cat <<'EOF'
Usage: setup-copilot-globals.sh [options]

Options:
  --repo <path>           Repo root containing .agents/skills and .github/agents.
                          Default: parent directory of this script.
  --copilot-home <path>   Global Copilot home. Default: ~/.copilot
  --vscode-prompts <path> VS Code prompts dir. Default: ~/Library/Application Support/Code/User/prompts
  --vibe-home <path>      Mistral Vibe home. Default: ~/.vibe
  --claude-home <path>    Claude Code home. Default: ~/.claude
  --codex-home <path>     Codex home. Default: ~/.codex
  --opencode-home <path>  OpenCode global home. Default: ~/.config/opencode
  --antigravity-plugin <path> Antigravity plugin dir. Default: ~/.gemini/config/plugins/agentskills
  --no-vscode-agents      Skip linking agents into VS Code prompts profile.
  --no-vibe               Skip linking skills/agents into Mistral Vibe.
  --no-claude             Skip linking skills into Claude Code.
  --no-codex              Skip linking Codex agents and skills.
  --no-opencode           Skip linking OpenCode skills, agents, and commands globally.
  --edd-only              Install only the EDD skill and its Codex/OpenCode adapters.
  --no-cursor             Skip linking skills/agents into Cursor (~/.agents, ~/.cursor).
  --cursor-home <path>    Cursor home. Default: ~/.cursor
  --agents-home <path>    Global .agents home. Default: ~/.agents
  --no-antigravity        Skip linking skills/agents into Antigravity.
  --force                 Replace existing files/symlinks at target paths.
  --dry-run               Show actions without making changes.
  -h, --help              Show this help.

Examples:
  ./scripts/setup-copilot-globals.sh
  ./scripts/setup-copilot-globals.sh --repo "$HOME/path/to/agentskills"
  ./scripts/setup-copilot-globals.sh --force
EOF
}

log() {
  printf '%s\n' "$*"
}

warn() {
  printf '%s\n' "$*" >&2
}

run_cmd() {
  if (( DRY_RUN )); then
    log "[dry-run] $*"
  else
    "$@"
  fi
}

while (( $# > 0 )); do
  case "$1" in
    --repo)
      [[ $# -ge 2 ]] || { warn "Missing value for --repo"; exit 1; }
      REPO_ROOT="$2"
      shift 2
      ;;
    --copilot-home)
      [[ $# -ge 2 ]] || { warn "Missing value for --copilot-home"; exit 1; }
      COPILOT_HOME="$2"
      shift 2
      ;;
    --vscode-prompts)
      [[ $# -ge 2 ]] || { warn "Missing value for --vscode-prompts"; exit 1; }
      VSCODE_PROMPTS_DIR="$2"
      shift 2
      ;;
    --no-vscode-agents)
      LINK_VSCODE_AGENTS=0
      shift
      ;;
    --no-vibe)
      LINK_VIBE=0
      shift
      ;;
    --vibe-home)
      [[ $# -ge 2 ]] || { warn "Missing value for --vibe-home"; exit 1; }
      VIBE_HOME="$2"
      shift 2
      ;;
    --no-claude)
      LINK_CLAUDE=0
      shift
      ;;
    --claude-home)
      [[ $# -ge 2 ]] || { warn "Missing value for --claude-home"; exit 1; }
      CLAUDE_HOME="$2"
      shift 2
      ;;
    --no-codex)
      LINK_CODEX=0
      shift
      ;;
    --no-opencode)
      LINK_OPENCODE=0
      shift
      ;;
    --edd-only)
      EDD_ONLY=1
      shift
      ;;
    --opencode-home)
      [[ $# -ge 2 ]] || { warn "Missing value for --opencode-home"; exit 1; }
      OPENCODE_HOME="$2"
      shift 2
      ;;
    --no-cursor)
      LINK_CURSOR=0
      shift
      ;;
    --cursor-home)
      [[ $# -ge 2 ]] || { warn "Missing value for --cursor-home"; exit 1; }
      CURSOR_HOME="$2"
      shift 2
      ;;
    --agents-home)
      [[ $# -ge 2 ]] || { warn "Missing value for --agents-home"; exit 1; }
      AGENTS_GLOBAL_HOME="$2"
      shift 2
      ;;
    --codex-home)
      [[ $# -ge 2 ]] || { warn "Missing value for --codex-home"; exit 1; }
      CODEX_GLOBAL_HOME="$2"
      shift 2
      ;;
    --no-antigravity)
      LINK_ANTIGRAVITY=0
      shift
      ;;
    --antigravity-plugin)
      [[ $# -ge 2 ]] || { warn "Missing value for --antigravity-plugin"; exit 1; }
      ANTIGRAVITY_PLUGIN_DIR="$2"
      shift 2
      ;;
    --force)
      FORCE=1
      shift
      ;;
    --dry-run)
      DRY_RUN=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      warn "Unknown option: $1"
      usage
      exit 1
      ;;
  esac
done

[[ -d "$REPO_ROOT" ]] || { warn "Missing repo root directory: $REPO_ROOT"; exit 1; }
REPO_ROOT="$(cd -- "$REPO_ROOT" && pwd)"
SKILLS_SRC="$REPO_ROOT/.agents/skills"
AGENTS_SRC="$REPO_ROOT/.github/agents"
COPILOT_SKILLS_DIR="$COPILOT_HOME/skills"
COPILOT_AGENTS_DIR="$COPILOT_HOME/agents"
VSCODE_AGENTS_DIR="$VSCODE_PROMPTS_DIR/agents"
VIBE_SKILLS_DIR="$VIBE_HOME/skills"
VIBE_AGENTS_DIR="$VIBE_HOME/agents"
CLAUDE_SKILLS_SRC="$REPO_ROOT/.claude/skills"
CLAUDE_SKILLS_DIR="$CLAUDE_HOME/skills"
CLAUDE_AGENTS_DIR="$CLAUDE_HOME/agents"
CODEX_SKILLS_DIR="$CODEX_GLOBAL_HOME/skills"
CODEX_AGENTS_SRC="$REPO_ROOT/.codex/agents"
CODEX_AGENTS_DIR="$CODEX_GLOBAL_HOME/agents"
CODEX_AGENT_GENERATOR="$REPO_ROOT/scripts/generate-codex-agent.zsh"
OPENCODE_AGENTS_SRC="$REPO_ROOT/.opencode/agents"
OPENCODE_COMMANDS_SRC="$REPO_ROOT/.opencode/commands"
OPENCODE_SKILLS_SRC="$REPO_ROOT/.agents/skills/edd-loop"
OPENCODE_AGENTS_DIR="$OPENCODE_HOME/agents"
OPENCODE_COMMANDS_DIR="$OPENCODE_HOME/commands"
OPENCODE_SKILLS_DIR="$OPENCODE_HOME/skills"
CURSOR_AGENT_GENERATOR="$REPO_ROOT/scripts/generate-cursor-agents.zsh"
CURSOR_AGENTS_SRC="$REPO_ROOT/.cursor/agents"
AGENTS_GLOBAL_SKILLS_DIR="$AGENTS_GLOBAL_HOME/skills"
CURSOR_AGENTS_DIR="$CURSOR_HOME/agents"
CODEX_SKILL_NAMES=(edd-loop nextjs-ssg nextjs-intl nextjs-tailwind-seo typescript-7)
CODEX_AGENT_NAMES=(nexter.toml edd_verifier.toml)
EDD_CODEX_SKILL_NAME=edd-loop
EDD_CODEX_AGENT_NAME=edd_verifier.toml
OPENCODE_EDD_AGENT_NAMES=(edd-luna-worker.md edd-sol-verifier.md)
OPENCODE_EDD_COMMAND_NAMES=(edd-loop.md)
# Antigravity uses a plugin directory — we symlink the whole repo as a plugin.
# The plugin.json at the repo root tells Antigravity where skills/ and agents/ live.

[[ -d "$SKILLS_SRC" ]] || { warn "Missing directory: $SKILLS_SRC"; exit 1; }
[[ -d "$AGENTS_SRC" ]] || { warn "Missing directory: $AGENTS_SRC"; exit 1; }

if (( EDD_ONLY )); then
  LINK_VSCODE_AGENTS=0
  LINK_VIBE=0
  LINK_CLAUDE=0
  LINK_CURSOR=0
  LINK_ANTIGRAVITY=0
  LINK_CODEX=1
  LINK_OPENCODE=1
fi

if (( LINK_CODEX && !EDD_ONLY )); then
  [[ -x "$CODEX_AGENT_GENERATOR" ]] || { warn "Missing Codex agent generator: $CODEX_AGENT_GENERATOR"; exit 1; }
  "$CODEX_AGENT_GENERATOR" --check || { warn "Regenerate the Codex agent before installing: scripts/generate-codex-agent.zsh"; exit 1; }
fi
if (( LINK_CURSOR )); then
  [[ -x "$CURSOR_AGENT_GENERATOR" ]] || { warn "Missing Cursor agent generator: $CURSOR_AGENT_GENERATOR"; exit 1; }
  "$CURSOR_AGENT_GENERATOR" --check || { warn "Regenerate Cursor agents before installing: scripts/generate-cursor-agents.zsh"; exit 1; }
fi
if (( LINK_OPENCODE )); then
  [[ -d "$OPENCODE_AGENTS_SRC" ]] || { warn "Missing OpenCode agents directory: $OPENCODE_AGENTS_SRC"; exit 1; }
  [[ -d "$OPENCODE_COMMANDS_SRC" ]] || { warn "Missing OpenCode commands directory: $OPENCODE_COMMANDS_SRC"; exit 1; }
  [[ -d "$OPENCODE_SKILLS_SRC" ]] || { warn "Missing OpenCode EDD skill source: $OPENCODE_SKILLS_SRC"; exit 1; }
  if (( EDD_ONLY )); then
    for opencode_agent_name in "${OPENCODE_EDD_AGENT_NAMES[@]}"; do
      [[ -f "$OPENCODE_AGENTS_SRC/$opencode_agent_name" ]] || { warn "Missing OpenCode agent source: $OPENCODE_AGENTS_SRC/$opencode_agent_name"; exit 1; }
    done
    for opencode_command_name in "${OPENCODE_EDD_COMMAND_NAMES[@]}"; do
      [[ -f "$OPENCODE_COMMANDS_SRC/$opencode_command_name" ]] || { warn "Missing OpenCode command source: $OPENCODE_COMMANDS_SRC/$opencode_command_name"; exit 1; }
    done
  fi
  run_cmd mkdir -p "$OPENCODE_AGENTS_DIR" "$OPENCODE_COMMANDS_DIR" "$OPENCODE_SKILLS_DIR"
fi

if (( !EDD_ONLY )); then
  run_cmd mkdir -p "$COPILOT_SKILLS_DIR" "$COPILOT_AGENTS_DIR"
  if (( LINK_VSCODE_AGENTS )); then
    run_cmd mkdir -p "$VSCODE_AGENTS_DIR"
  fi
  if (( LINK_VIBE )); then
    run_cmd mkdir -p "$VIBE_SKILLS_DIR" "$VIBE_AGENTS_DIR"
  fi
  if (( LINK_CLAUDE )); then
    run_cmd mkdir -p "$CLAUDE_SKILLS_DIR" "$CLAUDE_AGENTS_DIR"
  fi
fi
if (( LINK_CODEX )); then
  if (( EDD_ONLY )); then
    [[ -f "$CODEX_AGENTS_SRC/$EDD_CODEX_AGENT_NAME" ]] || { warn "Missing Codex agent source: $CODEX_AGENTS_SRC/$EDD_CODEX_AGENT_NAME"; exit 1; }
    [[ -d "$SKILLS_SRC/$EDD_CODEX_SKILL_NAME" ]] || { warn "Missing Codex skill source: $SKILLS_SRC/$EDD_CODEX_SKILL_NAME"; exit 1; }
  else
    for agent_name in "${CODEX_AGENT_NAMES[@]}"; do
      [[ -f "$CODEX_AGENTS_SRC/$agent_name" ]] || { warn "Missing Codex agent source: $CODEX_AGENTS_SRC/$agent_name"; exit 1; }
    done
    for skill_name in "${CODEX_SKILL_NAMES[@]}"; do
      [[ -d "$SKILLS_SRC/$skill_name" ]] || { warn "Missing Codex skill source: $SKILLS_SRC/$skill_name"; exit 1; }
    done
  fi
  run_cmd mkdir -p "$CODEX_SKILLS_DIR" "$CODEX_AGENTS_DIR"
fi
if (( LINK_CURSOR )); then
  [[ -d "$CURSOR_AGENTS_SRC" ]] || { warn "Missing Cursor agents directory: $CURSOR_AGENTS_SRC"; exit 1; }
  run_cmd mkdir -p "$AGENTS_GLOBAL_SKILLS_DIR" "$CURSOR_AGENTS_DIR"
fi
if (( LINK_ANTIGRAVITY )); then
  run_cmd mkdir -p "$(dirname "$ANTIGRAVITY_PLUGIN_DIR")"
fi

linked=0
skipped=0
replaced=0

link_one() {
  local src="$1"
  local dest_dir="$2"
  local name dest existing

  name="${src:t}"
  dest="$dest_dir/$name"

  if [[ -L "$dest" ]]; then
    existing="$(readlink "$dest")"
    if [[ "$existing" == "$src" ]]; then
      log "= already linked: $dest"
      return 0
    fi
    if (( FORCE )); then
      run_cmd rm -f "${dest:?dest is empty}"
      replaced=$((replaced + 1))
    else
      warn "! skip (symlink exists, use --force): $dest -> $existing"
      skipped=$((skipped + 1))
      return 0
    fi
  elif [[ -e "$dest" ]]; then
    if (( FORCE )); then
      run_cmd rm -rf "${dest:?dest is empty}"
      replaced=$((replaced + 1))
    else
      warn "! skip (path exists, use --force): $dest"
      skipped=$((skipped + 1))
      return 0
    fi
  fi

  run_cmd ln -s -- "$src" "$dest"
  if (( DRY_RUN )); then
    log "+ would link: $dest -> $src"
  else
    log "+ linked: $dest -> $src"
  fi
  linked=$((linked + 1))
}

if (( !EDD_ONLY )); then
  for skill_dir in "$SKILLS_SRC"/*(N/); do
    # Ignore empty/legacy directories that are not Agent Skills.
    [[ -f "$skill_dir/SKILL.md" ]] || continue
    link_one "$skill_dir" "$COPILOT_SKILLS_DIR"
    if (( LINK_VIBE )); then
      link_one "$skill_dir" "$VIBE_SKILLS_DIR"
    fi
    if (( LINK_CURSOR )); then
      link_one "$skill_dir" "$AGENTS_GLOBAL_SKILLS_DIR"
    fi
  done
fi

if (( LINK_CODEX )); then
  if (( EDD_ONLY )); then
    link_one "$SKILLS_SRC/$EDD_CODEX_SKILL_NAME" "$CODEX_SKILLS_DIR"
    link_one "$CODEX_AGENTS_SRC/$EDD_CODEX_AGENT_NAME" "$CODEX_AGENTS_DIR"
  else
    for skill_name in "${CODEX_SKILL_NAMES[@]}"; do
      link_one "$SKILLS_SRC/$skill_name" "$CODEX_SKILLS_DIR"
    done
    for agent_name in "${CODEX_AGENT_NAMES[@]}"; do
      link_one "$CODEX_AGENTS_SRC/$agent_name" "$CODEX_AGENTS_DIR"
    done
  fi
fi

if (( LINK_OPENCODE )); then
  link_one "$OPENCODE_SKILLS_SRC" "$OPENCODE_SKILLS_DIR"
  if (( EDD_ONLY )); then
    for opencode_agent_name in "${OPENCODE_EDD_AGENT_NAMES[@]}"; do
      link_one "$OPENCODE_AGENTS_SRC/$opencode_agent_name" "$OPENCODE_AGENTS_DIR"
    done
    for opencode_command_name in "${OPENCODE_EDD_COMMAND_NAMES[@]}"; do
      link_one "$OPENCODE_COMMANDS_SRC/$opencode_command_name" "$OPENCODE_COMMANDS_DIR"
    done
  else
    for opencode_agent in "$OPENCODE_AGENTS_SRC"/*.md(.N); do
      link_one "$opencode_agent" "$OPENCODE_AGENTS_DIR"
    done
    for opencode_command in "$OPENCODE_COMMANDS_SRC"/*.md(.N); do
      link_one "$opencode_command" "$OPENCODE_COMMANDS_DIR"
    done
  fi
fi

if (( LINK_ANTIGRAVITY )); then
  link_one "$REPO_ROOT" "$(dirname "$ANTIGRAVITY_PLUGIN_DIR")"
fi

if (( !EDD_ONLY )); then
  for agent_file in "$AGENTS_SRC"/*.agent.md(.N); do
    link_one "$agent_file" "$COPILOT_AGENTS_DIR"
    if (( LINK_VSCODE_AGENTS )); then
      link_one "$agent_file" "$VSCODE_AGENTS_DIR"
    fi
    if (( LINK_VIBE )); then
      link_one "$agent_file" "$VIBE_AGENTS_DIR"
    fi
    if (( LINK_CLAUDE )); then
      link_one "$agent_file" "$CLAUDE_AGENTS_DIR"
    fi
  done
fi

if (( LINK_CLAUDE )) && [[ -d "$CLAUDE_SKILLS_SRC" ]]; then
  for claude_skill in "$CLAUDE_SKILLS_SRC"/*.md(.N); do
    link_one "$claude_skill" "$CLAUDE_SKILLS_DIR"
  done
fi

if (( LINK_CURSOR )); then
  for cursor_agent in "$CURSOR_AGENTS_SRC"/*.md(.N); do
    link_one "$cursor_agent" "$CURSOR_AGENTS_DIR"
  done
fi

log ""
log "Global bootstrap complete."
log "Repo source of truth: $REPO_ROOT"
if (( DRY_RUN )); then
  log "Planned links: $linked | Planned replacements: $replaced | Planned skips: $skipped"
else
  log "Linked: $linked | Replaced: $replaced | Skipped: $skipped"
fi
if (( !EDD_ONLY )); then
  log "Global skills: $COPILOT_SKILLS_DIR"
  log "Global agents: $COPILOT_AGENTS_DIR"
fi
if (( LINK_VSCODE_AGENTS )); then
  log "VS Code agents: $VSCODE_AGENTS_DIR"
fi
if (( LINK_VIBE )); then
  log "Mistral Vibe skills: $VIBE_SKILLS_DIR"
  log "Mistral Vibe agents: $VIBE_AGENTS_DIR"
fi
if (( LINK_CLAUDE )); then
  log "Claude Code skills: $CLAUDE_SKILLS_DIR"
  log "Claude Code agents: $CLAUDE_AGENTS_DIR"
fi
if (( LINK_CODEX )); then
  if (( EDD_ONLY )); then
    log "Codex skills: $CODEX_SKILLS_DIR (EDD only)"
    log "Codex agents: $CODEX_AGENTS_DIR (EDD verifier only)"
  else
    log "Codex skills: $CODEX_SKILLS_DIR (Nexter dependencies, EDD loop)"
    log "Codex agents: $CODEX_AGENTS_DIR (Nexter, EDD verifier)"
  fi
fi
if (( LINK_OPENCODE )); then
  log "OpenCode skills: $OPENCODE_SKILLS_DIR (EDD loop)"
  log "OpenCode agents: $OPENCODE_AGENTS_DIR"
  log "OpenCode commands: $OPENCODE_COMMANDS_DIR"
fi
if (( LINK_CURSOR )); then
  log "Cursor global skills: $AGENTS_GLOBAL_SKILLS_DIR"
  log "Cursor agents: $CURSOR_AGENTS_DIR"
fi
if (( LINK_ANTIGRAVITY )); then
  log "Antigravity plugin: $ANTIGRAVITY_PLUGIN_DIR -> $REPO_ROOT"
fi
