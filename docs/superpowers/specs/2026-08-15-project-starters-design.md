# Project Starters — Design Spec

**Date:** 2026-08-15
**Status:** Approved design → pending implementation plan
**Source repo:** `~/claude-starters/` (installs artifacts into `~/.claude/`)

## Purpose

Automate a disciplined, token-lean project setup so that whenever a new
project's language and framework are chosen, the right conventions,
rules, and tooling are put in place without the user having to remember
to configure anything by hand.

The overarching goal is **efficiency and quality in both token usage and
output**. Every design choice is measured against: does this cost tokens
at rest? (It should not.)

## Non-negotiable principles

1. **Zero cost at rest.** Detection is deterministic shell (a glob or a
   decision already made in conversation), never LLM reasoning per
   session. Deep language knowledge lives in skills, which cost only
   their one-line description in context until they fire.
2. **Suggest, then confirm.** The system never silently writes into a
   user's repo. It proposes; the user approves once.
3. **One-time authoring, incremental payoff.** The expensive part is
   writing templates/skills once. We prove the framework on **one**
   stack (Python) before adding more.

## Two activation triggers

Projects here usually begin as an **empty directory + an idea prompt**,
brainstormed into a language/framework choice. File-based detection has
nothing to detect at that point. So there are two triggers:

### Trigger 1 — Greenfield (primary): decision-driven

Empty dir + idea → brainstorming → a language **and framework** are
chosen. *That decision is the trigger.* The starter is applied as the
**final step of brainstorming**, immediately before the writing-plans
step. No file detection is involved because the choice already happened
in context; applying it is a single command invocation.

### Trigger 2 — Existing repo (secondary): `SessionStart` hook

For reopening or cloning a repo that already has files, a `SessionStart`
hook globs the working directory for markers (`pyproject.toml`,
`Cargo.toml`, `package.json`, …). If a known stack is present and no
starter has been applied yet (no marker), it injects a one-line
suggestion into context. The agent relays it; on the user's yes, the
same applier runs. The hook also reads dependencies to recover the
framework so the lock is restored.

*Scope note:* Trigger 2 (the hook) is deferred until after the
greenfield path is proven. v1 ships Trigger 1.

## Framework decision and "stick to it"

During the greenfield brainstorm, once the language is chosen the agent
proposes a framework (e.g. FastAPI vs Django vs stdlib CLI) with a
recommendation. On approval, the choice is recorded as a **hard
constraint** in the project `CLAUDE.md`:

> `Framework: FastAPI — locked. Do not introduce alternative web/HTTP
> frameworks without explicit approval.`

Because the project `CLAUDE.md` is always in context for that project,
the agent honors the lock every session. "Locked" is the default; the
user can override at any time by explicitly asking to switch, which
updates the line.

## Footprint

The starter's `CLAUDE.md` is written to the **repo root** and hidden
from git via **`.git/info/exclude`** (not a tracked `.gitignore`), so
the repository stays untouched in git's eyes. Solo-focused by design; it
does not travel with the repo.

## Components

1. **Global lean layer** — ~8 distilled lines appended to
   `~/.claude/CLAUDE.md`: agent-friendly clean-code *spirit* (greppable
   distinctive names, one responsibility per module, early returns — no
   line-count dogma), human-decides-*what* / agent-does-*how*, and a
   test-discipline mindset. One-time, tiny.

2. **Starters library** — `~/claude-starters/starters/<stack>/`, each
   containing:
   - `CLAUDE.md` — the language's clean-code rules (the file copied to a
     project's root, with the framework lock line filled in on apply).
   - `manifest.json` — declares what to enable (plugins, commands, MCP
     servers), available framework options, and the stack's test/lint
     commands.

3. **Detection hook** (Trigger 2, deferred) — a `SessionStart` shell
   script. Globs markers, checks for the applied-marker, injects a
   one-line suggestion if a known unconfigured stack is present. Does
   zero LLM work.

4. **Applier** — `/apply-starter <stack> [--framework X]` command. It:
   - copies the starter `CLAUDE.md` to the project root, filling in the
     locked framework;
   - appends that path to `.git/info/exclude`;
   - enables the stack's plugin (if any) via project-local
     `.claude/settings.local.json`;
   - drops an applied-marker so Trigger 2 stops re-suggesting.

5. **Language skills** (deferred past v1) — always-available, cheap
   skills (e.g. `clean-code-python`) carrying deeper on-demand rules.
   Not needed for v1; the project `CLAUDE.md` carries the essentials.

## Installation model

`~/claude-starters/` is the source of truth and a git repo. An install
step copies (or symlinks) artifacts into `~/.claude/`:
- `starters/` → referenced by the applier
- the applier command → `~/.claude/commands/`
- the hook → wired into `~/.claude/settings.json` (deferred)
- skills → `~/.claude/skills/` (deferred)

`~/.claude/` itself is **never** git-initialized (it holds runtime
state: caches, daemon, sessions, history).

## v1 deliverables (Python)

- `~/claude-starters/starters/python/CLAUDE.md` — type hints required;
  `ruff` + `black`; `pytest` with a test-ratio target **on the core**
  (not a dogmatic 1.5×); greppable naming; early returns; one
  responsibility per module; a `Framework: <filled at apply>` lock line.
- `~/claude-starters/starters/python/manifest.json` — no plugin for v1
  (Python needs none yet); records lint/test commands and framework
  options.
- The `/apply-starter` command (stack-agnostic; built once).
- The greenfield hook-in: brainstorming's final step calls the applier
  once language + framework are chosen.
- The global lean layer block appended to `~/.claude/CLAUDE.md`.

## Error handling

- **Not a git repo** → skip `.git/info/exclude`; still write `CLAUDE.md`.
- **`CLAUDE.md` already exists** → never clobber; offer to merge.
- **Ambiguous markers** (e.g. both `pyproject.toml` and `package.json`)
  → suggest both; user picks.
- **Unknown stack** → hook stays silent; no suggestion.

## Testing

- **Detection** is a pure function (directory listing → stack): unit
  tested with fixture directories.
- **Applier** is tested in a temporary git repo: asserts `CLAUDE.md`
  written with the framework line filled, `.git/info/exclude` updated,
  marker dropped, and an existing `CLAUDE.md` left untouched.

## Build order

1. Framework + Python starter + `/apply-starter` + greenfield hook-in +
   global lean layer. Prove on one real empty-dir project.
2. `SessionStart` detection hook (Trigger 2).
3. Additional stacks (Rust, web/Edmund-based, C++/JUCE) as cheap
   add-ons: each is a template + a manifest + an optional skill/plugin.

## Explicitly out of scope (YAGNI)

- Language skills for v1 (project `CLAUDE.md` suffices).
- The `SessionStart` hook for v1.
- Publishing `~/claude-starters/` as a marketplace (possible later).
- Framework-specific rule overlays (v1 records the lock; deeper
  per-framework rules come with the skills phase).
