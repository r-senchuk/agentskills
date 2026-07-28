#!/bin/zsh
# Generate the Codex Nexter agent from the canonical OpenCode definition.
set -euo pipefail

SCRIPT_DIR="${0:A:h}"
REPO_ROOT="${SCRIPT_DIR:h}"
SOURCE="$REPO_ROOT/.opencode/agents/nexter.md"
OUTPUT="$REPO_ROOT/.codex/agents/nexter.toml"
CHECK_ONLY=0

usage() {
  cat <<'EOF'
Usage: generate-codex-agent.zsh [--check]

Generates .codex/agents/nexter.toml from .opencode/agents/nexter.md.

Options:
  --check    Exit non-zero if the generated file is missing or stale.
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

[[ -f "$SOURCE" ]] || { print -u2 -- "Missing canonical agent: $SOURCE"; exit 1; }
[[ "$(sed -n '1p' "$SOURCE")" == '---' ]] || { print -u2 -- "Missing YAML frontmatter: $SOURCE"; exit 1; }

name="$(awk 'NR > 1 && /^---$/ { exit } NR > 1 && /^name:[[:space:]]*/ { sub(/^name:[[:space:]]*/, ""); print; exit }' "$SOURCE")"
description="$(awk 'NR > 1 && /^---$/ { exit } NR > 1 && /^description:[[:space:]]*/ { sub(/^description:[[:space:]]*/, ""); print; exit }' "$SOURCE")"
[[ -n "$name" && -n "$description" ]] || { print -u2 -- "Canonical agent must define name and description"; exit 1; }
[[ "$description" == '"'*'"' ]] && description="${description#\"}" && description="${description%\"}"

toml_escape() {
  sed -e 's/\\/\\\\/g' -e 's/"/\\"/g'
}

escaped_description="$(print -r -- "$description" | toml_escape)"
temporary_output="$(mktemp "${TMPDIR:-/private/tmp}/nexter-codex-agent.XXXXXX")"
trap 'rm -f -- "$temporary_output"' EXIT

{
  print -- '# Generated from .opencode/agents/nexter.md; do not edit directly.'
  printf 'name = "%s"\n' "$name"
  printf 'description = "%s"\n\n' "$escaped_description"
  print -- "developer_instructions = '''"
  awk 'BEGIN { delimiters = 0 } /^---$/ { delimiters++; next } delimiters >= 2 { print }' "$SOURCE" \
    | sed -E 's#\.github/skills/([^/]+)/SKILL\.md#~/.codex/skills/\1/SKILL.md#g'
  print -- "'''"
} > "$temporary_output"

if (( CHECK_ONLY )); then
  if ! [[ -f "$OUTPUT" ]] || ! cmp -s "$temporary_output" "$OUTPUT"; then
    print -u2 -- "Stale generated Codex agent: run scripts/generate-codex-agent.zsh"
    exit 1
  fi
  print -- "Codex Nexter agent is current: $OUTPUT"
  exit 0
fi

mkdir -p "${OUTPUT:h}"
mv -- "$temporary_output" "$OUTPUT"
trap - EXIT
print -- "Generated Codex Nexter agent: $OUTPUT"
