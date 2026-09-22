# TapToTalker (iOS)

Offline-first AAC (Augmentative and Alternative Communication) app for iPad. Tap cards to build a phrase; each tap speaks with on-device `AVSpeechSynthesizer`. Settings, custom cards, PIN, and images stay on the device.

Vocabulary and phrase flow are aligned with the web baseline at [taptotalker.netlify.app](https://taptotalker.netlify.app/), expanded for iPad (larger targets, VoiceOver/Dynamic Type, caregiver customization).

## Requirements

- macOS with Xcode 16+ (tested with Xcode 26)
- iPad Simulator or a physical iPad (iOS 17+)

## Open & run

1. Clone this repo and open **`TapToTalker.xcodeproj`** in Xcode.
2. Select the **TapToTalker** scheme.
3. Choose an **iPad** simulator (for example *iPad Pro 13-inch*) or a connected iPad.
4. Press **Run** (⌘R).

### Command line

```bash
xcodebuild \
  -project TapToTalker.xcodeproj \
  -scheme TapToTalker \
  -destination 'platform=iOS Simulator,name=iPad Pro 13-inch (M5)' \
  build
```

## What shipped in this slice

- Tap AAC board with real starter vocabulary (I want to / I feel / I need / …)
- Speak each card + Speak full phrase
- Vocabulary modes: **Simple** (5 home, ≤3 steps), **Intermediate** (full, ≤3), **Guided** (6/screen, ≤3), **Advanced** (detail cards, ≤4)
- Card modes: **Default / Custom / Edit** (custom labels, emoji, local photos)
- Caregiver settings + optional PIN gate
- Local JSON + Documents image persistence (no network)

## Card artwork — OpenMoji

Default card symbols use curated artwork from **[OpenMoji](https://openmoji.org)** ([openmoji/openmoji](https://github.com/hfg-gmuend/openmoji)), licensed under [Creative Commons Attribution-ShareAlike 4.0 International (CC BY-SA 4.0)](https://creativecommons.org/licenses/by-sa/4.0/).

Bundled credit files:

- [`TapToTalker/Resources/OpenMoji-ATTRIBUTION.txt`](TapToTalker/Resources/OpenMoji-ATTRIBUTION.txt)
- [`TapToTalker/Resources/OpenMoji-LICENSE.txt`](TapToTalker/Resources/OpenMoji-LICENSE.txt)

The app also shows a short OpenMoji credit on the caregiver onboarding screen.

## Agent skills

`.cursor/skills/` contains iOS craft, accessibility, SwiftUI Pro, code-audit, and **github-triage** skills — keep them; do not delete.

## Git workflow

Work on a **feature branch**, open a **PR**, get **approval** and green **CI** (**Build & Test**), then **merge to `main`**. Do not commit or push directly to `main`.

- Cursor rule: `.cursor/rules/feature-branch-pr.mdc`
- Admin gate setup: [`.github/BRANCH_PROTECTION.md`](.github/BRANCH_PROTECTION.md)
- CI workflow: [`.github/workflows/ci.yml`](.github/workflows/ci.yml)
