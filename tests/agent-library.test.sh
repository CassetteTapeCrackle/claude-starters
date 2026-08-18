#!/usr/bin/env bash
set -euo pipefail
DIR="$(cd "$(dirname "$0")/.." && pwd)"
source "$DIR/tests/lib.sh"

# Every agent named in common.txt or any starter's agents.txt must exist in agent-library/.
test_no_dangling_agent_references() {
  local lists=("$DIR/agent-library/common.txt" "$DIR"/starters/*/agents.txt)
  for l in "${lists[@]}"; do
    [ -f "$l" ] || continue
    local label; label="$(basename "$(dirname "$l")")/$(basename "$l")"
    while IFS= read -r a || [ -n "$a" ]; do
      [ -n "$a" ] || continue
      case "$a" in \#*) continue ;; esac
      assert_file_exists "$DIR/agent-library/$a.md" "referenced agent '$a' exists (from $label)"
    done < "$l"
  done
}

# Every library agent has name + description frontmatter.
test_library_agents_have_frontmatter() {
  for f in "$DIR"/agent-library/*.md; do
    [ -e "$f" ] || continue
    local c; c="$(cat "$f")"
    assert_contains "$c" "name:" "$(basename "$f") has name"
    assert_contains "$c" "description:" "$(basename "$f") has description"
  done
}

run_tests
