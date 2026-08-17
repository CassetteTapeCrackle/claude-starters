# Electron (TypeScript) project rules

Framework: __FRAMEWORK__ — locked. Do not introduce alternative frameworks without explicit approval.

## Build & deps
- TypeScript, pnpm (committed lockfile), Vite/electron-vite. strict tsconfig. ESLint + Prettier.

## Security (non-negotiable)
- `contextIsolation: true`, `sandbox: true`, `nodeIntegration: false` in every renderer.
- Expose a minimal, typed API from a preload via `contextBridge` — never the raw `ipcRenderer` or Node built-ins to the renderer.
- Validate all IPC payloads in the main process (treat renderer input as untrusted). No remote content with Node access; set a strict CSP.

## Architecture
- Clear main / preload / renderer separation. Business logic + filesystem/OS access in main; renderer is UI. Keep the IPC surface small and explicit.

## Tests
- Vitest for main/preload logic; component tests for renderer. Regression test per bug.

## Depth
- When writing or reviewing TypeScript, use the `clean-code-ts` skill. Name it explicitly.

## Commands
- Dev: pnpm dev   ·   Build: pnpm build   ·   Test: pnpm test   ·   Lint: pnpm lint
