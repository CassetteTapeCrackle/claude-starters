# Agent ideas backlog

Candidate agents for the `claude-starters` system, captured for a later
session. Build them the same way as existing agents: `agents/<name>.md`
(frontmatter `name` + trigger `description` + `tools` + body), symlinked
into `~/.claude/agents/` by `install.sh`, with a content/install test.

**Status legend:** ✅ built · ⭐ proposed next batch · ⬜ backlog

## Design principles (why these and not "system-architect")
- Agents earn a slot only when **narrow and verb-y** — a bounded, repeatable,
  specialized job. Not generic "architect/engineer" scaffolds (those overlap
  feature-dev, superpowers, code-review and add noise).
- Best agents **enforce a starter's rules** automatically (e.g. RT-safety,
  DSP-sacred) — they compound the starter work.
- Don't duplicate existing tools: `/code-review`, feature-dev's
  `code-reviewer`/`code-explorer`/`code-architect`, and `harsh-reviewer`
  already exist. New review agents must be *specialized*, not general.
- **Interactive** superpowers workflows (brainstorming, writing-plans,
  finishing-a-branch) make **bad** autonomous agents — they need the human
  loop. Only the analysis/execution skills convert cleanly.

## Already built ✅
- `starter-author` — scaffold a new starter following the repo pattern.
- `dep-auditor` — dependency hygiene (pinning, lockfiles, advisories) across ecosystems.
- `harsh-reviewer` — already an available agent type (no need to rebuild).

## Proposed next batch ⭐ (tight, non-overlapping, spans the user's stack)
- ⭐ `rt-safety-auditor` — scan `processBlock`/audio callbacks for allocations, locks, logging, exceptions. Enforces the audio-plugin RT non-negotiables.
- ⭐ `dsp-golden-test-author` — generate impulse/sine-sweep golden-buffer tests for a DSP module. Makes "DSP is sacred" a tripwire.
- ⭐ `pluginval-runner` — build + run pluginval at strictness, triage failures. Automates the required gate.
- ⭐ `debugger` — systematic-debugging as an autonomous agent (reproduce → isolate → hypothesis → fix on a failing test).
- ⭐ `regression-hunter` — `git bisect` + systematic-debugging to pin the breaking commit.
- ⭐ `template-error-decoder` — turn a 400-line C++ template error into the real root cause.

## Language-specific backlog ⬜
**Audio (highest personal value):**
- `preset-roundtrip-tester` — get/setStateInformation symmetry.
- `latency-reporter` — plugin delay compensation (PDC) correctness.
- `parameter-smoothing-auditor` — raw parameter reads in the audio path.

**Rust:**
- `unsafe-auditor` — reviews `unsafe` blocks + `// SAFETY:` coverage.
- `lifetime-untangler` — resolve borrow-checker fights by restructuring ownership.
- `async-runtime-auditor` — blocking calls inside `async`, missing `.await`.
- `clippy-fixer`.

**Go:**
- `goroutine-leak-hunter` — goroutines with no cancellation path.
- `race-triage` — interpret `-race` output → root cause.
- `err-wrap-checker` · `context-propagation-checker`.

**Python:**
- `type-hint-adder` / `mypy-strictener` — tighten hints toward `--strict`.
- `async-blocking-auditor` — sync IO inside async paths.
- `notebook-to-module` — refactor notebook code into tested modules.
- `import-cycle-breaker`.

**C / C++:**
- `raii-converter` — raw `new`/`delete` → smart pointers.
- `asan-triage` — interpret sanitizer output → root cause.
- `const-correctness-agent` · `header-dependency-pruner` (IWYU) · `cmake-modernizer` · `ownership-mapper`.

**TypeScript / JS:**
- `any-eliminator` — raise type coverage.
- `tsconfig-strict-migrator` — enable `strict` incrementally.
- `react-hook-deps-auditor` — exhaustive-deps.
- `bundle-analyzer` · `a11y-auditor` · `dead-code-eliminator` · `zod-schema-generator`.

**Swift:**
- `swiftui-state-auditor` — @State/@Binding/@Observable misuse.
- `sendable-concurrency-checker` · `optionals-safety-auditor`.

**Kotlin:** `coroutine-scope-auditor` · `null-safety-agent`.

**SQL / DB:** `n+1-hunter` · `index-advisor` · `query-optimizer` · `migration-writer`.

**Shell:** `posix-portability-checker` (bashisms) · `quoting-auditor`.

**Infra:** `dockerfile-hardener` · `terraform-plan-reviewer`.

## Cross-language ⬜ (not language-specific, high leverage)
- `perf-profiler` — language-aware profiling (cargo-flamegraph / pprof / py-spy).
- `migration-agent` — framework/dependency major upgrades.
- `test-author` — write tests matching the project's existing conventions.
- `spec-critic` — attack a spec/plan for gaps before building (brainstorming self-review as an agent; complements harsh-reviewer, scoped to specs).

## Next session
Pick from ⭐ first (recommended: the three audio agents — nothing else covers
them and they enforce audio-plugin rules). Then convert ⬜ items on demand,
or point `starter-author`'s sibling pattern at them.
