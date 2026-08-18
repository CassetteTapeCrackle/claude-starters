#!/usr/bin/env bash
set -euo pipefail
DIR="$(cd "$(dirname "$0")/.." && pwd)"
source "$DIR/tests/lib.sh"
export CLAUDE_STARTERS_DIR="$DIR/starters"   # AGENT_LIB derives to $DIR/agent-library

test_activates_common_and_stack_agents() {
  local tmp; tmp="$(mktemp -d)"; ( cd "$tmp"; git init -q
    "$DIR/bin/apply-starter.sh" audio-plugin --framework juce >/dev/null )
  assert_file_exists "$tmp/.claude/agents/starter-conformance-checker.md" "common agent activated"
  assert_file_exists "$tmp/.claude/agents/rt-safety-auditor.md" "audio-plugin agent activated"
  assert_eq "1" "$(grep -c '^/.claude/agents/$' "$tmp/.git/info/exclude")" "agents dir excluded"
  assert_eq "1" "$(grep -c '^/.claude/.starter-state$' "$tmp/.git/info/exclude")" "state file excluded"
  rm -rf "$tmp"
}

test_add_composes_two_stacks() {
  local tmp; tmp="$(mktemp -d)"; ( cd "$tmp"; git init -q
    "$DIR/bin/apply-starter.sh" python --framework none >/dev/null
    "$DIR/bin/apply-starter.sh" rust --framework cli --add >/dev/null )
  local c; c="$(cat "$tmp/CLAUDE.md")"
  assert_contains "$c" "Python project rules" "base stack present"
  assert_contains "$c" "Starter rules: rust" "appended stack header"
  assert_contains "$c" "cargo clippy" "added stack rules present"
  assert_eq "$(printf 'python\nrust')" "$(cat "$tmp/.claude/.starter-applied")" "marker lists both stacks"
  rm -rf "$tmp"
}

test_add_preserves_arbitrary_existing_claudemd() {
  local tmp; tmp="$(mktemp -d)"; ( cd "$tmp"; git init -q
    printf '# My Project\n\nHand-written rules the user cares about.\n' > CLAUDE.md
    "$DIR/bin/apply-starter.sh" rust --framework cli --add >/dev/null )
  local c; c="$(cat "$tmp/CLAUDE.md")"
  assert_contains "$c" "# My Project" "original title preserved"
  assert_contains "$c" "Hand-written rules the user cares about." "original body preserved verbatim"
  assert_contains "$c" "Starter rules: rust" "starter rules appended below"
  rm -rf "$tmp"
}

test_add_is_idempotent() {
  local tmp; tmp="$(mktemp -d)"; ( cd "$tmp"; git init -q
    "$DIR/bin/apply-starter.sh" python --framework none >/dev/null
    "$DIR/bin/apply-starter.sh" rust --framework cli --add >/dev/null
    "$DIR/bin/apply-starter.sh" rust --framework cli --add >/dev/null 2>&1 || true )
  assert_eq "1" "$(grep -c '## Starter rules: rust (appended' "$tmp/CLAUDE.md")" "--add appends rust block exactly once"
  rm -rf "$tmp"
}

run_tests
