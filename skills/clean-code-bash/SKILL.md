---
name: clean-code-bash
description: Use when writing or reviewing shell scripts — deeper idioms (strict mode, quoting, traps, arrays, safe substitution, exit codes) beyond a shellcheck pass.
---

# Clean-code Bash (depth)

On top of the base rules (`set -euo pipefail`, shellcheck clean, bats tests).

## Safety
- `set -euo pipefail` always; understand where `-e` doesn't fire (in `if`, `||`, command substitution) and check explicitly there.
- Quote every expansion; `"${arr[@]}"` for arrays. `[[ ]]` for tests; `(( ))` for arithmetic.
- `trap 'rm -rf "$tmp"' EXIT` for cleanup; create temps with `mktemp -d`.

## Robustness
- `local` all function vars. Prefer functions + a `main "$@"` entrypoint.
- Read lines with `while IFS= read -r line` or `mapfile`; never parse `ls`.
- Parameter expansion for defaults/checks: `"${VAR:?message}"`, `"${VAR:-default}"`.
- `printf '%s\n'` over `echo` for arbitrary data. Meaningful exit codes; errors to stderr (`>&2`).

## Smells
- Unquoted `$var` in a path/test → word-splitting/glob bug.
- Parsing `ls`/`find` output by whitespace → use globs or `-print0`/`read -d ''`.
- A temp file with no `trap` cleanup → litter on failure.
