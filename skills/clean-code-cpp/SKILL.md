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

## Loops & algorithms
- A loop with a non-trivial body becomes a named function or a standard algorithm (`std::ranges::find_if`, `std::lower_bound`, `std::accumulate`). Hand-written binary searches and case-folding loops are where the bugs hide.
- Visiting many results: take a callback (`for_each_permutation(s, fn)`) or return a range, instead of filling a huge `std::vector` the caller may only stream through.

## Types that carry proof
- Invariants as thin wrapper types: `NormalizedVec3` is built only through `normalize()` and converts implicitly back to `Vec3`. Callees stop re-checking, and overloads can skip work the invariant already did.
- Call-order rules as parameters: a function that needs the mutex held takes the lock (`void flush(const std::scoped_lock<std::mutex>&)`), a receipt the caller cannot fake. It also catches the unnamed-lock bug, where `std::scoped_lock{m};` unlocks on the same line.
- Strong types (`Meters`, `Seconds`) where two bare `double` parameters invite a swap; weigh the boilerplate first.

## Signals it's going wrong
- A `shared_ptr` you can't explain the sharing for → probably a `unique_ptr` + reference.
- A template with one instantiation → make it concrete.
- A `try/catch` in an inner loop → wrong layer for error handling.
- A comment saying "must hold the lock" or "call A first" → make it a parameter.
