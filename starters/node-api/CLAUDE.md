# Node API project rules

Framework: __FRAMEWORK__ — locked. Do not introduce alternative frameworks without explicit approval.

## Build & deps
- Fastify + TypeScript, pnpm (committed lockfile). tsconfig `strict: true`.
- ESLint + Prettier. Validate env vars at boot (fail fast on missing config).

## Code
- Schema-first: validate request/response with JSON Schema (TypeBox) or zod; derive types from schemas.
- Structured logging with pino — no `console.log`. Never log secrets.
- Thin route handlers; business logic in services; errors mapped to proper status codes + typed error shapes.
- Async/await everywhere; every promise awaited or explicitly handled.

## Tests
- Vitest against the built app (inject/light integration). Cover handlers + services; regression test per bug.

## Depth
- When writing or reviewing TypeScript, use the `clean-code-ts` skill. Name it explicitly.

## Commands
- Dev: pnpm dev   ·   Build: pnpm build   ·   Test: pnpm test
- Lint: pnpm lint   ·   Typecheck: pnpm tsc --noEmit
