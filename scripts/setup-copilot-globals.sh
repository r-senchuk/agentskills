#!/bin/zsh
set -euo pipefail
setopt null_glob

# One-time bootstrap for global Copilot skills/agents via symlinks.
# After linking, updates in this repo are reflected everywhere immediately.

# Use zsh path expansion for macOS/BSD portability (avoids GNU-only dirname flags).
SCRIPT_DIR="${0:A:h}"
DEFAULT_REPO_ROOT="${SCRIPT_DIR:h}"

REPO_ROOT="$DEFAULT_REPO_ROOT"
COPILOT_HOME="${COPILOT_HOME:-$HOME/.copilot}"
VSCODE_PROMPTS_DIR="${VSCODE_PROMPTS_DIR:-$HOME/Library/Application Support/Code/User/prompts}"
LINK_VSCODE_AGENTS=1
FORCE=0
DRY_RUN=0

usage() {
  cat <<'EOF'
Usage: setup-copilot-globals.sh [options]

Options:
  --repo <path>           Repo root containing .github/skills and .github/agents.
                          Default: parent directory of this script.
  --copilot-home <path>   Global Copilot home. Default: ~/.copilot
  --vscode-prompts <path> VS Code prompts dir. Default: ~/Library/Application Support/Code/User/prompts
  --no-vscode-agents      Skip linking agents into VS Code prompts profile.
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
SKILLS_SRC="$REPO_ROOT/.github/skills"
AGENTS_SRC="$REPO_ROOT/.github/agents"
COPILOT_SKILLS_DIR="$COPILOT_HOME/skills"
COPILOT_AGENTS_DIR="$COPILOT_HOME/agents"
VSCODE_AGENTS_DIR="$VSCODE_PROMPTS_DIR/agents"

[[ -d "$SKILLS_SRC" ]] || { warn "Missing directory: $SKILLS_SRC"; exit 1; }
[[ -d "$AGENTS_SRC" ]] || { warn "Missing directory: $AGENTS_SRC"; exit 1; }

run_cmd mkdir -p "$COPILOT_SKILLS_DIR" "$COPILOT_AGENTS_DIR"
if (( LINK_VSCODE_AGENTS )); then
  run_cmd mkdir -p "$VSCODE_AGENTS_DIR"
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

for skill_dir in "$SKILLS_SRC"/*(N/); do
  link_one "$skill_dir" "$COPILOT_SKILLS_DIR"
done

for agent_file in "$AGENTS_SRC"/*.agent.md(.N); do
  link_one "$agent_file" "$COPILOT_AGENTS_DIR"
  if (( LINK_VSCODE_AGENTS )); then
    link_one "$agent_file" "$VSCODE_AGENTS_DIR"
  fi
done

log ""
log "Copilot global bootstrap complete."
log "Repo source of truth: $REPO_ROOT"
if (( DRY_RUN )); then
  log "Planned links: $linked | Planned replacements: $replaced | Planned skips: $skipped"
else
  log "Linked: $linked | Replaced: $replaced | Skipped: $skipped"
fi
log "Global skills: $COPILOT_SKILLS_DIR"
log "Global agents: $COPILOT_AGENTS_DIR"
if (( LINK_VSCODE_AGENTS )); then
  log "VS Code agents: $VSCODE_AGENTS_DIR"
fi
