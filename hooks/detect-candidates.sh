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

has_stack() { printf '%s\n' "$stacks" | grep -qxF "$1"; }                     # exact line match
is_audio()  { printf '%s\n' "$stacks" | grep -qxE 'audio-plugin|audio-app|audio-external|web-audio'; }
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

WB='[^[:alnum:]_]'   # portable word boundary (POSIX ERE has no \b)
cands=()
if has_stack rust && added_has "(^|$WB)unsafe($WB|\$)"; then
  cands+=("unsafe-auditor")
fi
if is_audio \
   && added_has "(^|$WB)new($WB|\$)|malloc|std::mutex|juce::String|(^|$WB)DBG($WB|\$)|std::cout" \
   && changed_file_has 'processBlock|::process|perform'; then
  cands+=("rt-safety-auditor")
fi
if { has_stack web-ts || has_stack node-api || has_stack electron || has_stack tauri; } \
   && added_has "(: any($WB|\$)|as any($WB|\$)|@ts-ignore)"; then
  cands+=("any-eliminator")
fi

if [ "${#cands[@]}" -gt 0 ]; then
  printf '%s\n' "${cands[@]}" | sort -u
fi
