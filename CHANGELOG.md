# Changelog

Bump `version` in `.claude-plugin/plugin.json` on every release — that's the
signal Claude Code uses to offer an update (`/plugin marketplace update
claude-starters` → `/plugin update claude-starters`).

## 1.2.0
- **Plugin configuration:** `userConfig` declares two boolean opt-outs, prompted
  when the plugin is enabled and changeable from `/plugin` — no hand-editing
  `settings.json`. `suggest_on_existing_repos` gates the existing-repo offer;
  `turn_end_orchestrator` gates the turn-end agent surfacing. The hooks read
  them from `CLAUDE_PLUGIN_OPTION_*`, and **unset means enabled**, so upgrading
  changes nothing for anyone who skips the prompts. Gates use `case`, not
  `[ ] && exit`, so a non-match can't trip the hooks' `ERR` trap.
- **`displayName`:** shows as "Claude Starters" in the `/plugin` picker.
- **Docs:** README restructured into chapters (Why / How it works /
  Orchestration / Configuration / Flags / FAQ / Contributing). The orchestrator
  and the full flag set were both undocumented despite being in the tagline and
  the script respectively.
- **Fixed:** plugin + marketplace descriptions said "74-agent library"; it is 68
  in the library plus 8 global = 76.
- **CI:** adds explicit `setup-python` — several content tests shell out to
  `python3` and were silently relying on the runner image providing it. Also
  `workflow_dispatch`, read-only permissions, and `checkout`/`setup-python` at
  v7. The `test` job must stay unnamed: `master` requires the status check
  context `test`, which is the job id, so adding a display name makes every PR
  unmergeable.
- **Repo:** CONTRIBUTING, bug + new-starter issue templates, Dependabot for
  Actions, and `assets/` — logo, animated demo, and a social preview card with
  the script that generates it.

## 1.1.1
Data-safety fixes from a rigorous harsh review + plugin-mechanics audit:
- **`--update`** refuses a file with a lone begin-marker (no end) instead of
  truncating everything after it.
- **`--force`** refuses to overwrite an existing `.bak` (a second `--force`
  would otherwise have destroyed the original).
- **`--framework`** values substituted literally — no `sed` crash/injection from
  `|`, `&`, etc. (and no truncate-then-crash stub in the `--force` path).
- **`--path`** rejects absolute paths and `..`.
- **Stop hook** now uses the documented exit-code-2 + stderr mechanism (not a
  `decision:block` JSON), and debounces by candidate **set** — each risk surfaces
  once (no per-edit nagging, no exit-2 loop).
- Portable word boundaries (no `\b`), exact stack matching (no substring
  collisions), targeted git-excludes (generated `.claude/agents/` + dotfiles +
  `.bak`, not the whole `.claude/`), `--add` idempotent.
- Framework substitution passes the value via `ENVIRON` (not awk `-v`), so
  backslash-bearing names (`C:\new`, `C++\Qt`) render literally.

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
