#!/usr/bin/env bash
set -euo pipefail
DIR="$(cd "$(dirname "$0")/.." && pwd)"
source "$DIR/tests/lib.sh"

test_template_has_framework_token() {
  local f="$DIR/starters/python/CLAUDE.md"
  assert_file_exists "$f" "python CLAUDE.md template exists"
  assert_contains "$(cat "$f")" "__FRAMEWORK__" "template has framework token"
}

test_template_has_core_rules() {
  local c; c="$(cat "$DIR/starters/python/CLAUDE.md")"
  assert_contains "$c" "ruff" "mentions ruff"
  assert_contains "$c" "pytest" "mentions pytest"
  assert_contains "$c" "type hints" "requires type hints"
  assert_contains "$c" "clean-code-python" "invokes clean-code-python skill"
}

test_manifest_is_valid_json() {
  python3 -c "import json,sys; json.load(open('$DIR/starters/python/manifest.json'))"
}

run_tests
