#!/usr/bin/env bash
# SessionStart hook: inject the proactive orchestration reflex as session context
# (plugin-native alternative to editing the user's CLAUDE.md; toggles with the plugin).
set -euo pipefail
ctx="Agent orchestration is active. At a task's start (or when the Stop hook surfaces a candidate), check whether the task's phase maps to a specialist agent (ideate/spec/design/research/debug/audit/ship), then apply the agent-orchestration skill to decide skip / inline / delegate. Bias to inline; delegate only when an isolated context clearly pays."
esc=${ctx//\\/\\\\}
esc=${esc//\"/\\\"}
printf '{"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":"%s"}}\n' "$esc"
