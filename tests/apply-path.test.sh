#!/usr/bin/env bash
set -euo pipefail
DIR="$(cd "$(dirname "$0")/.." && pwd)"
source "$DIR/tests/lib.sh"
export CLAUDE_STARTERS_DIR="$DIR/starters"

test_multilang_monorepo() {
  local tmp; tmp="$(mktemp -d)"; ( cd "$tmp"; git init -q
    "$DIR/bin/apply-starter.sh" rust --framework axum --path backend >/dev/null
    "$DIR/bin/apply-starter.sh" python-cli --framework typer --path tools >/dev/null )
  assert_contains "$(cat "$tmp/backend/CLAUDE.md")" "cargo clippy" "backend got rust rules"
  assert_contains "$(cat "$tmp/tools/CLAUDE.md")" "Typer" "tools got python-cli rules"
  assert_eq "rust" "$(cat "$tmp/backend/.claude/.starter-applied")" "backend marker"
  assert_eq "python-cli" "$(cat "$tmp/tools/.claude/.starter-applied")" "tools marker"
  local ex="$tmp/.git/info/exclude"
  assert_eq "1" "$(grep -c '^/backend/CLAUDE.md$' "$ex")" "backend CLAUDE.md excluded (repo-relative)"
  assert_eq "1" "$(grep -c '^/tools/CLAUDE.md$' "$ex")" "tools CLAUDE.md excluded (repo-relative)"
  rm -rf "$tmp"
}

test_root_still_works() {
  local tmp; tmp="$(mktemp -d)"; ( cd "$tmp"; git init -q
    "$DIR/bin/apply-starter.sh" go --framework gin >/dev/null )
  assert_contains "$(cat "$tmp/CLAUDE.md")" "golangci-lint" "root got go rules"
  assert_eq "1" "$(grep -c '^/CLAUDE.md$' "$tmp/.git/info/exclude")" "root exclude unchanged"
  rm -rf "$tmp"
}

run_tests
