# Validate Skill

Run the 8-point validation checklist against a named SKILL.md file.

## Usage

Provide the skill name (kebab-case directory name). If not provided, ask for it.

## Steps

1. Construct the path: `.github/skills/<name>/SKILL.md`
2. Confirm the file exists; if not, report the error and stop.
3. Run the validation script:

```bash
SKILL=".github/skills/<skill-name>/SKILL.md"
ROOT=$(git rev-parse --show-toplevel)
SKILL_ABS="$ROOT/$SKILL"
FOLDER=$(basename $(dirname "$SKILL_ABS"))
NAME=$(grep -m1 "^name:" "$SKILL_ABS" | sed 's/name: *//')

[ "$FOLDER" = "$NAME" ] && echo "✅ name match" || echo "❌ mismatch: folder=$FOLDER name=$NAME"
for F in name description argument-hint user-invocable; do
  grep -q "^$F:" "$SKILL_ABS" && echo "✅ $F" || echo "❌ missing: $F"
done
FM=$(sed -n '/^---$/,/^---$/p' "$SKILL_ABS" | head -20)
echo "$FM" | grep -q '[<>]' && echo "❌ XML tags in frontmatter" || echo "✅ no XML tags"
grep -m1 "^description:" "$SKILL_ABS" | grep -qi "use when\|when user\|use for" \
  && echo "✅ description has trigger phrase" || echo "❌ description missing trigger phrase"
for S in "When To Use" "Inputs To Collect First" "Procedure" "Completion Checks" "References"; do
  grep -q "^## $S" "$SKILL_ABS" && echo "✅ $S" || echo "❌ missing section: $S"
done
WC=$(wc -w < "$SKILL_ABS")
[ "$WC" -le 5000 ] && echo "✅ $WC words" || echo "❌ $WC words (limit 5000)"
```

4. Report each check result.
5. For any failures, state the exact fix required (e.g., rename directory, add missing section, update description).

To validate all skills at once:
```bash
for dir in .github/skills/*/; do
  name=$(basename "$dir")
  echo "--- $name ---"
  SKILL="${dir}SKILL.md"
  [ -f "$SKILL" ] || { echo "❌ SKILL.md missing"; continue; }
  FOLDER="$name"
  NAME=$(grep -m1 "^name:" "$SKILL" | sed 's/name: *//')
  [ "$FOLDER" = "$NAME" ] && echo "✅ name" || echo "❌ name mismatch: $NAME"
done
```
