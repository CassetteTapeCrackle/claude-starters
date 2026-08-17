#!/usr/bin/env bash
set -euo pipefail
DIR="$(cd "$(dirname "$0")/.." && pwd)"
source "$DIR/tests/lib.sh"

# stack|signature token that must appear in its CLAUDE.md
PAIRS=(
  "web-ts|Vite"
  "node-api|Fastify"
  "audio-app|ScopedNoDenormals"
  "web-audio|AudioWorklet"
  "audio-external|perform routine"
  "faust|Faust"
  "python-ml|Seed"
  "swiftui|Observation"
  "android|Compose"
  "flutter|Riverpod"
  "tauri|tauri::command"
  "electron|contextIsolation"
)

test_each_starter_token_framework_manifest() {
  for p in "${PAIRS[@]}"; do
    local stack="${p%%|*}" sig="${p#*|}" f="$DIR/starters/${p%%|*}/CLAUDE.md"
    assert_file_exists "$f" "$stack CLAUDE.md exists"
    local c; c="$(cat "$f" 2>/dev/null || true)"
    assert_contains "$c" "__FRAMEWORK__" "$stack has framework token"
    assert_contains "$c" "$sig" "$stack has signature '$sig'"
    python3 -c "import json; m=json.load(open('$DIR/starters/$stack/manifest.json')); assert m['stack']=='$stack', m['stack']"
  done
}

test_ts_skill_present() {
  local f="$DIR/skills/clean-code-ts/SKILL.md"
  assert_file_exists "$f" "clean-code-ts skill exists"
  local c; c="$(cat "$f" 2>/dev/null || true)"
  assert_contains "$c" "name: clean-code-ts" "ts skill named"
  assert_contains "$c" "discriminated union" "ts skill signature"
}

run_tests
