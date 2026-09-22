---
name: swiftui-pro
description: "Advanced SwiftUI architecture, state, concurrency, and performance. Use for non-trivial state management, data flow, rendering performance, and testable app structure."
metadata:
  surfaces:
    - ide
    - cloud
---

# SwiftUI Pro

Advanced guidance for SwiftUI beyond basic layout. Use this when state and data flow get complex, when views re-render too often, when integrating async work or UIKit, or when structuring an app to be testable and maintainable. Pair with `ios-swiftui-craft` for view construction and `ios-code-audit` before merge.

## State and observation

- Prefer the Observation framework (iOS 17+): annotate model classes with `@Observable`, hold them with `@State` in the owning view, and pass them down as plain `let` properties or via `@Environment`. Views automatically depend only on the fields they actually read, which minimizes invalidation.
- Use `@Bindable` to derive bindings from an `@Observable` model (`$model.field`).
- On pre-iOS-17 targets use `ObservableObject` + `@Published` with `@StateObject` (owner) and `@ObservedObject` (borrower). Do not create an `@StateObject` you don't own, and never allocate view models in `@ObservedObject` (it re-creates on redraw) — use `@StateObject` or inject.
- Choose the primitive deliberately:
  - `@State`: view-owned value or (with Observation) owned reference model.
  - `@Binding`: two-way delegation of state owned elsewhere.
  - `@Environment`: dependency injection down the tree (services, theme, dismiss, scene phase).
  - `@AppStorage`/`@SceneStorage`: small persisted/restored values.
- Keep a single source of truth. Derive, don't duplicate. Compute derived data in the model or in `body`, not in mirrored `@State`.

## Architecture and data flow

- Separate concerns: keep networking, persistence, and business rules out of views. Views render state and send intents to a model.
- Inject dependencies through initializers or `@Environment`, not global singletons, so code is testable and previewable. Define an environment key for each injected service.
- Model navigation as state (a `NavigationPath` or an enum-based route) held in an observable coordinator/router so deep links, restoration, and tests are straightforward.
- Represent screen state as data — ideally an enum (`.loading`, `.loaded(Model)`, `.empty`, `.failed(Error)`) — so the view is a pure function of state and every state is designed on purpose.
- Keep models framework-light and unit-testable; keep SwiftUI types at the edges.

## Concurrency

- Drive async work with `.task` (auto-cancels when the view disappears) and `.task(id:)` to restart when inputs change. Prefer this over `onAppear` + manual `Task`.
- Annotate UI-facing models with `@MainActor` so published mutations happen on the main actor. Do heavy work in detached/background contexts and hop back to the main actor to publish results.
- Always handle cancellation: check `Task.isCancelled` / allow `CancellationError` to propagate in long loops.
- Adopt strict concurrency incrementally: make shared model types `Sendable` where crossing actors, and avoid capturing non-`Sendable` state in concurrent closures.
- Use `AsyncStream`/`AsyncSequence` for streams of updates; bridge Combine only where it already exists.

## Performance

- Understand invalidation: a view recomputes when a value it reads changes. Reduce the surface by reading only what you need (Observation helps) and by splitting large views so a change invalidates a small subtree.
- Make `body` cheap. No sorting, filtering, formatting, or allocation of expensive objects inside `body`; precompute in the model and cache (e.g. a stored formatter, not a new `DateFormatter` per render).
- Use `Equatable` views or `.equatable()` for expensive subviews whose inputs rarely change, so SwiftUI can skip re-rendering.
- Lazy-load large collections with `LazyVStack`/`LazyHStack`/`List`; give `ForEach` stable identifiers to preserve state and animations.
- Prefer `.drawingGroup()` for expensive vector/shape composition and be deliberate with `.background`/`.overlay` layering. Avoid unnecessary `GeometryReader` (it can force layout passes and greedy sizing) — scope it tightly.
- Profile, don't guess: use Instruments (Time Profiler, SwiftUI/`View Body` template, Hangs) and Xcode's `Self._printChanges()` in debug to see what triggered a re-render.

## Reusable components and view modifiers

- Extract cross-cutting styling into `ViewModifier`s and expose them as `View` extensions for a fluent, testable API.
- Use `ButtonStyle`, `LabelStyle`, `ToggleStyle`, and other style protocols to theme controls consistently instead of wrapping them.
- Use `PreferenceKey` to pass data up the tree (e.g. measuring child size for a parent) and the environment to pass data down. Prefer these over bindings threaded through many layers.
- Build a small design-system layer (tokens + styles + primitives) so screens compose from consistent parts.

## UIKit / AppKit interop

- Bridge with `UIViewRepresentable`/`UIViewControllerRepresentable`. Keep the SwiftUI-owned state authoritative; use the `Coordinator` for delegate callbacks and `updateUIView` for syncing.
- Avoid two-way sync loops: update UIKit only when SwiftUI state actually changed, and feed UIKit events back through bindings/closures.

## Persistence and data

- For local data use SwiftData (`@Model`, `@Query`) on iOS 17+ or Core Data with the appropriate wrappers; keep the store injected for testing.
- Keep persistence operations off the main actor for large writes and observe results back on the main actor.

## Testing

- Unit-test models and reducers as plain Swift with injected fakes — no UI needed. Assert that intents produce the expected state transitions.
- Use snapshot or UI tests for critical screens; assert via `accessibilityIdentifier`s.
- Keep previews as a fast feedback loop for each state enum case.

## Definition of done

- State uses Observation (or the correct legacy primitive) with one source of truth.
- View bodies are cheap and invalidation is scoped to small subtrees.
- Async work uses `.task`/`@MainActor`, handles cancellation, and compiles clean under strict concurrency where enabled.
- Business logic is injected and unit-tested independent of the UI.
- Navigation and screen state are modeled as data.
- Performance was validated with Instruments or `Self._printChanges()` when re-renders were a concern.
