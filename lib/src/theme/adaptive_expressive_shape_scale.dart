import 'package:flutter/foundation.dart';

/// Optional corner radii for the eight real Compose Material 3 shape roles.
///
/// Unspecified roles keep their native Material defaults. These values are
/// logical pixels on Flutter and dp in Compose. The scale changes the native
/// theme; individual components can still choose their own explicit shapes.
@immutable
class AdaptiveExpressiveShapeScale {
  const AdaptiveExpressiveShapeScale({
    this.extraSmall,
    this.small,
    this.medium,
    this.large,
    this.extraLarge,
    this.largeIncreased,
    this.extraLargeIncreased,
    this.extraExtraLarge,
  });

  final double? extraSmall;
  final double? small;
  final double? medium;
  final double? large;
  final double? extraLarge;
  final double? largeIncreased;
  final double? extraLargeIncreased;
  final double? extraExtraLarge;

  /// Serializable overrides for `MaterialExpressiveTheme(shapes: ...)`.
  Map<String, double> toNativeRadii() {
    final values = <String, double?>{
      'extraSmall': extraSmall,
      'small': small,
      'medium': medium,
      'large': large,
      'extraLarge': extraLarge,
      'largeIncreased': largeIncreased,
      'extraLargeIncreased': extraLargeIncreased,
      'extraExtraLarge': extraExtraLarge,
    };
    final result = <String, double>{};
    for (final entry in values.entries) {
      final radius = entry.value;
      if (radius == null) continue;
      if (!radius.isFinite || radius < 0) {
        throw ArgumentError.value(radius, entry.key, 'Must be finite and >= 0');
      }
      result[entry.key] = radius;
    }
    return result;
  }
}
