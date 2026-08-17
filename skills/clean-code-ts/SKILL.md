---
name: clean-code-ts
description: Use when writing or reviewing TypeScript — deeper idioms (eliminate any, discriminated unions, narrowing, exhaustiveness, schema-derived types, async correctness).
---

# Clean-code TypeScript (depth)

On top of the base rules (strict tsconfig, ESLint+Prettier, Vitest).

## Types
- No `any`. Use `unknown` at boundaries and narrow. Prefer `type` aliases + **discriminated unions** for state over booleans/optionals.
- Model impossible states out of existence (a union, not many independent flags). Exhaustiveness-check unions with a `never` default in `switch`.
- Derive types from runtime schemas (zod/TypeBox) at IO boundaries — one source of truth, not parallel `interface` + validator.

## Correctness
- `strictNullChecks` on; handle `null`/`undefined` explicitly, no `!` non-null assertions outside tests.
- `await` every promise or handle it; no floating promises. `Promise.all` for independent async, not sequential awaits.
- Readonly by default (`readonly`, `as const`); immutable data flow.

## Style
- Named exports over default (grep + refactor friendliness). Small modules; pure functions; early returns.
- Narrow function signatures — take exactly what's used, not the whole object.

## Smells
- `any` or `as SomeType` casts → narrow or fix the type at the source.
- Booleans multiplying into impossible combinations → discriminated union.
- A validator and an `interface` that can drift → derive the type from the schema.
