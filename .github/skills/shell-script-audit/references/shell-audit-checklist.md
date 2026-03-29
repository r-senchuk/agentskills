# Shell Audit Checklist — Quick Reference

Use this as a rapid pass/fail checklist when auditing shell scripts. Each item maps to a category in the main procedure.

## Error Handling

| Check | bash/zsh | sh (POSIX) |
|---|---|---|
| `set -e` present | Required | Required |
| `set -u` present | Required | Required |
| `set -o pipefail` present | Required (bash/zsh) | N/A (not POSIX) |
| `trap cleanup EXIT` for temp files | Required if script creates temp files | Same |
| Non-zero exit on failure paths | Required | Required |

## Quoting Rules

| Context | Correct | Wrong |
|---|---|---|
| Variable in argument | `"$var"` | `$var` |
| Variable in `[[ ]]` | `[[ -f "$file" ]]` | `[[ -f $file ]]` (works but inconsistent) |
| Command substitution | `"$(cmd)"` | `$(cmd)` |
| Array expansion | `"${arr[@]}"` | `${arr[@]}` |
| Glob in assignment | `files=(*.txt)` | OK — no splitting in assignment |
| `$@` in function | `"$@"` | `$@` |

## Portability Matrix

| Feature | bash | zsh | sh (POSIX) |
|---|---|---|---|
| `[[ ]]` | ✅ | ✅ | ❌ use `[ ]` |
| `set -o pipefail` | ✅ | ✅ | ❌ |
| `local` keyword | ✅ | ✅ | ⚠️ common but not POSIX |
| `${var:h}` (dirname) | ❌ | ✅ | ❌ |
| `${0:A}` (realpath) | ❌ | ✅ | ❌ |
| `setopt` | ❌ | ✅ | ❌ |
| Arrays `arr=(...)` | ✅ | ✅ | ❌ |
| `read -r -a` (array) | ✅ `-a` | ✅ `-A` | ❌ |
| `sed -i ''` (in-place) | macOS BSD only | macOS BSD only | macOS BSD only |
| `sed -i` (no backup arg) | GNU only | GNU only | GNU only |

## Security Quick Checks

- [ ] No `eval "$user_input"` or `eval "$(cat file)"`
- [ ] No `` `command` `` with user-controlled strings
- [ ] Temp files via `mktemp`, not `/tmp/myapp.$$`
- [ ] No `curl ... | bash` patterns in production
- [ ] Credentials never in `echo`, `printf`, or log output
- [ ] `PATH` set explicitly or validated before security-critical commands

## ShellCheck Severity Map

| SC Code Range | Category |
|---|---|
| SC1000–SC1999 | Syntax/parsing errors |
| SC2000–SC2999 | Common bugs and pitfalls |
| SC3000–SC3999 | Portability warnings |
| SC4000–SC4999 | Style and best practice |

## Common Dangerous Patterns

```bash
# DANGEROUS: unquoted variable in rm
rm -rf $BUILD_DIR           # Could rm -rf / if BUILD_DIR is empty

# SAFE:
rm -rf "${BUILD_DIR:?BUILD_DIR not set}"

# DANGEROUS: unchecked cd
cd $dir && make             # If cd fails with set -e off, make runs in wrong dir

# SAFE:
cd "$dir" || { echo "Failed to cd to $dir" >&2; exit 1; }

# DANGEROUS: word splitting in for loop
for f in $(ls *.txt); do    # Breaks on spaces in filenames

# SAFE:
for f in *.txt; do
  [[ -e "$f" ]] || continue # Handle no-match case
```
