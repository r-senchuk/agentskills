---
name: macos-homebrew-troubleshoot
description: "Use when diagnosing and fixing macOS environment issues, Homebrew problems, PATH conflicts, binary version mismatches, permissions errors, quarantine attributes, code signing, and launchd service configuration. Do not use for writing new scripts, non-macOS platforms, or general application debugging."
argument-hint: "Symptom description, macOS version, relevant command output or error message."
user-invocable: false
---

# macOS & Homebrew Troubleshooting

## When To Use

- **Environment debugging**: PATH resolution failures, wrong binary picked up, missing tools after install.
- **Homebrew issues**: `brew doctor` warnings, formula/cask conflicts, tap problems, service failures, version pinning.
- **macOS-specific**: file system permissions (SIP, TCC), quarantine attributes (`com.apple.quarantine`), code signing errors, Gatekeeper blocks.
- **launchd services**: debugging `launchctl` issues, plist validation, service lifecycle.
- **BSD vs GNU**: diagnosing command flag differences between macOS BSD utils and GNU coreutils.

Do NOT use for writing new scripts from scratch, Linux-only issues, Windows issues, general application debugging unrelated to macOS/environment, or agent/skill authoring.

## Inputs To Collect First

1. **Symptom** — what is broken or unexpected (error message, wrong output, missing command)
2. **macOS version** — `sw_vers` output or approximate version (Ventura, Sonoma, Sequoia)
3. **Shell** — zsh or bash, and whether it's the system default or Homebrew-installed
4. **Relevant output** — error messages, `which <tool>`, `brew doctor`, `echo $PATH`, etc.

## Procedure

### Step 1 — Gather System Context

Collect baseline information to understand the environment:

```bash
# macOS version
sw_vers

# Active shell and version
echo "$SHELL" && $SHELL --version

# Homebrew status
brew --prefix && brew --version
brew doctor 2>&1 | head -30

# PATH inspection
echo "$PATH" | tr ':' '\n'

# Check for common conflicts
which -a python3 node ruby 2>/dev/null
```

Identify: macOS version, shell, Homebrew prefix (`/opt/homebrew` on Apple Silicon vs `/usr/local` on Intel), and any obvious PATH issues.

### Step 2 — Diagnose the Issue

Based on the symptom, investigate using the appropriate approach:

**PATH and binary conflicts:**
```bash
# Which binary is being picked up
which <command>
type -a <command>

# Check if Homebrew version exists
brew list --formula | grep <package>
brew info <package>

# Verify Homebrew paths are in PATH
echo "$PATH" | grep -q "$(brew --prefix)/bin" && echo "OK" || echo "Homebrew bin not in PATH"
```

**Homebrew problems:**
```bash
# Full diagnostic
brew doctor

# Check for broken links
brew missing

# Outdated packages
brew outdated

# Service status
brew services list
```

**Permission and security issues:**
```bash
# Check quarantine attribute
xattr -l /path/to/file

# Remove quarantine (with user confirmation)
# xattr -d com.apple.quarantine /path/to/file

# Check SIP status
csrutil status

# Check code signing
codesign -dv --verbose=4 /path/to/binary 2>&1
```

**launchd service issues:**
```bash
# List loaded services
launchctl list | grep <service>

# Check plist syntax
plutil -lint ~/Library/LaunchAgents/<plist>

# View service logs
log show --predicate 'senderImagePath CONTAINS "<service>"' --last 5m
```

### Step 3 — Identify Root Cause

Common root causes on macOS:

| Symptom | Likely Cause | Fix |
|---|---|---|
| `command not found` after `brew install` | Homebrew bin not in PATH | Add `eval "$(brew shellenv)"` to shell profile |
| Wrong version of tool runs | System binary shadows Homebrew | Reorder PATH or use `brew link --force` |
| `Permission denied` on `/usr/local` | Ownership issue | `sudo chown -R $(whoami) $(brew --prefix)/*` |
| `"app" is damaged and can't be opened` | Quarantine attribute | `xattr -cr /path/to/app` |
| `brew doctor` warns about unlinked kegs | Formula not linked | `brew link <formula>` |
| Intel Homebrew on Apple Silicon | Rosetta prefix conflict | Separate prefixes: `/opt/homebrew` (ARM) vs `/usr/local` (Intel) |
| `launchctl` service won't start | Bad plist or missing binary | Validate with `plutil -lint`, check binary path exists |

### Step 4 — Apply Fix

Apply the identified fix:
1. Explain what the fix does and why before applying
2. Prefer non-destructive fixes — suggest `--dry-run` flags where available
3. For PATH changes, edit the correct shell profile file (`.zshrc`, `.zprofile`, `.bash_profile`)
4. For Homebrew fixes, run the appropriate `brew` command
5. For permission fixes, use the minimum privilege needed

### Step 5 — Validate Fix

After applying the fix, verify it resolved the issue:

```bash
# Re-check the original symptom
which <command>
<command> --version

# Verify Homebrew health
brew doctor 2>&1 | head -10

# Source profile and re-test if PATH was changed
source ~/.zshrc && echo "$PATH" | tr ':' '\n'
```

Confirm:
- The original symptom is resolved
- No new warnings from `brew doctor`
- The fix is persistent (survives new shell sessions)

## Completion Checks

- [ ] System context gathered (macOS version, shell, Homebrew prefix)
- [ ] Root cause identified with evidence
- [ ] Fix applied and explained
- [ ] Original symptom verified resolved
- [ ] Fix is persistent across new shell sessions
- [ ] No new `brew doctor` warnings introduced
- [ ] No unnecessary privilege escalation used

## References

- [Homebrew Documentation](https://docs.brew.sh/)
- [Apple Developer — Code Signing](https://developer.apple.com/documentation/security/code-signing)
