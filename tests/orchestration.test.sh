#!/usr/bin/env bash
set -euo pipefail
DIR="$(cd "$(dirname "$0")/.." && pwd)"
source "$DIR/tests/lib.sh"

# Build a temp git repo with a committed baseline, a starter marker, then a
# working-tree change. Echoes the repo path.
mk_repo() { # <stack> <baseline-file> <baseline-content>
  local tmp; tmp="$(mktemp -d)"
  ( cd "$tmp"
    git init -q; git config user.email t@t; git config user.name t
    printf '%s\n' "$3" > "$2"; git add -A; git commit -qm base
    mkdir -p .claude; printf '%s\n' "$1" > .claude/.starter-applied )
  printf '%s' "$tmp"
}

test_detects_rust_unsafe() {
  local r; r="$(mk_repo rust main.rs 'fn main() {}')"
  printf 'fn f() { unsafe { } }\n' >> "$r/main.rs"
  assert_eq "unsafe-auditor" "$(bash "$DIR/hooks/detect-candidates.sh" "$r")" "rust unsafe -> unsafe-auditor"
  rm -rf "$r"
}

test_detects_audio_rt() {
  local r; r="$(mk_repo audio-plugin Proc.cpp 'void processBlock() { }')"
  printf 'int x = 1; auto* p = new float[8];\n' >> "$r/Proc.cpp"
  assert_eq "rt-safety-auditor" "$(bash "$DIR/hooks/detect-candidates.sh" "$r")" "alloc near processBlock -> rt-safety-auditor"
  rm -rf "$r"
}

test_no_candidate_for_benign_change() {
  local r; r="$(mk_repo rust main.rs 'fn main() {}')"
  printf '// a harmless comment\n' >> "$r/main.rs"
  assert_eq "" "$(bash "$DIR/hooks/detect-candidates.sh" "$r")" "benign change -> no candidate"
  rm -rf "$r"
}

test_stop_hook_surfaces_then_debounces() {
  local r; r="$(mk_repo rust main.rs 'fn main() {}')"
  printf 'fn f() { unsafe { } }\n' >> "$r/main.rs"
  local out1; out1="$( cd "$r" && bash "$DIR/hooks/stop-orchestrator.sh" </dev/null )"
  assert_contains "$out1" '"decision":"block"' "first stop surfaces a block"
  assert_contains "$out1" 'unsafe-auditor' "block names the candidate"
  local out2; out2="$( cd "$r" && bash "$DIR/hooks/stop-orchestrator.sh" </dev/null )"
  assert_eq "" "$out2" "same diff is debounced (silent second time)"
  rm -rf "$r"
}

test_install_wires_stop_hook_once() {
  local home; home="$(mktemp -d)"
  HOME="$home" bash "$DIR/install.sh" >/dev/null
  HOME="$home" bash "$DIR/install.sh" >/dev/null
  local n; n="$(python3 -c "import json;print(len(json.load(open('$home/.claude/settings.json'))['hooks']['Stop']))")"
  assert_eq "1" "$n" "Stop hook wired exactly once"
  assert_file_exists "$home/.claude/skills/agent-orchestration/SKILL.md" "orchestration skill installed"
  rm -rf "$home"
}

run_tests
