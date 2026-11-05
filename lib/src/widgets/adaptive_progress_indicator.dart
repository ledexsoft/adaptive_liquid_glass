import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../platform/platform_info.dart';
import 'android/android_m3e_platform_view.dart';

/// Native Material 3 Expressive active-indicator shape on Android.
enum AdaptiveProgressIndicatorShape { flat, wavy }

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
    this.trackColor,
    this.semanticsLabel,
    this.shape = AdaptiveProgressIndicatorShape.flat,
    this.radius = 10.0,
    this.strokeWidth = 3.0,
    this.animating = true,
  }) : _isLinear = false,
       backgroundColor = null,
       trackThickness = 4.0,
       linearInset = 0.0,
       minHeight = null,
       borderRadius = null;

  /// Creates an adaptive linear progress bar.
  const AdaptiveProgressIndicator.linear({
    super.key,
    this.value,
    this.color,
    this.backgroundColor,
    this.trackColor,
    this.semanticsLabel,
    this.shape = AdaptiveProgressIndicatorShape.flat,
    this.minHeight = 4.0,
    this.trackThickness = 4.0,
    this.linearInset = 4.0,
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

  /// Track color. Defaults to Material 3's secondary-container role on Android.
  /// On circular Cupertino indicators there is no separate track.
  final Color? trackColor;

  /// Accessibility label describing the process and affected content.
  final String? semanticsLabel;

  /// Flat is the baseline shape; wavy opts into the expressive Android variant.
  final AdaptiveProgressIndicatorShape shape;

  /// The background track color (linear mode).
  final Color? backgroundColor;

  /// The radius of the indicator on iOS / macOS (default: 10.0).
  final double radius;

  /// The stroke width of the indicator on Android (default: 3.0).
  final double strokeWidth;

  /// Active and track thickness in logical pixels on Android (default: 4.0).
  final double trackThickness;

  /// Horizontal inset for linear indicators on Android (default: 4 dp).
  final double linearInset;

  /// Whether the Cupertino activity indicator is animating (iOS only).
  final bool animating;

  /// The height of the linear progress bar (default: 4.0).
  final double? minHeight;

  /// Optional border radius for linear progress bar.
  final BorderRadius? borderRadius;

  final bool _isLinear;

  @override
  Widget build(BuildContext context) {
    final Widget indicator;
    if (_isLinear) {
      indicator = _buildLinear(context);
    } else {
      indicator = _buildCircular(context);
    }
    if (semanticsLabel == null || PlatformInfo.isAndroid) return indicator;
    return Semantics(
      label: semanticsLabel,
      value: value == null
          ? null
          : '${(value!.clamp(0.0, 1.0) * 100).round()}%',
      child: indicator,
    );
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
      final androidSize = (radius * 2).clamp(24.0, 240.0).toDouble();
      return AndroidM3EPlatformView(
        component: 'progressIndicator',
        width: androidSize,
        height: androidSize,
        properties: {
          'linear': false,
          'value': value,
          'size': androidSize,
          'strokeWidth': strokeWidth,
          'color': color?.toARGB32(),
          'trackColor': (trackColor ?? backgroundColor)?.toARGB32(),
          'shape': shape.name,
          'semanticsLabel': semanticsLabel,
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
      final effectiveTrackColor = backgroundColor ?? trackColor ?? defaultTrack;

      if (value == null) {
        // Indeterminate on Apple: clean smooth looping bar
        return ClipRRect(
          borderRadius: effectiveRadius,
          child: LinearProgressIndicator(
            color: activeColor,
            backgroundColor: effectiveTrackColor,
            minHeight: minHeight ?? 4.0,
          ),
        );
      }

      return ClipRRect(
        borderRadius: effectiveRadius,
        child: Container(
          height: minHeight ?? 4.0,
          color: effectiveTrackColor,
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
          final expressiveWavyHeight = trackThickness * 3 > 16
              ? trackThickness * 3
              : 16.0;
          final requestedHeight = minHeight ?? expressiveWavyHeight;
          return AndroidM3EPlatformView(
            component: 'progressIndicator',
            width: constraints.maxWidth.isFinite ? constraints.maxWidth : 240,
            height: shape == AdaptiveProgressIndicatorShape.wavy
                ? requestedHeight
                      .clamp(expressiveWavyHeight, double.infinity)
                      .toDouble()
                : (minHeight ?? trackThickness)
                      .clamp(trackThickness, double.infinity)
                      .toDouble(),
            properties: {
              'linear': true,
              'value': value,
              'color': color?.toARGB32(),
              'trackColor': (backgroundColor ?? trackColor)?.toARGB32(),
              'shape': shape.name,
              'trackThickness': trackThickness,
              'linearInset': linearInset,
              'semanticsLabel': semanticsLabel,
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
      backgroundColor: backgroundColor ?? trackColor,
      minHeight: minHeight,
      borderRadius: effectiveRadius,
    );
  }
}
