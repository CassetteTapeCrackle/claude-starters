# claude-starters

Token-lean project starters for Claude Code. On a chosen stack+framework,
`/apply-starter` writes a git-ignored project `CLAUDE.md` (framework locked)
and points the agent at deeper on-demand skills.

## Install
    bash install.sh

Symlinks the `/apply-starter` command, the `clean-code-*` skills, and the
agents into `~/.claude/`, and appends a lean block to `~/.claude/CLAUDE.md`.

## Use (greenfield)
After brainstorming settles on a language + framework:

    /apply-starter python --framework fastapi

## Use (multi-language monorepo)
Apply different starters to different subtrees; each gets its own scoped,
git-ignored `CLAUDE.md`:

    /apply-starter rust --framework axum --path backend
    /apply-starter web-ts --path frontend

## Starters
**Languages:** python · cpp · c · rust · go · bash-tooling · python-cli · python-data
**Web/backend:** web-ts · node-api · electron · tauri
**Audio:** audio-plugin · audio-app · web-audio · audio-external (max/pd) · faust
**Mobile/desktop:** swiftui · android · flutter
**ML/infra:** python-ml · terraform · docker

## Depth skills (auto-fire on relevant code, ~free at rest)
clean-code-cpp · clean-code-audio · clean-code-rust · clean-code-go ·
clean-code-python · clean-code-bash · clean-code-c · clean-code-ts

## Agents
starter-author (scaffold a new starter) · dep-auditor (dependency hygiene)

## Extend
Add `starters/<stack>/{CLAUDE.md,manifest.json}` + a content test; optionally
a `skills/clean-code-<x>/SKILL.md` wired in `install.sh`. Or ask the
`starter-author` agent. Everything is TDD'd (plain-bash harness) and
shellcheck-clean.

## Test
    for t in tests/*.test.sh; do bash "$t"; done
    shellcheck bin/apply-starter.sh install.sh tests/*.sh
