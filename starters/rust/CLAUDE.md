# Rust project rules

Framework: __FRAMEWORK__ — locked. Do not introduce alternative frameworks without explicit approval.

## Build & deps
- Edition 2021. Cargo for build/deps; pin versions in Cargo.toml, commit Cargo.lock for binaries.
- `cargo fmt` (rustfmt) and `cargo clippy -- -D warnings` — fix, don't `#[allow]`.

## Code
- Errors: return `Result<_, _>` and use `?`. Libraries define error enums (thiserror); binaries use anyhow.
- No `.unwrap()` / `.expect()` in library code; only in tests or clearly-justified startup.
- No `unsafe` without a `// SAFETY:` justification comment.
- Prefer iterators/borrows over clones; greppable names; one responsibility per module.

## Tests
- `cargo test` (unit + integration under tests/). Cover new functions; regression test per bug.

## Depth
- When writing or reviewing Rust, use the `clean-code-rust` skill. Name it explicitly.

## Commands
- Build: cargo build   ·   Test: cargo test
- Lint: cargo clippy -- -D warnings   ·   Format: cargo fmt
