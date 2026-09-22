---
name: ios-accessibility
description: "Make iOS/SwiftUI apps accessible and inclusive. Use when building or reviewing UI to support VoiceOver, Dynamic Type, contrast, motion, and other assistive features."
metadata:
  surfaces:
    - ide
    - cloud
---

# iOS Accessibility

Guidance for shipping iOS UI that works for everyone. Accessibility is a requirement, not a finishing touch: design and verify it as you build. This skill covers VoiceOver, Dynamic Type, contrast, motion, input, and how to test each.

## When to use

- Building any user-facing view (apply the checklist as you go).
- Reviewing a PR that adds or changes UI.
- Diagnosing a reported accessibility bug (VoiceOver skips a control, text truncates, contrast fails).

Use alongside `ios-swiftui-craft` while building and `ios-code-audit` before merge.

## Guiding principle

Prefer native controls (`Button`, `Toggle`, `List`, `NavigationStack`, `Slider`, `LabeledContent`). They come with correct traits, focus order, and actions for free. Every time you replace a native control with a custom gesture-driven view, you take on responsibility for its label, value, traits, and actions.

## VoiceOver

- Every actionable element needs a clear `.accessibilityLabel`. Labels describe purpose, not appearance ("Delete", not "trash icon"). Omit the control type from the label — the trait already announces "button".
- Hide decorative visuals from VoiceOver with `.accessibilityHidden(true)` or `Image(decorative:)`.
- Combine a label + value + icon into one element with `.accessibilityElement(children: .combine)` (or `.ignore` + explicit label) so VoiceOver reads one coherent item instead of fragments.
- Set traits with `.accessibilityAddTraits` / `.accessibilityRemoveTraits` (`.isButton`, `.isHeader`, `.isSelected`, `.updatesFrequently`).
- Expose non-tap interactions as `.accessibilityAction` (including `.accessibilityAction(named:)` for custom actions and swipe-equivalents via custom actions) so gesture-only features remain reachable.
- Control reading order with `.accessibilitySortPriority` when visual order and logical order differ. Use `.accessibilityElement(children: .contain)` to group regions.
- Announce important dynamic changes with `AccessibilityNotification.Announcement(...).post(...)` (iOS 17+) or `UIAccessibility.post(notification:argument:)`.
- Mark headings with the `.isHeader` trait and use `.accessibilityRotor` for long content so users can jump between sections.

## Dynamic Type

- Use semantic text styles (`.body`, `.headline`, `.footnote`) so text scales automatically. For custom fonts, use `.custom(_:size:relativeTo:)`.
- Never disable scaling with a fixed `.font(.system(size:))` for body content. Reserve fixed sizes for truly graphical text.
- Design layouts that reflow at accessibility sizes. Use `ViewThatFits`, stack instead of truncate, and switch horizontal layouts to vertical when `@Environment(\.dynamicTypeSize)` is `.isAccessibilitySize`.
- Scale spacing and image sizes that sit next to text with `@ScaledMetric` so proportions hold at large sizes.
- Never clip text: avoid fixed heights on text containers; allow `lineLimit(nil)` or a sensible limit with wrapping.

## Contrast and color

- Meet WCAG contrast: 4.5:1 for normal text, 3:1 for large text and meaningful UI/graphical elements.
- Never encode meaning in color alone. Pair color with text, an icon, or a shape (e.g. error = red + icon + message).
- Support Increase Contrast via `@Environment(\.colorSchemeContrast)` and Smart Invert by marking images that should not invert with `.accessibilityIgnoresInvertColors()` where appropriate.
- Verify both light and dark appearances.

## Motion

- Respect Reduce Motion: read `@Environment(\.accessibilityReduceMotion)` and replace large parallax/scale/slide animations with a simple cross-fade or no animation.
- Avoid autoplaying, looping, or flashing content. Never exceed three flashes per second.

## Touch targets and input

- Interactive controls need at least a 44×44pt hit area. Expand small icons with `.frame(minWidth: 44, minHeight: 44)` or `.contentShape`.
- Ensure full keyboard and hardware support where relevant; keep a logical focus order (`@AccessibilityFocusState` to move focus deliberately, e.g. to a newly shown error).
- Don't rely on hover; provide clear focus and selection states.

## Reduce Transparency and other settings

- Honor Reduce Transparency (`@Environment(\.accessibilityReduceTransparency)`) by swapping blur/vibrancy backgrounds for solid ones.
- Support Bold Text and Button Shapes by using native controls and not fighting the system appearance.

## Testing

- Turn on VoiceOver (Settings ▸ Accessibility, or triple-click side button) and navigate the whole flow by swiping; confirm every element is reachable, labeled, and actionable in a sensible order.
- Use the Accessibility Inspector (Xcode ▸ Open Developer Tool) to run an audit, inspect elements, and step through the hierarchy.
- Test at the largest Dynamic Type / accessibility sizes and in dark mode; confirm no truncation, clipping, or overlap.
- Toggle Reduce Motion, Increase Contrast, and Reduce Transparency and verify the UI adapts.
- Add UI tests that assert on `accessibilityIdentifier`s (set identifiers for testing; they are separate from user-facing labels).

## Definition of done

- Every control has an accurate label, correct traits, and reachable actions under VoiceOver.
- Text scales cleanly to the largest accessibility size with no clipping.
- Contrast passes and no information is conveyed by color alone.
- Reduce Motion, Increase Contrast, and Reduce Transparency are respected.
- Touch targets are at least 44×44pt.
- The flow was actually exercised with VoiceOver and the Accessibility Inspector, not just reasoned about.
