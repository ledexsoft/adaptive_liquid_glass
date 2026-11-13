import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../platform/platform_info.dart';
import 'android/android_m3e_platform_view.dart';
import 'android/android_m3e_slider_range.dart';
import 'ios26/ios26_slider.dart';

/// An adaptive slider that renders platform-specific slider styles
///
/// On iOS 26+: Uses native iOS 26 UISlider with native animations
/// On iOS <26 (iOS 18 and below): Uses CupertinoSlider with traditional iOS styling
/// On Android: Uses Material Design Slider
///
/// Example:
/// ```dart
/// double _value = 0.5;
///
/// AdaptiveSlider(
///   value: _value,
///   onChanged: (double newValue) {
///     setState(() {
///       _value = newValue;
///     });
///   },
/// )
/// ```
class AdaptiveSlider extends StatelessWidget {
  /// Creates an adaptive slider
  const AdaptiveSlider({
    super.key,
    required this.value,
    required this.onChanged,
    this.onChangeStart,
    this.onChangeEnd,
    this.min = 0.0,
    this.max = 1.0,
    this.divisions,
    this.label,
    this.activeColor,
    this.thumbColor,
    this.centeredTrack = false,
  }) : height = null,
       width = 48,
       topToBottom = true,
       _isVertical = false,
       assert(min <= max),
       assert(min > double.negativeInfinity && min < double.infinity),
       assert(max > double.negativeInfinity && max < double.infinity),
       assert(value > double.negativeInfinity && value < double.infinity),
       assert(
         value >= min && value <= max,
         'Value $value is not between minimum $min and maximum $max',
       ),
       assert(divisions == null || divisions > 0);

  /// Creates a vertical slider using Compose's real `VerticalSlider` on Android.
  ///
  /// [height] must be finite and positive. [width] reserves at least the
  /// 48 dp Material touch target. Other platforms orient their Flutter slider
  /// vertically because UIKit has no vertical slider control.
  const AdaptiveSlider.vertical({
    super.key,
    required this.value,
    required this.onChanged,
    required this.height,
    this.width = 48,
    this.topToBottom = true,
    this.onChangeStart,
    this.onChangeEnd,
    this.min = 0.0,
    this.max = 1.0,
    this.divisions,
    this.label,
    this.activeColor,
    this.thumbColor,
    this.centeredTrack = false,
  }) : _isVertical = true,
       assert(min <= max),
       assert(min > double.negativeInfinity && min < double.infinity),
       assert(max > double.negativeInfinity && max < double.infinity),
       assert(value > double.negativeInfinity && value < double.infinity),
       assert(
         value >= min && value <= max,
         'Value $value is not between minimum $min and maximum $max',
       ),
       assert(divisions == null || divisions > 0);

  /// The currently selected value for this slider
  ///
  /// The slider's thumb is drawn at a position that corresponds to this value.
  final double value;

  /// Called when the user is selecting a new value for the slider by dragging
  ///
  /// The slider passes the new value to the callback but does not actually
  /// change state until the parent widget rebuilds the slider with the new
  /// value.
  ///
  /// If null, the slider will be displayed as disabled.
  final ValueChanged<double>? onChanged;

  /// Called when the user starts selecting a new value for the slider
  final ValueChanged<double>? onChangeStart;

  /// Called when the user is done selecting a new value for the slider
  final ValueChanged<double>? onChangeEnd;

  /// The minimum value the user can select
  final double min;

  /// The maximum value the user can select
  final double max;

  /// The number of discrete divisions
  ///
  /// On iOS: Ignored (native sliders are always continuous)
  /// On Android: Used to create discrete steps
  final int? divisions;

  /// A label to show above the slider when active
  ///
  /// On iOS: Ignored (native sliders don't show labels)
  /// On Android: Shown in Compose's native thumb label during press or hover
  final String? label;

  /// The color of the track when the slider is active
  final Color? activeColor;

  /// The color of the thumb
  final Color? thumbColor;

  /// Uses Compose's native track that fills outward from the center on Android.
  /// Other platforms retain their standard slider track.
  final bool centeredTrack;

  /// Height reserved for a vertical slider; null for the horizontal variant.
  final double? height;

  /// Width reserved for a vertical slider, including its touch target.
  final double width;

  /// Whether the vertical slider increases from top to bottom.
  final bool topToBottom;

  final bool _isVertical;

  @override
  Widget build(BuildContext context) {
    if (_isVertical) {
      if (height == null || !height!.isFinite || height! <= 0) {
        throw FlutterError(
          'AdaptiveSlider.vertical height must be finite and positive.',
        );
      }
      if (!width.isFinite || width < 48) {
        throw FlutterError(
          'AdaptiveSlider.vertical width must be finite and at least 48.',
        );
      }
      if (!PlatformInfo.usesNativeAndroidViews) {
        final Widget fallback = PlatformInfo.isIOS
            ? CupertinoSlider(
                value: value,
                onChanged: onChanged,
                onChangeStart: onChangeStart,
                onChangeEnd: onChangeEnd,
                min: min,
                max: max,
                activeColor: activeColor,
                thumbColor: thumbColor ?? CupertinoColors.white,
              )
            : Slider(
                value: value,
                onChanged: onChanged,
                onChangeStart: onChangeStart,
                onChangeEnd: onChangeEnd,
                min: min,
                max: max,
                divisions: divisions,
                label: label,
                activeColor: activeColor,
                thumbColor: thumbColor,
              );
        return SizedBox(
          width: width,
          height: height,
          child: RotatedBox(
            quarterTurns: topToBottom ? 1 : 3,
            child: SizedBox(width: height, height: width, child: fallback),
          ),
        );
      }
    }

    // iOS 26+ - Use native iOS 26 slider
    if (PlatformInfo.isIOS26OrHigher()) {
      return IOS26Slider(
        value: value,
        onChanged: onChanged,
        onChangeStart: onChangeStart,
        onChangeEnd: onChangeEnd,
        min: min,
        max: max,
        activeColor: activeColor,
        thumbColor: thumbColor,
      );
    }

    // iOS 18 and below - Use traditional CupertinoSlider
    if (PlatformInfo.isIOS) {
      return CupertinoSlider(
        value: value,
        onChanged: onChanged,
        onChangeStart: onChangeStart,
        onChangeEnd: onChangeEnd,
        min: min,
        max: max,
        activeColor: activeColor,
        thumbColor: thumbColor ?? CupertinoColors.white,
      );
    }

    // Android - Use the native Compose Material 3 slider for every option.
    if (PlatformInfo.usesNativeAndroidViews) {
      if (!min.isFinite ||
          !max.isFinite ||
          !value.isFinite ||
          min > max ||
          value < min ||
          value > max ||
          (divisions != null && divisions! <= 0)) {
        throw FlutterError(
          'Android AdaptiveSlider requires a finite value within an ordered '
          'range and positive divisions.',
        );
      }
      final hasTrack = min < max;
      final canChange = onChanged != null && hasTrack;
      final nativeRange = AndroidM3ESliderRange(min, max, divisions);
      Widget nativeView(double hostWidth, double hostHeight) =>
          AndroidM3EPlatformView(
            component: 'slider',
            width: hostWidth,
            height: hostHeight,
            properties: {
              if (_isVertical) 'orientation': 'vertical',
              if (_isVertical) 'topToBottom': topToBottom,
              'value': nativeRange.encode(value),
              'min': nativeRange.nativeMin,
              'max': nativeRange.nativeMax,
              'divisions': divisions,
              'label': label,
              'centeredTrack': centeredTrack,
              'enabled': canChange,
              'hasCallback': canChange,
              'hasStartCallback': canChange && onChangeStart != null,
              'hasEndCallback': canChange && onChangeEnd != null,
              'activeColor': activeColor?.toARGB32(),
              'thumbColor': thumbColor?.toARGB32(),
            },
            onEvent: (event, nextValue) {
              if (!canChange || nextValue is! num) return;
              final next = nextValue.toDouble();
              if (!nativeRange.contains(next)) return;
              final bounded = nativeRange.decode(next, divisions: divisions);
              if (event == 'started') onChangeStart?.call(bounded);
              if (event == 'changed') onChanged?.call(bounded);
              if (event == 'finished') onChangeEnd?.call(bounded);
            },
          );
      if (_isVertical) return nativeView(width, height!);
      return LayoutBuilder(
        builder: (context, constraints) => nativeView(
          constraints.maxWidth.isFinite ? constraints.maxWidth : 240,
          48,
        ),
      );
    }

    // Fallback for other platforms (web, desktop, etc.)
    return Slider(
      value: value,
      onChanged: onChanged,
      onChangeStart: onChangeStart,
      onChangeEnd: onChangeEnd,
      min: min,
      max: max,
      divisions: divisions,
      label: label,
      activeColor: activeColor,
      thumbColor: thumbColor,
    );
  }
}
