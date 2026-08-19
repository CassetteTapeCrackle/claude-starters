<div align="center">

<img src="assets/logo.svg" width="84" alt="">

# claude-starters

**Token-lean project starters, on-demand clean-code skills, a scoped 76-agent
library, and cost-aware auto-launch orchestration — for Claude Code.**

[![CI](https://github.com/CassetteTapeCrackle/claude-starters/actions/workflows/ci.yml/badge.svg)](https://github.com/CassetteTapeCrackle/claude-starters/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue)](LICENSE)
[![Version](https://img.shields.io/badge/version-1.1.1-D97757)](CHANGELOG.md)
[![Starters](https://img.shields.io/badge/starters-23-4F9A61)](#starters)
[![Agents](https://img.shields.io/badge/agents-76-4F9A61)](#agents)
[![Claude Code plugin](https://img.shields.io/badge/Claude%20Code-plugin-D97757)](#install)

[Demo](#demo) · [Install](#install) · [Use](#use) · [Starters](#starters) · [Skills](#skills) · [Agents](#agents) · [Extend](#extend)

</div>

## Demo

<img src="assets/demo.svg" width="100%" alt="Terminal session: running /apply-starter rust --framework axum prints 'Applied rust starter (framework: axum) to .'; listing .claude/agents shows 14 agents were activated; then git status --short prints nothing, because every file it wrote is git-ignored.">

Pick a stack, get a framework-locked `CLAUDE.md` plus exactly the agents that stack
needs — and **`git status` stays empty**. Everything it writes is git-ignored, so your
repo is byte-for-byte what it was before.

## Install

    /plugin marketplace add CassetteTapeCrackle/claude-starters
    /plugin install claude-starters

Bundles the `/apply-starter` command, the `clean-code-*` + `agent-orchestration`
skills, the global agents, and the orchestration hooks. Enable / disable /
uninstall entirely through `/plugin` — no manual file surgery, nothing written
to your `~/.claude/`.

## Use

### Greenfield
After brainstorming settles on a language + framework:

    /apply-starter python --framework fastapi

### Existing repo
Open an existing repo and the plugin **detects the stack** (`Cargo.toml`,
`package.json`, …) and **offers** to apply the matching starter — once per repo,
opt-in. If the repo already has a `CLAUDE.md`, it appends the rules
non-destructively via `--add` (your file is never overwritten). Decline and the
repo is left completely untouched (the "already suggested" state is stored
outside the repo).

### Multi-language monorepo
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

## Skills
Depth skills that auto-fire on relevant code and cost ~nothing at rest:

clean-code-cpp · clean-code-audio · clean-code-rust · clean-code-go ·
clean-code-python · clean-code-bash · clean-code-c · clean-code-ts

## Agents
**76 agents total** — a **68-agent scoped library** (`agent-library/`) surfaced
*per codebase* so you only ever see the relevant few, plus **8 global** agents:
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
a `skills/clean-code-<x>/SKILL.md` (auto-discovered by the plugin). Or ask the
`starter-author` agent. Everything is TDD'd (plain-bash harness) and
shellcheck-clean.

## Test
    for t in tests/*.test.sh; do bash "$t"; done
    shellcheck bin/apply-starter.sh hooks/*.sh tests/*.sh

## License
MIT — see [LICENSE](LICENSE).
