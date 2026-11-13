import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../platform/platform_info.dart';
import 'android/android_m3e_platform_view.dart';

/// An adaptive divider that renders platform-specific styles.
///
/// On iOS & macOS: Uses a full-bleed hairline with standard inset styling.
/// On Android: Uses native Material 3 [Divider]. A custom [height] centers
/// the line within the reserved vertical space.
class AdaptiveDivider extends StatelessWidget {
  /// Creates an adaptive divider.
  const AdaptiveDivider({
    super.key,
    this.height,
    this.thickness,
    this.indent,
    this.endIndent,
    this.color,
  });

  /// The divider's height (total space it occupies including its margins).
  final double? height;

  /// The divider's thickness.
  final double? thickness;

  /// The amount of empty space to the leading edge of the divider.
  final double? indent;

  /// The amount of empty space to the trailing edge of the divider.
  final double? endIndent;

  /// The color to use when painting the divider.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    _validateDimension('height', height);
    _validateDimension('thickness', thickness);
    _validateDimension('indent', indent);
    _validateDimension('endIndent', endIndent);

    // iOS / macOS - hairline with grouped-table feel
    if (PlatformInfo.isIOS || PlatformInfo.isMacOS) {
      final isDark =
          MediaQuery.platformBrightnessOf(context) == Brightness.dark;
      final defaultColor = isDark
          ? CupertinoColors.separator.darkColor
          : CupertinoColors.separator.color;
      return SizedBox(
        height: height ?? 1.0,
        child: Padding(
          padding: EdgeInsetsDirectional.only(
            start: indent ?? 16.0,
            end: endIndent ?? 0.0,
          ),
          child: Center(
            child: Container(
              width: double.infinity,
              height: thickness ?? 0.5,
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: color ?? defaultColor,
                    width: thickness ?? 0.5,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    // Android - native Compose Material 3 divider.
    if (PlatformInfo.usesNativeAndroidViews) {
      return AndroidM3EPlatformView(
        component: 'divider',
        height: height ?? (thickness ?? 1),
        hitTestBehavior: PlatformViewHitTestBehavior.transparent,
        properties: {
          'thickness': thickness,
          'indent': indent ?? 0,
          'endIndent': endIndent ?? 0,
          'color': color?.toARGB32(),
        },
        onEvent: (_, __) {},
      );
    }
    return Divider(
      height: height,
      thickness: thickness,
      indent: indent,
      endIndent: endIndent,
      color: color,
    );
  }

  void _validateDimension(String name, double? value) {
    if (value != null && (!value.isFinite || value < 0)) {
      throw FlutterError(
        'AdaptiveDivider.$name must be finite and non-negative.',
      );
    }
  }
}

/// A vertical divider using the real Material 3 VerticalDivider on Android.
///
/// Place it in a parent with bounded height, such as a [Row] inside a
/// [SizedBox] with an explicit height. [width] is its total horizontal space; [indent]
/// and [endIndent] leave space above and below the line.
class AdaptiveVerticalDivider extends StatelessWidget {
  const AdaptiveVerticalDivider({
    super.key,
    this.width,
    this.thickness,
    this.indent,
    this.endIndent,
    this.color,
  });

  final double? width;
  final double? thickness;
  final double? indent;
  final double? endIndent;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    for (final (name, value) in [
      ('width', width),
      ('thickness', thickness),
      ('indent', indent),
      ('endIndent', endIndent),
    ]) {
      if (value != null && (!value.isFinite || value < 0)) {
        throw FlutterError(
          'AdaptiveVerticalDivider.$name must be finite and non-negative.',
        );
      }
    }
    final reservedWidth = width ?? (thickness ?? 1);

    if (PlatformInfo.isIOS || PlatformInfo.isMacOS) {
      final isDark =
          MediaQuery.platformBrightnessOf(context) == Brightness.dark;
      final defaultColor = isDark
          ? CupertinoColors.separator.darkColor
          : CupertinoColors.separator.color;
      return SizedBox(
        width: reservedWidth,
        child: Padding(
          padding: EdgeInsets.only(top: indent ?? 0, bottom: endIndent ?? 0),
          child: Center(
            child: SizedBox(
              width: thickness ?? 0.5,
              height: double.infinity,
              child: ColoredBox(color: color ?? defaultColor),
            ),
          ),
        ),
      );
    }

    if (PlatformInfo.usesNativeAndroidViews) {
      return AndroidM3EPlatformView(
        component: 'divider',
        width: reservedWidth,
        hitTestBehavior: PlatformViewHitTestBehavior.transparent,
        properties: {
          'orientation': 'vertical',
          'thickness': thickness,
          'indent': indent ?? 0,
          'endIndent': endIndent ?? 0,
          'color': color?.toARGB32(),
        },
        onEvent: (_, __) {},
      );
    }

    return VerticalDivider(
      width: reservedWidth,
      thickness: thickness,
      indent: indent,
      endIndent: endIndent,
      color: color,
    );
  }
}
