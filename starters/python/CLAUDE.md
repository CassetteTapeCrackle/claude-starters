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

## Depth
- When writing or reviewing Python, use the `clean-code-python` skill. Name it explicitly.

## Commands
- Test: `pytest -q`
- Lint: `ruff check .`
- Format: `ruff format .`
