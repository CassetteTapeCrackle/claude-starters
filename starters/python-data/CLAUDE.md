# Python data project rules

Framework: __FRAMEWORK__ — locked. Do not introduce alternative frameworks without explicit approval.

## Build & deps
- pyproject.toml; pin deps + lockfile. `ruff format` + `ruff check`.
- Notebooks: strip outputs before commit (nbstripout); keep reusable logic in .py modules, not notebooks.

## Code
- Explicit type hints. Prefer polars (or pandas) with explicit dtypes; avoid chained-index assignment.
- Determinism: set and record random seeds. No hardcoded absolute paths — config or CLI args.
- Vectorize over Python loops on frames; greppable names; one responsibility per module.

## Tests
- pytest with small fixture frames and golden outputs for transforms. Regression test per bug.

## Depth
- When writing or reviewing Python, use the `clean-code-python` skill. Name it explicitly.

## Commands
- Test: pytest -q   ·   Lint: ruff check .   ·   Format: ruff format .
