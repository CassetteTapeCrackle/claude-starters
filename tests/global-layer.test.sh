#!/usr/bin/env bash
set -euo pipefail
DIR="$(cd "$(dirname "$0")/.." && pwd)"
source "$DIR/tests/lib.sh"

test_appends_block_idempotently() {
  local home; home="$(mktemp -d)"; mkdir -p "$home/.claude"; printf '# existing\n' > "$home/.claude/CLAUDE.md"
  HOME="$home" bash "$DIR/install.sh" >/dev/null
  HOME="$home" bash "$DIR/install.sh" >/dev/null
  local n; n="$(grep -c 'claude-starters:begin' "$home/.claude/CLAUDE.md")"
  assert_eq "1" "$n" "block appended exactly once"
  assert_contains "$(cat "$home/.claude/CLAUDE.md")" "# existing" "original content preserved"
  rm -rf "$home"
}

run_tests
