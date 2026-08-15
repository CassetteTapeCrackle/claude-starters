---
name: clean-code-audio
description: Use when writing JUCE/audio DSP code — real-time-safety and DSP-specific idioms (parameter smoothing, block processing, branch-free loops, denormals, message↔audio-thread model). Complements clean-code-cpp.
---

# Clean-code audio / DSP (depth)

Apply on top of the audio-plugin base rules (RT-audio non-negotiables, DSP-is-sacred, golden-buffer tests, pluginval). Also use `clean-code-cpp`.

## The two-thread model
- The **audio thread** (processBlock) and the **message thread** (UI, params) never share mutable state via locks.
- Pass parameters across with `std::atomic` or a lock-free FIFO; the audio thread only *reads* smoothed snapshots.

## Parameter smoothing
- Never apply a raw parameter jump in the audio path — zipper noise. Smooth it (`juce::SmoothedValue` or a one-pole) and read per-sample or per-block.

## The inner loop
- Process in **blocks**; hoist invariants out of the per-sample loop.
- Prefer **branch-free** math in the hot loop (select/min/max over `if`); branches stall the pipeline and hurt determinism.
- Prefer `float` unless precision demands `double`. Flush **denormals** (`ScopedNoDenormals`), and design filters/feedback so denormals don't accumulate.

## Testability & sacredness
- Keep DSP as pure functions/classes over buffers in `Source/dsp/`, decoupled from JUCE UI, so it's unit-testable with signal fixtures and **golden buffers** (impulse, sine sweep).
- DSP is sacred: a golden-buffer test failing on a non-DSP change means something leaked into the algorithm — stop and fix the boundary, don't update the golden file.

## Signals it's going wrong
- Allocation/lock/log inside processBlock → move it to the message thread or preallocate.
- A parameter read directly in the loop without smoothing → audible artifacts.
- DSP logic reaching into UI/JUCE component state → break the coupling.
