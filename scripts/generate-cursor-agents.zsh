#!/bin/zsh
# Generate Cursor subagents from canonical Copilot .agent.md definitions.
set -euo pipefail
setopt null_glob

SCRIPT_DIR="${0:A:h}"
REPO_ROOT="${SCRIPT_DIR:h}"
AGENTS_SRC="$REPO_ROOT/.github/agents"
OUTPUT_DIR="$REPO_ROOT/.cursor/agents"
CHECK_ONLY=0

usage() {
  cat <<'EOF'
Usage: generate-cursor-agents.zsh [--check]

Generates .cursor/agents/*.md from .github/agents/*.agent.md.

Options:
  --check    Exit non-zero if any generated file is missing or stale.
  -h, --help Show this help.
EOF
}

while (( $# > 0 )); do
  case "$1" in
    --check) CHECK_ONLY=1 ;;
    -h|--help) usage; exit 0 ;;
    *) print -u2 -- "Unknown option: $1"; usage >&2; exit 1 ;;
  esac
  shift
done

[[ -d "$AGENTS_SRC" ]] || { print -u2 -- "Missing agents directory: $AGENTS_SRC"; exit 1; }

yaml_scalar() {
  local file="$1" key="$2" value
  value="$(awk -v key="$key" '
    NR > 1 && /^---$/ { exit }
    NR > 1 && $0 ~ "^" key ":[[:space:]]*" {
      sub("^" key ":[[:space:]]*", "")
      print
      exit
    }
  ' "$file")"
  value="${value#\'}"; value="${value%\'}"
  value="${value#\"}"; value="${value%\"}"
  print -r -- "$value"
}

agent_has_tool() {
  local file="$1" tool="$2"
  awk -v tool="$tool" '
    BEGIN { in_frontmatter = 0; in_tools = 0; found = 0 }
    /^---$/ { in_frontmatter++; next }
    in_frontmatter == 1 && /^tools:[[:space:]]*$/ { in_tools = 1; next }
    in_frontmatter == 1 && in_tools && /^[[:space:]]*-[[:space:]]*/ {
      gsub(/^[[:space:]]*-[[:space:]]*/, "")
      if ($0 == tool) found = 1
      next
    }
    in_frontmatter == 1 && in_tools && /^[^[:space:]]/ { in_tools = 0 }
    END { exit(found ? 0 : 1) }
  ' "$file"
}

generate_one() {
  local source="$1"
  local basename="${source:t}"
  local name="${basename%.agent.md}"
  local output="$OUTPUT_DIR/${name}.md"
  local description readonly_line temporary_output

  [[ "$basename" == *.agent.md ]] || return 0
  [[ "$(sed -n '1p' "$source")" == '---' ]] || { print -u2 -- "Missing YAML frontmatter: $source"; return 1; }

  description="$(yaml_scalar "$source" description)"
  [[ -n "$name" && -n "$description" ]] || { print -u2 -- "Agent must define name and description: $source"; return 1; }

  if agent_has_tool "$source" edit || agent_has_tool "$source" execute; then
    readonly_line=""
  else
    readonly_line="readonly: true"
  fi

  temporary_output="$(mktemp "${TMPDIR:-/private/tmp}/cursor-agent-${name}.XXXXXX")"

  {
    print -- '# Generated from .github/agents/'"${basename}"'; do not edit directly.'
    print -- '---'
    print -- "name: $name"
    print -- "description: >-"
    print -r -- "$description" | fold -s -w 100 | sed -e 's/[[:space:]]*$//' -e 's/^/  /'
    [[ -n "$readonly_line" ]] && print -- "$readonly_line"
    print -- 'model: inherit'
    print -- '---'
    print -- ''
    awk 'BEGIN { delimiters = 0 } /^---$/ { delimiters++; next } delimiters >= 2 { print }' "$source" \
      | sed -E \
        -e 's#\.agents/skills/#.agents/skills/#g' \
        -e 's#\.claude/skills/([^.]+)\.md#.agents/skills/\1/SKILL.md#g'
  } > "$temporary_output"

  if (( CHECK_ONLY )); then
    if ! [[ -f "$output" ]] || ! cmp -s "$temporary_output" "$output"; then
      print -u2 -- "Stale generated Cursor agent: $output (run scripts/generate-cursor-agents.zsh)"
      rm -f -- "$temporary_output"
      return 1
    fi
    rm -f -- "$temporary_output"
    return 0
  fi

  mkdir -p "$OUTPUT_DIR"
  mv -- "$temporary_output" "$output"
  print -- "Generated Cursor agent: $output"
}

stale=0
for agent_file in "$AGENTS_SRC"/*.agent.md; do
  generate_one "$agent_file" || stale=1
done

if (( CHECK_ONLY )); then
  if (( stale )); then
    exit 1
  fi
  print -- "Cursor agents are current: $OUTPUT_DIR"
  exit 0
fi
