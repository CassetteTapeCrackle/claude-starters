# SwiftUI (iOS/macOS) project rules

Framework: __FRAMEWORK__ — locked. Do not introduce alternative frameworks without explicit approval.

## Build & deps
- Swift + SwiftUI, targeting iOS 17+/macOS 14+. SwiftPM for deps. SwiftLint + swift-format — fix, don't disable.

## State & architecture
- Use the Observation framework (`@Observable`, `@State`, `@Bindable`); avoid legacy `ObservableObject`/`@Published` in new code.
- Light MVVM: views are declarative and dumb; logic in observable models. No business logic in view bodies.
- Value types (struct/enum) by default; reference types only when identity/shared state is required.

## Code
- `async/await` for concurrency; mark UI-touching code `@MainActor`. Structured concurrency (task groups), no detached tasks without reason.
- Safe optionals (`guard let`, no force-unwrap `!` outside tests). Greppable names; small views; extract subviews over giant bodies.

## Tests
- swift-testing (or XCTest) for models/logic; snapshot/UI tests where they earn it. Regression test per bug.

## Commands
- Build: xcodebuild build   ·   Test: xcodebuild test   ·   Lint: swiftlint   ·   Format: swift-format -i
