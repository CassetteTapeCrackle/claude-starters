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

BLOCK_BEGIN="<!-- claude-starters:begin -->"
BLOCK_END="<!-- claude-starters:end -->"
GCLAUDE="$DEST/CLAUDE.md"; touch "$GCLAUDE"
if ! grep -qF "$BLOCK_BEGIN" "$GCLAUDE"; then
  { printf '\n%s\n' "$BLOCK_BEGIN"; cat "$SRC/global/lean-layer.md"; printf '%s\n' "$BLOCK_END"; } >> "$GCLAUDE"
fi
echo "Installed apply-starter command → $DEST/commands/"
