# Expressive typography API — Plan

1. Expose `AdaptiveExpressiveTypography` as a `ThemeExtension` with required
   baseline and emphasized `TextTheme`s, optional lookup, role/size lookup,
   font-role assignment, copy, and interpolation.
2. Keep emphasized styles explicit; do not manufacture tokens by incrementing
   each baseline weight.
3. Export the API and its role/size enums from the package entry point.
4. Document Material's font choices, token roles, selective emphasis, variable
   axes, language-sensitive line metrics, accessibility, editorial treatments,
   and native Compose boundary.
5. Bump the package patch version; format, run static analysis, and check diff
   hygiene before committing to `main`.
