# SUPERSEDED — Native Android Material 3 Expressive Implementation Plan

This earlier plan preserves Flutter fallbacks and stable Material 3 1.4. Follow [`2026-11-05-android-native-material-expressive.md`](2026-11-05-android-native-material-expressive.md) for native-only Android M3E.

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox syntax for tracking.

**Goal:** Render supported Android adaptive widgets with native Jetpack Compose Material 3 Expressive while retaining Flutter fallbacks and existing Dart APIs.

**Architecture:** Register one generic Android PlatformView backed by `ComposeView`, render typed M3E composables from a stable component/property protocol, and use per-view method channels for property updates and callbacks. Dart wrappers select the native view only for serializable supported configurations; existing Flutter implementations remain fallback paths.

**Tech Stack:** Flutter/Dart, Kotlin, Android Platform Views, Jetpack Compose, `androidx.compose.material3` expressive APIs.

**Spec:** `docs/superpowers/specs/2026-11-04-native-android-material-expressive-design.md`

## Global Constraints

- Keep Flutter >=3.44.0, Dart ^3.12.0, and Android minSdk 21.
- Pin stable `androidx.compose.material3:material3:1.4.0`; do not require the 1.5 prerelease toolchain (minCompileSdk 37 / AGP 9.1 / Kotlin 2.2.20).
- Preserve existing public Dart constructors and all iOS/macOS/web rendering branches.
- Keep arbitrary Flutter children and unsupported custom options on their existing fallback paths.
- Keep the public Flutter M3E catalog export available through `adaptive_liquid_glass`.
- Preserve all pre-existing local workspace changes.
- Do not add or run tests unless requested; use analyzer, formatter, dependency resolution, and Android debug compilation for verification.

## Review Focus

- Compose compiler plugin version remains compatible with the Kotlin Gradle plugin in Flutter apps.
- Android compileSdk and Material 3 Expressive artifact versions resolve from Google Maven.
- Platform-view channel/view IDs remain paired across multiple instances and multiple Flutter engines.
- Native callbacks and parent-driven value changes do not create stale state or feedback loops.
- Unbounded Flutter layout and arbitrary children use the existing Flutter fallback.

---

### Task 1: Configure Compose and expressive dependencies

**Files:** `android/build.gradle`, Android source files.

- [x] Enable Compose for the Android library and configure the Compose compiler plugin matching the Flutter example's Kotlin 2.1.0 plugin.
- [x] Add stable Material 3 1.4.0 and compatible Compose dependencies.
- [x] Set the Android library compile SDK to 35, preserving minSdk 21; use stable expressive motion and component APIs available within this toolchain.
- [x] Resolve dependencies and compile the Android library before adding widget mappings. Targeted Kotlin compilation succeeded; full APK build hit an environment disk-space error while extracting Flutter engine JNI artifacts.

### Task 2: Add reusable Android Compose platform-view host

**Files:** `android/src/main/kotlin/com/ledexsoft/adaptive_liquid_glass/AdaptivePlatformUiPlugin.kt`, new focused native view/protocol Kotlin files.

- [x] Register a single `PlatformViewFactory` with a stable view type and standard message codec.
- [x] Implement a `ComposeView` host that receives component props, applies stable `MaterialTheme` with expressive shape/color tokens, updates composition from method-channel messages, emits interaction events, and disposes cleanly.
- [x] Add native rendering for text button, switch, checkbox, radio, and slider component types.
- [x] Confirm the Android plugin compiles.

### Task 3: Add Dart platform-view bridge and state protocol

**Files:** new `lib/src/widgets/android/` bridge files and `lib/adaptive_liquid_glass.dart`.

- [x] Add a package-private typed Dart wrapper around `AndroidView` with initial `creationParams`, property updates, and callbacks.
- [x] Encode colors as ARGB integers, sizes as logical pixels, and booleans/numbers as standard codec values.
- [x] Handle platform-view creation/disposal and updated callbacks without leaking method-channel handlers.
- [x] Export only the package-owned bridge API.

### Task 4: Route adaptive controls to native Compose

**Files:** `adaptive_button.dart`, `adaptive_switch.dart`, `adaptive_checkbox.dart`, `adaptive_radio.dart`, `adaptive_slider.dart`, and supported progress/badge wrappers.

- [x] Route Android label-only buttons and supported control configurations to native Compose.
- [x] Preserve Flutter rendering for icon/custom-child buttons and unsupported options.
- [x] Keep iOS and non-Android platform selection unchanged.
- [x] Keep the full Flutter M3E export for direct catalog use and document that direct exported widgets are Flutter-rendered.

### Task 5: Document and verify the Android native path

**Files:** `README.md`, `CHANGELOG.md`, integration notes.

- [x] Explain that Android adaptive controls use native Compose where mapped, and state the fallback boundary.
- [x] Run Dart formatting, `flutter analyze --no-pub`, `flutter pub get`, and Android debug compilation.
- [x] Review `git diff --check` and preserve unrelated local changes.
- [x] Record that no device-level Galaxy/AOSP visual check was performed unless one is actually run.

**Verification note:** `flutter analyze` and targeted Compose compilation passed. The example debug APK built successfully for `arm64`. No Android device/emulator visual validation was available. The implementation uses stable Material3 1.4 `MaterialTheme`; `MaterialExpressiveTheme` remains unavailable on the selected stable/toolchain baseline.
