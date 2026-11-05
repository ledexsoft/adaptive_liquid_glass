# Material 3 Expressive for Android — Design

## Intent

Render Material 3 Expressive styles through `adaptive_liquid_glass` on Android, so consuming apps continue using only this package's adaptive widgets. Preserve the existing native Liquid Glass path on iOS 26+, Cupertino path on older iOS, and current Flutter/Dart minimum versions.

## Approaches

- **Internal dependency on the newest `material_3_expressive`:** gives the broadest current API but version 1.2.0 raises minimums to Flutter 3.47/Dart 3.13 and uses `material_ui`.
- **Internal dependency pinned to compatible 1.1.x plus adaptive integration (chosen):** version 1.1.2 supports the package's existing Flutter 3.44/Dart 3.12 floor and contains the full component set. Keep it an implementation dependency; consumers import only this package. Do not expose an alternate app shell or require consumer imports to change.
- **Port/adapt selected components:** preserves SDK support but fails the updated requirement to provide the full M3E catalog.

## Scope

- Integrate the full component and token set from `material_3_expressive` 1.1.2 through this package. Prefer the package's existing `Adaptive*` wrappers; export the upstream catalog and provide one platform selector for components without an existing equivalent.
- Project the host's seed color and brightness into an `M3ETheme` on Android. Preserve explicit per-widget colors and the existing public constructors/callbacks where possible.
- Keep all consumer imports under `adaptive_liquid_glass`; do not require `material_ui` or direct M3E imports in app code.
- Keep the dependency below 1.2.0 while its SDK floor is compatible; revisit when our supported SDK floor moves.
- Preserve accessibility semantics, minimum touch targets, host colors where explicitly supplied, dark mode, and reduced-motion preferences.
- Track upstream source attribution and license notices for any copied or materially adapted code.

## Constraints and decisions

- Keep `environment.sdk: ^3.12.0` and Flutter `>=3.44.0`.
- Add `material_3_expressive: '>=1.1.2 <1.2.0'` as an implementation dependency. Its `material_ui` dependency remains transitive and hidden behind this package's API.
- Android uses expressive widgets for the full M3E catalog wherever an existing adaptive API can map the call; iOS/macOS keep their existing native/Cupertino routes for adaptive widgets. For modal and root-overlay components, install the theme above the app's Navigator.
- Avoid forcing apps to replace their `MaterialApp`, theme, or imports.

## Success criteria

- Existing adaptive API remains the consumer entry point.
- Existing adaptive controls route to M3E on Android wherever their options have a direct equivalent; M3E-specific components are reachable from this package's public API and the platform selector.
- Package minimum SDK constraints and existing consumer-facing signatures remain compatible.
