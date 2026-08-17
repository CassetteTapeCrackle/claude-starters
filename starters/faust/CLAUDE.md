# Faust DSP project rules

Framework: __FRAMEWORK__ — locked. Do not introduce alternative frameworks without explicit approval.

## Build & deps
- DSP in `.dsp` (Faust). Compile with the `faust` compiler / `faust2xxx` scripts (or faustcmake) to the target(s).
- Pin the Faust version. Keep architecture files and target configs in the repo.

## Code
- Idiomatic Faust: signal-processing algebra, named definitions, no magic constants (use `declare`d metadata + labelled UI).
- Keep the DSP pure in `.dsp`; wrappers/architecture separate. Meaningful UI labels + ranges (they become plugin/app parameters).
- DSP is sacred: don't alter the algorithm unless explicitly asked; changes must be intentional and audible-reviewed.

## Tests
- Golden-output tests: render fixed inputs (impulse, sine sweep) and diff against stored references. Regression case per bug.

## Depth
- Use the `clean-code-audio` skill for real-time/DSP concepts when wrapping to native targets. Name it explicitly.

## Commands
- Build: faust2caqt / faust2jaqt / faustcmake (per target)   ·   Check: faust -svg <file>.dsp
