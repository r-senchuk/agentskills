# Validate Skill

Run the current Agent Skills structure and metadata checks against a named SKILL.md file.

## Usage

Provide the skill name (kebab-case directory name). If not provided, ask for it.

## Steps

1. Construct the path: `.agents/skills/<name>/SKILL.md`
2. Confirm the file exists; if not, report the error and stop.
3. Run the validation script:

```bash
SKILL=".agents/skills/<skill-name>/SKILL.md"
ROOT=$(git rev-parse --show-toplevel)
SKILL_ABS="$ROOT/$SKILL"
FOLDER=$(basename $(dirname "$SKILL_ABS"))
NAME=$(grep -m1 "^name:" "$SKILL_ABS" | sed 's/name: *//')

[ "$FOLDER" = "$NAME" ] && echo "✅ name match" || echo "❌ mismatch: folder=$FOLDER name=$NAME"
for F in name description; do
  grep -q "^$F:" "$SKILL_ABS" && echo "✅ $F" || echo "❌ missing: $F"
done
grep -m1 "^description:" "$SKILL_ABS" | grep -qi "use when\|when user\|use for" \
  && echo "✅ description has trigger phrase" || echo "❌ description missing trigger phrase"
for S in "When To Use" "Inputs To Collect First" "Procedure" "Completion Checks" "References"; do
  grep -q "^## $S" "$SKILL_ABS" && echo "✅ $S" || echo "❌ missing section: $S"
done
LINES=$(wc -l < "$SKILL_ABS")
[ "$LINES" -lt 500 ] && echo "✅ $LINES lines" || echo "❌ $LINES lines (keep under 500)"

UI=$(grep -m1 '^user-invocable:' "$SKILL_ABS" | awk '{print $2}')
DI=$(grep -m1 '^disable-model-invocation:' "$SKILL_ABS" | awk '{print $2}')
if [ "$UI" = "false" ] && [ "$DI" = "true" ]; then
  echo "❌ unreachable skill: both invocation controls disable access"
else
  echo "✅ invocation controls"
fi
```

4. Report each check result.
5. For any failures, state the exact fix required (e.g., rename directory, add missing section, update description).

To validate all skills at once:
```bash
for dir in .agents/skills/*/; do
  name=$(basename "$dir")
  echo "--- $name ---"
  SKILL="${dir}SKILL.md"
  [ -f "$SKILL" ] || { echo "❌ SKILL.md missing"; continue; }
  FOLDER="$name"
  NAME=$(grep -m1 "^name:" "$SKILL" | sed 's/name: *//')
  [ "$FOLDER" = "$NAME" ] && echo "✅ name" || echo "❌ name mismatch: $NAME"
done
```
