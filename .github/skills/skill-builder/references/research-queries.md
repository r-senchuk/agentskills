# Research Query Playbook for Skill Building

Use these query templates before writing any SKILL.md. Replace `[DOMAIN]` with the specific technology, workflow, or tool name.

## Phase 1 — Perplexity Research

Use `perplexity-research-assistant` (model: `sonar-pro`) for up-to-date, source-grounded answers.

### Best Practices
```
[DOMAIN] best practices authoritative guide 2025 production patterns
```
Look for: official docs, consensus patterns, team conventions at reputable orgs.

### Anti-Patterns
```
[DOMAIN] common mistakes anti-patterns what NOT to do pitfalls 2024 2025
```
Look for: failure modes, gotchas, footguns from forum posts, postmortems, engineering blogs.

### Checklist / Quality Gates
```
[DOMAIN] production checklist review criteria before launch 2025
```
Look for: numbered checklists from practitioners, validation gates, quality criteria.

### Breaking Changes (fast-moving areas only)
```
[DOMAIN] breaking changes 2024 2025 migration guide deprecated removed
```
Look for: version diffs, migration notes, deprecation warnings.

## Phase 2 — GitHub Search for Comparable Skills

Search in this order:

### 1. Find existing SKILL.md files for this domain

GitHub code search query:
```
filename:SKILL.md [domain keyword]
```

Example: `filename:SKILL.md terraform`

### 2. Find related agent skill collections

GitHub repo search:
```
agent skill [domain keyword] copilot
```

Also check directly:
- [awesome-copilot.github.com/skills](https://awesome-copilot.github.com/skills) — full community index
- [github/awesome-copilot](https://github.com/github/awesome-copilot) — upstream source

### 3. Extract patterns from top results

For each relevant SKILL.md found, capture:
- Section structure that works well → adopt
- Gaps they left → fill in your skill
- Patterns to learn from but not copy verbatim

## Phase 3 — Gap Analysis

After research, classify each finding:

| Category | Action |
|---|---|
| Best practice with clear uplift beyond defaults | Include in Procedure |
| Generic advice the model handles well on its own | Skip |
| Anti-pattern worth encoding | Add to Completion Checks or a "What Not To Do" note |
| Official reference worth citing | Add to References section |
| Comparable skill already covers it fully | Narrow your scope or link to it |

## Research Output Contract

Document findings before writing the skill, using this format:

```
Domain: [name]
Key practices: [3–5 bullet points with source]
Key anti-patterns: [3–5 bullet points with source]
Authoritative refs: [URLs]
Comparable skills found: [skill name + repo URL]
Gaps this skill fills that others don't cover: [1–3 specific gaps]
```

This contract becomes the basis for the skill's Procedure steps and References section.
