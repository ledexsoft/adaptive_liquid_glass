# SUPERSEDED — Complete M3 Expressive Coverage Implementation Plan

This earlier plan preserves Flutter M3E routes and is no longer the implementation target. Follow [`2026-11-05-android-native-material-expressive.md`](2026-11-05-android-native-material-expressive.md).

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox syntax for tracking.

**Goal:** Automatically cover M3 Expressive component families from Material's update in the package's adaptive API.

**Architecture:** Use Compose Material3 Expressive 1.5.0-rc01 with `MaterialExpressiveTheme` for supported native Android controls. Keep the Flutter M3E catalog for cross-platform fallbacks and complex child-widget wrappers.

**Tech Stack:** Flutter 3.47+/Dart 3.12+, `material_3_expressive` 1.1.2, Jetpack Compose Material3 1.5.0-rc01, AGP 9.1.1, Gradle 9.3.1, Kotlin 2.2.20.

**Spec:** `docs/superpowers/specs/2026-11-04-complete-m3-expressive-design.md`

## Global Constraints

- Require Flutter >=3.47.0 and Dart ^3.12.0; keep Android minSdk 21 and compile against API 37.
- Preserve current iOS Liquid Glass and Cupertino paths.
- Compose-backed controls now inherit the official `MaterialExpressiveTheme`; default loading and progress indicators also use native Compose components. Complex child-widget wrappers remain Flutter-rendered M3E where the current platform-view bridge cannot represent their widget trees.
- Do not add/run tests unless separately requested; verify with analysis and builds.

## Review Focus

- Empty/short component lists and disabled actions remain safe and keyboard-accessible.
- Fallback interactions preserve selection, callbacks, and async refresh completion.
- Custom `MaterialApp` overlays receive M3E theme only when configured.
- Widget children, colors, and theme changes propagate through wrapper rebuilds.
- Web/desktop/iOS branches do not query Android platform views or require M3E theme.

---

### Task 1: Add adaptive wrappers for updated components

**Files:** Create `adaptive_carousel.dart`, `adaptive_extended_floating_action_button.dart`, `adaptive_icon_button.dart`, `adaptive_navigation_rail.dart`, `adaptive_refresh_indicator.dart`; modify `lib/adaptive_liquid_glass.dart`.

- [ ] Implement `AdaptiveCarousel` with M3E carousel on Android and `PageView` fallback.
- [ ] Implement expressive icon button, extended FAB, and navigation rail wrappers with Flutter/Cupertino fallbacks.
- [ ] Implement adaptive refresh indicator using M3E on Android and Flutter `RefreshIndicator` elsewhere.
- [ ] Export all wrappers and format/analyze.

### Task 2: Add adaptive wrappers for new components

**Files:** Create `adaptive_button_group.dart`, `adaptive_fab_menu.dart`, `adaptive_loading_indicator.dart`, `adaptive_split_button.dart`, `adaptive_toolbar.dart`; modify `lib/adaptive_liquid_glass.dart`.

- [ ] Implement each Android M3E route using the pinned `M3E*` component.
- [ ] Provide platform-appropriate Flutter/Cupertino fallbacks, including callbacks and state mapping.
- [ ] Preserve arbitrary caller widgets and M3E typed action models where needed.
- [ ] Export all wrappers and format/analyze.

### Task 3: Align documentation and verify integration

**Files:** Modify README and CHANGELOG.

- [ ] Document the automatic component coverage and theme setup.
- [ ] Separate Compose-native controls from Flutter-rendered M3E wrappers.
- [x] `flutter analyze --no-pub`, Kotlin compilation, arm64 APK debug build, and `git diff --check` pass.
- [ ] Review the public export list and ensure no generated artifacts are staged.
