# Python CLI project rules

Framework: __FRAMEWORK__ — locked. Do not introduce alternative frameworks without explicit approval.

## Build & deps
- pyproject.toml (PEP 621); pin deps; a lockfile (uv/pip-tools). Entry point via `[project.scripts]`.
- `ruff format` + `ruff check` — fix, don't suppress.

## Code
- Explicit type hints; no bare `Any`. Typer (or Click) for the CLI; keep command funcs thin, logic in importable modules.
- Exit codes matter: 0 success, non-zero on error; errors to stderr. No `print` for logging — use `logging`.
- Greppable names; one responsibility per module; early returns.

## Tests
- pytest; test the logic modules directly and the CLI via the runner. Cover new funcs; regression test per bug.

## Depth
- When writing or reviewing Python, use the `clean-code-python` skill. Name it explicitly.

## Commands
- Test: pytest -q   ·   Lint: ruff check .   ·   Format: ruff format .
