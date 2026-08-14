#!/usr/bin/env bash
set -euo pipefail
DIR="$(cd "$(dirname "$0")/.." && pwd)"
source "$DIR/tests/lib.sh"
export CLAUDE_STARTERS_DIR="$DIR/starters"

test_does_not_clobber_existing_claudemd() {
  local tmp; tmp="$(mktemp -d)"; ( cd "$tmp"; printf 'KEEP ME\n' > CLAUDE.md )
  assert_fail bash -c "cd '$tmp' && '$DIR/bin/apply-starter.sh' python"
  assert_eq "KEEP ME" "$(cat "$tmp/CLAUDE.md")" "existing CLAUDE.md untouched"
  rm -rf "$tmp"
}

test_updates_git_exclude_once() {
  local tmp; tmp="$(mktemp -d)"; ( cd "$tmp"; git init -q
    "$DIR/bin/apply-starter.sh" python --framework flask >/dev/null
    "$DIR/bin/apply-starter.sh" python --framework flask >/dev/null 2>&1 || true )
  local n; n="$(grep -c '^/CLAUDE.md$' "$tmp/.git/info/exclude")"
  assert_eq "1" "$n" "exclude line added exactly once"
  rm -rf "$tmp"
}

test_unknown_stack_fails() {
  local tmp; tmp="$(mktemp -d)"
  assert_fail bash -c "cd '$tmp' && '$DIR/bin/apply-starter.sh' cobol"
  rm -rf "$tmp"
}

run_tests
