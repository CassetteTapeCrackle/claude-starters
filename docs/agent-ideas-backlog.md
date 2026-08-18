# Agent ideas backlog

> **STATUS 2026-08-18:** BUILT. 76 agents total — 68 in the scoped library, 8 global — live in
> `agent-library/` and is wired per stack (`starters/<stack>/agents.txt`),
> plus `common.txt` (every project) and `global.txt` (installed globally).
> This document remains as the original ideation / catalogue. Remaining
> open items are the non-agent upgrades (SessionStart hook, `--list`/`--dry-run`).

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

## Per-starter agents ⬜ (audit/enforce, scoped to a stack)
- ⭐⭐ `starter-conformance-checker` — **meta**: audits a repo against its
  *applied* starter `CLAUDE.md` and flags drift (`.unwrap()` in Rust,
  allocation in `processBlock`, `any` in strict TS, missing `ScopedNoDenormals`).
  Makes the whole system self-enforcing. Crown jewel.
- web-ts: `a11y-auditor` · `dead-code-eliminator`
- node-api: `route-schema-auditor` (every route validates in/out) · `n+1-hunter`
- electron: `electron-security-auditor` (contextIsolation/sandbox/nodeIntegration/CSP)
- tauri: `capability-auditor` (least-privilege allowlist review)
- swiftui: `swiftui-state-auditor` · `retain-cycle-hunter`
- android: `recomposition-profiler` · `coroutine-scope-auditor`
- flutter: `rebuild-profiler` · `riverpod-provider-auditor`
- python-ml: `repro-auditor` (seeds/determinism/data-leakage) · `tensor-shape-checker`
- web-audio: `worklet-safety-auditor` · audio-external: `perform-routine-auditor`
  (or generalize `rt-safety-auditor` to cover all audio callbacks)

## Creation / design agents ⬜ (generative — each MUST produce a concrete artifact, not just a persona)
Mapped to lifecycle phases (Dream → Design → Ship → Research).

**Dream / ideate:**
- ⭐ `plugin-ideator` — concrete plugin concepts (DSP idea + parameter set + the hook). Domain-tuned.
- `idea-brainstormer` — divergent concept generation (distinct from superpowers `brainstorming`, which is convergent).
- `prd-writer` — vague idea → structured PRD (params, constraints, non-goals). Feeds the audio-plugin PRD step + node-api schemas.
- `product-critic` — attacks a concept on differentiation/scope/market (harsh-reviewer for the idea, not the code).

**Design (UX/UI):**
- `ux-critic` — real heuristics (Nielsen, IA, user flows) to critique/propose a flow.
- `ui-designer` — layout, visual hierarchy, component inventory → Design-phase mockup spec.
- ⭐ `plugin-ui-designer` — audio-UI conventions (knobs, meters, spectrum, skeuo vs flat); serves the audio-plugin Design phase.
- `design-system-author` — tokens (color/type/spacing) + component set.
- NOTE: `ux-critic`/`ui-designer` overlap superpowers `frontend-design`; justify only via isolated-context subagent use.

**Ship / communicate:**
- `technical-writer` — README/docs tuned to an audience.
- `release-copywriter` — plugin-store / landing-page copy.
- `demo-script-writer` — walkthrough/video script.
- `naming-agent` — product/feature/plugin names (greppable-names ethos).

**Research:**
- `deep-researcher` / `tech-scout` — survey libraries/approaches with sources.
- `competitor-analyst` — survey existing solutions before building.

**Top picks (domain-fit + real deliverable):** `plugin-ideator`,
`plugin-ui-designer`, `prd-writer`, `deep-researcher`, `technical-writer`.
**Skip:** generic "senior-engineer"/"architect" personas — overlap the base
assistant + superpowers with no distinct artifact.

## Related system upgrades (non-agent)
- ✅ `SessionStart` detection hook (Trigger 2) — offers a starter on existing repos, opt-in, non-destructive, zero repo footprint. BUILT.
- ✅ CI (GitHub Action: suite + shellcheck). BUILT.
- ⬜ Applier ergonomics: `--list`, `--dry-run`, and an `update`/sync path (vs the current no-clobber refusal).

## Next session
Pick from ⭐ first (recommended: the three audio agents — nothing else covers
them and they enforce audio-plugin rules). Then convert ⬜ items on demand,
or point `starter-author`'s sibling pattern at them.
