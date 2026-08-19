#!/usr/bin/env bash
set -euo pipefail
DIR="$(cd "$(dirname "$0")/.." && pwd)"
source "$DIR/tests/lib.sh"

# A rust repo with a starter applied and an unsafe block in the working tree —
# enough for the turn-end orchestrator to surface unsafe-auditor.
mk_flagged_repo() {
  local tmp; tmp="$(mktemp -d)"
  ( cd "$tmp"
    git init -q; git config user.email t@t; git config user.name t
    printf 'fn main() {}\n' > main.rs; git add -A; git commit -qm base
    mkdir -p .claude; printf 'rust\n' > .claude/.starter-applied
    printf 'fn f() { unsafe { } }\n' >> main.rs )
  printf '%s' "$tmp"
}

# A repo that looks like an unconfigured rust project, with an isolated HOME so
# the once-per-repo debounce file cannot leak between tests.
mk_bare_rust_repo() {
  local tmp; tmp="$(mktemp -d)"
  ( cd "$tmp"; git init -q; printf '[package]\n' > Cargo.toml; mkdir -p fakehome )
  printf '%s' "$tmp"
}

run_stop() { # <repo> ; echoes "<exit>|<stderr>"
  local r="$1" out rc
  set +e
  out="$(cd "$r" && bash "$DIR/hooks/stop-orchestrator.sh" 2>&1 >/dev/null)"; rc=$?
  set -e
  printf '%s|%s' "$rc" "$out"
}

test_orchestrator_on_by_default() {
  local r; r="$(mk_flagged_repo)"
  local got; got="$(run_stop "$r")"
  assert_eq "2" "${got%%|*}" "unset CLAUDE_PLUGIN_OPTION_TURN_END_ORCHESTRATOR -> still fires"
  assert_contains "$got" "unsafe-auditor" "default-on surfaces the candidate"
  rm -rf "$r"
}

test_orchestrator_opt_out() {
  local r; r="$(mk_flagged_repo)"
  local got
  got="$(CLAUDE_PLUGIN_OPTION_TURN_END_ORCHESTRATOR=false run_stop "$r")"
  assert_eq "0|" "$got" "turn_end_orchestrator=false -> silent, exit 0"
  rm -rf "$r"
}

test_orchestrator_accepts_other_falsey_values() {
  local r v got
  for v in 0 off; do
    r="$(mk_flagged_repo)"
    got="$(CLAUDE_PLUGIN_OPTION_TURN_END_ORCHESTRATOR="$v" run_stop "$r")"
    assert_eq "0|" "$got" "turn_end_orchestrator=$v -> silent"
    rm -rf "$r"
  done
}

test_suggest_on_by_default() {
  local r; r="$(mk_bare_rust_repo)"
  local out
  out="$(cd "$r" && HOME="$r/fakehome" bash "$DIR/hooks/detect-existing-stack.sh")"
  assert_contains "$out" "rust" "unset suggest_on_existing_repos -> suggests rust"
  rm -rf "$r"
}

test_suggest_opt_out() {
  local r; r="$(mk_bare_rust_repo)"
  local out
  out="$(cd "$r" && HOME="$r/fakehome" CLAUDE_PLUGIN_OPTION_SUGGEST_ON_EXISTING_REPOS=false \
        bash "$DIR/hooks/detect-existing-stack.sh")"
  assert_eq "" "$out" "suggest_on_existing_repos=false -> no suggestion"
  rm -rf "$r"
}

test_opt_out_leaves_no_debounce_state() {
  local r; r="$(mk_bare_rust_repo)"
  ( cd "$r" && HOME="$r/fakehome" CLAUDE_PLUGIN_OPTION_SUGGEST_ON_EXISTING_REPOS=false \
    bash "$DIR/hooks/detect-existing-stack.sh" >/dev/null )
  if [ -f "$r/fakehome/.claude/starter-suggested-repos" ]; then
    echo "FAIL: opting out still wrote the debounce file"; _TESTS_FAILED=1
  fi
  rm -rf "$r"
}

test_userconfig_declared_in_manifest() {
  local keys
  keys="$(python3 -c "
import json; d=json.load(open('$DIR/.claude-plugin/plugin.json'))
print(' '.join(sorted(d.get('userConfig', {}))))")"
  assert_eq "suggest_on_existing_repos turn_end_orchestrator" "$keys" "userConfig keys declared"
  local types
  types="$(python3 -c "
import json; d=json.load(open('$DIR/.claude-plugin/plugin.json'))
print(' '.join(sorted({v['type'] for v in d['userConfig'].values()})))")"
  assert_eq "boolean" "$types" "userConfig options are booleans"
}

run_tests
