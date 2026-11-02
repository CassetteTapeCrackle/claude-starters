---
name: clean-code-core
description: Use when writing or reviewing code in any language. Language-agnostic shape rules (naming, function shape, types, comments, errors) that the clean-code-<lang> skills build on. How much to build is a separate call (ponytail, if installed); this is how to shape what gets built.
---

# Clean code, core (any language)

The per-language `clean-code-*` skills add idioms on top. Scope decides how much to build; this decides its shape.

## Names
- Say what it is, in the domain's words: `unpaid_invoices`, not `data2` or `list`.
- Greppable and distinctive: a reader (or agent) finds every use with one search. Avoid `handle`, `process`, `manager`, `util` as whole names.
- Booleans read as questions: `is_ready`, `has_lock`. Functions are verbs, values are nouns.
- Length tracks scope: `i` in a 3-line loop, a full name at module level.
- Maps read `<values>_by_<key>`: `assets_by_name`, `users_by_id`.

## Functions
- One job. If the honest name needs "and", split it.
- One level of abstraction per body. Section comments inside a function ("find the asset", "check its type") are the tell: each section becomes a call.
- Early returns for guards and errors; keep the happy path flat and last.
- Honest signatures: everything a function reads or changes arrives through its parameters. Mutating an argument is fine when the signature says so (`sort(items)`).
- Push I/O, clocks, randomness and globals to the top of the call tree and pass them down (the RNG, `now`, the file handle). The core stays testable and reproducible; one hidden global makes every caller depend on it too.
- Ask for the least you need: the field, not the whole object; a view or iterable, not one specific container.
- A boolean flag parameter that switches behavior is two functions. Many arguments of one type, or bare `true`/`false` at call sites: pass a named options struct.
- Framework callbacks (`main`, `update`, `processBlock`, request handlers) stay thin: unpack the framework's arguments, then call your own testable functions.
- Write top-down: call the function you wish existed, finish the current thought, then write it.
- Extract a block that deserves its own name or its own test, even if it runs once.

## Types
- A property checked in many places (normalized, non-empty, validated) becomes a type that can only be built valid. Check once at construction; callees trust the type.
- Data kept consistent by hand across several functions (lowercase the key, then binary-search, in every method) becomes its own type with its own operations.

## Comments
- Explain why (a constraint, a tradeoff, a bug it avoids). The code already says what.
- A comment that restates the code, or is out of date, is deleted.
- Commented-out code is deleted. Git remembers.

## Errors
- Fail loudly at the boundary where the bad input enters; trust validated data inside.
- Never swallow an error silently. Handle it, or pass it up with context.
- Return a result the caller can act on (found, wrong type, missing); exit the process only at the top level.

## Smells
- Same 3+ lines in three places: extract. Twice: usually leave it.
- Nesting deeper than 3 levels: invert a condition or extract.
- A loop with a non-trivial body: extract it, or use the library's algorithm.
- A name you had to explain in chat: rename it.
