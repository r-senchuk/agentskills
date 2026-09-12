# EDD Loop Contracts

This is the single detailed source for EDD records, implementation-worker briefs, verifier briefs and outputs, and convergence classification. `SKILL.md` defines the workflow; do not copy these templates into it.

## Terms and invariants

- **EDD** means Evaluation-Driven Definition: a pre-edit, evidence-oriented record of what must be true, how it will be checked, and what is outside scope.
- **Required** criteria are release gates. **Advisory** criteria improve confidence but cannot turn a passing required gate into a failure without an explicit user decision.
- A **round** is one bounded implementation attempt followed by its deterministic gate and, only when that gate passes, a fresh Sol verification.
- The default round limit is three. A valid leading `max=N` invocation token explicitly overrides it. There is no silent limit change, model fallback, scope expansion, or criterion weakening.
- Preserve repository instructions, user approvals, dirty-worktree work, and unrelated files. No commit is implied.
- A client/model/permission preflight is required before the first edit and before every fresh verifier. Missing or mismatched preflight data is `BLOCKED`.
- Canonical global skill roots are client-specific: Codex reads `~/.codex/skills/edd-loop/`; OpenCode reads `~/.config/opencode/skills/edd-loop/`. These paths are installed by bootstrap independently of Cursor.

## EDD record

Create this record before any implementation edit. Keep it concise but complete.

```text
EDD
Task: <normalized, implementation-oriented task>
Mode: <Implement | Plan>
Scope: <allowed paths and explicitly excluded paths>
Required criteria:
  R1: <observable outcome>
  R2: <observable outcome>
Advisory criteria:
  A1: <useful but non-gating outcome>
Deterministic gate:
  - command: <exact command>
    pass: <exit/output condition>
  - command: <exact command>
    pass: <exit/output condition>
Risk and boundaries:
  - allowed effects: <writes, tools, network, or external systems authorized>
  - forbidden effects: <out-of-scope paths/actions>
  - approvals required: <approval or user decision>
Evidence targets:
  - <path, diff hunk, test result, or command output needed to establish a criterion>
Round limit: <resolved positive integer; default 3 or explicit max=N>
Verifier: <fresh edd_verifier / edd-sol-verifier, read-only, no delegation>
Preflight: <client, canonical skill root, exact model/reasoning, effective permissions, and pass/fail result>
```

An EDD is not complete until every required criterion has a check and evidence target, commands have unambiguous pass conditions, and risk/boundary decisions are explicit. If a command is unavailable or a required criterion is untestable, stop before editing and classify the work as blocked for user escalation.

## Round-limit override

Resolve the round limit before normalizing the task or editing:

- Accept `max=N` only as the first whitespace-delimited token after `$edd-loop` or `/edd-loop`.
- `N` must be a base-10 positive integer. Store its value in the EDD and remove only that token from the normalized task.
- With no leading override, use three rounds.
- An invalid leading `max=` token is `BLOCKED` pending a corrected invocation; never guess, clamp, or silently use the default.
- If the requested limit exceeds the available validation budget, stop as `BLOCKED` and ask the user to lower it or authorize the additional cost; never clamp it silently.
- The override changes only the number of implementation rounds. It does not expand scope, permissions, context, model fallback, or external-effect authority.

Examples: `$edd-loop max=5 <task>` and `/edd-loop max=5 <task>` resolve to five rounds. A later phrase such as `set max=5 in config` remains part of the task and does not change the loop limit.

## Normalized task

Normalize the user request into one sentence that preserves intent, scope, authority, and deliverable. Include paths and constraints by reference, not copied file contents. Remove conversational filler and do not add acceptance criteria that the user did not authorize.

## Implementation-worker brief

Each brief must be no more than 400 tokens and must contain only the information needed for the assigned bounded work. Pass paths, not content; the worker reads files itself.

```text
Role: edd-luna-worker (bounded implementation owner)
Task: <normalized task and assigned criterion(s)>
Read first: <repository instruction paths and EDD path/record location>
Allowed paths: <exact writable paths>
Checks: <commands relevant to this assignment>
Constraints: preserve dirty work, no commit, no delegation, report changed paths and evidence only
Done: <observable criterion and expected handoff>
```

On Codex, use at most two independent built-in workers with `gpt-5.6-luna`, high reasoning, minimal/fresh context. On OpenCode, use the installed `edd-luna-worker`. Do not include a prior worker's conclusions in another worker's brief.

Before dispatch, the caller records the preflight fields above. Implementation
workers may edit only the explicitly allowed paths and must have the requested
edit/write permission; they never receive verifier conclusions or unrelated
repository content.

## Verifier brief

Start a fresh verifier each round. Keep the brief at or below 400 tokens and pass only normalized task, EDD, paths, diff, and deterministic command/evidence results. Never pass worker conclusions, confidence claims, or hidden chain-of-thought.

```text
Role: edd_verifier (read-only)
Task: <normalized task>
EDD: <complete EDD record or path to it>
Inspect: <changed paths and diff>
Evidence: <deterministic commands, exit statuses, and relevant output paths>
Preflight: <client, canonical skill root, exact model/reasoning, effective permissions, and pass/fail result>
Rules: read-only; no delegation; assess required criteria first; advisory findings are non-gating
Output: exactly one verdict token, then explicit criterion-to-evidence findings and gaps
```

Codex uses a fresh `edd_verifier` with exactly `gpt-5.6-sol` at high reasoning;
no fallback or substitution is permitted. OpenCode uses the installed
`edd-sol-verifier` agent with its pinned Sol model. The verifier must not
modify files, run bash, run mutating commands, or delegate.

## Progressive context

Keep context minimal and add it only as needed: first pass the normalized task,
scope, EDD, and paths; then let the worker or verifier read the named files;
finally pass the current diff and deterministic evidence. Never paste whole
repositories, duplicate contract text, or pass worker conclusions to a fresh
verifier.

## Verifier output

The first non-empty line must be exactly one of these tokens, with no decoration:

```text
VERIFIED
INCOMPLETE
BLOCKED
```

After that line, provide a compact evidence table or bullets mapping every required criterion to evidence, list advisory findings separately, name missing/failed checks, and state the next safe action. `VERIFIED` requires every required criterion and deterministic gate to pass. `INCOMPLETE` means safe, bounded repair remains. `BLOCKED` means a required authority, input, command, safe boundary, or repair path is unavailable. Do not invent a fourth verdict or silently translate a worker's opinion into a verdict.

## Deterministic gate and round protocol

For each round:

1. Capture the pre-round status and the implementation paths.
2. Re-run the client/model/permission preflight and apply only bounded edits.
3. Run every required deterministic command and record exit status plus evidence path/output.
4. If any required deterministic check fails, do not start Sol. Classify as `INCOMPLETE` when a safe repair remains; classify as `BLOCKED` when the failure exposes an unavailable prerequisite or unsafe boundary.
5. If all required deterministic checks pass, invoke a fresh Sol verifier with the verifier brief.
6. For `INCOMPLETE`, repair only identified gaps, preferably reusing the implementation owner for narrow repairs, then begin the next round. For `VERIFIED`, stop. For `BLOCKED`, stop and escalate.

At the end of the EDD's resolved round limit, any non-`VERIFIED` state becomes `BLOCKED`, even if another repair seems possible. The escalation must name each remaining gap, the evidence showing it, the missing authority/input, and a proposed next action (for example, user decision, new command, expanded approved scope, or human review). Never silently increase the round limit.

## Convergence classification

Use this classification consistently:

| State | Meaning | Required action |
| --- | --- | --- |
| `VERIFIED` | All required criteria and deterministic checks pass; no blocking boundary remains. | Report evidence and hand off. |
| `INCOMPLETE` | One or more required criteria fail, but the EDD, authority, commands, and safe repair path remain available and the round limit is not exhausted. | Repair within scope and run the next round. |
| `BLOCKED` | Required authority, input, command, safe boundary, or repair path is unavailable; or the configured rounds have ended without `VERIFIED`. | Stop, report explicit gaps, and propose escalation. |

Advisory criteria may be reported as gaps without changing `VERIFIED` unless the EDD explicitly promotes them to required criteria through an authorized user decision. A deterministic failure always prevents Sol for that round.

## Final evidence packet

The handoff/report must include: normalized task; resolved round limit; EDD criteria status; exact changed paths; relevant diff summary; deterministic commands with statuses; verifier verdict and criterion evidence; rounds used; skipped checks and reasons; explicit gaps/escalation if not `VERIFIED`; and confirmation that no unrequested commit or unrelated change was made.
