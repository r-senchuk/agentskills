---
name: mistral-skill-governance
description: "Use when you need to audit, optimize, or refactor the Mistral skill portfolio for routing quality, overlap reduction, and best-practice compliance in this repository."
argument-hint: "Audit scope (all skills or subset), primary consumer (mistral-sdk-agent or direct user), and optimization goals (discoverability, de-duplication, maintenance)"
user-invocable: false
---

# Mistral Skill Governance

Workflow for reviewing Mistral-focused skills as a coherent portfolio: measure usefulness for the entrypoint router, identify overlap, enforce quality standards, and produce concrete keep/merge/trim decisions.

## When To Use
- You want to verify whether current skills are still needed for the entrypoint workflow.
- You suspect overlap or duplication across specialized skills.
- You need to improve discoverability and routing precision.
- You want to prepare a clean, maintainable set of skills before upstream submission.

## Inputs To Collect First
1. Audit scope: all skills or a named subset.
2. Primary consumer: entrypoint router skill, custom agent, direct slash-invocation, or all three.
3. Decision criteria: correctness, discoverability, maintenance overhead, and user value.
4. Constraints: backward compatibility, naming stability, and release timeline.

## Procedure
1. Inventory and validate skill metadata.
2. Evaluate routing utility for the entrypoint.
3. Score overlap and maintenance risk.
4. Decide keep, optimize, merge, or deprecate.
5. Implement low-risk fixes first.

## 1) Inventory and Validate Skill Metadata
- Confirm each skill has required frontmatter fields.
- Verify name-to-folder match.
- Check discovery quality of description text using specific trigger phrases.
- Confirm body contains ordered sections:
  - When To Use
  - Inputs To Collect First
  - Procedure
  - Completion Checks
  - References

## 2) Evaluate Routing Utility for the Entrypoint
- Map each specialized skill to one and only one dominant intent.
- Ensure the entrypoint triage table references every active specialized skill.
- Flag any specialized skill that is not reachable from the entrypoint's decision table.

## 3) Score Overlap and Maintenance Risk
- Overlap score: estimate duplicated procedural guidance across skills.
- Drift score: estimate risk of model/version recommendations diverging across files.
- Maintenance score: estimate update burden when APIs or model names change.

Use this lightweight scoring rubric:
- Low: isolated domain and low cross-file duplication.
- Medium: partial overlap but clear primary owner.
- High: substantial duplication or ambiguous ownership.

## 4) Decide Keep, Optimize, Merge, or Deprecate
- Keep: unique domain coverage and strong routing value.
- Optimize: keep domain but tighten scope, wording, or examples.
- Merge: two skills have materially overlapping purpose and procedures.
- Deprecate: little routing value, stale guidance, or superseded by another skill.

Decision rule:
- Merge or deprecate only when user outcome quality is unchanged or improved.

## 5) Implement Low-Risk Fixes First
- Fix snippet correctness issues (missing imports, mismatched variable names).
- Tighten descriptions for discovery.
- Normalize recurring guidance into references when duplication is high.
- Re-run completion checks after edits.

## Completion Checks
- Every active skill is reachable through entrypoint routing.
- No skill has ambiguous domain ownership.
- At least one concrete optimization action is documented per medium/high overlap area.
- Fixes are applied for all correctness issues found during the audit.
- Keep/optimize/merge/deprecate decisions are recorded with rationale.

## References
- [Entrypoint skill](../mistral-sdk-agent/SKILL.md)
- [Agent builder](../mistral-agent-builder/SKILL.md)
- [Function calling](../mistral-function-calling/SKILL.md)
- [Embeddings and RAG](../mistral-embeddings-rag/SKILL.md)
- [Structured outputs](../mistral-structured-outputs/SKILL.md)
- [Document AI](../mistral-document-ai/SKILL.md)
- [Vibe expert](../mistral-vibe-expert/SKILL.md)
- [Shared Mistral cross-cutting guidance](../../references/mistral-cross-cutting-guidance.md)
