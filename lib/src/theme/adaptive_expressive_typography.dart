import 'package:flutter/material.dart';

/// Baseline and emphasized Material 3 Expressive text scales.
///
/// The extension is opt-in: it does not replace Flutter's [TextTheme] or
/// change the appearance of existing package widgets. Register it in
/// [ThemeData.extensions] to provide a custom scale. If none is registered,
/// [of] derives an emphasized scale from the current theme.
@immutable
class AdaptiveExpressiveTypography
    extends ThemeExtension<AdaptiveExpressiveTypography> {
  const AdaptiveExpressiveTypography({
    required this.baseline,
    required this.emphasized,
  });

  /// Creates an expressive scale from a standard Material [TextTheme].
  ///
  /// Unless [emphasized] is supplied, each non-null style is copied with a
  /// heavier weight. All other style properties, including font family,
  /// spacing, color, and variable-font axes, are preserved.
  factory AdaptiveExpressiveTypography.fromTextTheme(
    TextTheme baseline, {
    TextTheme? emphasized,
  }) {
    return AdaptiveExpressiveTypography(
      baseline: baseline,
      emphasized: emphasized ?? _emphasizeTextTheme(baseline),
    );
  }

  /// The regular 15-style Material text scale.
  final TextTheme baseline;

  /// The emphasized counterpart of the 15-style text scale.
  ///
  /// Use selectively for headlines, key actions, selected states, and other
  /// moments that need stronger hierarchy.
  final TextTheme emphasized;

  /// Reads a registered scale, or derives one from the active theme.
  static AdaptiveExpressiveTypography of(BuildContext context) {
    final theme = Theme.of(context);
    return theme.extension<AdaptiveExpressiveTypography>() ??
        AdaptiveExpressiveTypography.fromTextTheme(theme.textTheme);
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

  static TextTheme _emphasizeTextTheme(TextTheme theme) {
    return theme.copyWith(
      displayLarge: _emphasize(theme.displayLarge),
      displayMedium: _emphasize(theme.displayMedium),
      displaySmall: _emphasize(theme.displaySmall),
      headlineLarge: _emphasize(theme.headlineLarge),
      headlineMedium: _emphasize(theme.headlineMedium),
      headlineSmall: _emphasize(theme.headlineSmall),
      titleLarge: _emphasize(theme.titleLarge),
      titleMedium: _emphasize(theme.titleMedium),
      titleSmall: _emphasize(theme.titleSmall),
      bodyLarge: _emphasize(theme.bodyLarge),
      bodyMedium: _emphasize(theme.bodyMedium),
      bodySmall: _emphasize(theme.bodySmall),
      labelLarge: _emphasize(theme.labelLarge),
      labelMedium: _emphasize(theme.labelMedium),
      labelSmall: _emphasize(theme.labelSmall),
    );
  }

  static TextStyle? _emphasize(TextStyle? style) {
    if (style == null) return null;

    final variations = style.fontVariations;
    if (variations != null) {
      final weightAxis = variations.indexWhere(
        (variation) => variation.axis == 'wght',
      );
      if (weightAxis >= 0) {
        final updatedVariations = List<FontVariation>.of(variations);
        final variation = updatedVariations[weightAxis];
        updatedVariations[weightAxis] = FontVariation.weight(
          (variation.value + 100).clamp(1, 1000).toDouble(),
        );
        return style.copyWith(fontVariations: updatedVariations);
      }
    }

    final currentWeight = style.fontWeight ?? FontWeight.w400;
    final nextWeight = FontWeight.values.firstWhere(
      (weight) => weight.value > currentWeight.value,
      orElse: () => currentWeight,
    );
    return style.copyWith(fontWeight: nextWeight);
  }
}
