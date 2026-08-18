#!/usr/bin/env bash
set -euo pipefail
SRC="$(cd "$(dirname "$0")" && pwd)"
DEST="$HOME/.claude"
mkdir -p "$DEST/commands"
ln -sf "$SRC/commands/apply-starter.md" "$DEST/commands/apply-starter.md"
chmod +x "$SRC/bin/apply-starter.sh"
chmod +x "$SRC"/hooks/*.sh 2>/dev/null || true

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
# Insert or replace the lean-layer block between markers (propagates edits on re-install).
python3 - "$GCLAUDE" "$BLOCK_BEGIN" "$BLOCK_END" "$SRC/global/lean-layer.md" <<'PY'
import sys, re
path, begin, end, blockfile = sys.argv[1:5]
txt = open(path).read()
body = open(blockfile).read().rstrip('\n')
new = f"{begin}\n{body}\n{end}"
pat = re.compile(re.escape(begin) + r".*?" + re.escape(end), re.S)
if pat.search(txt):
    txt = pat.sub(lambda _: new, txt)
else:
    if txt and not txt.endswith('\n'): txt += '\n'
    txt = txt + '\n' + new + '\n'
open(path, 'w').write(txt)
PY

# Wire the light-Stop orchestration hook into settings.json (idempotent; never clobbers).
SETTINGS="$DEST/settings.json"
python3 - "$SETTINGS" "$SRC/hooks/stop-orchestrator.sh" <<'PY'
import json, sys, os
path, cmd = sys.argv[1], sys.argv[2]
data = {}
if os.path.exists(path):
    try:
        data = json.load(open(path))
    except Exception:
        sys.stderr.write("settings.json is not valid JSON; skipping Stop hook wiring\n")
        sys.exit(0)
stop = data.setdefault("hooks", {}).setdefault("Stop", [])
present = any(
    isinstance(e, dict) and any(
        isinstance(h, dict) and h.get("command") == cmd for h in e.get("hooks", [])
    ) for e in stop
)
if not present:
    stop.append({"hooks": [{"type": "command", "command": cmd}]})
    json.dump(data, open(path, "w"), indent=2)
    print("wired")
PY

echo "Installed apply-starter command → $DEST/commands/ (+ skills, agents, orchestration hook)"
