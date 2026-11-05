# Android Native Material 3 Expressive Design

## Intent

Make Android implementations in adaptive_liquid_glass use official Android UI components, especially Jetpack Compose Material 3 Expressive, rather than Flutter-rendered M3E lookalikes. This supports the package's goal: native platform UI on Android and iOS, with Flutter remaining the cross-platform API and composition layer.

## Goals

- Replace every Android route that currently renders material_3_expressive Flutter widgets with an Android-native Compose implementation when an official component exists.
- Use platform views for native components embedded in Flutter, preserving Dart state and callbacks through a typed, lifecycle-safe bridge.
- Use Android-native framework or Compose equivalents where Material3 Expressive has no component; do not imitate missing components in Flutter.
- Preserve iOS UIKit, Cupertino, and Liquid Glass routes.
- Remove the material_3_expressive Flutter dependency and direct catalog export after every usage has migrated.
- Set the Flutter minimum to the newest stable release verified at implementation time; never label beta/dev as stable.
- Document arbitrary Flutter-child constraints and add native-friendly data APIs where needed.

## Non-goals

- Claim Flutter-rendered M3E widgets are native.
- Keep a Flutter M3E Android rendering fallback.
- Port arbitrary Flutter widget trees into Compose.
- Change iOS rendering architecture.

## Approaches

1. Keep Flutter M3E as fallback: rejected because Android UI must be native.
2. Use Android Views: suitable for framework-native gaps, but insufficient as the main M3 Expressive route.
3. Host official Jetpack Compose Material 3 Expressive in Android PlatformViews, using framework-native Android components for gaps: chosen because this uses Google's Android implementation and fits the Flutter plugin boundary.

## Architecture and versions

Keep adaptive Dart widgets as the public API. Route Android to native Compose PlatformViews through a typed serialized protocol for labels, icons, values, colors, enabled state, semantic labels, and callbacks. Flutter Widget children cannot cross the platform-view boundary; wrappers with arbitrary children need native-friendly parameters (text/icon/action models) or must clearly report that no native representation exists. Android must never silently render an M3E Flutter imitation.

Material 3 Expressive's official Compose implementation is in the Material3 1.5 prerelease line; 1.4.0 is stable. Pin the newest release providing required expressive APIs, record its prerelease status and Android toolchain requirements, and update it when stable. The chosen native API line requires Android minSdk 24 and compileSdk 37; keep build tools aligned to official requirements. Flutter stable is a separate constraint: use the newest stable verified at implementation time. As of 2026-11-05, 3.47.9 is stable and 3.50 remains beta.

## Native coverage groups

- Theme/tokens: expressive color, shapes, typography, motion, system dark mode and dynamic colors.
- Core controls: buttons, icon/toggle buttons, button groups, switches, checkboxes, radio buttons, sliders, progress and loading indicators.
- Navigation/layout: scaffold, top app bars, navigation bar/rail/drawer, tabs and adaptive navigation.
- Actions/surfaces: FAB variants and menus, split buttons, toolbars, cards, lists, menus, dialogs, sheets and pickers.
- Content/feedback: carousel, search/text fields, badges, tooltips, dividers and pull-to-refresh.

For each wrapper, record whether an official Compose component exists, which Dart options map losslessly, the native protocol, and unsupported API. Use standard Android/Compose APIs for missing M3E components. No Flutter visual fallback is permitted on Android.

## Acceptance criteria

- An inventory maps every exported adaptive component and existing M3E Flutter usage to native Compose/Android, or documents why no Android-native counterpart exists.
- No Android path instantiates M3E Flutter widgets or Flutter Material widgets as visual fallbacks for M3E components.
- material_3_expressive is removed from pubspec.yaml, imports, and public exports after migration.
- Android state, callbacks, disabled state, accessibility semantics, theme changes, dark mode, and dynamic colors work for supported components.
- Existing iOS behavior and public APIs are preserved except documented Android-oriented native data APIs.
- Flutter minimum is the newest stable verified at implementation time; Android SDK/toolchain floors match official requirements.
- Analyzer, dependency resolution, Android compilation, and device visual/interaction checks pass before completion is claimed.
