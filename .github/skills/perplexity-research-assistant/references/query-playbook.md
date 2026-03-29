# Query Playbook

## Query Skeleton
Use this structure for reliable retrieval:

1. Topic: exact subject.
2. Scope: specific aspect(s) only.
3. Constraints: region/domain/language/timeframe.
4. Output format: table, bullets, pros/cons, matrix.
5. Fallback: instruct model to declare missing evidence.

Template:

"Analyze [topic] focusing on [scope] for [timeframe/region]. Use [constraints]. Return [output format]. If reliable evidence is insufficient, say so explicitly and list what is missing."

## Good Patterns
- Comparative: "Compare A vs B for C in terms of X, Y, Z; include recent evidence."
- Troubleshooting: "Root causes of [error] in [context], ranked by likelihood with verification steps."
- Change tracking: "What changed in [tool/version] since [date/version], with impact on [use case]?"

## Anti-Patterns
- Vague: "Tell me about X"
- Multi-topic bundle: unrelated questions in one request
- Prompt-only search control: "search only on ..." without API filters
- URL forcing: asking model text to fabricate links instead of using metadata

## Iterative Refinement Workflow
1. Run broad but scoped query.
2. Identify weak evidence areas.
3. Re-run with tighter domain and recency filters.
4. Reconcile conflicts and report remaining uncertainty.

## Output Contract Suggestion
- Findings (3-7 bullets)
- Source table (title, URL, date, claim supported)
- Confidence level per finding
- Open questions and next query
