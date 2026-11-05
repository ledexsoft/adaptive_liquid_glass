# Android Native Material Expressive Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace Flutter-rendered M3 Expressive Android UI with official native Compose/Android components and set the package's Flutter floor to the latest stable release line.

**Architecture:** Keep Flutter adaptive widgets as the API and send serializable models/state through a lifecycle-safe Android PlatformView bridge to official Compose Material3 Expressive components. Use framework-native Android components for gaps; no Flutter-rendered visual fallback on Android. Preserve iOS paths.

**Tech Stack:** Flutter stable 3.47 line (3.47.9 current verified), Dart 3.13, Kotlin, Android PlatformViews, Jetpack Compose Material3 1.5.0-rc01 pending stable, Android SDK per official artifact requirements.

**Spec:** `docs/superpowers/specs/2026-11-05-android-native-material-expressive-design.md`

## Global Constraints

- Android must not instantiate Flutter M3E or Flutter Material visual substitutes for M3E components.
- Keep iOS UIKit, Cupertino, and Liquid Glass behavior.
- Use only official Android native component implementations; serialize data and events, never Flutter Widget instances.
- Keep Flutter minimum at `>=3.47.0` while 3.47 is latest stable; raise to 3.50 only after official stable release verification.
- Compose Material 3 1.5 is RC01 as of 2026-11-05; record prerelease use and refresh to stable once released.
- Set Android `minSdk 24` and `compileSdk 37` for the selected native expressive API line.
- Remove dependency and catalog exports only after the last M3E Flutter import is migrated.
- Do not change or discard unrelated workspace modifications.
- Follow repository verification policy: format/analyze/dependency resolution/Android compilation; device UI verification where available.

## Review Focus

- Multiple native PlatformViews, updates, detach/dispose, and multiple Flutter engines do not leak handlers or stale state.
- Light/dark, dynamic color, host custom scheme, accessibility labels, text scale, RTL, and system animation settings reach native components.
- Null callbacks and disabled states remain non-interactive; controlled values round-trip without feedback loops.
- Arbitrary Flutter children have explicit Android-native data replacements or clearly documented API limitations.
- iOS, macOS, web, and desktop imports remain buildable after removal of Flutter M3E symbols.

## File responsibilities

- `android/.../M3EPlatformView.kt`: platform factory, view lifecycle, properties/events.
- `android/.../M3EAndroidContent.kt`: Compose theme and component registry; split into focused files as registry grows.
- `lib/src/widgets/android/`: shared PlatformView protocol and model serializers.
- `lib/src/widgets/adaptive_*.dart`: platform dispatch and public API/native-friendly models.
- `pubspec.yaml`, `README.md`, `CHANGELOG.md`: dependency floor, coverage and migration docs.

---

### Task 1: Establish toolchain baseline and coverage inventory

**Files:** Modify `pubspec.yaml`, `android/build.gradle`, example Android Gradle files, Flutter version metadata/CI if present; create `docs/android-m3e-native-coverage.md`.

- [x] Verify latest Flutter stable tag 3.47.9 and local SDK 3.44.8; install 3.47.9 to isolated `/tmp/flutter-3.47.9` rather than changing global setup.
- [x] Package constraints already require Flutter `>=3.47.0` and Dart `^3.12.0`; record 3.50 as pending until stable.
- [x] Inventory every Flutter M3E import and the major Android wrapper groups in `docs/android-m3e-native-coverage.md`.
- [x] Existing Compose RC toolchain is AGP 9.1.1, Gradle 9.3.1, Kotlin 2.2.20, compileSdk 37; raise plugin/example minSdk to 24.
- [x] Run dependency resolution, `flutter analyze`, and an arm64 Android debug build with global Flutter 3.47.9; preserve existing local modifications.

### Task 2: Native theme and bridge protocol

**Files:** `M3EPlatformView.kt`, `M3EAndroidContent.kt`, `AdaptivePlatformUiPlugin.kt`, `lib/src/widgets/android/android_m3e_platform_view.dart`, focused new protocol files.

- [ ] Refactor generic bridge to typed component IDs, theme tokens, locale/direction, density/text scale, accessibility data, state and events.
- [ ] Ensure Compose content is lifecycle-aware, updates in-place, supports more than one view, and releases channels/compositions on disposal.
- [ ] Apply official expressive theme defaults and Android system dark/dynamic color while honoring explicit host colors.
- [ ] Verify plugin compilation and existing core controls against the new protocol.

### Task 3: Core controls and typography/motion coverage

**Files:** `adaptive_button.dart`, `adaptive_icon_button.dart`, `adaptive_button_group.dart`, `adaptive_switch.dart`, `adaptive_checkbox.dart`, `adaptive_radio.dart`, `adaptive_slider.dart`, `adaptive_progress_indicator.dart`, `adaptive_loading_indicator.dart`, native Compose control files.

- [ ] Route every Android button/control option with a Compose equivalent to native APIs, including icon/toggle/group variants and supported shapes/sizes.
- [x] Route `AdaptiveButtonGroup` through Compose `ButtonGroup` with serializable actions and native expressive toggle buttons.
- [x] Route both loading-indicator variants to official Compose `LoadingIndicator` / `ContainedLoadingIndicator`, preserving configured colors, sizing, and semantic labels.
- [ ] Preserve callbacks, controlled/uncontrolled state semantics, disabled state, range/ticks, tri-state, semantics, and progress defaults for the remaining controls.
- [ ] Replace unsupported Flutter-child configurations with native-friendly label/icon models where feasible; do not draw Flutter fallback on Android.
- [ ] Verify Dart analysis, Android compile, and manual interaction/accessibility on device/emulator when available.

### Task 4: Navigation and app structure

**Files:** `adaptive_scaffold.dart`, `adaptive_app_bar.dart`, `adaptive_bottom_navigation_bar.dart`, `adaptive_navigation_rail.dart`, `adaptive_tab_view.dart`, `adaptive_segmented_control.dart`, native Compose navigation files.

- [ ] Render Android scaffold, expressive app bars, bottom navigation/rail/drawer, tabs, and adaptive navigation with native Compose APIs.
- [x] Route generated Android app bars and bottom navigation through Compose; arbitrary scaffold body content remains Flutter-managed.
- [ ] Add serializable title/action/destination models for native Android; retain arbitrary Widget slots only on iOS/non-Android paths and document migration.
- [ ] Preserve back navigation, selected destinations, drawer state, scroll behavior, badges, and custom host colors.
- [ ] Verify Android compilation and navigation flows; inspect iOS unaffected paths.

### Task 5: Surfaces and action components

**Files:** FAB, extended FAB, FAB menu, split button, toolbar, cards, list tiles, expansion/form sections, popup/context menus, dialogs, action sheets, date/time pickers, native Compose component files.

- [ ] Replace each Android M3E Flutter route with the corresponding official Compose component or native Android component.
- [x] Route split button and toolbar through official native Compose components with serializable item/action models.
- [ ] Add native action/item/content data types where arbitrary Flutter Widget APIs cannot be represented.
- [ ] Ensure dialog, popup and sheet surfaces are hosted in the Android window/Compose overlay with correct back/outside dismissal and keyboard behavior.
- [ ] Verify Android compilation and manual selection, dismissal, keyboard, and accessibility behavior.

### Task 6: Content, input, and feedback components

**Files:** carousel, search/text fields, badge, tooltip, divider, refresh indicator, snackbar, blur view and related wrappers/native Compose files.

- [x] Route the Android carousel through official Compose hero, multi-browse, and uncontained APIs with serializable item data.
- [ ] Use official Compose components for search/text input/pull-to-refresh and native Android equivalents for the rest where expressive APIs are absent.
- [ ] Bridge text editing, focus, IME actions, validation, async refresh, loading/progress, and accessibility semantics.
- [ ] Keep unsupported custom decoration/model paths explicit and native; no Flutter visual M3E path on Android.
- [ ] Verify compilation and keyboard/refresh/semantics interaction.

### Task 7: Remove Flutter M3E dependency and close documentation gaps

**Files:** all remaining `lib/src/widgets/*.dart` imports, `pubspec.yaml`, `pubspec.lock`, `lib/adaptive_liquid_glass.dart`, README, CHANGELOG, coverage inventory.

- [ ] Remove all `material_3_expressive` imports and any Flutter M3E/Material visual Android fallback.
- [ ] Remove `material_3_expressive` dependency and catalog re-export; resolve dependencies.
- [ ] Update docs with Flutter stable floor, Android SDK/toolchain requirements, native component coverage, API migration for widget children, and Compose prerelease/stable status.
- [ ] Run formatter, `flutter analyze`, dependency resolution, Android debug build, `git diff --check`, and platform-specific compile checks.
- [ ] Perform available Android device visual/accessibility pass and confirm iOS Liquid Glass smoke behavior; report unavailable device checks explicitly.

---

## Self-review

- Spec coverage: theme, full native inventory, protocol, version policy, dependency removal, child-widget constraints, iOS preservation, and validation all have tasks.
- Dependency order: bridge precedes controls; navigation/surfaces/content can then integrate; dependency removal is last.
- Review focus is represented in protocol, component and platform validation steps.
- Scope is large, so the work is staged by Android subsystem while keeping one final dependency-removal gate.
