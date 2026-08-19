# Contributing

Thanks for looking. The most useful contribution is **a new starter** — the bar is
deliberately low, and the tests will tell you if you've met it.

## Ground rules

- Everything is TDD'd with a plain-bash harness. No framework, no dependencies.
- `shellcheck` must be clean.
- Starters are **lean on purpose**. A starter that restates general good practice
  is worse than no starter — it spends context the agent needs for your code.
  Write the handful of rules that are specific to *this* stack.

## Adding a starter

1. Create `starters/<stack>/`:
   - `CLAUDE.md` — the rules. Use `__FRAMEWORK__` wherever the framework name
     belongs; it is substituted at apply time.
   - `manifest.json` — `stack`, `frameworks` (list, include `"none"`), `skill`,
     and the `commands` map (`build` / `test` / `lint` / `format`).
   - `agents.txt` *(optional)* — one agent name per line, drawn from
     `agent-library/`. These are activated on top of `agent-library/common.txt`.
2. Add a content test at `tests/<stack>-content.test.sh` asserting the rules you
   care about actually render. Copy `tests/cpp-content.test.sh` as a model.
3. Optionally add `skills/clean-code-<stack>/SKILL.md` for depth guidance. It is
   auto-discovered — no registration needed.

The `starter-author` agent will scaffold all of this for you if you'd rather
describe the stack than write the files.

## Adding an agent

Drop a markdown file in `agent-library/`. Add it to a starter's `agents.txt` to
have it activated for that stack, or to `agent-library/common.txt` to activate it
everywhere. Keep the frontmatter `description` specific — it's what determines
whether the agent is ever selected.

## Running the tests

    for t in tests/*.test.sh; do bash "$t"; done
    shellcheck bin/apply-starter.sh hooks/*.sh tests/*.sh

CI runs exactly this on Linux. If it passes locally on macOS it will almost
always pass there too; the one portability trap is that the content tests
require `python3`.

## Pull requests

Small and focused beats large and sweeping. Explain what the starter is for and
why the rules you chose are the ones that matter for that stack.
