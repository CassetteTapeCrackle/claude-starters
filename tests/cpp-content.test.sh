#!/usr/bin/env bash
set -euo pipefail
DIR="$(cd "$(dirname "$0")/.." && pwd)"
source "$DIR/tests/lib.sh"

test_cpp_template_tokens_and_rules() {
  local f="$DIR/starters/cpp/CLAUDE.md"
  assert_file_exists "$f" "cpp CLAUDE.md exists"
  local c; c="$(cat "$f")"
  assert_contains "$c" "__FRAMEWORK__" "has framework token"
  assert_contains "$c" "C++20" "locks C++20"
  assert_contains "$c" "CPM" "uses CPM"
  assert_contains "$c" "clang-tidy" "lint via clang-tidy"
  assert_contains "$c" "ASan" "sanitizers"
  assert_contains "$c" "Catch2" "Catch2 tests"
  assert_contains "$c" "clean-code-cpp" "invokes clean-code-cpp skill"
}

test_cpp_manifest_valid() {
  python3 -c "import json; m=json.load(open('$DIR/starters/cpp/manifest.json')); assert m['stack']=='cpp'; assert m['standard']=='c++20'; assert m['package_manager']=='cpm'"
}

run_tests
