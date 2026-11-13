import 'package:flutter/material.dart';

import '../platform/platform_info.dart';
import 'android/android_m3e_platform_view.dart';
import 'android/android_m3e_slider_range.dart';

/// A two-thumb range slider.
///
/// Android uses Compose Material 3's real [RangeSlider]. Other platforms use
/// Flutter's [RangeSlider]. The caller owns [values] and updates them in
/// [onChanged], as with Flutter's controlled slider.
class AdaptiveRangeSlider extends StatelessWidget {
  AdaptiveRangeSlider({
    super.key,
    required this.values,
    required this.onChanged,
    this.onChangeStart,
    this.onChangeEnd,
    this.min = 0.0,
    this.max = 1.0,
    this.divisions,
    this.labels,
    this.activeColor,
    this.inactiveColor,
  }) : assert(min <= max),
       assert(min.isFinite && max.isFinite),
       assert(values.start.isFinite && values.end.isFinite),
       assert(values.start >= min && values.end <= max),
       assert(values.start <= values.end),
       assert(divisions == null || divisions > 0);

  final RangeValues values;
  final ValueChanged<RangeValues>? onChanged;
  final ValueChanged<RangeValues>? onChangeStart;
  final ValueChanged<RangeValues>? onChangeEnd;
  final double min;
  final double max;
  final int? divisions;
  final RangeLabels? labels;
  final Color? activeColor;
  final Color? inactiveColor;

  @override
  Widget build(BuildContext context) {
    if (!PlatformInfo.usesNativeAndroidViews) {
      return RangeSlider(
        values: values,
        onChanged: onChanged,
        onChangeStart: onChangeStart,
        onChangeEnd: onChangeEnd,
        min: min,
        max: max,
        divisions: divisions,
        labels: labels,
        activeColor: activeColor,
        inactiveColor: inactiveColor,
      );
    }

    if (!min.isFinite ||
        !max.isFinite ||
        !values.start.isFinite ||
        !values.end.isFinite ||
        min > max ||
        values.start < min ||
        values.end > max ||
        values.start > values.end ||
        (divisions != null && divisions! <= 0)) {
      throw FlutterError(
        'Android AdaptiveRangeSlider requires finite, ordered values within '
        'the range and positive divisions.',
      );
    }

    final hasTrack = min < max;
    final canChange = onChanged != null && hasTrack;
    final nativeRange = AndroidM3ESliderRange(min, max, divisions);

    return LayoutBuilder(
      builder: (context, constraints) => AndroidM3EPlatformView(
        component: 'rangeSlider',
        width: constraints.maxWidth.isFinite ? constraints.maxWidth : 240,
        height: 48,
        properties: {
          'start': nativeRange.encode(values.start),
          'end': nativeRange.encode(values.end),
          'min': nativeRange.nativeMin,
          'max': nativeRange.nativeMax,
          'divisions': divisions,
          'startLabel': labels?.start,
          'endLabel': labels?.end,
          'enabled': canChange,
          'hasCallback': canChange,
          'hasStartCallback': canChange && onChangeStart != null,
          'hasEndCallback': canChange && onChangeEnd != null,
          'activeColor': activeColor?.toARGB32(),
          'inactiveColor': inactiveColor?.toARGB32(),
        },
        onEvent: (event, payload) {
          if (!canChange || payload is! Map) return;
          final rawStart = payload['start'];
          final rawEnd = payload['end'];
          if (rawStart is! num || rawEnd is! num) return;
          final start = rawStart.toDouble();
          final end = rawEnd.toDouble();
          if (!nativeRange.contains(start) ||
              !nativeRange.contains(end) ||
              start > end) {
            return;
          }
          final next = RangeValues(
            nativeRange.decode(start, divisions: divisions),
            nativeRange.decode(end, divisions: divisions),
          );
          if (event == 'started') onChangeStart?.call(next);
          if (event == 'changed') onChanged?.call(next);
          if (event == 'finished') onChangeEnd?.call(next);
        },
      ),
    );
  }
}
