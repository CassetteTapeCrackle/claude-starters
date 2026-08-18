---
name: agent-orchestration
description: Use to decide whether to delegate a task to a specialist agent, do it inline yourself, or skip — a cost/benefit policy over the project's scoped agents. Fires when a task begins that a specialist could handle, or when the orchestration hook surfaces a candidate.
---

# Agent orchestration (the dispatcher policy)

You are the orchestrator. You choose between doing work yourself and delegating to a specialist agent. Optimize for **fewer tokens and better output** — most of the time that means doing it yourself or skipping.

## Candidates come from two channels
- **Reactive** — the Stop hook surfaced a code-risk candidate (e.g. `unsafe-auditor`, `rt-safety-auditor`, `any-eliminator`) because changed code matched a risk pattern.
- **Proactive** — the *phase* of the current task maps to a specialist:
  - ideate → `plugin-ideator` / `idea-brainstormer` / `competitor-analyst`
  - spec/plan → `prd-writer` / `spec-critic`
  - research an unknown → `deep-researcher`
  - design UI → `ui-designer` / `ux-critic` / `plugin-ui-designer` / `design-system-author`
  - debug → `debugger` / `regression-hunter`
  - audit quality → the per-stack auditors + `starter-conformance-checker`
  - ship → `technical-writer` / `release-copywriter` / `demo-script-writer` / `naming-agent`

Only consider agents that actually exist for this project: the ones in `.claude/agents/` (scoped) plus the global ones. Don't invent agents.

## The decision — skip / inline / delegate
For each candidate, pick the cheapest option that gets the job done well:

- **SKIP** if the agent's concern isn't really implicated, or the change is trivial (docs, a rename, a one-line tweak). This is the most common answer. Don't dispatch to prove diligence.
- **INLINE** (do it yourself) if the surface is small and local (a few lines / one file) and you already have the context. Spinning a subagent would cost *more* than just doing it.
- **DELEGATE** only when it clearly pays: a **broad scan** (many files / a whole module), work that would **pull a lot into your context** (isolation is the payoff — the subagent's tokens stay out of your window), or a **well-scoped specialist** job whose prompt does better than you would ad hoc.

## Rules
- Bias to skip/inline. When unsure and the surface is small, inline.
- One agent at a time; don't chain speculative delegations. Delegate, read the result, then decide the next step.
- Respect the project's own rules (its `CLAUDE.md`) — e.g. don't let an agent touch DSP on a non-DSP task.
- After you've handled a surfaced candidate, don't re-evaluate the same unchanged diff.
