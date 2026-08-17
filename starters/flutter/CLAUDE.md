# Flutter (Dart) project rules

Framework: __FRAMEWORK__ — locked. Do not introduce alternative frameworks without explicit approval.

## Build & deps
- Dart + Flutter (stable channel). Pin deps; commit pubspec.lock. `dart format` + `flutter analyze` (with `flutter_lints`) — fix, don't ignore.

## State & architecture
- Riverpod for state/DI. Immutable state (freezed/data classes); unidirectional flow. Keep widgets dumb; logic in providers/notifiers.
- No business logic in `build()`; extract widgets over deeply nested trees. `const` constructors wherever possible.

## Code
- Null-safety on; avoid `!` and `late` unless justified. Async with `Future`/`Stream`; handle errors + loading states explicitly.
- Greppable names; one responsibility per file.

## Tests
- Unit tests for notifiers/logic; widget tests for screens; golden tests where visual regressions matter. Regression test per bug.

## Commands
- Run: flutter run   ·   Test: flutter test   ·   Analyze: flutter analyze   ·   Format: dart format .
