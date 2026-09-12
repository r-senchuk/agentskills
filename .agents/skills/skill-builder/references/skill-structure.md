# Skill Structure Reference

> Reference: the [Agent Skills specification](https://agentskills.io/specification) and
> current GitHub Copilot skills guidance. Product-specific fields are optional;
> keep the portable core valid first.

## Canonical SKILL.md Frontmatter

```yaml
---
name: <kebab-case>                    # Required. Max 64 chars. Must match folder name exactly.
description: "Use when..."            # Required. What it does and when to use it.
license: MIT                           # Optional. State the applicable license when sharing.
argument-hint: "Input1, Input2"       # Optional. Copilot/VS Code slash-command hint.
user-invocable: false                  # Optional. Hides a background skill from the slash menu.
disable-model-invocation: true         # Optional. Use only for an explicit-only workflow.
---
```

## Description Field Rules

- Must contain trigger keywords that clearly differentiate this skill from others
- Start with "Use when..." pattern
- Include synonyms for the action: `create|build|generate` OR `audit|review|inspect`
- Quote the entire value if it contains colons: `description: "Use when: X"`
- Max 1024 chars — stay concise enough to be useful among all available skills
- No vague words: "helpful", "useful", "general", "various"

## Section Order (Required)

1. `## When To Use` — trigger conditions, what this skill is NOT for
2. `## Inputs To Collect First` — numbered list of required context
3. `## Procedure` — numbered top-level steps; each step has its own `### Step N — Title` subsection
4. `## Completion Checks` — bullet checklist with `- [ ]` items
5. `## References` — relative links to `./references/*.md` files

## Folder Layout

```
.agents/skills/<skill-name>/
├── SKILL.md                    # Required. Keep activated instructions under 500 lines.
├── references/
│   ├── topic-a.md              # Loaded only when referenced
│   └── topic-b.md
└── scripts/
    └── validate.sh             # Executable helpers
```

`SKILL.md` is the only required file. Supporting documents, templates, assets, and
scripts are allowed when they are necessary and referenced by the instructions.

## Progressive Loading Design

- **Body** (SKILL.md): Core procedure all steps need. Keep focused.
- **References**: Lookup tables, templates, advanced detail — load only when the step needs them.
- **Scripts**: Runnable code — reference with relative path in fenced block.

Rule of thumb: if a section is >80 lines, extract to a reference file.

## Common Frontmatter Mistakes

| Mistake | Fix |
|---|---|
| Folder `my-skill`, `name: myskill` | Must match exactly: both must be `my-skill` |
| `description: Use when: doing X` | Unescaped colon → `description: "Use when: doing X"` |
| Tab indentation in YAML | Always use spaces |
| `user-invocable: false` plus `disable-model-invocation: true` | The skill is unreachable; use only one based on the intended behavior |
| Description without trigger words | Add "Use when...", "Use for...", domain-specific nouns |
| Description without NOT clause | Add "Do not use for X" to prevent false positives |
| `name` field > 64 chars | Shorten to max 64 alphanumeric + hyphen characters |
| `name` uses uppercase, edge hyphens, or `--` | Use 1–64 lowercase letters, digits, and single internal hyphens |
| Step headings using `## Step N` | Use `### Step N` — steps live under `## Procedure`, so `###` is correct |

## Slash Command Behavior

| `user-invocable` | `disable-model-invocation` | Effect |
|---|---|---|
| `true` (default) | `false` (default) | Appears in `/` picker + auto-triggered by model |
| `false` | `false` | Hidden from picker, auto-triggered only (subagent use) |
| `true` | `true` | Picker only, NOT auto-triggered |
| `false` | `true` | Neither — effectively disabled |
