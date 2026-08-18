# claude-starters

Token-lean project starters for Claude Code. On a chosen stack+framework,
`/apply-starter` writes a git-ignored project `CLAUDE.md` (framework locked)
and points the agent at deeper on-demand skills.

## Install
    /plugin marketplace add CassetteTapeCrackle/claude-starters
    /plugin install claude-starters

Bundles the `/apply-starter` command, the `clean-code-*` + `agent-orchestration`
skills, the global agents, and the orchestration hooks. Enable / disable /
uninstall entirely through `/plugin` — no manual file surgery, nothing written
to your `~/.claude/`.

## Use (greenfield)
After brainstorming settles on a language + framework:

    /apply-starter python --framework fastapi

## Use (existing repo)
Open an existing repo and the plugin **detects the stack** (`Cargo.toml`,
`package.json`, …) and **offers** to apply the matching starter — once per repo,
opt-in. If the repo already has a `CLAUDE.md`, it appends the rules
non-destructively via `--add` (your file is never overwritten). Decline and the
repo is left completely untouched (the "already suggested" state is stored
outside the repo).

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
A **74-agent library** (`agent-library/`), surfaced *per codebase* so you only ever
see the relevant few:
- **Global** (installed to `~/.claude/agents/`): `starter-author`, `dep-auditor`, and
  stack-agnostic product agents (`idea-brainstormer`, `product-critic`, `naming-agent`,
  `release-copywriter`, `demo-script-writer`, `competitor-analyst`).
- **Common** (activated into every applied project's `.claude/agents/`): conformance,
  debugger, regression-hunter, test-author, prd-writer, spec-critic, technical-writer,
  deep-researcher, migration-agent, perf-profiler.
- **Per-stack**: language/domain auditors activated by the starter — e.g. `audio-plugin`
  brings `rt-safety-auditor`, `dsp-golden-test-author`, `pluginval-runner`, …; `rust`
  brings `unsafe-auditor`, `lifetime-untangler`, …

Add a second stack's agents to a mixed directory with `/apply-starter <stack> --add`.
See `docs/agent-ideas-backlog.md` for the full catalogue.

## Extend
Add `starters/<stack>/{CLAUDE.md,manifest.json}` + a content test; optionally
a `skills/clean-code-<x>/SKILL.md` wired in `install.sh`. Or ask the
`starter-author` agent. Everything is TDD'd (plain-bash harness) and
shellcheck-clean.

## Test
    for t in tests/*.test.sh; do bash "$t"; done
    shellcheck bin/apply-starter.sh install.sh tests/*.sh
