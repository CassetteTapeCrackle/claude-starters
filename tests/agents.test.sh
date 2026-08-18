#!/usr/bin/env bash
set -euo pipefail
DIR="$(cd "$(dirname "$0")/.." && pwd)"
source "$DIR/tests/lib.sh"

test_agents_have_frontmatter() {
  for a in starter-author dep-auditor; do
    local f="$DIR/agents/$a.md"
    assert_file_exists "$f" "$a agent exists"
    local c; c="$(cat "$f" 2>/dev/null || true)"
    assert_contains "$c" "name: $a" "$a has name"
    assert_contains "$c" "description:" "$a has description"
  done
}

test_install_symlinks_agents() {
  local home; home="$(mktemp -d)"
  HOME="$home" bash "$DIR/install.sh" >/dev/null
  assert_file_exists "$home/.claude/agents/starter-author.md" "starter-author installed"
  assert_file_exists "$home/.claude/agents/dep-auditor.md" "dep-auditor installed"
  assert_file_exists "$home/.claude/agents/naming-agent.md" "global product agent installed"
  rm -rf "$home"
}

run_tests
