---
name: clean-code-python
description: Use when writing or reviewing Python — deeper idioms (type hints, dataclasses/pydantic, no mutable defaults, EAFP, pathlib, context managers, comprehensions).
---

# Clean-code Python (depth)

On top of the base rules (type hints, ruff, pytest).

## Types & data
- Explicit hints on public functions; `from __future__ import annotations` for forward refs. No bare `Any`.
- Model records with `@dataclass` (or pydantic at boundaries); avoid dicts-as-objects for structured data.

## Footguns
- Never mutable default args (`def f(x=[])`) — use `None` + assign inside.
- EAFP over LBYL: `try/except` around the operation rather than pre-checking, but keep `try` bodies small.
- No bare `except:` — catch specific exceptions; re-raise with context.

## Idioms
- `pathlib.Path` over `os.path` string surgery. Context managers (`with`) for files/locks/resources.
- Comprehensions/generators over manual accumulation loops; generators for large/streamed data.
- f-strings for formatting; `logging` not `print` for diagnostics.

## Smells
- A function taking/returning big untyped dicts → dataclass.
- `except Exception: pass` → swallows bugs.
- Manual file `open`/`close` without `with` → leak on error.
