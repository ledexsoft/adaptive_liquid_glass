# Expressive typography API — Design

## Intent

Expose Material 3's paired baseline/emphasized typography scales in
`adaptive_liquid_glass` so consuming Flutter apps can use the official hierarchy
without changing current package widgets. Keep this as a Flutter theme API;
Android views rendered wholly in Compose continue to use Compose typography.

## Material guidance applied

- A type scale has 15 baseline and 15 emphasized styles across display,
  headline, title, body, and label at large/medium/small sizes.
- Every token represents its full properties. Emphasized styles are a separate
  set and must not be fabricated by uniformly increasing font weight.
- Brand type may be used for display/headline/title; plain type is more
  appropriate for body/label. Font fallbacks and variable axes depend on the
  app's actual font files and supported scripts.
- Editorial treatments are bespoke, intentional moments, not another
  functional scale role. Reading styles need adequate line metrics, contrast,
  and language coverage.

## Design

`AdaptiveExpressiveTypography` is an opt-in `ThemeExtension` with required,
explicit baseline and emphasized `TextTheme`s. It exposes `maybeOf` and a
diagnostic `of`, `styleFor(role, size)`, and `withFontRoles` to assign brand and
plain families without discarding other style properties. It does not bundle
fonts, guess unavailable axes, alter the app's base text theme, or style native
Compose content.

## Constraints and success

- Additive API; no new dependencies and no package-wide appearance change.
- Export the extension and its semantic role/size enums.
- Document usage, font roles and fallbacks, variable axes, language-sensitive
  line metrics, legibility/accessibility, editorial treatments, and platform
  boundary.
- Validate formatting, static analysis, and diff hygiene; do not change
  OneBlink in this task.
