#!/usr/bin/env bash
# Stop hook (light-Stop): on turn end, in a starter-applied project, surface any
# NEW reactive agent candidate — once per candidate type, not once per diff — via
# the documented Stop mechanism (exit code 2 + stderr, which continues the turn
# and feeds the message back). Debounced by candidate SET (not diff hash), so
# iterating on the same risk never re-nags and can't loop. Free unless a new risk
# pattern appears. No dependencies beyond git + bash.
set -euo pipefail
trap 'exit 0' ERR   # fail-safe: a hook must never wedge the session
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
dir="$PWD"

[ -f "$dir/.claude/.starter-applied" ] || exit 0

cands="$(bash "$SCRIPT_DIR/detect-candidates.sh" "$dir" 2>/dev/null || true)"
[ -n "$cands" ] || exit 0

seen="$dir/.claude/.orchestrator-seen"
prev=""
[ -f "$seen" ] && prev="$(cat "$seen" 2>/dev/null || true)"

# Only candidate agents not already surfaced for this repo.
new="$(comm -23 \
        <(printf '%s\n' "$cands" | sed '/^$/d' | sort -u) \
        <(printf '%s\n' "$prev"  | sed '/^$/d' | sort -u) || true)"
[ -n "$new" ] || exit 0

# Record the union BEFORE blocking, so the next turn stays silent (no loop).
{ printf '%s\n' "$prev"; printf '%s\n' "$cands"; } | sed '/^$/d' | sort -u > "$seen"

list="$(printf '%s' "$new" | tr '\n' ' ')"
printf 'Orchestration: changed code surfaced new candidate agent(s): %s. Apply the agent-orchestration skill to decide skip / inline / delegate for each — bias to skip or inline unless an isolated context clearly pays.\n' "$list" >&2
exit 2
