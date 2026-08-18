#!/usr/bin/env bash
set -euo pipefail
STARTERS_DIR="${CLAUDE_STARTERS_DIR:-$HOME/claude-starters/starters}"
AGENT_LIB="${CLAUDE_AGENT_LIB:-$(dirname "$STARTERS_DIR")/agent-library}"

usage() { echo "usage: apply-starter <stack> [--framework <name>] [--path <subdir>] [--add]" >&2; exit 2; }

stack="${1:-}"; [ -n "$stack" ] || usage; shift
framework="none"
subpath="."
add=0
while [ "$#" -gt 0 ]; do
  case "$1" in
    --framework) framework="${2:-}"; [ -n "$framework" ] || usage; shift 2 ;;
    --path)      subpath="${2:-}";   [ -n "$subpath" ]   || usage; shift 2 ;;
    --add)       add=1; shift ;;
    *) usage ;;
  esac
done

template="$STARTERS_DIR/$stack/CLAUDE.md"
[ -f "$template" ] || { echo "error: unknown stack '$stack' (no $template)" >&2; exit 1; }

target_dir="$PWD/$subpath"
mkdir -p "$target_dir"
target="$target_dir/CLAUDE.md"

if [ -e "$target" ] && [ "$add" -eq 0 ]; then
  echo "error: CLAUDE.md already exists at $target; not clobbering. Use --add to layer a second stack, or merge manually." >&2
  exit 3
fi

if [ -e "$target" ] && [ "$add" -eq 1 ]; then
  { printf '\n\n---\n\n# Additional stack: %s\n' "$stack"; sed "s|__FRAMEWORK__|$framework|g" "$template" | tail -n +2; } >> "$target"
  printf '%s\n' "$stack" >> "$target_dir/.claude/.starter-applied"
else
  sed "s|__FRAMEWORK__|$framework|g" "$template" > "$target"
  mkdir -p "$target_dir/.claude"
  printf '%s\n' "$stack" > "$target_dir/.claude/.starter-applied"
fi

# Activate scoped agents (common + per-stack) into the project's .claude/agents/
activate_agent() {
  local name="$1" src="$AGENT_LIB/$1.md"
  [ -n "$name" ] || return 0
  case "$name" in \#*) return 0 ;; esac
  if [ -f "$src" ]; then
    mkdir -p "$target_dir/.claude/agents"
    cp "$src" "$target_dir/.claude/agents/$name.md"
  else
    echo "warn: agent '$name' not in library ($src)" >&2
  fi
}
if [ -f "$AGENT_LIB/common.txt" ]; then
  while IFS= read -r a || [ -n "$a" ]; do activate_agent "$a"; done < "$AGENT_LIB/common.txt"
fi
if [ -f "$STARTERS_DIR/$stack/agents.txt" ]; then
  while IFS= read -r a || [ -n "$a" ]; do activate_agent "$a"; done < "$STARTERS_DIR/$stack/agents.txt"
fi

# Hide generated files via .git/info/exclude (repo-root-relative), if in a git repo.
if git -C "$target_dir" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  gitdir="$(git -C "$target_dir" rev-parse --absolute-git-dir)"
  prefix="$(git -C "$target_dir" rev-parse --show-prefix)"   # "" at root, "backend/" in a subdir
  exclude="$gitdir/info/exclude"; mkdir -p "$(dirname "$exclude")"
  for line in "/${prefix}CLAUDE.md" "/${prefix}.claude/agents/"; do
    grep -qxF "$line" "$exclude" 2>/dev/null || printf '%s\n' "$line" >> "$exclude"
  done
fi
echo "Applied $stack starter (framework: $framework) to $target_dir"
