/// Keeps an unknown determinate value at the start instead of reporting completion.
double? normalizeAdaptiveProgress(double? value) {
  if (value == null) return null;
  if (!value.isFinite) return 0.0;
  return value.clamp(0.0, 1.0).toDouble();
}
