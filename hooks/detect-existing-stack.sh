#!/usr/bin/env bash
# SessionStart hook (existing-repo detection): if the current git repo has a
# recognizable stack but no starter applied, suggest applying one — ONCE per
# repo. Debounce state lives OUTSIDE the repo (~/.claude/starter-suggested-repos)
# so declining leaves the repo completely untouched. Never writes into the repo,
# never touches CLAUDE.md — it only surfaces a suggestion for the agent to relay.
set -euo pipefail
trap 'exit 0' ERR   # fail-safe: never wedge the session
dir="$PWD"

# Opt-out via plugin userConfig. `case` (not `[ ] &&`) so a non-match cannot
# trip the ERR trap. Unset/empty means enabled, preserving default behaviour.
case "${CLAUDE_PLUGIN_OPTION_SUGGEST_ON_EXISTING_REPOS:-}" in false|0|off) exit 0 ;; esac

root="$(git -C "$dir" rev-parse --show-toplevel 2>/dev/null || true)"
[ -n "$root" ] || exit 0

# Already configured by a starter? Stay silent.
[ -f "$root/.claude/.starter-applied" ] && exit 0

# Global, out-of-repo debounce: already suggested for this repo path?
suggested="$HOME/.claude/starter-suggested-repos"
if [ -f "$suggested" ] && grep -qxF "$root" "$suggested" 2>/dev/null; then
  exit 0
fi

# Detect stack candidate(s) from marker files.
stacks=()
[ -f "$root/Cargo.toml" ] && stacks+=("rust")
[ -f "$root/go.mod" ] && stacks+=("go")
{ [ -f "$root/pyproject.toml" ] || [ -f "$root/setup.py" ] || [ -f "$root/requirements.txt" ]; } && stacks+=("python")
[ -f "$root/package.json" ] && stacks+=("web-ts")
[ -f "$root/CMakeLists.txt" ] && stacks+=("cpp")
[ "${#stacks[@]}" -gt 0 ] || exit 0

# Mark suggested (outside the repo) so we don't nag across sessions.
mkdir -p "$HOME/.claude"
printf '%s\n' "$root" >> "$suggested"

list="$(printf '%s ' "${stacks[@]}")"
addnote=""
[ -f "$root/CLAUDE.md" ] && addnote=" This repo already has a CLAUDE.md — use --add to APPEND the rules without overwriting it."
ctx="claude-starters: detected an existing project (stack candidate(s): ${list%% }) with no starter applied. Ask the user whether to apply the right starter via /apply-starter <stack> [--framework <name>].${addnote} If they decline, do nothing and leave the repo untouched. Never overwrite an existing CLAUDE.md."
esc=${ctx//\\/\\\\}
esc=${esc//\"/\\\"}
printf '{"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":"%s"}}\n' "$esc"
