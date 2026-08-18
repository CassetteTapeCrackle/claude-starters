#!/usr/bin/env bash
# Stop hook (light-Stop): on turn end, in a starter-applied project, surface any
# reactive agent candidate ONCE per unique diff (debounced), then block the stop
# so the orchestrator applies the agent-orchestration policy. Free unless a risk
# pattern actually changed. No dependencies beyond git + bash.
set -euo pipefail
trap 'exit 0' ERR   # fail-safe: a hook must never wedge the session
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
dir="$PWD"

# Only act inside a starter-applied project.
[ -f "$dir/.claude/.starter-applied" ] || exit 0

# Debounce by the content hash of the current diff (git-native, portable).
hash="$(git -C "$dir" diff HEAD 2>/dev/null | git hash-object --stdin 2>/dev/null || true)"
seen="$dir/.claude/.orchestrator-seen"
if [ -n "$hash" ] && [ -f "$seen" ] && [ "$(cat "$seen" 2>/dev/null || true)" = "$hash" ]; then
  exit 0
fi
[ -n "$hash" ] && printf '%s' "$hash" > "$seen"

cands="$(bash "$SCRIPT_DIR/detect-candidates.sh" "$dir" || true)"
[ -n "$cands" ] || exit 0

list="$(printf '%s' "$cands" | tr '\n' ' ')"
reason="Orchestration: changed code surfaced candidate agent(s): ${list}. Apply the agent-orchestration skill to decide skip / inline / delegate for each — bias to skip or inline unless an isolated context clearly pays. Do not re-run for this same diff."
# JSON-escape without python (reason is single-line): backslash then doublequote.
esc=${reason//\\/\\\\}
esc=${esc//\"/\\\"}
printf '{"decision":"block","reason":"%s"}\n' "$esc"
