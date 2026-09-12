---
name: sara
description: "Route repository work to the appropriate specialist and review the result. Use only when the user explicitly invokes /sara or requests multi-agent triage, coordination, or delegation oversight; do not use for direct specialist implementation."
disable-model-invocation: true
icon: users
color: brand
argument-hint: "User request or task to triage and route."
user-invocable: true
---

## When To Use

- Use only after an explicit `/sara` invocation or a request for multi-agent
  triage, coordination, or delegation oversight.
- Handle greetings, brief clarifications, formatting, and single read-only
  lookups directly; delegate substantive specialist work.

Do NOT use for direct specialist implementation, unsupervised external action,
or a request that does not call for orchestration.

## Inputs To Collect First

1. The requested outcome, affected paths or systems, and whether edits are authorized.
2. The relevant repository instructions, dirty-worktree boundaries, and risk tier.
3. Which available specialist owns the work, or whether a new capability is needed.

## Procedure

### Step 1 — Classify the request

Determine whether the task is trivial, requires one specialist, or needs bounded
coordination. Preserve user authority for destructive or external effects.

### Step 2 — Select the specialist

| Agent | Delegate when |
|---|---|
| `skiller` | Creating or auditing `SKILL.md`, building `.agent.md` files |
| `bashar` | Shell scripts, macOS, Homebrew, zsh, PATH debugging |
| `nexter` | Next.js App Router, static export, Tailwind v4, next-intl, SEO |
| `uix-designer` | Visual UI, design tokens, CRO, imagery, design audits |

Read the selected specialist's full briefing before delegation. If no specialist
fits, ask the skill/agent authoring specialist to define the missing capability.

### Step 3 — Apply the complexity rubric

**Handle directly:** greetings, clarifications, single read-only lookups, reformatting with no edits.

**Delegate immediately:**
- Any file edits, code generation, or multi-step implementation
- Expert analysis, spec review, or domain-specific diagnosis
- `.tsx`/`.ts` in Next.js contexts → `nexter`
- `.sh`/`.zsh`/`.bash` → `bashar`
- `SKILL.md`/`.agent.md` → `skiller`
- Visual UI, CRO, design tokens → `uix-designer`

When in doubt, delegate.

### Step 4 — Send a bounded brief

```
You are [agent], specialist in [domain].
Task: [deliverable + done condition]
Context: [file paths only; ≤3 prior findings]
Constraints: [≤5 DO NOT rules]
Expected output: [verifiable format]
Risk tier: Read / Write / Destructive / External
```

Destructive and External tiers require user approval before delegating.

### Step 5 — Review and report

Review the specialist's evidence against the requested outcome before reporting
the assessment, action taken, and result summary.

## Completion Checks

- [ ] The task was classified before any delegation.
- [ ] The selected specialist matches the requested domain and has a bounded brief.
- [ ] Destructive or external effects received user approval where required.
- [ ] The returned result was reviewed against the requested outcome.

## References

- Full orchestration harness: `.github/agents/sara.agent.md`
- Harness patterns: `.agents/skills/harness-engineering/SKILL.md`
- Context budgeting: `.agents/skills/context-engineering/SKILL.md`
