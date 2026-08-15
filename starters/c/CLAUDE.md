# C project rules

Framework: __FRAMEWORK__ — locked. Do not introduce alternative frameworks without explicit approval.

## Build & deps
- Standard C11. Build with CMake (out-of-source). Deps vendored or via CPM/FetchContent.
- clang-format + clang-tidy. Warnings: -Wall -Wextra -Wpedantic (-Werror in CI).

## Code
- A Debug build with ASan + UBSan; run tests under it. Check every malloc/realloc; free on every path (or document the owner).
- No VLAs; no unbounded `strcpy`/`sprintf` — use `snprintf`/`strlcpy`-style bounded calls.
- Clear ownership in comments (who allocates, who frees). Greppable names; one responsibility per file; early returns.

## Tests
- Unity or CMocka. Cover new functions; add a regression test for every bug.

## Depth
- When writing or reviewing C, use the `clean-code-c` skill. Name it explicitly.

## Commands
- Configure: cmake -B build -DCMAKE_BUILD_TYPE=Debug
- Build: cmake --build build   ·   Test: ctest --test-dir build
- Format: clang-format -i   ·   Lint: clang-tidy
