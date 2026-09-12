# EDD Loop

Run an explicit, evidence-driven implementation workflow with bounded edits,
deterministic checks, and a fresh read-only verification pass.

## Required inputs

Provide the implementation task, allowed paths, acceptance criteria, required
and advisory checks, and any leading `max=N` round-limit override. If the task
is planning-only, review-only, trivial, or lacks edit authority, stop and report
that this workflow does not apply.

## Steps

1. Read `AGENTS.md`, `CLAUDE.md`, and the canonical workflow at
   `.agents/skills/edd-loop/SKILL.md`. Read
   `.agents/skills/edd-loop/references/contracts.md` before editing or
   delegating.
2. Normalize the task and resolve the round limit. Record an EDD containing
   scope, required and advisory criteria, exact deterministic commands and
   pass conditions, risk boundaries, evidence targets, and the client/model/
   permission preflight.
3. In Plan Mode, return the EDD and implementation plan only. Do not edit,
   delegate, or verify.
4. For implementation mode, use `Agent` only when a bounded worker is
   available and authorized. Pass paths and the EDD, keep the brief under 400
   tokens, preserve unrelated work, and prohibit commits and delegation.
5. Run every required deterministic check. If one fails, do not start a
   verifier; repair only the identified gap within the remaining rounds.
6. After a passing gate, use a fresh read-only `Agent` verifier when the exact
   client, model, reasoning, and permissions required by the contract are
   available. If they are unavailable, report `BLOCKED` rather than silently
   substituting. Pass no worker conclusions.
7. Converge only to `VERIFIED`, `INCOMPLETE`, or `BLOCKED`. Stop at the resolved
   round limit and report exact changed paths, commands, evidence, skipped
   checks, verdict, and remaining gaps. Do not commit unless requested.

## Done when

- The EDD was recorded before edits.
- Required deterministic checks passed before verification.
- A fresh verifier returned `VERIFIED`, or the report explicitly explains why
  the workflow is `INCOMPLETE` or `BLOCKED`.
- The final report includes the round count, changed paths, evidence, and any
  required user decision.
