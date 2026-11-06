# Expressive typography API — Plan

1. Add `AdaptiveExpressiveTypography` as a `ThemeExtension` with baseline/emphasized `TextTheme`s, context lookup, copy, and interpolation.
2. Derive emphasis using one heavier weight step (or a heavier `wght` variation when explicitly present), preserving every other `TextStyle` property.
3. Export the API from `adaptive_liquid_glass.dart`.
4. Document the M3 typography roles, opt-in usage, custom emphasized styles, and variable-font axes; clarify that this does not implement the separate lock-screen clock stretching effect.
5. Update package changelog/version to `0.2.14` and align the release APK workflow's Flutter version with the package's `>=3.47.0` minimum; run `dart format` on changed Dart files, `flutter analyze --fatal-infos`, and `git diff --check`.
