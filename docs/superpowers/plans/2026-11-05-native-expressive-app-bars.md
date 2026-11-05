# Native Material 3 Expressive App Bars Implementation Plan

> **For agentic workers:** This work is implemented inline by the primary agent using the existing package patterns.

**Goal:** Make Android `AdaptiveAppBar` cover the M3 Expressive app bar variants, layout, scrolling, search, and accessibility behaviors with native Compose components.

**Architecture:** Keep the Flutter API serializable and platform-neutral, and render it in the package's Android Compose host. Observe Flutter scroll notifications at the scaffold boundary and forward scroll state into Compose, where Material3's native app bar and search components own layout, motion, states, and semantics.

**Tech Stack:** Flutter/Dart, Android Platform Views, Kotlin, Jetpack Compose Material3 Expressive 1.5.0-rc01.

**Spec:** https://m3.material.io/components/app-bars/overview, /specs, /guidelines, /accessibility

## Global Constraints

- Preserve existing iOS Liquid Glass and Cupertino app bar behavior.
- Keep the app bar fully native on Android; do not draw its visual controls in Flutter.
- Use the existing Material3 Expressive Compose dependency and Flutter 3.47 package floor.
- Preserve source compatibility for callers that use the existing `AdaptiveAppBar` constructor.

## Review Focus

- Scroll notifications from nested or horizontal scrollables must not collapse the app bar.
- A search query must update Flutter state and dismiss/submit through native Compose search UI.
- Long titles and subtitles must wrap only for flexible variants and remain accessible.
- Filled/tonal emphasis must be limited to one primary trailing action.
- The first keyboard focus target must be the leading action, with native Tab/Space/Enter behavior.

---

### Task 1: Public configuration and Flutter bridge

**Files:** `lib/src/widgets/adaptive_app_bar.dart`, `lib/src/widgets/adaptive_app_bar_action.dart`, `lib/src/widgets/adaptive_scaffold.dart`, `lib/src/widgets/android/android_m3e_platform_view.dart`, package exports.

- [ ] Add variant, text alignment, scroll behavior, image/logo, search callbacks, and action emphasis configuration with backwards-compatible defaults.
- [ ] Serialize icons, labels, variant, optional image bytes, search settings, action style, and scroll state to Android.
- [ ] Observe vertical depth-zero body scroll notifications and update only the native app bar state.
- [ ] Preserve iOS paths and custom Android `AppBar` override.

### Task 2: Native Compose app bar variants and search

**Files:** `android/src/main/kotlin/com/ledexsoft/adaptive_liquid_glass/M3EAndroidContent.kt`.

- [ ] Render native small, centered small, medium flexible, and large flexible Material3 app bars at their official default heights.
- [ ] Render official `AppBarWithSearch` and expanded native search view, forwarding query and submission events.
- [ ] Add native image/logo slots and at most one filled/tonal/wide primary action.
- [ ] Apply surface/on-surface roles and native scrolled state without elevation shadows.
- [ ] Ensure RTL mirroring, semantic title/action descriptions, focus indicator, Tab navigation, and first focus on the leading button.

### Task 3: Documentation, verification, and release

**Files:** `README.md`, Android coverage docs, `CHANGELOG.md`, `pubspec.yaml`.

- [ ] Document the public API, Android-only expressive behavior, default dimensions, search event contract, and Flutter scroll bridge limits.
- [ ] Run formatting, static analysis, and Android assemble for the plugin/example.
- [ ] Review the final diff and repository status; commit and push the release/tag to origin.
