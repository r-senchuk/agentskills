# Sync

Refresh symlinks for all skills and agents into global Copilot, Vibe, and Claude Code directories.

## Steps

1. Preview what will be linked:
```bash
./scripts/setup-copilot-globals.sh --dry-run
```

2. Apply all links (replace conflicting targets):
```bash
./scripts/setup-copilot-globals.sh --force
```

3. Verify Claude Code skills are linked:
```bash
ls ~/.claude/skills/
```

## What Gets Linked

| Source | Target |
|---|---|
| `.github/skills/*/` | `~/.copilot/skills/` and `~/.vibe/skills/` |
| `.github/agents/*.agent.md` | `~/.copilot/agents/`, `~/.vibe/agents/`, VS Code prompts |
| `.claude/skills/*.md` | `~/.claude/skills/` |

After syncing, all skills and agents in this repo are instantly available globally — no restart needed for file edits (only for newly added files requiring a re-sync).

## Troubleshooting

```bash
# Check what is linked where
ls -la ~/.copilot/skills/
ls -la ~/.copilot/agents/
ls -la ~/.claude/skills/

# Validate a specific symlink still points here
readlink ~/.copilot/skills/skill-builder
readlink ~/.claude/skills/sara.md
```
