# Android (Kotlin/Compose) project rules

Framework: __FRAMEWORK__ — locked. Do not introduce alternative frameworks without explicit approval.

## Build & deps
- Kotlin + Jetpack Compose. Gradle (version catalogs, committed lockfile). ktlint + detekt — fix, don't suppress.

## State & architecture
- MVVM: `ViewModel` exposes immutable UI state via `StateFlow`; Composables are stateless and hoist state.
- Unidirectional data flow (events up, state down). DI with Hilt. Repository layer for data; no I/O in ViewModels' constructors.
- Coroutines + Flow for async; scope to lifecycle (`viewModelScope`); no `GlobalScope`.

## Code
- Null-safety: no `!!`. Immutable `val`/data classes by default; sealed classes/interfaces for state + events.
- Small Composables; preview-driven; no business logic in Composables.

## Tests
- JUnit + Turbine for Flows; Compose UI tests for screens. Regression test per bug.

## Commands
- Build: ./gradlew assembleDebug   ·   Test: ./gradlew test   ·   Lint: ./gradlew ktlintCheck detekt
