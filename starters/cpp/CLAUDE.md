# C++ project rules

Framework: __FRAMEWORK__ — locked. Do not introduce alternative frameworks without explicit approval.

## Build & deps
- Standard C++20. Build with CMake (presets, out-of-source).
- Dependencies via CPM.cmake (pinned versions). No system-wide installs.

## Code
- clang-format + clang-tidy — fix, don't suppress. Warnings: -Wall -Wextra -Wpedantic (-Werror in CI).
- RAII / rule-of-zero; no raw new/delete; smart pointers; const-correctness; avoid needless copies.
- Header hygiene: #pragma once, forward-declare, include-what-you-use.
- Greppable distinctive names (avoid data/handler/manager); one responsibility per translation unit; early returns.

## Sanitizers & tests
- A Debug build with ASan + UBSan; run tests under it.
- Catch2. Cover new functions; add a regression test for every bug.

## Depth
- When writing or reviewing C++, use the `clean-code-cpp` skill (ownership, noexcept/constexpr, span/string_view, error-handling). Name it explicitly.

## Commands
- Configure: cmake --preset default
- Build:     cmake --build --preset default
- Test:      ctest --preset default
- Format:    clang-format -i   ·   Lint: clang-tidy
