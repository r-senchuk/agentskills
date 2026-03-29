---
name: zsh-config-expert
description: "Use when configuring, troubleshooting, or optimizing zsh: shell options, completion system, prompt customization, parameter expansion, glob qualifiers, .zshrc/.zprofile structure, and plugin management. Do not use for bash-only scripts, non-shell configuration, or writing new scripts from scratch."
argument-hint: "Zsh configuration goal or issue, relevant .zshrc snippet or error, plugin framework (if any)."
user-invocable: false
---

# Zsh Configuration Expert

## When To Use

- **Configuration**: Structuring `.zshrc` / `.zprofile` / `.zshenv` / `.zlogin` for correctness and fast startup.
- **Completion system**: Setting up `compinit`, writing custom completers, debugging completion behavior.
- **Zsh features**: Glob qualifiers, extended globbing, parameter expansion flags, associative arrays, zsh-specific builtins.
- **Prompt customization**: `PROMPT`/`RPROMPT` with escape sequences, `vcs_info`, `prompt_subst`.
- **Plugin management**: Configuring oh-my-zsh, zinit, antidote, or manual plugin loading.
- **Startup performance**: Profiling and optimizing slow shell startup (`zprof`, lazy loading, deferred init).
- **Zsh vs bash differences**: Translating bash idioms to zsh or explaining behavioral differences (array indexing, word splitting, globbing defaults).

Do NOT use for bash-only scripting that doesn't involve zsh, writing new scripts from scratch, non-shell configuration files, or agent/skill authoring.

## Inputs To Collect First

1. **Goal** — what the user wants to achieve or fix (completion setup, slow startup, prompt issue, etc.)
2. **Current config** — relevant snippet from `.zshrc` or related file, or "starting fresh"
3. **Plugin framework** — oh-my-zsh, zinit, antidote, manual, or none
4. **macOS or Linux** — affects default paths, system zsh version, and Homebrew integration

## Procedure

### Step 1 — Understand Zsh Startup File Order

Zsh loads files in this order — the correct file depends on what's being configured:

| File | When loaded | Use for |
|---|---|---|
| `.zshenv` | Always (every zsh invocation, including scripts) | Environment variables (`PATH`, `EDITOR`), no interactive config |
| `.zprofile` | Login shells only | One-time setup (Homebrew shellenv, SSH agent) |
| `.zshrc` | Interactive shells only | Aliases, functions, completions, prompt, plugins, key bindings |
| `.zlogin` | Login shells, after `.zshrc` | Rarely used; login messages |
| `.zlogout` | Login shell exit | Cleanup tasks |

**Common mistakes to check:**
- PATH modifications in `.zshrc` instead of `.zshenv` (not available in non-interactive scripts)
- `compinit` called in `.zshenv` (too early, loads for non-interactive shells)
- Homebrew `eval "$(brew shellenv)"` in `.zshrc` instead of `.zprofile` (runs on every shell, not just login)

### Step 2 — Diagnose or Implement

Based on the user's goal, follow the appropriate path:

**Completion system setup:**
```zsh
# Basic completion init (place in .zshrc)
autoload -Uz compinit
compinit

# Enable menu-driven completion
zstyle ':completion:*' menu select

# Case-insensitive completion
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

# Cache completions for speed
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompcache"
```

**Startup profiling:**
```zsh
# Add to top of .zshrc
zmodload zsh/zprof

# Add to bottom of .zshrc
zprof

# Then open a new shell and review the output
# Look for plugins/functions taking >50ms
```

**Key zsh-specific syntax reference:**

```zsh
# Glob qualifiers — filter by file attributes
ls *(.)          # regular files only
ls *(/)          # directories only
ls *(.om[1,5])   # 5 most recently modified files
ls **/*.md(D)    # include dotfiles in recursive glob

# Parameter expansion flags
echo ${(U)var}    # uppercase
echo ${(L)var}    # lowercase
echo ${(s:/:)PATH}  # split on /
echo ${#array}    # array length (1-indexed in zsh!)

# Array indexing (zsh arrays are 1-indexed!)
arr=(a b c)
echo $arr[1]      # "a" (not "b" like bash)
echo $arr[-1]     # "c" (negative indexing works)
```

### Step 3 — Apply Changes

When modifying zsh configuration files:
1. Read the existing file fully before making changes
2. Place configuration in the correct startup file (see Step 1 table)
3. Preserve existing content — add new config in the appropriate section
4. Add a brief comment explaining non-obvious settings
5. Group related settings together

### Step 4 — Validate

After making changes:

```zsh
# Syntax check
zsh -n ~/.zshrc

# Test in a subshell (won't affect current session)
zsh -i -c 'echo "Config loaded OK"'

# If completion was changed, verify
zsh -i -c 'which compinit && echo "compinit available"'

# If startup perf was the goal, measure
time zsh -i -c exit
```

Confirm:
- No syntax errors in any modified file
- Changes take effect in a new shell session
- No regressions in existing functionality
- If startup optimization was the goal, measure improvement

## Completion Checks

- [ ] Configuration placed in the correct startup file (`.zshenv` / `.zprofile` / `.zshrc`)
- [ ] Syntax check passes (`zsh -n`)
- [ ] Changes work in a fresh interactive shell
- [ ] No regressions to existing aliases, completions, or prompt
- [ ] Zsh-specific syntax used correctly (1-indexed arrays, zsh globs, parameter expansion)
- [ ] Startup time acceptable if performance was the goal

## References

- [Zsh Manual — Startup Files](https://zsh.sourceforge.io/Doc/Release/Files.html)
- [Zsh Manual — Completion System](https://zsh.sourceforge.io/Doc/Release/Completion-System.html)
- [Zsh Manual — Expansion](https://zsh.sourceforge.io/Doc/Release/Expansion.html)
