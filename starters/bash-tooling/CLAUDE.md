# Bash tooling project rules

Framework: __FRAMEWORK__ — locked. Do not introduce alternative frameworks without explicit approval.

## Shell discipline
- `#!/usr/bin/env bash` and `set -euo pipefail` at the top of every executable script.
- Quote every expansion: `"$var"`, `"${arr[@]}"`. Prefer `[[ ]]` over `[ ]`.
- `shellcheck` clean — fix, don't disable (a targeted `# shellcheck disable=` needs a reason).
- Small functions; `local` for function vars; `trap 'cleanup' EXIT` for temp files.
- Prefer `printf` over `echo` for anything non-trivial. No parsing `ls`.

## Tests
- `bats` (or a plain-bash assert harness) against temp dirs. Cover each behavior; regression test per bug.

## Depth
- When writing or reviewing shell scripts, use the `clean-code-bash` skill. Name it explicitly.

## Commands
- Lint: shellcheck **/*.sh   ·   Test: bats tests/   ·   Format: shfmt -w .
