#!/usr/bin/env bash
set -euo pipefail
STARTERS_DIR="${CLAUDE_STARTERS_DIR:-$HOME/claude-starters/starters}"

usage() { echo "usage: apply-starter <stack> [--framework <name>] [--path <subdir>]" >&2; exit 2; }

stack="${1:-}"; [ -n "$stack" ] || usage; shift
framework="none"
subpath="."
while [ "$#" -gt 0 ]; do
  case "$1" in
    --framework) framework="${2:-}"; [ -n "$framework" ] || usage; shift 2 ;;
    --path)      subpath="${2:-}";   [ -n "$subpath" ]   || usage; shift 2 ;;
    *) usage ;;
  esac
done

template="$STARTERS_DIR/$stack/CLAUDE.md"
[ -f "$template" ] || { echo "error: unknown stack '$stack' (no $template)" >&2; exit 1; }

target_dir="$PWD/$subpath"
mkdir -p "$target_dir"
target="$target_dir/CLAUDE.md"
if [ -e "$target" ]; then
  echo "error: CLAUDE.md already exists at $target; not clobbering. Merge manually." >&2
  exit 3
fi
sed "s|__FRAMEWORK__|$framework|g" "$template" > "$target"
mkdir -p "$target_dir/.claude"
printf '%s\n' "$stack" > "$target_dir/.claude/.starter-applied"

# Hide the generated CLAUDE.md via .git/info/exclude (repo-root-relative), if in a git repo.
if git -C "$target_dir" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  gitdir="$(git -C "$target_dir" rev-parse --absolute-git-dir)"
  prefix="$(git -C "$target_dir" rev-parse --show-prefix)"   # "" at root, "backend/" in a subdir
  exclude="$gitdir/info/exclude"; mkdir -p "$(dirname "$exclude")"
  line="/${prefix}CLAUDE.md"
  grep -qxF "$line" "$exclude" 2>/dev/null || printf '%s\n' "$line" >> "$exclude"
fi
echo "Applied $stack starter (framework: $framework) to $target_dir"
