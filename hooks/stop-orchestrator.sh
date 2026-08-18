#!/usr/bin/env bash
# Stop hook (light-Stop): on turn end, in a starter-applied project, surface
# any reactive agent candidate ONCE per unique diff (debounced). If a candidate
# exists, block the stop and hand the orchestrator the candidate list so it can
# apply the agent-orchestration policy (skip / inline / delegate). Free unless a
# risk pattern actually changed.
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
dir="$PWD"

# Only act inside a starter-applied project.
[ -f "$dir/.claude/.starter-applied" ] || exit 0

# Debounce by the content hash of the current diff — surface once per change.
hash="$(git -C "$dir" diff HEAD 2>/dev/null | shasum 2>/dev/null | awk '{print $1}')"
seen="$dir/.claude/.orchestrator-seen"
if [ -n "$hash" ] && [ -f "$seen" ] && [ "$(cat "$seen" 2>/dev/null || true)" = "$hash" ]; then
  exit 0
fi
[ -n "$hash" ] && printf '%s' "$hash" > "$seen"

cands="$(bash "$SCRIPT_DIR/detect-candidates.sh" "$dir" || true)"
[ -n "$cands" ] || exit 0

list="$(printf '%s' "$cands" | tr '\n' ' ')"
reason="Orchestration: changed code surfaced candidate agent(s): ${list}. Apply the agent-orchestration skill to decide skip / inline / delegate for each — bias to skip or inline unless an isolated context clearly pays. Do not re-run for this same diff."
printf '{"decision":"block","reason":%s}\n' \
  "$(printf '%s' "$reason" | python3 -c 'import json,sys; print(json.dumps(sys.stdin.read()))')"
