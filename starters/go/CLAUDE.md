# Go project rules

Framework: __FRAMEWORK__ — locked. Do not introduce alternative frameworks without explicit approval.

## Build & deps
- Go modules; pin versions in go.mod, commit go.sum. `gofmt`/`goimports` on save.
- `go vet` + `golangci-lint run` clean before commit.

## Code
- Errors: return `error` as the last value; wrap with `fmt.Errorf("...: %w", err)`; check every error.
- `context.Context` is the first parameter for anything cancellable/IO.
- Small interfaces, defined at the consumer, not the producer. Accept interfaces, return structs.
- No naked returns in non-trivial funcs; greppable names; one responsibility per file.

## Tests
- Table-driven tests with `t.Run`. `go test ./...`. Cover new funcs; regression test per bug.

## Depth
- When writing or reviewing Go, use the `clean-code-go` skill. Name it explicitly.

## Commands
- Build: go build ./...   ·   Test: go test ./...
- Vet: go vet ./...   ·   Lint: golangci-lint run   ·   Format: gofmt -w .
