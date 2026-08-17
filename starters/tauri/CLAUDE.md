# Tauri (Rust + web) project rules

Framework: __FRAMEWORK__ — locked. Do not introduce alternative frameworks without explicit approval.

## Build & deps
- Rust backend (edition 2021, clippy -D warnings, rustfmt) + TypeScript frontend (pnpm, Vite, strict tsconfig).
- Pin versions; commit Cargo.lock and pnpm-lock.yaml.

## Architecture & security
- Minimal Tauri capabilities/allowlist — grant only the commands/APIs actually used; least privilege.
- Cross the boundary through typed `#[tauri::command]`s; validate all input from the webview (treat it as untrusted). No secrets in the frontend bundle.
- Backend logic in Rust; the webview is UI. Keep IPC surface small and explicit.

## Code
- Rust errors: `Result` + `?`, thiserror/anyhow; no `.unwrap()` in commands. TS: no `any`, typed IPC wrappers.

## Tests
- `cargo test` for backend/commands; Vitest for frontend logic. Regression test per bug.

## Depth
- Use `clean-code-rust` (backend) and `clean-code-ts` (frontend). Name them explicitly.

## Commands
- Dev: pnpm tauri dev   ·   Build: pnpm tauri build   ·   Test: cargo test && pnpm test
