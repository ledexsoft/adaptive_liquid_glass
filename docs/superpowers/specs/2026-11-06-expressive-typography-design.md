# Expressive typography API — Design

## Intent

Expose Material 3 Expressive typography styles from `adaptive_liquid_glass` so consuming apps can guide attention with type hierarchy without depending on a second UI package. Do not alter existing app typography or apply the styles to OneBlink yet.

## Approaches

- Add a public `ThemeExtension` containing baseline and emphasized Flutter `TextTheme`s (chosen): integrates with Flutter theming, preserves normal styles, and works in consuming apps using the package's single import.
- Add a new `AdaptiveText` widget: convenient for one call site but duplicates Flutter `Text` API and makes typography harder to compose.
- Change package-wide defaults: would alter existing screens without explicit adoption and is outside the requested scope.

## Design

`AdaptiveExpressiveTypography` exposes baseline and emphasized scales, with all 15 standard `TextTheme` roles in each. `of(context)` reads a registered extension or derives emphasized styles from the active theme by increasing font weight while preserving other text properties. Apps may register a fully customized emphasized `TextTheme`, including variable-font axes. Document the distinction between emphasized styles and Samsung-style vertical clock stretching.

## Constraints and success

- Additive public API, no new dependencies and no changes to current widget styling.
- Export from the package entry point and document registration, lookup, custom styles, and variable font usage.
- Analyze the package; do not change OneBlink in this task.
