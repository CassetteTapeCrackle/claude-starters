#!/usr/bin/env bash
set -euo pipefail
DIR="$(cd "$(dirname "$0")/.." && pwd)"
source "$DIR/tests/lib.sh"
export CLAUDE_STARTERS_DIR="$DIR/starters"
AS="$DIR/bin/apply-starter.sh"

test_list_all_and_one() {
  local out; out="$(bash "$AS" --list)"
  assert_contains "$out" "rust" "list includes rust"
  assert_contains "$out" "audio-plugin" "list includes audio-plugin"
  assert_contains "$(bash "$AS" --list rust)" "clean-code-rust" "list <stack> shows its manifest"
}

test_version() {
  assert_contains "$(bash "$AS" --version)" "claude-starters" "version prints name"
}

test_print_renders_without_writing() {
  local tmp; tmp="$(mktemp -d)"
  local out; out="$( cd "$tmp" && bash "$AS" python --framework fastapi --print )"
  assert_contains "$out" "Framework: fastapi" "print renders framework"
  if [ -e "$tmp/CLAUDE.md" ]; then echo "FAIL: print wrote a file"; _TESTS_FAILED=1; fi
  rm -rf "$tmp"
}

test_dry_run_writes_nothing() {
  local tmp; tmp="$(mktemp -d)"
  local out; out="$( cd "$tmp" && git init -q && bash "$AS" rust --framework cli --dry-run )"
  assert_contains "$out" "[dry-run]" "dry-run marked"
  assert_contains "$out" "unsafe-auditor" "dry-run lists a scoped agent"
  if [ -e "$tmp/CLAUDE.md" ]; then echo "FAIL: dry-run wrote CLAUDE.md"; _TESTS_FAILED=1; fi
  if [ -e "$tmp/.claude" ]; then echo "FAIL: dry-run wrote .claude"; _TESTS_FAILED=1; fi
  rm -rf "$tmp"
}

test_no_agents_skips_activation() {
  local tmp; tmp="$(mktemp -d)"
  ( cd "$tmp" && git init -q && bash "$AS" python --framework none --no-agents >/dev/null )
  assert_file_exists "$tmp/CLAUDE.md" "rules written"
  if [ -d "$tmp/.claude/agents" ]; then echo "FAIL: agents activated despite --no-agents"; _TESTS_FAILED=1; fi
  rm -rf "$tmp"
}

test_update_refreshes_block_preserving_user_edits() {
  local tmp st; tmp="$(mktemp -d)"; st="$(mktemp -d)"
  ( cd "$tmp" && git init -q && bash "$AS" python --framework fastapi >/dev/null
    printf '\n## My own notes\nKeep me.\n' >> CLAUDE.md )
  cp -R "$DIR/starters/python" "$st/python"
  printf '\nNEW-RULE-XYZ\n' >> "$st/python/CLAUDE.md"
  ( cd "$tmp" && CLAUDE_STARTERS_DIR="$st" bash "$AS" --update >/dev/null )
  local c; c="$(cat "$tmp/CLAUDE.md")"
  assert_contains "$c" "NEW-RULE-XYZ" "update pulled the new rule into the managed block"
  assert_contains "$c" "Keep me." "update preserved the user's out-of-block notes"
  assert_contains "$c" "Framework: fastapi" "update preserved the framework lock from state"
  rm -rf "$tmp" "$st"
}

test_update_refuses_handwritten_claudemd() {
  local tmp; tmp="$(mktemp -d)"
  ( cd "$tmp" && git init -q && printf '# Mine\n' > CLAUDE.md )
  assert_fail bash -c "cd '$tmp' && CLAUDE_STARTERS_DIR='$DIR/starters' '$AS' python --update"
  assert_eq "# Mine" "$(cat "$tmp/CLAUDE.md")" "hand-written CLAUDE.md untouched"
  rm -rf "$tmp"
}

test_force_backs_up_then_overwrites() {
  local tmp; tmp="$(mktemp -d)"
  ( cd "$tmp" && git init -q && printf 'OLD\n' > CLAUDE.md && bash "$AS" python --framework none --force >/dev/null )
  assert_eq "OLD" "$(cat "$tmp/CLAUDE.md.bak")" "force backed up the original"
  assert_contains "$(cat "$tmp/CLAUDE.md")" "Python project rules" "force wrote the new rules"
  rm -rf "$tmp"
}

test_update_refuses_lone_begin_marker() {
  local tmp; tmp="$(mktemp -d)"
  ( cd "$tmp" && git init -q
    printf '<!-- claude-starters:rules begin -->\nOLD\nPRECIOUS USER NOTES\n' > CLAUDE.md )
  assert_fail bash -c "cd '$tmp' && CLAUDE_STARTERS_DIR='$DIR/starters' '$AS' python --framework fastapi --update"
  assert_contains "$(cat "$tmp/CLAUDE.md")" "PRECIOUS USER NOTES" "lone-begin-marker file left intact (not truncated)"
  rm -rf "$tmp"
}

test_double_force_preserves_original() {
  local tmp; tmp="$(mktemp -d)"
  ( cd "$tmp" && git init -q && printf 'MY ORIGINAL HANDWRITTEN\n' > CLAUDE.md
    "$AS" python --framework none --force >/dev/null )
  assert_fail bash -c "cd '$tmp' && CLAUDE_STARTERS_DIR='$DIR/starters' '$AS' python --framework none --force"
  assert_eq "MY ORIGINAL HANDWRITTEN" "$(cat "$tmp/CLAUDE.md.bak")" "original preserved in .bak after refused 2nd force"
  rm -rf "$tmp"
}

test_framework_with_metacharacters_is_literal() {
  local tmp; tmp="$(mktemp -d)"
  ( cd "$tmp" && git init -q && "$AS" python --framework 'A|B & C' >/dev/null )
  assert_contains "$(cat "$tmp/CLAUDE.md")" "Framework: A|B & C" "metachar framework rendered literally (no sed crash/injection)"
  rm -rf "$tmp"
}

test_framework_backslash_is_literal() {
  local tmp; tmp="$(mktemp -d)"
  ( cd "$tmp" && git init -q && "$AS" python --framework 'C:\new' >/dev/null )
  assert_contains "$(cat "$tmp/CLAUDE.md")" 'Framework: C:\new' "backslash framework literal (awk ENVIRON, not -v)"
  rm -rf "$tmp"
}

test_path_rejects_absolute_and_dotdot() {
  local tmp; tmp="$(mktemp -d)"
  assert_fail bash -c "cd '$tmp' && CLAUDE_STARTERS_DIR='$DIR/starters' '$AS' python --path /etc"
  assert_fail bash -c "cd '$tmp' && CLAUDE_STARTERS_DIR='$DIR/starters' '$AS' python --path ../escape"
  rm -rf "$tmp"
}

run_tests
