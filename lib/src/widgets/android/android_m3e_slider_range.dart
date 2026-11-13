import 'dart:typed_data';

/// Chooses caller units for Compose when Float still resolves the slider's
/// useful positions, otherwise preserves precision with a normalized track.
class AndroidM3ESliderRange {
  AndroidM3ESliderRange._(
    this.min,
    this.max,
    this.nativeMin,
    this.nativeMax,
    this.usesCallerUnits,
  );

  factory AndroidM3ESliderRange(double min, double max, int? divisions) {
    final span = max - min;
    if (min < max && span.isFinite) {
      final nativeMin = _float32(min);
      final nativeMax = _float32(max);
      final quantum = span / (divisions ?? 4096);
      if (nativeMin.isFinite &&
          nativeMax.isFinite &&
          nativeMin < nativeMax &&
          _float32(nativeMax - nativeMin).isFinite &&
          quantum.isFinite &&
          quantum > 0 &&
          (nativeMin - min).abs() <= quantum / 4 &&
          (nativeMax - max).abs() <= quantum / 4 &&
          _float32(min + quantum) > nativeMin &&
          _float32(max - quantum) < nativeMax) {
        return AndroidM3ESliderRange._(min, max, nativeMin, nativeMax, true);
      }
    }
    return AndroidM3ESliderRange._(min, max, 0, 1, false);
  }

  final double min;
  final double max;
  final double nativeMin;
  final double nativeMax;
  final bool usesCallerUnits;

  bool contains(double value) =>
      value.isFinite && value >= nativeMin && value <= nativeMax;

  double encode(double value) {
    if (usesCallerUnits) return value;
    if (min == max) return 0;
    final span = max - min;
    final fraction = span.isFinite
        ? (value - min) / span
        : (value / 2 - min / 2) / (max / 2 - min / 2);
    return fraction.clamp(0.0, 1.0).toDouble();
  }

  double decode(double nativeValue, {int? divisions}) {
    final fraction = usesCallerUnits
        ? (nativeValue - nativeMin) / (nativeMax - nativeMin)
        : nativeValue;
    final selected = divisions == null
        ? fraction.clamp(0.0, 1.0).toDouble()
        : (fraction.clamp(0.0, 1.0) * divisions).round() / divisions;
    if (selected <= 0) return min;
    if (selected >= 1) return max;
    final span = max - min;
    return span.isFinite
        ? min + selected * span
        : min * (1 - selected) + max * selected;
  }
}

double _float32(double value) => Float32List.fromList([value]).first;
