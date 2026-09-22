---
name: ios-code-audit
description: "Review and audit iOS/Swift code for correctness, safety, concurrency, performance, and style before merge. Use when reviewing a PR or self-auditing changes to Swift/SwiftUI code."
metadata:
  surfaces:
    - ide
    - cloud
---

# iOS Code Audit

A structured review pass for Swift and SwiftUI changes. Use this before opening or approving a PR, or to self-audit your own work. Read the diff first, then walk the checklist below and report concrete findings (file + line + why + suggested fix), grouped by severity: blocker, should-fix, nit.

## How to run the audit

1. Read the full diff and understand the intent of the change.
2. Build the project and run the test suite; note failures and warnings.
3. Walk each section below against the changed code and directly affected call sites.
4. Report findings by severity with actionable suggestions. Distinguish "this is a bug" from "this is a preference".

## Correctness and safety

- No force-unwraps (`!`), force casts (`as!`), or `try!` on values that can realistically be `nil`/fail. Use `guard let`, `if let`, `??`, or typed error handling.
- No force-unwrapped implicitly optional properties unless genuinely guaranteed set before use.
- Optionals are handled intentionally; empty/`nil`/zero cases are designed, not accidental.
- Error handling is real: errors are surfaced to the user or logged with context, not swallowed by empty `catch {}`.
- Array/collection access is bounds-safe (no `array[i]` without knowing `i` is valid).
- Equatable/Hashable/Comparable conformances are consistent with each other.
- Value vs reference semantics are correct: structs for value data, classes only when identity/shared mutation is needed.
- Numeric conversions and date/locale handling are correct (use `Measurement`, `Locale`, `Calendar`; avoid manual math on dates).

## Concurrency

- UI updates happen on the main actor. UI-facing types are `@MainActor` or explicitly hop to main before mutating published state.
- No data races: shared mutable state is actor-isolated or otherwise synchronized; concurrent closures don't capture non-`Sendable` mutable state.
- `async`/`await` used correctly; long work is off the main thread; results published back on main.
- Tasks handle cancellation and don't leak. Prefer `.task`/`.task(id:)` over unmanaged `Task {}` tied to view lifetime.
- Strict-concurrency warnings (if enabled) are addressed, not suppressed.

## Memory management

- No retain cycles: closures that capture `self` in stored/escaping contexts use `[weak self]` (or `[unowned self]` only when lifetime is guaranteed). Delegate properties are `weak`.
- Combine subscriptions are stored and cancelled (`store(in:)`); timers, observers, and notification tokens are invalidated/removed.
- `@StateObject` is used by the owner and `@ObservedObject` by borrowers; view models are not re-allocated on redraw.
- No large captures keeping objects alive longer than needed.

## SwiftUI-specific

- State primitive is correct (`@State`/`@Binding`/`@Observable`/`@Environment`) with a single source of truth; no duplicated/mirrored state.
- `body` is cheap: no sorting/filtering/formatting/allocation of expensive objects (e.g. `DateFormatter`) inside `body`.
- `ForEach` uses stable identifiers, not array indices, for mutable data.
- No heavy `GeometryReader` where a simpler layout works; invalidation is scoped to small subtrees.
- Deprecated APIs (`NavigationView`, global `.animation(_:)`) are not used in new code without reason.
- Views are decomposed; no unmanageably large `body`.

## Accessibility

- New/changed controls have accurate labels, correct traits, and reachable actions (see `ios-accessibility`).
- Text uses semantic styles and scales with Dynamic Type; touch targets are ≥ 44×44pt; contrast is sufficient; color is not the only signal.

## API and architecture

- Access control is minimal (`private`/`fileprivate`/`internal`) — nothing is `public`/`open` without cause.
- Business logic and side effects are out of views and are injected + testable, not reaching for singletons.
- Public types have clear, documented contracts; naming follows the Swift API Design Guidelines (clear at the call site, no redundant words).
- No dead code, commented-out blocks, or leftover debug prints/`print(...)`; logging uses the project's logger (`os.Logger`).
- New dependencies are justified and pinned; no unnecessary third-party additions.

## Performance

- No obvious O(n²) work in hot paths or per-row expensive computation in lists.
- Images are sized/downsampled appropriately; large data is paginated or lazily loaded.
- Caching (formatters, computed results) is used where recomputation is costly.

## Testing and tooling

- New logic has unit tests; changed behavior updates existing tests. Tests are deterministic (no real network/time/random without control).
- The project builds with no new warnings; linter/formatter (SwiftLint/`swift format`) passes if configured.
- Previews exist for new views and cover key states.

## Security and privacy

- No secrets, tokens, or keys committed in source or plists. Secrets come from secure storage/config.
- Sensitive data uses Keychain, not `UserDefaults`. Network calls use HTTPS/ATS; no disabled ATS without justification.
- Required `Info.plist` usage-description strings are present for accessed capabilities (camera, location, etc.), and permissions are requested with rationale.
- User input is validated; PII is logged minimally and appropriately.

## Reporting format

For each finding: `path:line — severity — what's wrong and why — suggested fix`. Lead the report with blockers, then should-fix, then nits, and end with a short overall assessment (safe to merge / changes required).
