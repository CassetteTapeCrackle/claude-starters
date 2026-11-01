#!/usr/bin/env bash
set -euo pipefail
DIR="$(cd "$(dirname "$0")/.." && pwd)"
source "$DIR/tests/lib.sh"

fm() { awk '/^---$/{c++;next} c==1{print}' "$1"; }  # frontmatter body

test_cpp_skill() {
  local f="$DIR/skills/clean-code-cpp/SKILL.md"
  assert_file_exists "$f" "clean-code-cpp SKILL.md exists"
  local head; head="$(fm "$f")"
  assert_contains "$head" "name: clean-code-cpp" "has name"
  assert_contains "$head" "description:" "has description"
  local c; c="$(cat "$f")"
  assert_contains "$c" "expected" "error-handling policy"
  assert_contains "$c" "unique_ptr" "ownership model"
  assert_contains "$c" "noexcept" "noexcept discipline"
  assert_contains "$c" "string_view" "non-owning views"
  assert_contains "$c" "lower_bound" "algorithms over raw loops"
  assert_contains "$c" "receipt" "call-order rules as parameters"
}

test_audio_skill() {
  local f="$DIR/skills/clean-code-audio/SKILL.md"
  assert_file_exists "$f" "clean-code-audio SKILL.md exists"
  local head; head="$(fm "$f")"
  assert_contains "$head" "name: clean-code-audio" "has name"
  local c; c="$(cat "$f")"
  assert_contains "$c" "smoothing" "parameter smoothing"
  assert_contains "$c" "denormal" "denormals"
  assert_contains "$c" "atomic" "thread model"
  assert_contains "$c" "block" "block processing"
  assert_contains "$c" "thin dispatcher" "processBlock stays thin"
  assert_contains "$c" "fixed seed" "seeded RNG for golden buffers"
}

run_tests
