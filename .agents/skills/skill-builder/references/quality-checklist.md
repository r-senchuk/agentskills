# Skill Quality Checklist

Use this checklist when auditing or validating any SKILL.md. Run structural checks first, then content checks.

## Structural Checks (terminal)

```bash
SKILL=".agents/skills/<name>/SKILL.md"

# 1. Folder/name match
FOLDER=$(basename $(dirname "$SKILL"))
NAME=$(grep -m1 "^name:" "$SKILL" | sed 's/name: *//')
[ "$FOLDER" = "$NAME" ] && echo "✅ name match" || echo "❌ name mismatch: folder=$FOLDER, name=$NAME"

# 2. Line count (keep the activated instruction file compact)
LINES=$(wc -l < "$SKILL")
[ "$LINES" -lt 500 ] && echo "✅ $LINES lines" || echo "❌ $LINES lines (keep under 500)"

# 3. Required Agent Skills frontmatter fields
for F in name description; do
  grep -q "^$F:" "$SKILL" && echo "✅ $F" || echo "❌ missing: $F"
done

# 4. Required sections
for S in "When To Use" "Inputs To Collect First" "Procedure" "Completion Checks" "References"; do
  grep -q "^## $S" "$SKILL" && echo "✅ $S" || echo "❌ missing section: $S"
done

# 5. Step subsections exist under Procedure
STEPS=$(grep -c "^### Step" "$SKILL" 2>/dev/null || echo 0)
[ "$STEPS" -gt 0 ] && echo "✅ $STEPS step subsections (### Step N)" || echo "❌ no '### Step N' subsections found under Procedure"

# 6. Reference files exist (covers both markdown links and backtick inline references)
grep -oE "'\./references/[^']+'\.md|\./references/[^)]+" "$SKILL" | tr -d "'" | while read F; do
  BASE=$(dirname "$SKILL")
  [ -f "$BASE/$F" ] && echo "✅ $F" || echo "❌ missing reference file: $F"
done

# 7. Description has trigger phrase
grep -m1 "^description:" "$SKILL" | grep -qi "use when\|when user\|use for"   && echo "✅ description has trigger phrase" || echo "❌ description missing 'Use when' / trigger phrase"

# 8. Individual assets must stay small enough for upstream packaging.
find "$(dirname "$SKILL")" -type f -size +5M -print | grep -q . \
  && echo "❌ asset exceeds 5 MB" || echo "✅ assets under 5 MB"
```

## Content Quality Checks (manual)

### Description
- [ ] Contains ≥3 trigger keywords matching the domain
- [ ] Starts with "Use when" or "Use for"
- [ ] Describes what NOT to use it for (to prevent false positives)
- [ ] No vague words: "helpful", "useful", "general", "various"
- [ ] Uses valid YAML quoting; use single quotes when preparing an Awesome Copilot contribution
- [ ] `argument-hint`, `user-invocable`, and `disable-model-invocation` are used only when their platform-specific behavior is intended

### When To Use
- [ ] Lists specific trigger conditions (not just "use this skill")
- [ ] Has explicit NEGATIVE cases ("Do NOT use for...")

### Procedure
- [ ] Each step is numbered and has its own `### Step N` subsection under `## Procedure`
- [ ] Terminal commands use fenced code blocks with `bash` tag
- [ ] No hardcoded personal values (usernames, paths, API keys)
- [ ] References from `SKILL.md` use one-level relative paths and resolve
- [ ] No steps that say "if needed" without specifying when
- [ ] Skill includes error handling or troubleshooting content (inline guards, common issues step, or explicit error cases)

### Completion Checks
- [ ] Uses `- [ ]` checkbox format
- [ ] Covers both structural AND content quality dimensions
- [ ] All checkboxes are verifiable (not subjective like "is it good?")

### References
- [ ] All linked files exist and are readable
- [ ] No dead links
- [ ] Reference files use a clear heading structure

## Awesome-Copilot Upstream Bar (additional)

Only applies when submitting to [github/awesome-copilot](https://github.com/github/awesome-copilot):
- [ ] Skill addresses a concrete gap, not generic advice
- [ ] Verified working with GitHub Copilot agents in a real workflow
- [ ] No overlap with existing skills in the upstream collection
- [ ] `npm run skill:validate` passes in the awesome-copilot repo
- [ ] `🤖🤖🤖` included in PR title if submitted via AI agent

### Agent Skills Specification Compliance
- [ ] `description` includes WHAT the skill does + WHEN to use it (trigger conditions)
- [ ] `name` is 1–64 lowercase letters, digits, or hyphens, has no repeated/edge hyphen, and matches its folder
- [ ] `description` is non-empty and ≤1024 characters
- [ ] Each bundled asset is referenced where its use is needed and is under 5 MB for Awesome Copilot packaging
- [ ] Main instructions stay under 500 lines; heavy material is progressively disclosed through focused references
- [ ] At least one troubleshooting or error-handling section in the body
- [ ] Progressive disclosure applied: heavy reference content extracted to `./references/`

## Common Failure Modes

| Problem | Symptom | Fix |
|---|---|---|
| Vague description | Model never auto-triggers skill | Add specific domain nouns and action verbs |
| Missing negative case | Skill triggers when it shouldn't | Add "Do NOT use for X" to When To Use and description |
| Procedure without terminal commands | Steps are hand-wavy | Add concrete `bash` commands for each step |
| Step headings at wrong level | `## Step N` used instead of `### Step N` | Steps live under `## Procedure` — use `###` to stay in hierarchy |
| Monolithic body | >500 lines | Extract secondary content to `./references/` |
| Dead reference links | Reference files don't exist | Create files or remove broken links |
| Unreachable skill | `user-invocable: false` and `disable-model-invocation: true` are both set | Remove one flag: background skills omit `disable-model-invocation`; explicit-only skills keep `user-invocable: true` |
| Generic best practices | No uplift over default model | Replace with workflow-specific constraints |
