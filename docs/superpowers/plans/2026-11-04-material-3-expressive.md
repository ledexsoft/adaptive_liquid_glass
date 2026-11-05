# Material 3 Expressive Integration Plan

> Implementation is being carried out inline in the current workspace as requested.

**Goal:** Make the full Material 3 Expressive component catalog available through `adaptive_liquid_glass`, with Android adaptive widgets using M3E while iOS keeps Liquid Glass/Cupertino behavior.

**Architecture:** Pin the compatible M3E 1.1.2 implementation internally and prefix all imports. Add an adaptive M3E theme bridge that derives seed color and brightness from the host Flutter theme, and adds M3E localizations without replacing the host app's delegates. Route existing adaptive widgets to M3E on Android and export the full upstream catalog for components without an existing wrapper. Keep consumer code importing this package only.

**Tech Stack:** Flutter, Dart, `material_3_expressive` 1.1.x, existing adaptive package APIs.

**Spec:** `docs/superpowers/specs/2026-11-04-material-3-expressive-design.md`

## Global Constraints

- Dart SDK stays `^3.12.0`; Flutter stays `>=3.44.0`.
- M3E dependency constraint is `>=1.1.2 <1.2.0` until a later M3E release supports the current SDK floor.
- iOS 26+ native widgets and legacy Cupertino behavior remain intact.
- Consumer-facing imports remain `package:adaptive_liquid_glass/adaptive_liquid_glass.dart`.
- Existing local modifications are preserved.

## Review Focus

- Android running under ordinary Flutter `MaterialApp`: each M3E widget receives an M3E theme independent of `material_ui` app imports.
- Host app custom colors/brightness: derive expressive defaults from its active `ThemeData`, preserve explicit widget color arguments.
- iOS/macOS/web: adaptive wrappers do not accidentally build M3E widgets.
- Stateful controls and modal flows: callbacks, focus, semantics, and navigator usage remain connected to existing API behavior.
- Pub resolution: dependency stays at 1.1.x and does not change the declared Dart/Flutter floor.

---

### Task 1: Internal M3E dependency and theme bridge — complete

**Files:** `pubspec.yaml`, `lib/src/theme/adaptive_material_expressive_theme.dart`, `lib/adaptive_liquid_glass.dart`.

- Added the compatible M3E constraint and preserved the Flutter/Dart floors.
- Added a theme bridge using the host primary color and brightness, reduced-motion state, and additive localization delegates.
- `AdaptiveApp` installs the theme above its Navigator; apps using another shell can add the same wrapper in their app builder.
- No upstream implementation source was copied, so no new source attribution notice was required.

### Task 2: Route existing adaptive components to M3E on Android — complete

**Files:** Existing files under `lib/src/widgets/` that have direct M3E equivalents, plus `lib/src/widgets/adaptive_app.dart`.

- Mapped buttons, FABs, scaffold/app bars/navigation, controls, cards/lists/forms, menus, dialogs, pickers, tabs, text/search, progress, feedback, badges, dividers, and tooltips where their existing APIs match the M3E component.
- Retained Cupertino/native branches and existing adaptive constructor signatures. Unsupported custom Material options keep their Material fallback rather than being dropped.
- Modal M3E routes use the M3E surface only when its theme is above the relevant Navigator overlay; otherwise they retain the Material fallback.

### Task 3: Expose the rest of the M3E catalog through this package — complete

**Files:** `lib/adaptive_liquid_glass.dart`, `lib/src/theme/adaptive_material_expressive_theme.dart`.

- Re-exported the full M3E 1.1.2 component and foundation catalog using the upstream `M3E*` names.
- Added `AdaptiveMaterialExpressive` as a platform selector for M3E-only components that have no existing adaptive API. This avoids adding many one-off wrappers that would need to duplicate every upstream constructor.
- Consumers import only this package and use the supplied fallback builder on other platforms.

### Task 4: Example and package documentation — complete

**Files:** `README.md`, `CHANGELOG.md`.

- Documented setup, the complete exported catalog, supported automatic mappings, fallback behavior, and the package-only import path.
- Existing example pages already use the adaptive wrappers and now render the Android M3E paths.

### Task 5: Review changes and resolve integration issues — complete

- Preserve the pre-existing workspace changes and avoid reverting unrelated permission-only changes.
- Ran Dart formatting and reviewed the integration diff, including theme placement for route overlays and fallback behavior for unsupported custom options.
- `flutter analyze --no-pub` completed with no issues; `git diff --check` is clean. Tests and device-level visual checks were not run.
