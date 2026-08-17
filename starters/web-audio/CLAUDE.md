# Web Audio (AudioWorklet + WASM) project rules

Framework: __FRAMEWORK__ — locked. Do not introduce alternative frameworks without explicit approval.

## Build & deps
- TypeScript front (pnpm, Vite, strict tsconfig). DSP authored in C++ compiled to WASM via Emscripten.
- ESLint + Prettier for TS; clang-format for the C++ DSP.

## DSP is sacred
- Never modify DSP code unless explicitly asked to change the sound. Keep DSP in its own C++ module; golden-buffer tests (impulse, sine sweep) as a tripwire.

## Real-time: the AudioWorklet process() — NON-NEGOTIABLE
- No allocation, no locks, no logging, no exceptions inside `process()` (runs on the audio render thread).
- Cross the main↔audio boundary with a lock-free ring buffer / SharedArrayBuffer; parameters via AudioParam or atomics.
- Preallocate WASM memory; never grow the heap in the audio callback. Flush denormals.

## Structure & tests
- C++ DSP unit-tested natively with Catch2 + signal fixtures (fast); TS glue tested with Vitest.
- Keep the WASM boundary thin: pointers + lengths, no per-sample JS↔WASM calls.

## Depth
- Use `clean-code-cpp` and `clean-code-audio` (DSP) and `clean-code-ts` (glue). Name them explicitly.

## Commands
- Dev: pnpm dev   ·   Build: pnpm build (invokes emcc)   ·   Test: pnpm test && ctest --test-dir dsp/build
