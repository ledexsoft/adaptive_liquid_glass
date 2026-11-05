# SUPERSEDED — Full M3 Expressive Adaptive Coverage

This earlier design allowed Flutter-rendered M3E fallbacks. It is superseded by [`2026-11-05-android-native-material-expressive-design.md`](2026-11-05-android-native-material-expressive-design.md), which requires native Android implementations and removal of the Flutter M3E dependency.

## Intent

Make the package select an expressive implementation automatically for the M3 Expressive component families described in Material's update article. Keep the existing public adaptive API style and platform fallbacks.

## Goals

- Cover the new component families: button groups, FAB menu, loading indicator, split button, and toolbar.
- Cover updated component families without a dedicated wrapper today: carousel, extended FAB, icon button, and navigation rail.
- Use native Jetpack Compose Material 3 Expressive 1.5.0-rc01 for the Android Compose bridge.
- Raise Flutter and Android build requirements to match Material Expressive's Compose compiler and SDK needs.
- Keep the package's Flutter M3E catalog for cross-platform fallbacks and components that do not yet have a Compose bridge.
- Document which Android paths are Compose-native and which are Flutter-rendered M3E.

## Non-goals

- Do not claim every M3 component is an Android native View.
- Preserve Android `minSdk 21`; use `compileSdk 37` and the compatible AGP/Gradle/Kotlin toolchain.
- Do not replace iOS Liquid Glass/Cupertino behavior.

## Approaches

1. Keep stable Compose 1.4 and Flutter M3E for expressive-only components. This preserves toolchain compatibility but lacks the official native Expressive theme and motion defaults.
2. Upgrade the Android toolchain to Compose Material 3 Expressive 1.5.0-rc01, keep API 21, and let current native wrappers inherit official Expressive theme defaults. Chosen after the user explicitly authorized all necessary upgrades.
3. Leave the catalog as manually selected `M3E*` widgets. This does not satisfy automatic adaptive selection.

## Design

On Android, native Compose-backed wrappers use `MaterialExpressiveTheme` and official Expressive component defaults. New wrappers without Compose mappings still invoke their corresponding Flutter `M3E*` component. On other platforms they render a documented Flutter/Cupertino fallback or a caller-provided fallback where the M3E component accepts arbitrary child widgets. `AdaptiveApp` continues installing the Flutter M3E theme automatically; users with a custom `MaterialApp` use `AdaptiveMaterialExpressiveTheme`.

The complete catalog remains re-exported. Current native Compose coverage: label-only `AdaptiveButton`, `AdaptiveSwitch`, `AdaptiveCheckbox`, `AdaptiveRadio`, supported `AdaptiveSlider` configurations, the default `AdaptiveLoadingIndicator`, and `AdaptiveProgressIndicator`. Other new wrappers continue using Flutter-rendered M3E pending Compose bridges; the package documents this split accurately.

## Acceptance

- Every new or previously unwrapped component family named above has an `Adaptive*` wrapper exported by the package and selects M3E automatically on Android.
- Non-Android fallback works without an M3E theme.
- README and API docs distinguish Compose-native from Flutter-rendered M3E paths.
- `flutter analyze --no-pub`, Kotlin compile, Android arm64 debug APK build, and `git diff --check` pass.
