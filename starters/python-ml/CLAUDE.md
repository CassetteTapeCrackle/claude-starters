# Python ML project rules

Framework: __FRAMEWORK__ — locked. Do not introduce alternative frameworks without explicit approval.

## Build & deps
- PyTorch. pyproject.toml + lockfile (uv/pip-tools); pin CUDA/torch versions. ruff format + ruff check.
- Experiment tracking is per-project (add W&B/MLflow when needed) — not baked in.

## Reproducibility (the thing that bites)
- Seed everything (python, numpy, torch) and record seeds + config with each run. Log the git SHA of the run.
- Config-driven (hydra/pydantic/argparse) — no hardcoded hyperparameters or absolute paths.
- Deterministic data splits; never leak test/val into train or fit scalers on the full set.

## Code
- Type hints; keep model/data/train/eval in separate modules (not one notebook). Notebooks strip outputs before commit.
- Vectorize; move tensors to device explicitly; no silent CPU/GPU mismatches.

## Tests & eval
- pytest for data transforms and model I/O shapes (tiny fixtures). Eval on a held-out set with fixed metrics; log them.

## Depth
- When writing or reviewing Python, use the `clean-code-python` skill. Name it explicitly.

## Commands
- Test: pytest -q   ·   Lint: ruff check .   ·   Format: ruff format .
