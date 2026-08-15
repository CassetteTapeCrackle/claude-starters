#!/usr/bin/env bash
set -euo pipefail
DIR="$(cd "$(dirname "$0")/.." && pwd)"
source "$DIR/tests/lib.sh"

# skill|signature token
PAIRS=(
  "clean-code-rust|thiserror"
  "clean-code-go|goroutine"
  "clean-code-python|pathlib"
  "clean-code-bash|pipefail"
  "clean-code-c|malloc"
)

test_each_skill_named_and_signed() {
  for p in "${PAIRS[@]}"; do
    local name="${p%%|*}" sig="${p#*|}" f="$DIR/skills/${p%%|*}/SKILL.md"
    assert_file_exists "$f" "$name SKILL.md exists"
    local c; c="$(cat "$f" 2>/dev/null || true)"
    assert_contains "$c" "name: $name" "$name has name in frontmatter"
    assert_contains "$c" "description:" "$name has description"
    assert_contains "$c" "$sig" "$name has signature '$sig'"
  done
}

run_tests
