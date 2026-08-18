#!/usr/bin/env bash
set -euo pipefail
SELF="$(cd "$(dirname "$0")" && pwd)"; ROOT="$(dirname "$SELF")"   # bin/ -> plugin root
STARTERS_DIR="${CLAUDE_STARTERS_DIR:-$ROOT/starters}"
AGENT_LIB="${CLAUDE_AGENT_LIB:-$ROOT/agent-library}"
RULES_BEGIN="<!-- claude-starters:rules begin -->"
RULES_END="<!-- claude-starters:rules end -->"

usage() {
  cat >&2 <<'EOF'
usage:
  apply-starter <stack> [--framework <name>] [--path <subdir>]
                        [--add | --update | --force] [--no-agents]
                        [--dry-run] [--print]
  apply-starter --list [<stack>]
  apply-starter --version | --help
EOF
}

version() {
  local pj="$ROOT/.claude-plugin/plugin.json" v=""
  if [ -f "$pj" ]; then
    v="$(grep -oE '"version"[[:space:]]*:[[:space:]]*"[^"]+"' "$pj" | head -1 | sed -E 's/.*"([^"]+)"$/\1/')"
  fi
  printf 'claude-starters %s\n' "${v:-unknown}"
}

list_stacks() {
  if [ -n "${1:-}" ]; then
    local m="$STARTERS_DIR/$1/manifest.json"
    if [ ! -f "$m" ]; then echo "error: unknown stack '$1'" >&2; exit 1; fi
    printf '%s:\n' "$1"; cat "$m"
  else
    local d
    for d in "$STARTERS_DIR"/*/; do
      if [ -d "$d" ]; then basename "$d"; fi
    done | sort
  fi
}

# ---- standalone modes ----
case "${1:-}" in
  --list)    shift; list_stacks "${1:-}"; exit 0 ;;
  --version) version; exit 0 ;;
  --help|-h) usage; exit 0 ;;
  "")        usage; exit 2 ;;
esac

stack=""; framework=""; subpath="."; add=0; update=0; noagents=0; force=0; dry=0; printonly=0
case "$1" in --*) : ;; *) stack="$1"; shift ;; esac
while [ "$#" -gt 0 ]; do
  case "$1" in
    --framework) framework="${2:-}"; if [ -z "$framework" ]; then usage; exit 2; fi; shift 2 ;;
    --path)      subpath="${2:-}";   if [ -z "$subpath" ];   then usage; exit 2; fi; shift 2 ;;
    --add)       add=1; shift ;;
    --update)    update=1; shift ;;
    --force)     force=1; shift ;;
    --no-agents) noagents=1; shift ;;
    --dry-run)   dry=1; shift ;;
    --print)     printonly=1; shift ;;
    *) usage; exit 2 ;;
  esac
done

target_dir="$PWD/$subpath"
state="$target_dir/.claude/.starter-state"

# --update infers stack/framework from stored state when omitted.
if [ "$update" -eq 1 ] && [ -z "$stack" ] && [ -f "$state" ]; then
  stack="$(awk -F'\t' 'NR==1{print $1}' "$state")"
  if [ -z "$framework" ]; then framework="$(awk -F'\t' 'NR==1{print $2}' "$state")"; fi
fi
if [ -z "$stack" ]; then echo "error: no stack specified" >&2; usage; exit 2; fi
if [ -z "$framework" ]; then framework="none"; fi

template="$STARTERS_DIR/$stack/CLAUDE.md"
if [ ! -f "$template" ]; then echo "error: unknown stack '$stack' (no $template)" >&2; exit 1; fi

render() { sed "s|__FRAMEWORK__|$framework|g" "$template"; }

# --print: render to stdout, no writes.
if [ "$printonly" -eq 1 ]; then render; exit 0; fi

collect_agents() {
  { if [ -f "$AGENT_LIB/common.txt" ]; then cat "$AGENT_LIB/common.txt"; fi
    if [ -f "$STARTERS_DIR/$stack/agents.txt" ]; then cat "$STARTERS_DIR/$stack/agents.txt"; fi
  } 2>/dev/null | sed 's/[[:space:]]*$//' | sed '/^$/d; /^#/d' | sort -u
}

target="$target_dir/CLAUDE.md"
rel="$subpath"
if [ "$rel" = "." ]; then rel=""; else rel="${rel#./}"; rel="${rel%/}/"; fi

# --dry-run: report and stop.
if [ "$dry" -eq 1 ]; then
  echo "[dry-run] stack=$stack framework=$framework path=$subpath (add=$add update=$update force=$force)"
  echo "[dry-run] target CLAUDE.md: $target"
  if [ "$noagents" -eq 0 ]; then
    echo "[dry-run] agents to activate:"; collect_agents | sed 's/^/  - /'
  else
    echo "[dry-run] agents: (skipped, --no-agents)"
  fi
  echo "[dry-run] git-exclude: /${rel}CLAUDE.md and /${rel}.claude/agents/"
  exit 0
fi

activate_agents() {
  if [ "$noagents" -eq 1 ]; then return 0; fi
  local a src
  while IFS= read -r a; do
    if [ -z "$a" ]; then continue; fi
    src="$AGENT_LIB/$a.md"
    if [ -f "$src" ]; then
      mkdir -p "$target_dir/.claude/agents"; cp "$src" "$target_dir/.claude/agents/$a.md"
    else
      echo "warn: agent '$a' not in library" >&2
    fi
  done < <(collect_agents)
}

write_fresh() {
  mkdir -p "$target_dir/.claude"
  { printf '%s\n' "$RULES_BEGIN"; render; printf '%s\n' "$RULES_END"; } > "$target"
  printf '%s\t%s\n' "$stack" "$framework" > "$state"
  printf '%s\n' "$stack" > "$target_dir/.claude/.starter-applied"
}

if [ "$update" -eq 1 ]; then
  if [ ! -f "$target" ]; then echo "error: nothing to update (no $target)" >&2; exit 3; fi
  if ! grep -qF "$RULES_BEGIN" "$target"; then
    echo "error: $target has no claude-starters managed block; refusing to touch a hand-written CLAUDE.md." >&2
    exit 3
  fi
  rules_tmp="$(mktemp)"; render > "$rules_tmp"
  out_tmp="$(mktemp)"
  awk -v b="$RULES_BEGIN" -v e="$RULES_END" -v rf="$rules_tmp" '
    $0==b { print; while ((getline l < rf) > 0) print l; close(rf); skip=1; next }
    $0==e { skip=0; print; next }
    skip==1 { next }
    { print }
  ' "$target" > "$out_tmp"
  mv "$out_tmp" "$target"; rm -f "$rules_tmp"
  printf '%s\t%s\n' "$stack" "$framework" > "$state"
elif [ -e "$target" ]; then
  if [ "$add" -eq 1 ]; then
    { printf '\n\n---\n\n## Starter rules: %s (appended by claude-starters)\n' "$stack"; render | tail -n +2; } >> "$target"
    mkdir -p "$target_dir/.claude"
    printf '%s\n' "$stack" >> "$target_dir/.claude/.starter-applied"
  elif [ "$force" -eq 1 ]; then
    cp "$target" "$target.bak"
    write_fresh
  else
    echo "error: CLAUDE.md already exists at $target; not clobbering. Use --add (append), --update (refresh managed block), or --force (overwrite; backs up to CLAUDE.md.bak)." >&2
    exit 3
  fi
else
  write_fresh
fi

activate_agents

# Hide generated files via .git/info/exclude (repo-root-relative), if in a git repo.
if git -C "$target_dir" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  gitdir="$(git -C "$target_dir" rev-parse --absolute-git-dir)"
  prefix="$(git -C "$target_dir" rev-parse --show-prefix)"
  exclude="$gitdir/info/exclude"; mkdir -p "$(dirname "$exclude")"
  for line in "/${prefix}CLAUDE.md" "/${prefix}.claude/agents/"; do
    grep -qxF "$line" "$exclude" 2>/dev/null || printf '%s\n' "$line" >> "$exclude"
  done
fi
echo "Applied $stack starter (framework: $framework) to $target_dir"
