#!/usr/bin/env bash
set -euo pipefail
DIR="$(cd "$(dirname "$0")/.." && pwd)"
source "$DIR/tests/lib.sh"

test_plugin_json_valid() {
  python3 -c "
import json
m=json.load(open('$DIR/.claude-plugin/plugin.json'))
assert m['name']=='claude-starters', m['name']
assert 'version' in m and 'description' in m
assert isinstance(m.get('keywords'), list)
"
}

test_marketplace_json_valid() {
  python3 -c "
import json
m=json.load(open('$DIR/.claude-plugin/marketplace.json'))
assert m['name']=='claude-starters'
ps=m['plugins']; assert isinstance(ps, list) and ps
assert ps[0]['name']=='claude-starters' and ps[0]['source']=='./'
"
}

test_hooks_json_uses_plugin_root() {
  python3 -c "
import json
h=json.load(open('$DIR/hooks/hooks.json'))['hooks']
assert 'Stop' in h and 'SessionStart' in h
cmds=[hh['command'] for e in h['Stop']+h['SessionStart'] for hh in e['hooks']]
assert all(c.startswith('\${CLAUDE_PLUGIN_ROOT}/hooks/') for c in cmds), cmds
"
}

test_no_hardcoded_home_paths_in_runtime() {
  # The command + runtime scripts must not hardcode ~/claude-starters.
  # shellcheck disable=SC2016  # literal $HOME in the search regex is intentional
  if grep -rnE '(~|\$HOME)/claude-starters' "$DIR/bin" "$DIR/hooks" "$DIR/commands" 2>/dev/null; then
    echo "FAIL: hardcoded home path in runtime files"; _TESTS_FAILED=1
  fi
}

test_applier_self_locates_from_install_dir() {
  # Simulate a plugin install: copy runtime bits to a fresh dir, run with NO env
  # override — the applier must self-locate starters/ and agent-library/.
  local inst proj
  inst="$(mktemp -d)"; proj="$(mktemp -d)"
  mkdir -p "$inst/bin"
  cp "$DIR/bin/apply-starter.sh" "$inst/bin/"
  cp -R "$DIR/starters" "$inst/starters"
  cp -R "$DIR/agent-library" "$inst/agent-library"
  ( cd "$proj" && git init -q \
    && env -u CLAUDE_STARTERS_DIR -u CLAUDE_AGENT_LIB "$inst/bin/apply-starter.sh" python --framework none >/dev/null )
  assert_file_exists "$proj/CLAUDE.md" "self-located starters/"
  assert_file_exists "$proj/.claude/agents/starter-conformance-checker.md" "self-located agent-library/"
  rm -rf "$inst" "$proj"
}

run_tests
