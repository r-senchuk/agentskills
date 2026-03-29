# Skill Quality Checklist

Use this checklist when auditing or validating any SKILL.md. Run structural checks first, then content checks.

## Structural Checks (terminal)

```bash
SKILL=".github/skills/<name>/SKILL.md"

# 1. Folder/name match
FOLDER=$(basename $(dirname "$SKILL"))
NAME=$(grep -m1 "^name:" "$SKILL" | sed 's/name: *//')
[ "$FOLDER" = "$NAME" ] && echo "✅ name match" || echo "❌ name mismatch: folder=$FOLDER, name=$NAME"

# 2. Line count
LINES=$(wc -l < "$SKILL")
[ "$LINES" -le 500 ] && echo "✅ $LINES lines" || echo "❌ $LINES lines (limit 500)"

# 3. Required frontmatter fields
for F in name description argument-hint user-invocable; do
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
```

## Content Quality Checks (manual)

### Description
- [ ] Contains ≥3 trigger keywords matching the domain
- [ ] Starts with "Use when" or "Use for"
- [ ] Describes what NOT to use it for (to prevent false positives)
- [ ] No vague words: "helpful", "useful", "general", "various"
- [ ] Quoted and no unescaped colons

### When To Use
- [ ] Lists specific trigger conditions (not just "use this skill")
- [ ] Has explicit NEGATIVE cases ("Do NOT use for...")

### Procedure
- [ ] Each step is numbered and has its own `### Step N` subsection under `## Procedure`
- [ ] Terminal commands use fenced code blocks with `bash` tag
- [ ] No hardcoded personal values (usernames, paths, API keys)
- [ ] References to external files use relative `./references/` paths
- [ ] No steps that say "if needed" without specifying when

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

## Common Failure Modes

| Problem | Symptom | Fix |
|---|---|---|
| Vague description | Model never auto-triggers skill | Add specific domain nouns and action verbs |
| Missing negative case | Skill triggers when it shouldn't | Add "Do NOT use for X" to When To Use and description |
| Procedure without terminal commands | Steps are hand-wavy | Add concrete `bash` commands for each step |
| Step headings at wrong level | `## Step N` used instead of `### Step N` | Steps live under `## Procedure` — use `###` to stay in hierarchy |
| Monolithic body | >500 lines | Extract secondary content to `./references/` |
| Dead reference links | Reference files don't exist | Create files or remove broken links |
| Generic best practices | No uplift over default model | Replace with workflow-specific constraints |
