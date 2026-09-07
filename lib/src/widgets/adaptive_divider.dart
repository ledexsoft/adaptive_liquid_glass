import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../platform/platform_info.dart';

/// An adaptive divider that renders platform-specific styles.
///
/// On iOS & macOS: Uses a full-bleed hairline with standard inset styling.
/// On Android: Uses Material 3 [Divider] with the standard vertical margin.
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
    // iOS / macOS - hairline with grouped-table feel
    if (PlatformInfo.isIOS || PlatformInfo.isMacOS) {
      final isDark = MediaQuery.platformBrightnessOf(context) == Brightness.dark;
      final defaultColor = isDark
          ? CupertinoColors.separator.darkColor
          : CupertinoColors.separator.color;
      return Container(
        height: height ?? 1.0,
        margin: EdgeInsets.only(
          left: indent ?? 16.0,
          right: endIndent ?? 0.0,
          top: (height ?? 1.0) > 1 ? 4.0 : 0.0,
          bottom: (height ?? 1.0) > 1 ? 4.0 : 0.0,
        ),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: color ?? defaultColor,
              width: thickness ?? 0.5,
            ),
          ),
        ),
      );
    }

    // Android & other platforms - Material 3 Divider
    return Divider(
      height: height,
      thickness: thickness,
      indent: indent,
      endIndent: endIndent,
      color: color,
    );
  }
}
