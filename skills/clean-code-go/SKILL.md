---
name: clean-code-go
description: Use when writing or reviewing Go — deeper idioms (error wrapping, small interfaces at the consumer, context, goroutine lifecycle, avoiding interface{}).
---

# Clean-code Go (depth)

On top of the base rules (gofmt, go vet, golangci-lint, table tests).

## Errors
- Wrap with context: `fmt.Errorf("doing X: %w", err)`; inspect with `errors.Is`/`errors.As`.
- Handle every error where it happens; don't `_ =` it away. Sentinel errors as package vars when callers must branch.

## Interfaces & types
- Define interfaces at the **consumer**, keep them 1–3 methods. Accept interfaces, return concrete structs.
- Avoid `interface{}`/`any` except at true boundaries (encoding). Prefer concrete types and generics where they fit.

## Concurrency
- Every goroutine needs a clear stop condition and owner; pass `context.Context` (first param) and honor cancellation.
- Don't leak goroutines or channels; the launcher is responsible for shutdown. Guard shared state with a mutex or a channel, not both.

## Style
- Zero-value-useful structs; constructors only when needed. Early returns; no deep nesting.

## Smells
- `interface{}` threaded through business logic → concrete types/generics.
- A goroutine with no cancellation path → a leak.
- Errors logged *and* returned at every layer → double logging; wrap and return, log once at the edge.
