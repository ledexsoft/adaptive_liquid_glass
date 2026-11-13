import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../platform/platform_info.dart';
import 'adaptive_progress_value.dart';
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
    this.androidSize,
    this.strokeWidth = 4.0,
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
    this.shape = AdaptiveProgressIndicatorShape.wavy,
    this.minHeight,
    this.trackThickness = 4.0,
    this.linearInset = 0.0,
    this.borderRadius,
  }) : _isLinear = true,
       radius = 10.0,
       androidSize = null,
       strokeWidth = 4.0,
       animating = true;

  /// The progress value between 0.0 and 1.0.
  /// If null, the indicator is indeterminate.
  final double? value;

  /// The color of the indicator.
  final Color? color;

  /// Track color. Android uses the native Material 3 default for the selected
  /// indicator variant when this is null.
  /// On circular Cupertino indicators there is no separate track.
  final Color? trackColor;

  /// Accessibility label describing the process and affected content.
  final String? semanticsLabel;

  /// Flat is the circular default; use [AdaptiveProgressIndicatorShape.wavy]
  /// for the expressive waveform. Linear indicators default to wavy.
  final AdaptiveProgressIndicatorShape shape;

  /// The background track color (linear mode).
  final Color? backgroundColor;

  /// The radius on iOS / macOS (default: 10.0). On Android, a nondefault
  /// radius sets the circular diameter when [androidSize] is absent.
  final double radius;

  /// Circular container size on Android. Defaults to the native 40 dp flat or
  /// 48 dp wavy token; set this to customize Android independently of [radius].
  final double? androidSize;

  /// The stroke width of the indicator on Android (default: 4.0).
  final double strokeWidth;

  /// Active and track thickness in logical pixels on Android (default: 4.0).
  /// For a flat bar, a larger [minHeight] also increases the native stroke
  /// thickness; the wavy stroke retains this value inside its taller container.
  final double trackThickness;

  /// Horizontal inset for linear indicators on Android (default: 0 dp).
  final double linearInset;

  /// Whether the Cupertino activity indicator is animating (iOS only).
  final bool animating;

  /// Optional linear height. For a flat Android indicator this is also the
  /// stroke thickness; for a wavy indicator it expands the container around
  /// the [trackThickness] stroke. Other platforms use 4.0 when null.
  final double? minHeight;

  /// Optional border radius for the linear progress bar. On Android this clips
  /// the native Compose indicator to the supplied corners.
  final BorderRadius? borderRadius;

  final bool _isLinear;

  @override
  Widget build(BuildContext context) {
    final normalizedValue = normalizeAdaptiveProgress(value);
    final Widget indicator;
    if (_isLinear) {
      indicator = _buildLinear(context, normalizedValue);
    } else {
      indicator = _buildCircular(context, normalizedValue);
    }
    if (semanticsLabel == null || PlatformInfo.usesNativeAndroidViews) {
      return indicator;
    }
    return Semantics(
      label: semanticsLabel,
      value: normalizedValue == null
          ? null
          : '${(normalizedValue * 100).round()}%',
      child: indicator,
    );
  }

  Widget _buildCircular(BuildContext context, double? normalizedValue) {
    if (PlatformInfo.isIOS || PlatformInfo.isMacOS) {
      if (normalizedValue != null) {
        return CupertinoActivityIndicator.partiallyRevealed(
          radius: radius,
          color: color,
          progress: normalizedValue,
        );
      }
      return CupertinoActivityIndicator(
        radius: radius,
        color: color,
        animating: animating,
      );
    }

    // Android & other platforms
    if (PlatformInfo.usesNativeAndroidViews) {
      if (!strokeWidth.isFinite || strokeWidth < 0) {
        throw FlutterError(
          'AdaptiveProgressIndicator.strokeWidth must be finite and non-negative on Android.',
        );
      }
      if (androidSize case final configuredSize?
          when !configuredSize.isFinite || configuredSize <= 0) {
        throw FlutterError(
          'AdaptiveProgressIndicator.androidSize must be finite and positive.',
        );
      }
      if (androidSize == null && (!radius.isFinite || radius <= 0)) {
        throw FlutterError(
          'AdaptiveProgressIndicator.radius must be finite and positive when used as the Android circular size.',
        );
      }
      final resolvedAndroidSize =
          androidSize ??
          (radius == 10.0
              ? (shape == AdaptiveProgressIndicatorShape.wavy ? 48.0 : 40.0)
              : radius * 2);
      return AndroidM3EPlatformView(
        component: 'progressIndicator',
        width: resolvedAndroidSize,
        height: resolvedAndroidSize,
        hitTestBehavior: PlatformViewHitTestBehavior.transparent,
        properties: {
          'linear': false,
          'value': normalizedValue,
          'size': resolvedAndroidSize,
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
      value: normalizedValue,
      color: color,
      strokeWidth: strokeWidth,
    );
  }

  Widget _buildLinear(BuildContext context, double? normalizedValue) {
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

      if (normalizedValue == null) {
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
            widthFactor: normalizedValue,
            child: Container(color: activeColor),
          ),
        ),
      );
    }

    // Android uses a native Compose Material 3 Expressive progress indicator.
    if (PlatformInfo.usesNativeAndroidViews) {
      if (!trackThickness.isFinite || trackThickness < 0) {
        throw FlutterError(
          'AdaptiveProgressIndicator.trackThickness must be finite and non-negative on Android.',
        );
      }
      if (!linearInset.isFinite || linearInset < 0) {
        throw FlutterError(
          'AdaptiveProgressIndicator.linearInset must be finite and non-negative on Android.',
        );
      }
      if (minHeight case final configuredHeight?
          when !configuredHeight.isFinite || configuredHeight < 0) {
        throw FlutterError(
          'AdaptiveProgressIndicator.minHeight must be finite and non-negative on Android.',
        );
      }
      if (borderRadius case final corners?) {
        final radii = [
          corners.topLeft,
          corners.topRight,
          corners.bottomRight,
          corners.bottomLeft,
        ];
        if (radii.any(
          (radius) =>
              !radius.x.isFinite ||
              !radius.y.isFinite ||
              radius.x < 0 ||
              radius.y < 0,
        )) {
          throw FlutterError(
            'AdaptiveProgressIndicator.borderRadius must have finite, '
            'non-negative corner radii on Android.',
          );
        }
      }
      return LayoutBuilder(
        builder: (context, constraints) {
          final expressiveWavyHeight = (trackThickness + 6).clamp(
            10.0,
            double.infinity,
          );
          final requestedHeight = minHeight ?? expressiveWavyHeight;
          final nativeHeight = shape == AdaptiveProgressIndicatorShape.wavy
              ? requestedHeight
                    .clamp(expressiveWavyHeight, double.infinity)
                    .toDouble()
              : (minHeight ?? trackThickness)
                    .clamp(trackThickness, double.infinity)
                    .toDouble();
          return AndroidM3EPlatformView(
            component: 'progressIndicator',
            width: constraints.maxWidth.isFinite ? constraints.maxWidth : 240,
            height: nativeHeight,
            hitTestBehavior: PlatformViewHitTestBehavior.transparent,
            properties: {
              'linear': true,
              'value': normalizedValue,
              'color': color?.toARGB32(),
              'trackColor': (backgroundColor ?? trackColor)?.toARGB32(),
              'shape': shape.name,
              'trackThickness': trackThickness,
              'containerHeight': nativeHeight,
              'linearInset': linearInset,
              'semanticsLabel': semanticsLabel,
              'cornerRadii': borderRadius == null
                  ? null
                  : {
                      'topLeftX': borderRadius!.topLeft.x,
                      'topLeftY': borderRadius!.topLeft.y,
                      'topRightX': borderRadius!.topRight.x,
                      'topRightY': borderRadius!.topRight.y,
                      'bottomRightX': borderRadius!.bottomRight.x,
                      'bottomRightY': borderRadius!.bottomRight.y,
                      'bottomLeftX': borderRadius!.bottomLeft.x,
                      'bottomLeftY': borderRadius!.bottomLeft.y,
                    },
            },
            onEvent: (_, __) {},
          );
        },
      );
    }
    return LinearProgressIndicator(
      value: normalizedValue,
      color: color,
      backgroundColor: backgroundColor ?? trackColor,
      minHeight: minHeight,
      borderRadius: effectiveRadius,
    );
  }
}
