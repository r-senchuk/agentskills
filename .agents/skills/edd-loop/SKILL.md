---
name: edd-loop
description: "Use when the user explicitly invokes $edd-loop for evaluation-driven implementation that must meet a written EDD. Do not use for planning-only requests, review-only requests, or trivial work."
argument-hint: "[max=N] Implementation task, scope and paths, acceptance criteria, required/advisory checks, and validation commands."
user-invocable: true
disable-model-invocation: true
---

## When To Use

- Run only after an explicit `$edd-loop <task>` invocation. `disable-model-invocation: true` is intentional: never infer this workflow from an ordinary implementation request.
- Use for substantive, evaluation-driven implementation where an Evaluation-Driven Definition (EDD) can state required and advisory criteria and produce inspectable evidence.
- Do NOT use for planning-only work, review/audit-only work, trivial edits, or requests that lack authority to edit the requested scope.

## Inputs To Collect First

1. The normalized task, intended paths, acceptance criteria, whether the user selected Plan Mode, and the resolved round limit. A leading `max=N` explicitly overrides the default of three rounds; parse it using [contracts](./references/contracts.md).
2. Repository instructions, approval constraints, current branch, dirty-worktree boundaries, and any applicable security or ownership rules.
3. Required and advisory checks, their exact commands, risk boundaries, allowed external effects, and evidence expected from each check.
4. The platform (Codex or OpenCode), available implementation/verifier workers, and the maximum safe validation budget.

Before any edit or worker/verifier call, complete the client/model/permission
preflight in [contracts](./references/contracts.md). Record the client, exact
model and reasoning setting, canonical global skill path, and effective tool
permissions; stop as `BLOCKED` on any mismatch or missing permission. Do not
silently substitute a client or model.

## Procedure

### Step 1 — Establish scope and authority

Confirm the explicit invocation, read applicable repository instructions, inspect status/diff read-only, and record paths already changed by others. Refuse or narrow work that is planning-only, review-only, trivial, or outside approved boundaries. Do not commit unless requested.

### Step 2 — Build the EDD before editing

Create the EDD record before any implementation edit. Include required and advisory criteria, deterministic commands and pass conditions, risk/boundaries, and evidence targets using [contracts](./references/contracts.md). Resolve missing commands or unsafe scope before assigning work. In Plan Mode, return the EDD and implementation plan only, then stop; do not edit or verify.

### Step 3 — Assign bounded implementation work

Use briefs and the worker contract in [contracts](./references/contracts.md). Keep every brief at or below 400 tokens, pass paths rather than file contents, and preserve minimal/fresh context. On Codex, use at most two independent built-in workers, each with `gpt-5.6-luna` at high reasoning. On OpenCode, route to the installed `edd-luna-worker` agent. Keep ownership clear and do not delegate verifier work to implementation workers.

### Step 4 — Implement, then run the deterministic gate

Implement within the EDD boundaries and preserve unrelated changes, approvals, and repository instructions. Run required deterministic checks before any Sol verifier. If the deterministic gate fails, skip Sol, capture the failing commands/evidence, and repair only within the remaining round budget. Reuse the implementation owner for a narrow repair when possible; do not silently fall back to another model.

### Step 5 — Obtain a fresh read-only verification

After a passing deterministic gate, start a fresh verifier for this round. On Codex use `edd_verifier` with `gpt-5.6-sol` at high reasoning; on OpenCode route to the installed `edd-sol-verifier`. Pass only the normalized task, EDD, changed paths, diff, and command/evidence results. Never pass worker conclusions. The verifier is read-only and may not delegate. Require exactly one verdict: `VERIFIED`, `INCOMPLETE`, or `BLOCKED`.

The Codex caller must supply exactly `gpt-5.6-sol` with high reasoning. No
fallback, model substitution, or automatic retry on another model is allowed;
an unavailable exact model is `BLOCKED`.

### Step 6 — Converge or escalate

Classify the result using [contracts](./references/contracts.md). `VERIFIED` ends the loop. For `INCOMPLETE`, make a bounded repair and repeat the deterministic gate and fresh verifier. Use the resolved round limit recorded in the EDD. After the final configured round, or whenever safe progress is impossible, return `BLOCKED` with explicit gaps and a proposed escalation; do not silently change the limit, models, scope, or criteria.

### Step 7 — Report evidence and hand off

Report the exact changed files, EDD criteria results, commands and evidence, round count, and the exact final verdict. State skipped checks and why. Leave the worktree uncommitted unless the user requested a commit, and mention any required follow-up without modifying unrelated files.

## Completion Checks

- [ ] Invocation was explicit and the task was substantive implementation, not planning-only, review-only, or trivial work.
- [ ] EDD was recorded before edits with required/advisory criteria, commands, risk/boundaries, and evidence targets.
- [ ] Plan Mode produced no edits or verification.
- [ ] Worker/platform/model limits, fresh-context rules, and brief budget were followed.
- [ ] Client/model/permission preflight was recorded before edits and each fresh verifier; no fallback or substitution occurred.
- [ ] Context was supplied progressively: paths and contracts first, then only the evidence needed for the current criterion.
- [ ] Deterministic checks ran before Sol, and Sol was skipped when that gate failed.
- [ ] The verifier received no worker conclusions and remained fresh, read-only, and non-delegating.
- [ ] The loop used no more than the EDD's resolved round limit and ended with exactly `VERIFIED`, `INCOMPLETE`, or `BLOCKED`.
- [ ] Unrelated work, approvals, instructions, and dirty-worktree changes were preserved; no unrequested commit was made.
- [ ] Final report names changed paths and command evidence, and scoped diff checks pass.

## References

- [EDD record, worker/verifier briefs, outputs, and convergence contracts](./references/contracts.md)
