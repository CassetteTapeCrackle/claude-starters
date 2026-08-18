#!/usr/bin/env bash
set -euo pipefail
DIR="$(cd "$(dirname "$0")/.." && pwd)"
source "$DIR/tests/lib.sh"
HOOK="$DIR/hooks/detect-existing-stack.sh"

# git repo with the given marker files; echoes its path
mk() {
  local tmp; tmp="$(mktemp -d)"
  ( cd "$tmp" && git init -q && git config user.email t@t && git config user.name t )
  local f; for f in "$@"; do : > "$tmp/$f"; done
  printf '%s' "$tmp"
}

test_suggests_rust_and_leaves_repo_pristine() {
  local home r out
  home="$(mktemp -d)"; r="$(mk Cargo.toml)"
  out="$( cd "$r" && HOME="$home" bash "$HOOK" </dev/null )"
  assert_contains "$out" "additionalContext" "emits SessionStart context"
  assert_contains "$out" "rust" "names rust candidate"
  assert_eq "1" "$(grep -c . "$home/.claude/starter-suggested-repos")" "recorded suggestion OUT of the repo"
  if [ -e "$r/.claude" ]; then echo "FAIL: wrote into the repo"; _TESTS_FAILED=1; fi
  rm -rf "$home" "$r"
}

test_debounced_after_first() {
  local home r; home="$(mktemp -d)"; r="$(mk Cargo.toml)"
  ( cd "$r" && HOME="$home" bash "$HOOK" </dev/null >/dev/null )
  assert_eq "" "$( cd "$r" && HOME="$home" bash "$HOOK" </dev/null )" "silent on the next session"
  rm -rf "$home" "$r"
}

test_silent_when_already_applied() {
  local home r; home="$(mktemp -d)"; r="$(mk Cargo.toml)"
  mkdir -p "$r/.claude"; : > "$r/.claude/.starter-applied"
  assert_eq "" "$( cd "$r" && HOME="$home" bash "$HOOK" </dev/null )" "silent when a starter is applied"
  rm -rf "$home" "$r"
}

test_suggests_add_when_claudemd_present() {
  local home r out; home="$(mktemp -d)"; r="$(mk Cargo.toml CLAUDE.md)"
  out="$( cd "$r" && HOME="$home" bash "$HOOK" </dev/null )"
  assert_contains "$out" "--add" "suggests --add to preserve the existing CLAUDE.md"
  rm -rf "$home" "$r"
}

run_tests
