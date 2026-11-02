# Web (TypeScript) project rules

Framework: __FRAMEWORK__ — locked. Do not introduce alternative frameworks without explicit approval.

## Build & deps
- pnpm (committed pnpm-lock.yaml) and Vite+ (`vite-plus`): one `vite.config.ts` holds dev/build (Vite), lint (Oxlint, type-aware), format (Oxfmt), tests (Vitest) and the pre-commit hook. Node LTS.
- New project: `pnpm --package=vite-plus dlx vp create vite -- --template <framework>-ts`. Existing ESLint/Prettier project: `pnpm vp migrate`, then review the rules it reports as skipped.
- `pnpm vp check` must pass: fix, don't disable. tsconfig `strict: true`; no implicit `any`.

## Code
- Explicit types at module boundaries; avoid `any` (use `unknown` + narrowing). Prefer `type`/discriminated unions for state.
- Small, focused modules; pure functions where possible; greppable names; early returns.
- No default exports for shared modules (named exports grep better).

## Tests
- Vitest through `pnpm vp test`, importing from `vite-plus/test` (+ Testing Library for components). Cover new logic; regression test per bug.

## Depth
- When writing or reviewing TypeScript, use the `clean-code-ts` skill. Name it explicitly.

## Commands
- Dev: pnpm vp dev   ·   Build: pnpm vp build   ·   Test: pnpm vp test
- Check (format + lint + types): pnpm vp check   ·   Fix: pnpm vp check --fix
