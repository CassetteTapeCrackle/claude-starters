#!/usr/bin/env bash
set -euo pipefail
DIR="$(cd "$(dirname "$0")/.." && pwd)"
source "$DIR/tests/lib.sh"

test_install_symlinks_command() {
  local home; home="$(mktemp -d)"
  HOME="$home" bash "$DIR/install.sh" >/dev/null
  assert_file_exists "$home/.claude/commands/apply-starter.md" "command installed"
  rm -rf "$home"
}

run_tests
