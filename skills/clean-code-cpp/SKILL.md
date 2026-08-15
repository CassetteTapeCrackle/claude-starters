---
name: clean-code-cpp
description: Use when writing or reviewing C++ code — deeper idioms beyond the basics (ownership, noexcept/constexpr discipline, span/string_view, error-handling policy, concrete-before-abstract).
---

# Clean-code C++ (depth)

Apply on top of the project's base rules (C++20/17, CMake+CPM, clang-tidy, sanitizers, Catch2).

## Error handling
- Pick one policy per module and state it: exceptions, or `std::expected`/error codes.
- Exceptions are fine on the general/message path. **Never let exceptions cross a real-time/audio callback.**
- Exception messages carry full context (offending value + expected shape).

## Ownership & lifetime
- Prefer `std::unique_ptr` + raw *non-owning* pointers/references. Reach for `std::shared_ptr` only when ownership is genuinely shared — it is not a default.
- Make ownership legible: one owner, clear handoff. Rule of zero; let RAII types manage resources.

## const / noexcept / constexpr
- `const`-correct by default; `constexpr` what can be evaluated at compile time.
- Mark leaf functions `noexcept` when they truly can't throw (moves, swaps, small getters) — it enables optimizations and documents intent.

## Views & interfaces
- `std::span` / `std::string_view` for non-owning views; take them by value in parameters.
- Concrete before abstract: don't introduce templates, interfaces, or virtual layers until a second concrete case demands them.

## Signals it's going wrong
- A `shared_ptr` you can't explain the sharing for → probably a `unique_ptr` + reference.
- A template with one instantiation → make it concrete.
- A `try/catch` in an inner loop → wrong layer for error handling.
