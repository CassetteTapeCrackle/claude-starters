#!/usr/bin/env bash
set -euo pipefail
DIR="$(cd "$(dirname "$0")/.." && pwd)"
source "$DIR/tests/lib.sh"
export CLAUDE_STARTERS_DIR="$DIR/starters"

test_renders_framework_and_marker() {
  local tmp; tmp="$(mktemp -d)"; ( cd "$tmp"
    "$DIR/bin/apply-starter.sh" python --framework fastapi >/dev/null )
  local out; out="$(cat "$tmp/CLAUDE.md")"
  assert_contains "$out" "Framework: fastapi — locked" "framework substituted"
  case "$out" in *"__FRAMEWORK__"*) echo "FAIL: token left unsubstituted"; _TESTS_FAILED=1;; esac
  assert_eq "python" "$(cat "$tmp/.claude/.starter-applied")" "marker holds stack"
  rm -rf "$tmp"
}

test_defaults_framework_to_none() {
  local tmp; tmp="$(mktemp -d)"; ( cd "$tmp"
    "$DIR/bin/apply-starter.sh" python >/dev/null )
  assert_contains "$(cat "$tmp/CLAUDE.md")" "Framework: none — locked" "defaults to none"
  rm -rf "$tmp"
}

run_tests
