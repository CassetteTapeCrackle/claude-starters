# Audio plugin project rules

Framework: __FRAMEWORK__ — locked. Do not introduce alternative frameworks without explicit approval.
UI approach: <choose ONE at Design time: JUCE Components | WebView | Visage> — locked once chosen.

## Build & deps
- Standard C++17. Build with CMake; pull JUCE (JUCE 9, pinned tag) and other deps via CPM.cmake. No system-wide installs.
- Plugin formats: VST3, AU (macOS), Standalone. Use `juce_add_plugin`.
- **JUCE licensing:** free under AGPLv3 (open-source) or the Starter tier (≤ $20k/yr revenue); a paid JUCE licence is required for closed-source above that. Keep this in mind before shipping closed-source.

## DSP is sacred
- **Never modify DSP / signal-processing code (the algorithm math and its state) unless explicitly asked to change the sound.** UI, parameter-plumbing, build, and refactor tasks must leave DSP behavior bit-for-bit identical — a UI refactor on a delay must not change how the delay repeats.
- Keep DSP isolated in `Source/dsp/`, separate from UI/plumbing.
- Maintain golden-buffer regression tests (impulse, sine sweep) as a tripwire: any change to DSP output must fail CI.

## Real-time audio thread (inside processBlock / any audio callback) — NON-NEGOTIABLE
- No heap allocation (no new/delete, no vector resize, no String).
- No locks/mutexes — lock-free only (atomics, juce::AbstractFifo, SPSC FIFO).
- No file/console IO, no logging, no exceptions across the callback.
- `juce::ScopedNoDenormals` at the top of processBlock.
- Bounded, deterministic work. Clarity beats fragmentation in the hot path — a longer linear processBlock is better than adding virtual calls/indirection for "cleanliness".

## Structure, state & UI
- State via AudioProcessorValueTreeState; strict message-thread ↔ audio-thread separation (atomics for parameter passing).
- Prescribed layout: `specs/` (PRD/ideas) · `Design/` (UI mockups) · `Source/dsp/` (DSP) · `Source/` (plugin/UI).
- **Parameter spec (PRD) before implementation:** produce an explicit parameter table — name · default · range · units — during the Design phase.
- **Specify the UI/layout explicitly** in Design; unspecified UI gets scattered.

## Tests & validation
- Catch2 for DSP unit tests using signal/golden fixtures — not by spinning up a host.
- **pluginval is a required gate** (strictness ≥ 8); the build isn't "done" until it passes.

## When a JUCE/DSP gotcha is solved
- Save it to auto-memory AND append it to a project-local `TROUBLESHOOTING.md`, so it isn't re-debugged.

## Depth
- When writing C++/DSP here, use the `clean-code-cpp` and `clean-code-audio` skills. Name them explicitly.

## Commands
- Configure: cmake -B build -DCMAKE_BUILD_TYPE=Debug
- Build:     cmake --build build
- Test:      ctest --test-dir build
- Validate:  pluginval --strictness-level 8 <plugin>
- Format:    clang-format -i   ·   Lint: clang-tidy
