## Working with starters
- Agent-friendly clean code: greppable distinctive names, one responsibility per unit, early returns. Spirit over line-count rules.
- Human decides *what*; agent decides *how* and executes. Interrupt over-engineering.
- Tests grow with the code; add a regression test for every bug.
- New project from an empty dir: once language + framework are chosen in brainstorming, run `/apply-starter <stack> --framework <name>` before writing-plans.
- Multi-language repo: apply per-subtree with `/apply-starter <stack> --path <subdir>`.
- Agent orchestration: at a task's start (or when the Stop hook surfaces a candidate), check if its phase maps to a specialist agent, then apply the `agent-orchestration` skill to decide skip / inline / delegate. Bias to inline; delegate only when isolation pays.
