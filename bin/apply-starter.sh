#!/usr/bin/env bash
set -euo pipefail
STARTERS_DIR="${CLAUDE_STARTERS_DIR:-$HOME/claude-starters/starters}"

usage() { echo "usage: apply-starter <stack> [--framework <name>]" >&2; exit 2; }

stack="${1:-}"; [ -n "$stack" ] || usage; shift
framework="none"
while [ "$#" -gt 0 ]; do
  case "$1" in
    --framework) framework="${2:-}"; [ -n "$framework" ] || usage; shift 2 ;;
    *) usage ;;
  esac
done

template="$STARTERS_DIR/$stack/CLAUDE.md"
[ -f "$template" ] || { echo "error: unknown stack '$stack' (no $template)" >&2; exit 1; }

target="$PWD/CLAUDE.md"
sed "s|__FRAMEWORK__|$framework|g" "$template" > "$target"
mkdir -p "$PWD/.claude"
printf '%s\n' "$stack" > "$PWD/.claude/.starter-applied"
echo "Applied $stack starter (framework: $framework) to $PWD"
