# Web (TypeScript) project rules

Framework: __FRAMEWORK__ — locked. Do not introduce alternative frameworks without explicit approval.

## Build & deps
- pnpm (committed pnpm-lock.yaml). Vite for dev/build. Node LTS.
- ESLint + Prettier — fix, don't disable. tsconfig `strict: true`; no implicit `any`.

## Code
- Explicit types at module boundaries; avoid `any` (use `unknown` + narrowing). Prefer `type`/discriminated unions for state.
- Small, focused modules; pure functions where possible; greppable names; early returns.
- No default exports for shared modules (named exports grep better).

## Tests
- Vitest (+ Testing Library for components). Cover new logic; regression test per bug.

## Depth
- When writing or reviewing TypeScript, use the `clean-code-ts` skill. Name it explicitly.

## Commands
- Dev: pnpm dev   ·   Build: pnpm build   ·   Test: pnpm test
- Lint: pnpm lint   ·   Format: pnpm format   ·   Typecheck: pnpm tsc --noEmit
