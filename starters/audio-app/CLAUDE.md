# Audio app (JUCE standalone/host) project rules

Framework: __FRAMEWORK__ — locked. Do not introduce alternative frameworks without explicit approval.

## Build & deps
- C++17. CMake; pull JUCE (JUCE 9, pinned) and deps via CPM.cmake. No system-wide installs.
- clang-format + clang-tidy; -Wall -Wextra -Wpedantic (-Werror in CI); Debug build with ASan+UBSan.

## DSP is sacred
- Never modify DSP / signal-processing code unless explicitly asked to change the sound. UI/plumbing/refactor tasks leave DSP bit-for-bit identical.
- DSP isolated in `Source/dsp/`; golden-buffer regression tests (impulse, sine sweep) as a tripwire.

## Real-time audio thread (audio callback) — NON-NEGOTIABLE
- No heap allocation, no locks/mutexes (lock-free only), no file/console IO, no logging, no exceptions.
- `juce::ScopedNoDenormals` at the top of the callback. Bounded, deterministic work. Clarity beats hot-path fragmentation.

## Structure & tests
- Message-thread ↔ audio-thread separation via atomics. Audio device/IO on the message thread.
- Catch2 for DSP with signal/golden fixtures — not by spinning a device.

## Depth
- Use the `clean-code-cpp` and `clean-code-audio` skills. Name them explicitly.

## Commands
- Configure: cmake -B build -DCMAKE_BUILD_TYPE=Debug   ·   Build: cmake --build build
- Test: ctest --test-dir build   ·   Format: clang-format -i   ·   Lint: clang-tidy
