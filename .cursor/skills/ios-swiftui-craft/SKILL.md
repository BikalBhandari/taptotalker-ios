---
name: ios-swiftui-craft
description: "Build polished, idiomatic SwiftUI screens and components for iOS. Use when creating or refining UI: views, layout, navigation, state wiring, animations, and design-system consistency."
metadata:
  surfaces:
    - ide
    - cloud
---

# iOS SwiftUI Craft

Guidance for producing production-quality SwiftUI UI on iOS. Use this when adding a screen, extracting a component, wiring view state, or tightening the visual polish of existing views. Prefer the platform's native idioms over custom reimplementations.

## When to use

- Creating a new screen, sheet, or reusable component.
- Restructuring a large `body` into composable pieces.
- Choosing the right state primitive (`@State`, `@Binding`, `@Observable`, `@Environment`).
- Getting layout, spacing, typography, and color to match the design system.
- Adding tasteful animation and transitions.

Pair this with `swiftui-pro` for advanced state/performance topics and `ios-accessibility` for inclusive UI. Run `ios-code-audit` before merging significant UI work.

## Project baseline

Establish these before writing view code:

- Minimum deployment target. It gates which APIs are available (`NavigationStack` needs iOS 16+, `@Observable`/Observation and `ScrollView` scroll APIs need iOS 17+, `@Entry` and many refinements need iOS 18+). Confirm the target in the Xcode project settings and don't use an API newer than it allows without an `if #available` guard.
- Swift and Xcode versions, and whether Swift Concurrency strict checking is on.
- Existing design tokens (colors in the asset catalog, a spacing scale, shared `Font` extensions). Reuse them; do not hardcode parallel values.

## Core principles

1. Keep `body` declarative and small. If a `body` exceeds roughly 40–60 lines or nests more than a few levels, extract subviews or `@ViewBuilder` computed properties. Extract a real `View` struct when the piece has its own state or is reused; use a computed `some View` for local decomposition.
2. Model state at the right level. Use `@State` for view-local value state, `@Binding` to delegate ownership to a parent, `@Observable` reference models (iOS 17+) for shared/business state, and `@Environment` for cross-cutting dependencies. Do not store derived values in `@State` when they can be computed in `body`.
3. Make views value-typed and cheap. Avoid heavy work in `body`; it can run frequently. Precompute in the model, not the view.
4. Prefer native containers and controls. `List`, `Form`, `NavigationStack`, `TabView`, `LabeledContent`, `ControlGroup`. They bring free accessibility, keyboard, and platform behavior.
5. One source of truth per piece of state. Never mirror the same data in two `@State`s that can drift.

## Layout

- Compose with `VStack`/`HStack`/`ZStack` plus `Spacer`, `padding`, and `frame`. Reach for `Grid` (iOS 16+) for true 2D alignment and `ViewThatFits` for adaptive layouts.
- Use `alignment` and custom `alignmentGuide`s instead of magic padding to line elements up.
- Respect the safe area; use `.safeAreaInset` for bars/toolbars rather than manual insets. Only use `.ignoresSafeArea` for intentional full-bleed backgrounds.
- Size with intent: use `.frame(maxWidth: .infinity)` to fill, `.fixedSize` to prevent truncation, and `.layoutPriority` to resolve competition. Avoid hardcoding widths that break with Dynamic Type or narrow devices.
- Support all size classes and orientations you ship. Test iPhone SE width and the largest Pro Max, plus landscape if enabled.

## Navigation

- Use `NavigationStack` with a value-based `navigationDestination(for:)` and, for programmatic control, a bound `path`. Avoid deprecated `NavigationView` in new code.
- Present modals with `.sheet`, `.fullScreenCover`, `.popover`, `.alert`, and `.confirmationDialog` bound to state (`item:` or `isPresented:`). Drive presentation from the model, not from imperative calls.
- Keep navigation state in a model you can test and restore, not scattered across views.

## Typography, color, and spacing

- Prefer semantic `Font.TextStyle` (`.body`, `.headline`, `.title`) so text scales with Dynamic Type. If a custom font is required, register it and use `.custom(_:size:relativeTo:)` so it still scales.
- Use semantic and asset-catalog colors (`Color.primary`, `Color(.systemBackground)`, named colors) so light/dark and high-contrast modes work automatically. Never hardcode hex that ignores appearance.
- Pull spacing from a shared scale. Consistent 4/8-point rhythm reads as polished; ad hoc values read as sloppy.

## Animation and transitions

- Animate state, not views: change a value inside `withAnimation` or attach `.animation(_:value:)` scoped to a specific value. Avoid the global implicit `.animation(_:)` modifier (deprecated behavior).
- Prefer springs (`.snappy`, `.smooth`, `.bouncy` on iOS 17+, or `.spring(...)`) for natural motion. Keep durations short (150–350ms) for UI feedback.
- Use `matchedGeometryEffect` for shared-element transitions and `.transition` with `.combined(with:)` for insert/remove. Give animated collections stable `id`s.
- Respect Reduce Motion (see `ios-accessibility`): gate large motion behind `@Environment(\.accessibilityReduceMotion)`.

## Images and assets

- Use `Image(systemName:)` SF Symbols for iconography; configure with `.symbolRenderingMode`, `.font`, and `.imageScale`. Use `.symbolEffect` (iOS 17+) for lively state changes.
- Load remote images with `AsyncImage`, always providing a placeholder and a failure state.
- Mark decorative images accessibility-hidden and give meaningful images a label.

## Data-driven lists

- Give `ForEach` a stable `Identifiable` id; never use array indices for mutable collections.
- Add swipe actions, context menus, and pull-to-refresh (`.refreshable`) via native modifiers.
- For large data sets use `LazyVStack`/`LazyHStack` inside a `ScrollView`, or `List`, so rows are created lazily.

## Previews

- Add SwiftUI previews for every new view. Cover meaningful states: empty, loaded, error, long text, and dark mode.
- Exercise Dynamic Type in previews with `.dynamicTypeSize(.accessibility3)` or a preview modifier to catch truncation and clipping early.
- Keep preview data in a dedicated fixture/factory so previews stay fast and deterministic.

## Definition of done

- `body`s are small and composed; no giant monolithic views.
- State uses the correct primitive with a single source of truth.
- Layout holds up at the smallest and largest supported widths and at large Dynamic Type sizes.
- Colors and fonts are semantic; light/dark both look correct.
- Animations are value-scoped and respect Reduce Motion.
- Previews cover the important states.
- The view passes an `ios-accessibility` pass and an `ios-code-audit` review.
