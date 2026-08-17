# Audio external (Max/Pd) project rules

Framework: __FRAMEWORK__ — locked (max | puredata). Do not introduce alternative frameworks without explicit approval.

## Build & deps
- C (C11) against the Max SDK or Pure Data API (per framework). CMake; SDK vendored or pinned.
- clang-format + clang-tidy; -Wall -Wextra; ASan+UBSan on a debug build.

## DSP is sacred
- Never modify DSP code unless explicitly asked to change the sound. Keep DSP in its own translation unit; golden-buffer tests (impulse, sine sweep) as a tripwire.

## Real-time: the perform/DSP routine — NON-NEGOTIABLE
- No allocation, no locks, no file/console IO, no logging inside the perform routine (runs on the audio thread).
- Allocate/free in setup/free methods, never in perform. Handle denormals. Bounded, deterministic per-block work.

## Structure & memory
- Respect the SDK object lifecycle (new/free, dsp add). Check every allocation; free on every path (document owner).
- Bounded string ops; `static` internal linkage; const-correct.

## Depth
- Use the `clean-code-c` and `clean-code-audio` skills. Name them explicitly.

## Commands
- Configure: cmake -B build -DCMAKE_BUILD_TYPE=Debug   ·   Build: cmake --build build
- Test: ctest --test-dir build   ·   Format: clang-format -i
