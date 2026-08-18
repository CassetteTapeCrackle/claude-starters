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

test_stop_hook_surfaces_new_candidate_then_silent() {
  local r; r="$(mk_repo rust main.rs 'fn main() {}')"
  printf 'fn f() { unsafe { } }\n' >> "$r/main.rs"
  local err1 rc1
  set +e
  err1="$( cd "$r" && bash "$DIR/hooks/stop-orchestrator.sh" </dev/null 2>&1 1>/dev/null )"; rc1=$?
  set -e
  assert_eq "2" "$rc1" "blocks with exit code 2 on first surface"
  assert_contains "$err1" "unsafe-auditor" "names the candidate on stderr"
  # Keep editing (changed diff) but SAME candidate type -> must not re-fire.
  printf 'fn g() { unsafe { } }\n' >> "$r/main.rs"
  local err2 rc2
  set +e
  err2="$( cd "$r" && bash "$DIR/hooks/stop-orchestrator.sh" </dev/null 2>&1 1>/dev/null )"; rc2=$?
  set -e
  assert_eq "0" "$rc2" "changed diff, already-surfaced candidate -> exit 0 (no nag, no loop)"
  assert_eq "" "$err2" "no message on the already-surfaced turn"
  rm -rf "$r"
}

run_tests
