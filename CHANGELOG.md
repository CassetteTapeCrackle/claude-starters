# Changelog

Bump `version` in `.claude-plugin/plugin.json` on every release — that's the
signal Claude Code uses to offer an update (`/plugin marketplace update
claude-starters` → `/plugin update claude-starters`).

## 1.1.0
- **Applier flags:** `--list [<stack>]`, `--dry-run`, `--print`, `--no-agents`,
  `--force` (backs up to `CLAUDE.md.bak`), `--version`, `--help`.
- **Update path:** starter rules now live in a managed block
  (`<!-- claude-starters:rules … -->`). `--update` refreshes that block from the
  current template (framework preserved from stored state) and leaves everything
  outside the block untouched. Refuses to touch a hand-written `CLAUDE.md`.
- **Existing-repo detection:** a `SessionStart` hook offers the matching starter
  on existing repos — opt-in, non-destructive, debounced out-of-repo (zero
  footprint on decline).
- **Robustness:** hooks fail-safe (never wedge a session); `.gitattributes`
  forces LF for cross-platform hooks.

## 1.0.0
- Initial plugin: 23 starters; 8 `clean-code-*` skills + `agent-orchestration`;
  a scoped 74-agent library + 8 global agents; greenfield `apply-starter` with
  `--path` (monorepo subtrees) and `--add` (mixed dirs); auto-launch
  orchestration (Stop + SessionStart hooks); git-ignored per-project setup.
