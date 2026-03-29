---
name: shell-script-audit
description: "Use when reviewing, auditing, or hardening shell scripts for stability, portability, error handling, edge cases, and best practices. Covers bash and zsh scripts. Do not use for writing new scripts from scratch, general coding tasks, or non-shell languages."
argument-hint: "Path to script or directory, target shell (bash/zsh), portability scope (macOS, Linux, cross-platform)."
user-invocable: false
---

# Shell Script Audit

## When To Use

- **Audit**: Reviewing an existing shell script for bugs, fragility, missing error handling, or portability issues.
- **Harden**: Adding defensive patterns — `set -euo pipefail`, quoting, trap handlers, input validation.
- **Fix**: Applying targeted fixes for specific shell script issues (race conditions, unquoted expansions, missing checks).
- **Validate**: Running syntax checks (`bash -n`, `zsh -n`), dry-run verification, and shellcheck analysis.

Do NOT use for writing entirely new scripts from scratch (use standard coding workflow), non-shell languages, or general debugging unrelated to shell scripting.

## Inputs To Collect First

1. **Script path(s)** — file or directory to audit (e.g., `scripts/setup.sh` or `scripts/`)
2. **Target shell** — bash, zsh, sh, or auto-detect from shebang
3. **Portability scope** — macOS only, Linux only, or cross-platform
4. **Audit focus** — full audit, or specific concern (e.g., "error handling only", "portability only")

## Procedure

### Step 1 — Discover and Read Scripts

Locate all shell scripts in scope:

```bash
# Find by extension and shebang
find <target-path> -type f \( -name '*.sh' -o -name '*.bash' -o -name '*.zsh' \) 2>/dev/null
grep -rl '^#!.*\(bash\|zsh\|sh\)' <target-path> 2>/dev/null
```

For each script:
1. Read the full file contents
2. Identify the shebang line to determine target shell
3. Note the script's purpose from comments or usage functions

### Step 2 — Static Analysis

Run automated checks where available:

```bash
# Syntax check (use the shell from the shebang)
bash -n script.sh    # for bash scripts
zsh -n script.zsh    # for zsh scripts

# ShellCheck (if installed)
shellcheck -s bash script.sh 2>&1 || true
```

If `shellcheck` is not installed, perform manual static analysis covering the same categories.

### Step 3 — Manual Review Checklist

Evaluate each script against these categories. For each finding, note the line number, severity (critical/warning/info), and a concrete fix.

**Error Handling:**
- Shebang is present and correct for the target shell
- `set -e` (exit on error) or equivalent is active
- `set -u` (undefined variable errors) is active
- `set -o pipefail` catches pipeline failures (bash/zsh)
- `trap` handlers clean up temp files, restore state on EXIT/ERR/INT
- Commands that can fail have explicit error checks or `|| { handle; }`
- Exit codes are meaningful (not all `exit 1`)

**Quoting and Expansion:**
- All variable expansions are double-quoted: `"$var"`, `"${array[@]}"`
- Command substitutions are quoted: `"$(command)"`
- Globs that may expand to nothing are handled (`nullglob`, default values, or explicit checks)
- No unquoted `$@` or `$*` in contexts where arguments contain spaces
- Word splitting is intentional, never accidental

**Portability:**
- No GNU-only flags without checking OS (e.g., `sed -i ''` vs `sed -i`)
- `[[ ]]` used instead of `[ ]` for bash/zsh (or POSIX `[ ]` for sh)
- No bashisms in `#!/bin/sh` scripts
- Path assumptions are documented or configurable (no hardcoded `/usr/local/bin`)
- `command -v` used instead of `which` for portability

**Input Validation and Edge Cases:**
- Required arguments are checked before use: `[[ $# -ge N ]]`
- File/directory existence checked before access: `[[ -f "$path" ]]`
- Empty string and whitespace inputs are handled
- Paths with spaces, special characters, and symlinks work correctly
- Race conditions between check and use (TOCTOU) are minimized

**Security:**
- No `eval` on user-controlled input
- No unquoted variables in command position
- Temp files use `mktemp` (not predictable names)
- Secrets are not logged or echoed
- `PATH` is not blindly trusted for security-sensitive operations

**Style and Maintainability:**
- Functions are used for repeated logic
- A `usage()` function exists for scripts with arguments
- Variables use consistent naming convention (UPPER for env/config, lower for local)
- Complex logic has inline comments
- Magic numbers and paths are named constants

### Step 4 — Produce Findings Report

Structure findings as a table:

```markdown
| # | Line | Severity | Category | Finding | Fix |
|---|------|----------|----------|---------|-----|
| 1 | 42   | critical | error-handling | `rm -rf $dir` unquoted — could delete wrong path | `rm -rf "$dir"` |
```

Severity levels:
- **critical** — data loss, security vulnerability, or script breaks silently
- **warning** — fragile behavior under edge cases, non-portable construct
- **info** — style improvement, maintainability suggestion

### Step 5 — Apply Fixes

For each critical and warning finding:
1. Edit the script to apply the fix
2. Preserve existing behavior — do not refactor beyond the fix scope
3. Add a brief inline comment only when the fix is non-obvious

### Step 6 — Validate Changes

After applying fixes, re-run validation:

```bash
# Re-check syntax
bash -n script.sh

# Re-run shellcheck if available
shellcheck -s bash script.sh 2>&1 || true

# Dry-run if the script supports it
./script.sh --dry-run 2>&1 || true
```

Confirm:
- Syntax check passes with no errors
- No new shellcheck warnings introduced
- Dry-run (if supported) completes without errors

## Completion Checks

- [ ] All scripts in scope have been read and analyzed
- [ ] Shebang line is correct for each script
- [ ] `set -euo pipefail` (or shell-appropriate equivalent) is present
- [ ] All variable expansions are properly quoted
- [ ] No unguarded `rm`, `mv`, or destructive commands on unquoted paths
- [ ] Required arguments and file existence are validated before use
- [ ] No `eval` on untrusted input; no secrets in logs
- [ ] Findings table is complete with line numbers and concrete fixes
- [ ] All critical and warning fixes have been applied
- [ ] Syntax check passes after fixes
- [ ] Shellcheck (if available) shows no new warnings after fixes

## References

- [Shell Audit Checklist](./references/shell-audit-checklist.md)
