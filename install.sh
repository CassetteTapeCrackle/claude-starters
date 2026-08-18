#!/usr/bin/env bash
set -euo pipefail
SRC="$(cd "$(dirname "$0")" && pwd)"
DEST="$HOME/.claude"
mkdir -p "$DEST/commands"
ln -sf "$SRC/commands/apply-starter.md" "$DEST/commands/apply-starter.md"
chmod +x "$SRC/bin/apply-starter.sh"

mkdir -p "$DEST/skills"
for s in "$SRC"/skills/*/; do
  [ -d "$s" ] || continue
  ln -sfn "${s%/}" "$DEST/skills/$(basename "$s")"
done

mkdir -p "$DEST/agents"
for a in "$SRC"/agents/*.md; do
  [ -e "$a" ] || continue
  ln -sf "$a" "$DEST/agents/$(basename "$a")"
done
# Stack-agnostic product/ideation agents are global (available everywhere, not per-project).
if [ -f "$SRC/agent-library/global.txt" ]; then
  while IFS= read -r a || [ -n "$a" ]; do
    [ -n "$a" ] || continue
    case "$a" in \#*) continue ;; esac
    [ -f "$SRC/agent-library/$a.md" ] && ln -sf "$SRC/agent-library/$a.md" "$DEST/agents/$a.md"
  done < "$SRC/agent-library/global.txt"
fi

BLOCK_BEGIN="<!-- claude-starters:begin -->"
BLOCK_END="<!-- claude-starters:end -->"
GCLAUDE="$DEST/CLAUDE.md"; touch "$GCLAUDE"
if ! grep -qF "$BLOCK_BEGIN" "$GCLAUDE"; then
  { printf '\n%s\n' "$BLOCK_BEGIN"; cat "$SRC/global/lean-layer.md"; printf '%s\n' "$BLOCK_END"; } >> "$GCLAUDE"
fi
echo "Installed apply-starter command → $DEST/commands/"
