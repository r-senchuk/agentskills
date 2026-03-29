# agent-sync.zsh — Source this file from ~/.zshrc to get the `agent-sync` command.
#
# Usage:
#   # Add to your ~/.zshrc:
#   source "/Users/roman/src/github.com/r-senchuk/agentskills/scripts/agent-sync.zsh"
#
#   # Then run from anywhere:
#   agent-sync              # normal sync
#   agent-sync --force      # replace existing links
#   agent-sync --dry-run    # preview changes

agent-sync() {
  local _agent_sync_script="/Users/roman/src/github.com/r-senchuk/agentskills/scripts/setup-copilot-globals.sh"
  if [[ ! -x "$_agent_sync_script" ]]; then
    printf 'agent-sync: script not found or not executable: %s\n' "$_agent_sync_script" >&2
    return 1
  fi
  "$_agent_sync_script" "$@"
}
