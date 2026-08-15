#!/usr/bin/env bash
set -euo pipefail
DIR="$(cd "$(dirname "$0")/.." && pwd)"
source "$DIR/tests/lib.sh"

# stack|signature token that must appear in its CLAUDE.md
PAIRS=(
  "rust|cargo clippy"
  "go|golangci-lint"
  "bash-tooling|set -euo pipefail"
  "python-cli|Typer"
  "python-data|nbstripout"
  "c|ASan"
  "terraform|terraform validate"
  "docker|Multi-stage"
)

test_each_starter_has_token_and_framework() {
  for p in "${PAIRS[@]}"; do
    local stack="${p%%|*}" sig="${p#*|}" f="$DIR/starters/${p%%|*}/CLAUDE.md"
    assert_file_exists "$f" "$stack CLAUDE.md exists"
    local c; c="$(cat "$f" 2>/dev/null || true)"
    assert_contains "$c" "__FRAMEWORK__" "$stack has framework token"
    assert_contains "$c" "$sig" "$stack has signature '$sig'"
  done
}

test_each_manifest_valid_and_named() {
  for p in "${PAIRS[@]}"; do
    local stack="${p%%|*}"
    python3 -c "import json; m=json.load(open('$DIR/starters/$stack/manifest.json')); assert m['stack']=='$stack', m['stack']"
  done
}

run_tests
