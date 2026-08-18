#!/usr/bin/env bash
# Reactive channel (free, deterministic): scan the working-tree diff for
# high-risk patterns tied to the applied stack(s) and print candidate agent
# names (one per line). No LLM. Exit silent if nothing to surface.
set -euo pipefail
trap 'exit 0' ERR   # fail-safe: never wedge the session
dir="${1:-$PWD}"

marker="$dir/.claude/.starter-applied"
[ -f "$marker" ] || exit 0
stacks="$(cat "$marker" 2>/dev/null || true)"

diff_all="$(git -C "$dir" diff HEAD 2>/dev/null || true)"
[ -n "$diff_all" ] || exit 0
added="$(printf '%s\n' "$diff_all" | grep '^+' | grep -v '^+++' || true)"
[ -n "$added" ] || exit 0
changed_files="$(git -C "$dir" diff --name-only HEAD 2>/dev/null || true)"

has_stack() { case "$stacks" in *"$1"*) return 0 ;; *) return 1 ;; esac; }
added_has() { printf '%s\n' "$added" | grep -qE "$1"; }

# Does any changed file contain an audio callback? (grep the file, not the diff.)
changed_file_has() {
  local pat="$1" f
  while IFS= read -r f; do
    [ -n "$f" ] || continue
    [ -f "$dir/$f" ] || continue
    grep -qE "$pat" "$dir/$f" && return 0
  done <<EOF
$changed_files
EOF
  return 1
}

cands=()
if has_stack rust && added_has '\bunsafe\b'; then
  cands+=("unsafe-auditor")
fi
if has_stack audio \
   && added_has '(\bnew\b|malloc|std::mutex|juce::String|\bDBG\b|std::cout)' \
   && changed_file_has '(processBlock|::process|perform)'; then
  cands+=("rt-safety-auditor")
fi
if { has_stack web-ts || has_stack node-api || has_stack electron || has_stack tauri; } \
   && added_has '(: any\b|as any\b|@ts-ignore)'; then
  cands+=("any-eliminator")
fi

if [ "${#cands[@]}" -gt 0 ]; then
  printf '%s\n' "${cands[@]}" | sort -u
fi
