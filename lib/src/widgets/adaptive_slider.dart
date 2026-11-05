import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:material_3_expressive/material_3_expressive.dart' as m3e;
import '../platform/platform_info.dart';
import 'android/android_m3e_platform_view.dart';
import 'ios26/ios26_slider.dart';
import '../theme/adaptive_material_expressive_theme.dart';

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
  });

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
  /// On Android: Shown as a tooltip
  final String? label;

  /// The color of the track when the slider is active
  final Color? activeColor;

  /// The color of the thumb
  final Color? thumbColor;

  @override
  Widget build(BuildContext context) {
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

    // Android - Use Material Design Slider
    if (PlatformInfo.isAndroid) {
      if (onChangeStart == null && label == null && value.isFinite) {
        return LayoutBuilder(
          builder: (context, constraints) {
            if (!constraints.maxWidth.isFinite) {
              return _buildAndroidFlutterSlider(context);
            }
            return AndroidM3EPlatformView(
              component: 'slider',
              width: constraints.maxWidth,
              height: 48,
              properties: {
                'value': value,
                'min': min,
                'max': max,
                'divisions': divisions,
                'enabled': onChanged != null,
                'hasCallback': onChanged != null,
                'hasEndCallback': onChangeEnd != null,
                'activeColor': activeColor?.toARGB32(),
                'thumbColor': thumbColor?.toARGB32(),
              },
              onEvent: (event, nextValue) {
                if (nextValue is num) {
                  if (event == 'changed') onChanged?.call(nextValue.toDouble());
                  if (event == 'finished') {
                    onChangeEnd?.call(nextValue.toDouble());
                  }
                }
              },
            );
          },
        );
      }
      return _buildAndroidFlutterSlider(context);
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

  Widget _buildAndroidFlutterSlider(BuildContext context) {
    if (activeColor == null && thumbColor == null && onChangeStart == null) {
      return withAdaptiveMaterialExpressiveTheme(
        context,
        m3e.M3ESlider(
          value: value,
          onChanged: onChanged,
          onChangeEnd: onChangeEnd,
          min: min,
          max: max,
          divisions: divisions,
          label: label,
        ),
      );
    }
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
