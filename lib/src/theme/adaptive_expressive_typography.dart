import 'package:flutter/material.dart';

/// The five semantic roles in the Material 3 type scale.
enum AdaptiveTypographyRole { display, headline, title, body, label }

/// The three sizes available for each [AdaptiveTypographyRole].
enum AdaptiveTypographySize { large, medium, small }

/// Paired baseline and emphasized Material 3 text scales.
///
/// Each scale contains the 15 styles in Flutter's [TextTheme]. Supply both
/// complete scales: emphasized tokens have their own font, size, line height,
/// tracking, and weight values, so they must not be synthesized by blindly
/// increasing the baseline weight.
///
/// Register this extension in [ThemeData.extensions]. It does not replace the
/// theme's normal [TextTheme] or change any package widget by itself.
@immutable
class AdaptiveExpressiveTypography
    extends ThemeExtension<AdaptiveExpressiveTypography> {
  const AdaptiveExpressiveTypography({
    required this.baseline,
    required this.emphasized,
  });

  /// The regular 15-style scale: display, headline, title, body, and label,
  /// each in large, medium, and small sizes.
  final TextTheme baseline;

  /// The separately defined emphasized counterpart of [baseline].
  ///
  /// Use these styles selectively for emphasis and state. Body copy and dense
  /// information should usually continue to use [baseline].
  final TextTheme emphasized;

  /// Returns the registered expressive type scale, or `null` if the theme
  /// does not provide one.
  static AdaptiveExpressiveTypography? maybeOf(BuildContext context) {
    return Theme.of(context).extension<AdaptiveExpressiveTypography>();
  }

  /// Returns the registered expressive type scale.
  ///
  /// Throws a [FlutterError] with setup guidance if it has not been added to
  /// the active [ThemeData.extensions]. Use [maybeOf] for optional lookup.
  static AdaptiveExpressiveTypography of(BuildContext context) {
    final typography = maybeOf(context);
    if (typography != null) return typography;
    throw FlutterError.fromParts(<DiagnosticsNode>[
      ErrorSummary('No AdaptiveExpressiveTypography is registered.'),
      ErrorDescription(
        'Add an AdaptiveExpressiveTypography with explicit baseline and '
        'emphasized TextThemes to ThemeData.extensions before calling of().',
      ),
    ]);
  }

  /// Gets one role/size token from [baseline] or [emphasized].
  TextStyle? styleFor(
    AdaptiveTypographyRole role,
    AdaptiveTypographySize size, {
    bool emphasized = false,
  }) {
    final theme = emphasized ? this.emphasized : baseline;
    return switch ((role, size)) {
      (AdaptiveTypographyRole.display, AdaptiveTypographySize.large) =>
        theme.displayLarge,
      (AdaptiveTypographyRole.display, AdaptiveTypographySize.medium) =>
        theme.displayMedium,
      (AdaptiveTypographyRole.display, AdaptiveTypographySize.small) =>
        theme.displaySmall,
      (AdaptiveTypographyRole.headline, AdaptiveTypographySize.large) =>
        theme.headlineLarge,
      (AdaptiveTypographyRole.headline, AdaptiveTypographySize.medium) =>
        theme.headlineMedium,
      (AdaptiveTypographyRole.headline, AdaptiveTypographySize.small) =>
        theme.headlineSmall,
      (AdaptiveTypographyRole.title, AdaptiveTypographySize.large) =>
        theme.titleLarge,
      (AdaptiveTypographyRole.title, AdaptiveTypographySize.medium) =>
        theme.titleMedium,
      (AdaptiveTypographyRole.title, AdaptiveTypographySize.small) =>
        theme.titleSmall,
      (AdaptiveTypographyRole.body, AdaptiveTypographySize.large) =>
        theme.bodyLarge,
      (AdaptiveTypographyRole.body, AdaptiveTypographySize.medium) =>
        theme.bodyMedium,
      (AdaptiveTypographyRole.body, AdaptiveTypographySize.small) =>
        theme.bodySmall,
      (AdaptiveTypographyRole.label, AdaptiveTypographySize.large) =>
        theme.labelLarge,
      (AdaptiveTypographyRole.label, AdaptiveTypographySize.medium) =>
        theme.labelMedium,
      (AdaptiveTypographyRole.label, AdaptiveTypographySize.small) =>
        theme.labelSmall,
    };
  }

  /// Applies a brand font to display/headline/title and a plain font to
  /// body/label styles in both scales.
  ///
  /// Unspecified font families and fallbacks are preserved. This only assigns
  /// family names; the consuming app must bundle or otherwise make those fonts
  /// available. Existing weight, line height, size, tracking, colors, and
  /// variable-font axes remain intact.
  AdaptiveExpressiveTypography withFontRoles({
    String? brandFontFamily,
    String? plainFontFamily,
    List<String>? fontFamilyFallback,
  }) {
    return AdaptiveExpressiveTypography(
      baseline: _applyFontRoles(
        baseline,
        brandFontFamily: brandFontFamily,
        plainFontFamily: plainFontFamily,
        fontFamilyFallback: fontFamilyFallback,
      ),
      emphasized: _applyFontRoles(
        emphasized,
        brandFontFamily: brandFontFamily,
        plainFontFamily: plainFontFamily,
        fontFamilyFallback: fontFamilyFallback,
      ),
    );
  }

  @override
  AdaptiveExpressiveTypography copyWith({
    TextTheme? baseline,
    TextTheme? emphasized,
  }) {
    return AdaptiveExpressiveTypography(
      baseline: baseline ?? this.baseline,
      emphasized: emphasized ?? this.emphasized,
    );
  }

  @override
  AdaptiveExpressiveTypography lerp(
    covariant AdaptiveExpressiveTypography? other,
    double t,
  ) {
    if (other == null) return this;
    return AdaptiveExpressiveTypography(
      baseline: TextTheme.lerp(baseline, other.baseline, t),
      emphasized: TextTheme.lerp(emphasized, other.emphasized, t),
    );
  }

  static TextTheme _applyFontRoles(
    TextTheme theme, {
    required String? brandFontFamily,
    required String? plainFontFamily,
    required List<String>? fontFamilyFallback,
  }) {
    return theme.copyWith(
      displayLarge: _withFont(
        theme.displayLarge,
        brandFontFamily,
        fontFamilyFallback,
      ),
      displayMedium: _withFont(
        theme.displayMedium,
        brandFontFamily,
        fontFamilyFallback,
      ),
      displaySmall: _withFont(
        theme.displaySmall,
        brandFontFamily,
        fontFamilyFallback,
      ),
      headlineLarge: _withFont(
        theme.headlineLarge,
        brandFontFamily,
        fontFamilyFallback,
      ),
      headlineMedium: _withFont(
        theme.headlineMedium,
        brandFontFamily,
        fontFamilyFallback,
      ),
      headlineSmall: _withFont(
        theme.headlineSmall,
        brandFontFamily,
        fontFamilyFallback,
      ),
      titleLarge: _withFont(
        theme.titleLarge,
        brandFontFamily,
        fontFamilyFallback,
      ),
      titleMedium: _withFont(
        theme.titleMedium,
        brandFontFamily,
        fontFamilyFallback,
      ),
      titleSmall: _withFont(
        theme.titleSmall,
        brandFontFamily,
        fontFamilyFallback,
      ),
      bodyLarge: _withFont(
        theme.bodyLarge,
        plainFontFamily,
        fontFamilyFallback,
      ),
      bodyMedium: _withFont(
        theme.bodyMedium,
        plainFontFamily,
        fontFamilyFallback,
      ),
      bodySmall: _withFont(
        theme.bodySmall,
        plainFontFamily,
        fontFamilyFallback,
      ),
      labelLarge: _withFont(
        theme.labelLarge,
        plainFontFamily,
        fontFamilyFallback,
      ),
      labelMedium: _withFont(
        theme.labelMedium,
        plainFontFamily,
        fontFamilyFallback,
      ),
      labelSmall: _withFont(
        theme.labelSmall,
        plainFontFamily,
        fontFamilyFallback,
      ),
    );
  }

  static TextStyle? _withFont(
    TextStyle? style,
    String? fontFamily,
    List<String>? fontFamilyFallback,
  ) {
    return style?.copyWith(
      fontFamily: fontFamily ?? style.fontFamily,
      fontFamilyFallback: fontFamilyFallback ?? style.fontFamilyFallback,
    );
  }
}
