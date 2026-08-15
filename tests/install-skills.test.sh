#!/usr/bin/env bash
set -euo pipefail
DIR="$(cd "$(dirname "$0")/.." && pwd)"
source "$DIR/tests/lib.sh"

test_install_symlinks_skills() {
  local home; home="$(mktemp -d)"
  HOME="$home" bash "$DIR/install.sh" >/dev/null
  assert_file_exists "$home/.claude/skills/clean-code-cpp/SKILL.md" "cpp skill installed"
  assert_file_exists "$home/.claude/skills/clean-code-audio/SKILL.md" "audio skill installed"
  rm -rf "$home"
}

run_tests
