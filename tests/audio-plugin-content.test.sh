#!/usr/bin/env bash
set -euo pipefail
DIR="$(cd "$(dirname "$0")/.." && pwd)"
source "$DIR/tests/lib.sh"

test_audio_template_tokens_and_rules() {
  local f="$DIR/starters/audio-plugin/CLAUDE.md"
  assert_file_exists "$f" "audio-plugin CLAUDE.md exists"
  local c; c="$(cat "$f")"
  assert_contains "$c" "__FRAMEWORK__" "has framework token"
  assert_contains "$c" "C++17" "locks C++17"
  assert_contains "$c" "CPM" "CPM pulls JUCE"
  assert_contains "$c" "JUCE" "JUCE framework"
  assert_contains "$c" "ScopedNoDenormals" "denormal handling"
  assert_contains "$c" "DSP is sacred" "DSP-sacred rule"
  assert_contains "$c" "pluginval" "pluginval gate"
  assert_contains "$c" "UI approach" "UI-approach lock"
  assert_contains "$c" "TROUBLESHOOTING" "gotcha capture"
  assert_contains "$c" "Catch2" "golden-buffer tests via Catch2"
}

test_audio_manifest_valid() {
  python3 -c "import json; m=json.load(open('$DIR/starters/audio-plugin/manifest.json')); assert m['stack']=='audio-plugin'; assert m['standard']=='c++17'; assert m['frameworks']==['juce']; assert 'VST3' in m['formats']"
}

run_tests
