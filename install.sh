#!/usr/bin/env bash
set -euo pipefail
SRC="$(cd "$(dirname "$0")" && pwd)"
DEST="$HOME/.claude"
mkdir -p "$DEST/commands"
ln -sf "$SRC/commands/apply-starter.md" "$DEST/commands/apply-starter.md"
chmod +x "$SRC/bin/apply-starter.sh"
echo "Installed apply-starter command → $DEST/commands/"
