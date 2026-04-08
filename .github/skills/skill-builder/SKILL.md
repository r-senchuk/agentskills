---
name: skill-builder
description: "Use when creating a new SKILL.md from scratch, auditing an existing skill for gaps or stale content, or refactoring a skill to meet quality standards. Covers research (Perplexity, GitHub), structure, frontmatter validation, and completion checks. Use when user asks to 'create new skill', 'audit existing skill', 'refactor skill structure', or 'improve skill quality'. Do not use for coding tasks, application debugging, or feature implementation."
argument-hint: "Skill name or domain, goal (create|audit|refactor), and any constraints or quality bar."
user-invocable: false
license: MIT
compatibility: "Works with any text editor, requires web access for research (Perplexity, GitHub), and YAML validation tools."
metadata:
  author: "Roman Senchuk"
  version: "1.2.0"
  last-updated: "2026-04-08"
---

# Skill Builder

## When To Use

- **Create**: Building a new `SKILL.md` for a domain or workflow not covered by existing skills.
- **Audit**: Reviewing an existing skill — checking for missing sections, weak triggers, stale API references, or incomplete procedures.
- **Refactor**: Restructuring a skill that works but violates quality standards (vague description, monolithic body, name/folder mismatch, broken references).

Do NOT use for general coding tasks. Use when the output is a `SKILL.md` file.

## Inputs To Collect First

1. **Skill name** (kebab-case, 1–64 chars, matches folder name exactly)
2. **Goal**: `create`, `audit`, or `refactor`
3. **Domain summary**: One sentence describing what the skill enables agents to do
4. **Quality bar**: Target repo (this repo vs. awesome-copilot upstream) — upstream requires evidence of real gap

## Procedure

### Step 1 — Inventory Existing Skills

Before creating or refactoring, list all existing skills to avoid duplication:

```bash
ls .github/skills/
```

For each existing skill relevant to the domain, read its `SKILL.md`:

```bash
cat .github/skills/<related-skill>/SKILL.md
```

Identify: gaps the new skill fills, overlap to avoid, related skills to link.

### Step 2 — Research Domain

Use the `web` tool to gather domain knowledge:
- Best practices and common patterns
- Anti-patterns and failure modes
- Authoritative references (official docs, RFCs, widely-used guides)

Then search GitHub for comparable skills using these strategies:
1. Code search: `filename:SKILL.md <domain-keyword>` across GitHub
2. Repo search: `"agent skill" <domain-keyword> copilot`
3. Browse [awesome-copilot.github.com/skills](https://awesome-copilot.github.com/skills) for overlap

Read top 2–3 results for structure and content patterns. Record:
- **What to include**: practices with evidence of real uplift
- **What NOT to include**: rules the model handles well by default, vague generic advice
- **References to cite**: official docs, authoritative guides

Load `./references/research-queries.md` for GitHub query templates.

### Step 3 — Design Structure

Lay out the skill using this section order (required):
1. When To Use
2. Inputs To Collect First
3. Procedure (numbered steps, each with its own `### Step N` subsection)
4. Completion Checks
5. References

Choose reference files: if any section would push the body >500 lines, extract it to `./references/<topic>.md`. Reference files load only when invoked — put core procedure in the body.

Load `./references/skill-structure.md` for the canonical frontmatter schema and body template.

### Step 4 — Write or Update SKILL.md

**Creating new:**
1. Create folder: `.github/skills/<skill-name>/`
2. Write `SKILL.md` with complete frontmatter + all required sections
3. Create reference files under `./references/` if needed

**Auditing existing:**
1. Read the current `SKILL.md` fully
2. Check against `./references/quality-checklist.md`
3. Write a gap report using this format:

| # | Check | Finding | Fix Required |
|---|---|---|---|
| G1 | <check name> | <what failed> | <concrete change> |

4. Apply all fixes directly to the file — do not leave gaps unresolved

**Refactoring existing:**
1. Apply all gap-report fixes
2. Preserve all content that passes the checklist — do not delete working sections
3. Update references if files were added or renamed
4. Re-run the Step 5 validation script to confirm all checks pass after edits

### Step 5 — Validate

Run structural validation:

```bash
SKILL=".github/skills/<skill-name>/SKILL.md"
ROOT=$(git rev-parse --show-toplevel)
SKILL_ABS="$ROOT/$SKILL"
FOLDER=$(basename $(dirname "$SKILL_ABS"))
NAME=$(grep -m1 "^name:" "$SKILL_ABS" | sed 's/name: *//')

# 1. Name/folder match
[ "$FOLDER" = "$NAME" ] && echo "✅ name match" || echo "❌ mismatch: folder=$FOLDER name=$NAME"

# 2. Required frontmatter fields
for F in name description argument-hint user-invocable; do
  grep -q "^$F:" "$SKILL_ABS" && echo "✅ $F" || echo "❌ missing: $F"
done

# 3. No XML tags in frontmatter (security: forbidden per spec)
FM=$(sed -n '/^---$/,/^---$/p' "$SKILL_ABS" | head -20)
echo "$FM" | grep -q '[<>]' && echo "❌ XML tags in frontmatter" || echo "✅ no XML tags"

# 4. No README.md in skill folder
[ -f "$(dirname "$SKILL_ABS")/README.md" ] && echo "❌ README.md found (remove it)" || echo "✅ no README.md"

# 5. Description has trigger phrase
grep -m1 "^description:" "$SKILL_ABS" | grep -qi "use when\|when user\|use for"   && echo "✅ description has trigger phrase" || echo "❌ description missing trigger phrase"

# 6. Required sections
for S in "When To Use" "Inputs To Collect First" "Procedure" "Completion Checks" "References"; do
  grep -q "^## $S" "$SKILL_ABS" && echo "✅ $S" || echo "❌ missing section: $S"
done

# 7. Troubleshooting content present
grep -qi "troubleshoot\|common issue\|error\|fail" "$SKILL_ABS"   && echo "✅ troubleshooting/error content present" || echo "⚠  no troubleshooting content"

# 8. Word count (PDF: keep under 5,000 words)
WC=$(wc -w < "$SKILL_ABS")
[ "$WC" -le 5000 ] && echo "✅ $WC words" || echo "❌ $WC words (limit 5000)"
```

Load `./references/quality-checklist.md` for the full validation matrix including content checks.

### Step 6 — Troubleshoot Common Issues

**Skill fails to load — "missing or malformed YAML frontmatter"**
- Open the file and verify `---` appears on lines 1 and N with no leading spaces or BOM characters.
- Check for non-standard sections before `## When To Use` (e.g., `## Purpose`, `## Context`) — remove them; these break parsers.
- Run `python3 -c "import yaml; yaml.safe_load(open('SKILL.md').read().split('---')[1])"` to surface YAML parse errors.

**Skill never auto-triggers**
- The `description` field is too generic. Add domain-specific nouns and the exact phrase pattern users say.
- Ask Claude: "When would you use the `<name>` skill?" — it quotes the description back. Edit based on what's missing.

**Skill triggers for unrelated queries (overtriggering)**
- Add or strengthen the "Do NOT use for" clause in both `description` and `## When To Use`.
- Make the trigger more specific — replace broad verbs ("help", "build") with domain-specific ones.

**`./references/<file>` not found**
- The reference file doesn't exist or is misnamed. Create it or fix the path.
- Paths are relative to the `SKILL.md` file, not the repo root.

**Step 5 validation script fails on `git rev-parse`**
- You are not in a git repo. Either `cd` to the repo root or replace `$ROOT` with an absolute path for local testing.

## Completion Checks

- [ ] Folder name exactly matches `name:` frontmatter field
- [ ] `description` ≥ 10 chars, ≤ 1024 chars, quoted, contains no unescaped colons
- [ ] `description` contains a "Do not use for" clause to prevent false positives
- [ ] `argument-hint` is present and lists concrete inputs
- [ ] All 5 required sections present: When To Use, Inputs, Procedure, Completion Checks, References
- [ ] `When To Use` contains at least one explicit `Do NOT use for` negative case
- [ ] Each procedure step is expanded in its own `### Step N` subsection under `## Procedure`
- [ ] SKILL.md body ≤ 500 lines
- [ ] All `./references/<file>` paths resolve to real files
- [ ] No hardcoded personal paths, API keys, or user-specific values
- [ ] Skills that duplicate existing model defaults have been removed or strengthened with specific workflow
- [ ] No XML tags (`< >`) anywhere in the frontmatter block
- [ ] No `README.md` file inside the skill folder
- [ ] Troubleshooting or error-handling content is present (inline guards, common issues step, or completion check)

## References

- [Skill Structure Template](./references/skill-structure.md)
- [Quality Checklist](./references/quality-checklist.md)
- [Research Query Playbook](./references/research-queries.md)
