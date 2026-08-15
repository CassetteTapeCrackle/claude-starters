---
name: clean-code-rust
description: Use when writing or reviewing Rust — deeper idioms (ownership/borrows, error handling with thiserror/anyhow, avoiding unwrap and Rc<RefCell>, iterator style, newtypes).
---

# Clean-code Rust (depth)

On top of the base rules (edition 2021, clippy -D warnings, rustfmt, cargo test).

## Errors
- Libraries: define an error enum with `thiserror`, return `Result<_, MyError>`, propagate with `?`.
- Binaries: `anyhow::Result` + `.context("...")`. Never `.unwrap()`/`.expect()` outside tests or justified startup.

## Ownership & borrows
- Take `&T`/`&mut T` in function signatures; own only when you must. Return owned values.
- Reach for `Rc<RefCell<_>>` only when shared mutability is genuinely required — it's a smell as a default; prefer restructuring ownership or passing `&mut`.
- Newtypes (`struct UserId(u64)`) over bare primitives for meaning + type safety.

## Style
- Iterators/adapters over manual index loops; `?` over match-on-error pyramids.
- Derive (`Debug`, `Clone`, `PartialEq`) rather than hand-writing. `impl Trait` in args for flexibility.
- `clippy::pedantic` is a good aspiration; silence lints with a reason, never blanket-allow.

## Smells
- `.clone()` sprinkled to dodge the borrow checker → rethink ownership.
- `unsafe` without `// SAFETY:` → not acceptable.
- Stringly-typed IDs/states → newtype or enum.
