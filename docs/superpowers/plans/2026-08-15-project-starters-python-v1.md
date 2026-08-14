# Project Starters (Python v1) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a token-lean applier that, on a chosen stack+framework, writes a git-ignored project `CLAUDE.md` with the framework locked, plus the Python starter payload and an installer into `~/.claude/`.

**Architecture:** A deterministic bash script (`apply-starter.sh`) does all file work — no LLM reasoning. A thin slash command invokes it. Starter payloads are plain template files. An `install.sh` wires artifacts into `~/.claude/`. Tests are plain bash against temp dirs (zero external deps).

**Tech Stack:** Bash, git, Claude Code slash commands. No test framework dependency (a small assert lib in `tests/lib.sh`).

**Spec:** `docs/superpowers/specs/2026-08-15-project-starters-design.md`

## Global Constraints

- **Zero cost at rest.** The applier is pure shell; no per-session LLM reasoning.
- **Suggest-then-confirm.** The script only runs when explicitly invoked; it never auto-writes.
- **Footprint:** the project `CLAUDE.md` is written to repo root and hidden via `.git/info/exclude` (exact line: `/CLAUDE.md`), never a tracked `.gitignore`.
- **Framework lock line (verbatim format):** `Framework: <name> — locked. Do not introduce alternative frameworks without explicit approval.`
- **No line-count dogma** in starter rules — greppable distinctive names + one responsibility, not "functions must be 4-20 lines."
- **Never clobber** an existing `CLAUDE.md`.
- **Template token:** `__FRAMEWORK__` is the substitution point in starter `CLAUDE.md`.
- **Marker file:** `.claude/.starter-applied` (contents = stack name).

---

### Task 1: Test harness + Python starter payload

**Files:**
- Create: `tests/lib.sh`
- Create: `starters/python/CLAUDE.md`
- Create: `starters/python/manifest.json`
- Test: `tests/starter-content.test.sh`

**Interfaces:**
- Produces: `tests/lib.sh` exposing `assert_eq <expected> <actual> <msg>`, `assert_contains <haystack> <needle> <msg>`, `assert_file_exists <path> <msg>`, `assert_fail <cmd...>` (asserts nonzero exit); a `run_tests` that prints PASS/FAIL and exits nonzero on any failure.
- Produces: `starters/python/CLAUDE.md` containing the token `__FRAMEWORK__` and Python rules.

- [ ] **Step 1: Write the failing test**

```bash
# tests/starter-content.test.sh
#!/usr/bin/env bash
set -euo pipefail
DIR="$(cd "$(dirname "$0")/.." && pwd)"
source "$DIR/tests/lib.sh"

test_template_has_framework_token() {
  local f="$DIR/starters/python/CLAUDE.md"
  assert_file_exists "$f" "python CLAUDE.md template exists"
  assert_contains "$(cat "$f")" "__FRAMEWORK__" "template has framework token"
}

test_template_has_core_rules() {
  local c; c="$(cat "$DIR/starters/python/CLAUDE.md")"
  assert_contains "$c" "ruff" "mentions ruff"
  assert_contains "$c" "pytest" "mentions pytest"
  assert_contains "$c" "type hints" "requires type hints"
}

test_manifest_is_valid_json() {
  python3 -c "import json,sys; json.load(open('$DIR/starters/python/manifest.json'))"
}

run_tests
```

- [ ] **Step 2: Run test to verify it fails**

Run: `bash tests/starter-content.test.sh`
Expected: FAIL — `tests/lib.sh` and the template files do not exist yet.

- [ ] **Step 3: Write `tests/lib.sh`**

```bash
# tests/lib.sh
_TESTS_FAILED=0
assert_eq()       { [ "$1" = "$2" ] || { echo "FAIL: $3 (expected '$1', got '$2')"; _TESTS_FAILED=1; }; }
assert_contains() { case "$1" in *"$2"*) ;; *) echo "FAIL: $3 (missing '$2')"; _TESTS_FAILED=1;; esac; }
assert_file_exists() { [ -f "$1" ] || { echo "FAIL: $2 (no file $1)"; _TESTS_FAILED=1; }; }
assert_fail()     { if "$@" >/dev/null 2>&1; then echo "FAIL: expected nonzero exit: $*"; _TESTS_FAILED=1; fi; }
run_tests() {
  for fn in $(declare -F | awk '{print $3}' | grep '^test_'); do "$fn"; done
  if [ "$_TESTS_FAILED" -eq 0 ]; then echo "ALL PASS"; else echo "TESTS FAILED"; exit 1; fi
}
```

- [ ] **Step 4: Write the Python starter payload**

```markdown
<!-- starters/python/CLAUDE.md -->
# Python project rules

Framework: __FRAMEWORK__ — locked. Do not introduce alternative frameworks without explicit approval.

## Code
- Explicit type hints on all public functions; no bare `Any`.
- Format with `ruff format`; lint with `ruff check`. Fix, don't suppress.
- Greppable, distinctive names (avoid `data`, `handler`, `manager`).
- One responsibility per module; early returns over nesting.

## Tests
- `pytest`. Cover new functions and add a regression test for every bug.
- Aim for a healthy test-to-code ratio on the core logic — not a fixed
  number, and not on glue/IO you'd test with fixtures instead.

## Commands
- Test: `pytest -q`
- Lint: `ruff check .`
- Format: `ruff format .`
```

```json
{
  "stack": "python",
  "plugin": null,
  "frameworks": ["fastapi", "django", "flask", "cli", "none"],
  "commands": { "test": "pytest -q", "lint": "ruff check .", "format": "ruff format ." }
}
```

- [ ] **Step 5: Run test to verify it passes**

Run: `bash tests/starter-content.test.sh`
Expected: `ALL PASS`

- [ ] **Step 6: Commit**

```bash
git add tests/lib.sh tests/starter-content.test.sh starters/python/
git commit -m "feat: python starter payload + test harness"
```

---

### Task 2: Applier core — render template + drop marker

**Files:**
- Create: `bin/apply-starter.sh`
- Test: `tests/apply-core.test.sh`

**Interfaces:**
- Produces: `bin/apply-starter.sh` invoked as `apply-starter.sh <stack> [--framework <name>]`. Operates on `$PWD` as the project dir. Reads templates from `${CLAUDE_STARTERS_DIR:-$HOME/claude-starters/starters}`. Writes `$PWD/CLAUDE.md` with `__FRAMEWORK__` replaced by the framework (default `none`), and writes marker `$PWD/.claude/.starter-applied` containing the stack name.

- [ ] **Step 1: Write the failing test**

```bash
# tests/apply-core.test.sh
#!/usr/bin/env bash
set -euo pipefail
DIR="$(cd "$(dirname "$0")/.." && pwd)"
source "$DIR/tests/lib.sh"
export CLAUDE_STARTERS_DIR="$DIR/starters"

test_renders_framework_and_marker() {
  local tmp; tmp="$(mktemp -d)"; ( cd "$tmp"
    "$DIR/bin/apply-starter.sh" python --framework fastapi >/dev/null )
  local out; out="$(cat "$tmp/CLAUDE.md")"
  assert_contains "$out" "Framework: fastapi — locked" "framework substituted"
  case "$out" in *"__FRAMEWORK__"*) echo "FAIL: token left unsubstituted"; _TESTS_FAILED=1;; esac
  assert_eq "python" "$(cat "$tmp/.claude/.starter-applied")" "marker holds stack"
  rm -rf "$tmp"
}

test_defaults_framework_to_none() {
  local tmp; tmp="$(mktemp -d)"; ( cd "$tmp"
    "$DIR/bin/apply-starter.sh" python >/dev/null )
  assert_contains "$(cat "$tmp/CLAUDE.md")" "Framework: none — locked" "defaults to none"
  rm -rf "$tmp"
}

run_tests
```

- [ ] **Step 2: Run test to verify it fails**

Run: `bash tests/apply-core.test.sh`
Expected: FAIL — `bin/apply-starter.sh` does not exist.

- [ ] **Step 3: Write minimal `bin/apply-starter.sh`**

```bash
#!/usr/bin/env bash
set -euo pipefail
STARTERS_DIR="${CLAUDE_STARTERS_DIR:-$HOME/claude-starters/starters}"

usage() { echo "usage: apply-starter <stack> [--framework <name>]" >&2; exit 2; }

stack="${1:-}"; [ -n "$stack" ] || usage; shift
framework="none"
while [ "$#" -gt 0 ]; do
  case "$1" in
    --framework) framework="${2:-}"; [ -n "$framework" ] || usage; shift 2 ;;
    *) usage ;;
  esac
done

template="$STARTERS_DIR/$stack/CLAUDE.md"
[ -f "$template" ] || { echo "error: unknown stack '$stack' (no $template)" >&2; exit 1; }

target="$PWD/CLAUDE.md"
sed "s|__FRAMEWORK__|$framework|g" "$template" > "$target"
mkdir -p "$PWD/.claude"
printf '%s\n' "$stack" > "$PWD/.claude/.starter-applied"
echo "Applied $stack starter (framework: $framework) to $PWD"
```

Then: `chmod +x bin/apply-starter.sh`

- [ ] **Step 4: Run test to verify it passes**

Run: `bash tests/apply-core.test.sh`
Expected: `ALL PASS`

- [ ] **Step 5: Commit**

```bash
git add bin/apply-starter.sh tests/apply-core.test.sh
git commit -m "feat: apply-starter core render + marker"
```

---

### Task 3: Applier guards — clobber, git-exclude, unknown stack

**Files:**
- Modify: `bin/apply-starter.sh`
- Test: `tests/apply-guards.test.sh`

**Interfaces:**
- Consumes: `bin/apply-starter.sh` from Task 2.
- Produces: on existing `$PWD/CLAUDE.md`, exit code 3 and no overwrite; in a git repo, `/CLAUDE.md` appended once to `$(git rev-parse --git-dir)/info/exclude`; unknown stack exits nonzero.

- [ ] **Step 1: Write the failing test**

```bash
# tests/apply-guards.test.sh
#!/usr/bin/env bash
set -euo pipefail
DIR="$(cd "$(dirname "$0")/.." && pwd)"
source "$DIR/tests/lib.sh"
export CLAUDE_STARTERS_DIR="$DIR/starters"

test_does_not_clobber_existing_claudemd() {
  local tmp; tmp="$(mktemp -d)"; ( cd "$tmp"; printf 'KEEP ME\n' > CLAUDE.md )
  assert_fail bash -c "cd '$tmp' && '$DIR/bin/apply-starter.sh' python"
  assert_eq "KEEP ME" "$(cat "$tmp/CLAUDE.md")" "existing CLAUDE.md untouched"
  rm -rf "$tmp"
}

test_updates_git_exclude_once() {
  local tmp; tmp="$(mktemp -d)"; ( cd "$tmp"; git init -q
    "$DIR/bin/apply-starter.sh" python --framework flask >/dev/null
    "$DIR/bin/apply-starter.sh" python --framework flask >/dev/null 2>&1 || true )
  local n; n="$(grep -c '^/CLAUDE.md$' "$tmp/.git/info/exclude")"
  assert_eq "1" "$n" "exclude line added exactly once"
  rm -rf "$tmp"
}

test_unknown_stack_fails() {
  local tmp; tmp="$(mktemp -d)"
  assert_fail bash -c "cd '$tmp' && '$DIR/bin/apply-starter.sh' cobol"
  rm -rf "$tmp"
}

run_tests
```

- [ ] **Step 2: Run test to verify it fails**

Run: `bash tests/apply-guards.test.sh`
Expected: FAIL — no clobber guard and no exclude handling yet.

- [ ] **Step 3: Add guards to `bin/apply-starter.sh`**

Replace the `target=...`/`sed` block and append git handling:

```bash
target="$PWD/CLAUDE.md"
if [ -e "$target" ]; then
  echo "error: CLAUDE.md already exists at $target; not clobbering. Merge manually." >&2
  exit 3
fi
sed "s|__FRAMEWORK__|$framework|g" "$template" > "$target"
mkdir -p "$PWD/.claude"
printf '%s\n' "$stack" > "$PWD/.claude/.starter-applied"

if git -C "$PWD" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  gitdir="$(git -C "$PWD" rev-parse --git-dir)"
  exclude="$gitdir/info/exclude"; mkdir -p "$(dirname "$exclude")"
  grep -qxF "/CLAUDE.md" "$exclude" 2>/dev/null || printf '%s\n' "/CLAUDE.md" >> "$exclude"
fi
echo "Applied $stack starter (framework: $framework) to $PWD"
```

(Unknown-stack already exits 1 via the `[ -f "$template" ]` check from Task 2.)

- [ ] **Step 4: Run all tests to verify they pass**

Run: `bash tests/apply-core.test.sh && bash tests/apply-guards.test.sh`
Expected: `ALL PASS` for both.

- [ ] **Step 5: Commit**

```bash
git add bin/apply-starter.sh tests/apply-guards.test.sh
git commit -m "feat: apply-starter guards (clobber, git-exclude, unknown stack)"
```

---

### Task 4: Slash command + installer

**Files:**
- Create: `commands/apply-starter.md`
- Create: `install.sh`
- Test: `tests/install.test.sh`

**Interfaces:**
- Consumes: `bin/apply-starter.sh`, `starters/`.
- Produces: `install.sh` that symlinks `commands/apply-starter.md` → `$HOME/.claude/commands/apply-starter.md` and ensures the command can locate `bin/apply-starter.sh`. Honors `HOME` override for testing.

- [ ] **Step 1: Write the failing test**

```bash
# tests/install.test.sh
#!/usr/bin/env bash
set -euo pipefail
DIR="$(cd "$(dirname "$0")/.." && pwd)"
source "$DIR/tests/lib.sh"

test_install_symlinks_command() {
  local home; home="$(mktemp -d)"
  HOME="$home" bash "$DIR/install.sh" >/dev/null
  assert_file_exists "$home/.claude/commands/apply-starter.md" "command installed"
  rm -rf "$home"
}

run_tests
```

- [ ] **Step 2: Run test to verify it fails**

Run: `bash tests/install.test.sh`
Expected: FAIL — `install.sh` and `commands/apply-starter.md` do not exist.

- [ ] **Step 3: Write the command and installer**

```markdown
<!-- commands/apply-starter.md -->
---
description: Apply a language starter (git-ignored CLAUDE.md + framework lock) to the current project
argument-hint: <stack> [--framework <name>]
allowed-tools: Bash(*/claude-starters/bin/apply-starter.sh:*)
---

Run the applier for the current working directory:

!`~/claude-starters/bin/apply-starter.sh $ARGUMENTS`

Then confirm to the user what was applied and remind them the framework is now locked in the project CLAUDE.md.
```

```bash
# install.sh
#!/usr/bin/env bash
set -euo pipefail
SRC="$(cd "$(dirname "$0")" && pwd)"
DEST="$HOME/.claude"
mkdir -p "$DEST/commands"
ln -sf "$SRC/commands/apply-starter.md" "$DEST/commands/apply-starter.md"
chmod +x "$SRC/bin/apply-starter.sh"
echo "Installed apply-starter command → $DEST/commands/"
```

- [ ] **Step 4: Run test to verify it passes**

Run: `bash tests/install.test.sh`
Expected: `ALL PASS`

- [ ] **Step 5: Commit**

```bash
git add commands/apply-starter.md install.sh tests/install.test.sh
git commit -m "feat: /apply-starter command + installer"
```

---

### Task 5: Global lean layer + greenfield wiring doc

**Files:**
- Create: `global/lean-layer.md`
- Modify: `install.sh`
- Create: `README.md`
- Test: `tests/global-layer.test.sh`

**Interfaces:**
- Consumes: `install.sh` from Task 4.
- Produces: `install.sh` idempotently appends the contents of `global/lean-layer.md` to `$HOME/.claude/CLAUDE.md`, wrapped in `<!-- claude-starters:begin -->` / `<!-- claude-starters:end -->` markers; running install twice yields exactly one block.

- [ ] **Step 1: Write the failing test**

```bash
# tests/global-layer.test.sh
#!/usr/bin/env bash
set -euo pipefail
DIR="$(cd "$(dirname "$0")/.." && pwd)"
source "$DIR/tests/lib.sh"

test_appends_block_idempotently() {
  local home; home="$(mktemp -d)"; mkdir -p "$home/.claude"; printf '# existing\n' > "$home/.claude/CLAUDE.md"
  HOME="$home" bash "$DIR/install.sh" >/dev/null
  HOME="$home" bash "$DIR/install.sh" >/dev/null
  local n; n="$(grep -c 'claude-starters:begin' "$home/.claude/CLAUDE.md")"
  assert_eq "1" "$n" "block appended exactly once"
  assert_contains "$(cat "$home/.claude/CLAUDE.md")" "# existing" "original content preserved"
  rm -rf "$home"
}

run_tests
```

- [ ] **Step 2: Run test to verify it fails**

Run: `bash tests/global-layer.test.sh`
Expected: FAIL — install.sh does not touch CLAUDE.md yet.

- [ ] **Step 3: Write the global block**

```markdown
<!-- global/lean-layer.md -->
## Working with starters
- Agent-friendly clean code: greppable distinctive names, one responsibility per unit, early returns. Spirit over line-count rules.
- Human decides *what*; agent decides *how* and executes. Interrupt over-engineering.
- Tests grow with the code; add a regression test for every bug.
- New project from an empty dir: once language + framework are chosen in brainstorming, run `/apply-starter <stack> --framework <name>` before writing-plans.
```

- [ ] **Step 4: Append the idempotent block logic to `install.sh`**

Add before the final `echo`:

```bash
BLOCK_BEGIN="<!-- claude-starters:begin -->"
BLOCK_END="<!-- claude-starters:end -->"
GCLAUDE="$DEST/CLAUDE.md"; touch "$GCLAUDE"
if ! grep -qF "$BLOCK_BEGIN" "$GCLAUDE"; then
  { printf '\n%s\n' "$BLOCK_BEGIN"; cat "$SRC/global/lean-layer.md"; printf '%s\n' "$BLOCK_END"; } >> "$GCLAUDE"
fi
```

- [ ] **Step 5: Write `README.md`**

```markdown
# claude-starters

Token-lean project starters for Claude Code. On a chosen stack+framework,
`/apply-starter` writes a git-ignored project `CLAUDE.md` (framework locked)
and enables the stack's tooling.

## Install
    bash install.sh

## Use (greenfield)
After brainstorming settles on a language + framework:
    /apply-starter python --framework fastapi

## Test
    for t in tests/*.test.sh; do bash "$t"; done
```

- [ ] **Step 6: Run all tests to verify they pass**

Run: `for t in tests/*.test.sh; do bash "$t" || exit 1; done`
Expected: `ALL PASS` for each.

- [ ] **Step 7: Commit**

```bash
git add global/lean-layer.md install.sh README.md tests/global-layer.test.sh
git commit -m "feat: global lean layer + greenfield wiring + README"
```

---

## Self-Review

**Spec coverage:**
- Global lean layer → Task 5. ✓
- Starters library (CLAUDE.md + manifest) → Task 1. ✓
- Applier (render, framework fill, exclude, marker) → Tasks 2–3. ✓
- Footprint via `.git/info/exclude` → Task 3. ✓
- Framework lock line → Task 1 template + Task 2 substitution. ✓
- Error handling (clobber, unknown stack, non-git) → Task 3 (non-git: exclude block simply skipped). ✓
- Slash command + install into `~/.claude/` → Task 4. ✓
- Greenfield hook-in (brainstorming's final step) → Task 5 global block instruction. ✓
- Testing (applier in temp git repo) → Tasks 2–3. ✓
- Deferred (Trigger 2 hook, language skills, plugin-enable) → not in this plan, per spec scope. ✓

**Placeholder scan:** none — every step has runnable content.

**Type/name consistency:** `apply-starter.sh <stack> [--framework <name>]`, token `__FRAMEWORK__`, marker `.claude/.starter-applied`, exclude line `/CLAUDE.md`, block markers `claude-starters:begin/end` — used consistently across tasks.
