import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../platform/platform_info.dart';
import 'android/android_m3e_platform_view.dart';

/// An adaptive progress indicator that renders platform-specific styles.
///
/// On iOS & macOS: Uses [CupertinoActivityIndicator] with native spin or partial reveal.
/// On Android: Uses native Compose Material 3 Expressive progress indicators.
///
/// For linear progress, use [AdaptiveProgressIndicator.linear].
///
/// Example:
/// ```dart
/// // Indeterminate spinner
/// AdaptiveProgressIndicator()
///
/// // Determinate spinner
/// AdaptiveProgressIndicator(value: 0.65)
///
/// // Linear progress bar
/// AdaptiveProgressIndicator.linear(value: 0.5)
/// ```
class AdaptiveProgressIndicator extends StatelessWidget {
  /// Creates an adaptive circular progress / activity indicator.
  const AdaptiveProgressIndicator({
    super.key,
    this.value,
    this.color,
    this.radius = 10.0,
    this.strokeWidth = 3.0,
    this.animating = true,
  }) : _isLinear = false,
       backgroundColor = null,
       minHeight = null,
       borderRadius = null;

  /// Creates an adaptive linear progress bar.
  const AdaptiveProgressIndicator.linear({
    super.key,
    this.value,
    this.color,
    this.backgroundColor,
    this.minHeight = 4.0,
    this.borderRadius,
  }) : _isLinear = true,
       radius = 10.0,
       strokeWidth = 3.0,
       animating = true;

  /// The progress value between 0.0 and 1.0.
  /// If null, the indicator is indeterminate.
  final double? value;

  /// The color of the indicator.
  final Color? color;

  /// The background track color (linear mode).
  final Color? backgroundColor;

  /// The radius of the indicator on iOS / macOS (default: 10.0).
  final double radius;

  /// The stroke width of the indicator on Android (default: 3.0).
  final double strokeWidth;

  /// Whether the Cupertino activity indicator is animating (iOS only).
  final bool animating;

  /// The height of the linear progress bar (default: 4.0).
  final double? minHeight;

  /// Optional border radius for linear progress bar.
  final BorderRadius? borderRadius;

  final bool _isLinear;

  @override
  Widget build(BuildContext context) {
    if (_isLinear) {
      return _buildLinear(context);
    }
    return _buildCircular(context);
  }

  Widget _buildCircular(BuildContext context) {
    if (PlatformInfo.isIOS || PlatformInfo.isMacOS) {
      if (value != null) {
        return CupertinoActivityIndicator.partiallyRevealed(
          radius: radius,
          color: color,
          progress: value!.clamp(0.0, 1.0),
        );
      }
      return CupertinoActivityIndicator(
        radius: radius,
        color: color,
        animating: animating,
      );
    }

    // Android & other platforms
    if (PlatformInfo.isAndroid) {
      return AndroidM3EPlatformView(
        component: 'progressIndicator',
        width: radius * 2,
        height: radius * 2,
        properties: {
          'linear': false,
          'value': value,
          'size': radius * 2,
          'strokeWidth': strokeWidth,
          'color': color?.toARGB32(),
        },
        onEvent: (_, __) {},
      );
    }
    return CircularProgressIndicator(
      value: value,
      color: color,
      strokeWidth: strokeWidth,
    );
  }

  Widget _buildLinear(BuildContext context) {
    final effectiveRadius =
        borderRadius ?? BorderRadius.circular((minHeight ?? 4.0) / 2);

    if (PlatformInfo.isIOS || PlatformInfo.isMacOS) {
      final isDark =
          MediaQuery.platformBrightnessOf(context) == Brightness.dark;
      final defaultTrack = isDark
          ? CupertinoColors.systemGrey5.darkColor
          : CupertinoColors.systemGrey5.color;
      final activeColor = color ?? CupertinoTheme.of(context).primaryColor;

      if (value == null) {
        // Indeterminate on Apple: clean smooth looping bar
        return ClipRRect(
          borderRadius: effectiveRadius,
          child: LinearProgressIndicator(
            color: activeColor,
            backgroundColor: backgroundColor ?? defaultTrack,
            minHeight: minHeight ?? 4.0,
          ),
        );
      }

      return ClipRRect(
        borderRadius: effectiveRadius,
        child: Container(
          height: minHeight ?? 4.0,
          color: backgroundColor ?? defaultTrack,
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: value!.clamp(0.0, 1.0),
            child: Container(color: activeColor),
          ),
        ),
      );
    }

    // Android uses a native Compose Material 3 Expressive progress indicator.
    if (PlatformInfo.isAndroid) {
      return LayoutBuilder(
        builder: (context, constraints) {
          return AndroidM3EPlatformView(
            component: 'progressIndicator',
            width: constraints.maxWidth.isFinite ? constraints.maxWidth : 240,
            height: minHeight ?? 4.0,
            properties: {
              'linear': true,
              'value': value,
              'color': color?.toARGB32(),
              'trackColor': backgroundColor?.toARGB32(),
              'borderRadius': borderRadius?.topLeft.x,
            },
            onEvent: (_, __) {},
          );
        },
      );
    }
    return LinearProgressIndicator(
      value: value,
      color: color,
      backgroundColor: backgroundColor,
      minHeight: minHeight,
      borderRadius: effectiveRadius,
    );
  }
}
