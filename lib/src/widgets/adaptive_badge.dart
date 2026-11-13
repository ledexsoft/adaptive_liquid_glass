import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../platform/platform_info.dart';
import 'android/android_m3e_platform_view.dart';

/// An adaptive badge that renders platform-specific badge styles
///
/// On iOS: Uses custom iOS-style badge with Cupertino design
/// On Android: Uses Material Design Badge
///
/// Example:
/// ```dart
/// AdaptiveBadge(
///   count: 5,
///   child: Icon(Icons.notifications),
/// )
/// ```
class AdaptiveBadge extends StatelessWidget {
  /// Creates an adaptive badge
  const AdaptiveBadge({
    super.key,
    this.count,
    this.label,
    this.backgroundColor,
    this.textColor,
    this.showZero = false,
    this.isLarge = false,
    this.semanticsLabel,
    this.alignment,
    this.offset,
    required this.child,
  }) : assert(
         count != null || label != null,
         'Either count or label must be provided',
       );

  /// The count to display in the badge
  ///
  /// If null, [label] must be provided
  final int? count;

  /// The label text to display in the badge
  ///
  /// If null, [count] will be used
  final String? label;

  /// The background color of the badge
  ///
  /// Defaults to the Material error color on Android and red on iOS.
  final Color? backgroundColor;

  /// The text color of the badge
  ///
  /// On Android, the native Badge resolves this from [backgroundColor]: the
  /// matching Material content color for a theme color, or the surrounding
  /// content color otherwise. With the default error background this is
  /// on-error. On iOS the default is white.
  final Color? textColor;

  /// Whether to show the badge when [count] is 0 and [label] is absent.
  ///
  /// Defaults to false
  final bool showZero;

  /// Whether to use a larger badge size (24 dp minimum on Android).
  ///
  /// Defaults to false
  final bool isLarge;

  /// Contextual accessibility description for this badge, such as
  /// "5 unread messages" or "New activity" for a dot badge.
  /// The decorated [child] keeps its own semantics.
  final String? semanticsLabel;

  /// The alignment of the badge relative to the child
  ///
  /// Defaults to top-end alignment
  final AlignmentGeometry? alignment;

  /// The offset of the badge from its default position
  final Offset? offset;

  /// The widget to display the badge on
  final Widget child;

  @override
  Widget build(BuildContext context) {
    // Don't show badge if count is 0 and showZero is false
    if (label == null && count == 0 && !showZero) {
      return child;
    }

    // Display "99+" for counts greater than 99
    final displayText =
        label ??
        (count != null ? (count! > 99 ? '99+' : count!.toString()) : '');
    final description = semanticsLabel?.trim();
    final effectiveSemanticsLabel = description?.isNotEmpty == true
        ? description
        : null;

    // iOS - Use custom iOS-style badge
    if (PlatformInfo.isIOS) {
      return _IOSBadge(
        displayText: displayText,
        backgroundColor: backgroundColor ?? CupertinoColors.systemRed,
        textColor: textColor ?? CupertinoColors.white,
        isLarge: isLarge,
        semanticsLabel: effectiveSemanticsLabel,
        alignment: alignment,
        offset: offset,
        child: child,
      );
    }

    // Android - Use Material Design Badge
    if (PlatformInfo.usesNativeAndroidViews) {
      final minimumSize = isLarge ? 24.0 : 16.0;
      double badgeWidth;
      double badgeHeight;
      if (displayText.isEmpty) {
        badgeWidth = isLarge ? 24.0 : 6.0;
        badgeHeight = badgeWidth;
      } else {
        final textPainter = TextPainter(
          text: TextSpan(
            text: displayText,
            style: Theme.of(context).textTheme.labelSmall,
          ),
          textDirection: Directionality.of(context),
          textScaler: MediaQuery.textScalerOf(context),
          maxLines: 1,
        )..layout();
        badgeWidth = math.max(minimumSize, textPainter.width + 12);
        badgeHeight = math.max(minimumSize, textPainter.height + 2);
        textPainter.dispose();
      }
      // Reserve a safe first frame; Compose reports the actual Badge size.
      return _AndroidMeasuredBadge(
        label: displayText,
        isLarge: isLarge,
        backgroundColor: backgroundColor,
        textColor: textColor,
        semanticsLabel: effectiveSemanticsLabel,
        alignment: alignment,
        offset: offset,
        initialWidth: badgeWidth,
        initialHeight: badgeHeight,
        child: child,
      );
    }

    // Fallback for other platforms (web, desktop, etc.)
    final fallbackBadge = Badge(
      label: displayText.isEmpty
          ? null
          : effectiveSemanticsLabel == null
          ? Text(displayText)
          : Semantics(
              label: effectiveSemanticsLabel,
              child: ExcludeSemantics(child: Text(displayText)),
            ),
      backgroundColor: backgroundColor,
      textColor: textColor,
      isLabelVisible: true,
      alignment: alignment ?? AlignmentDirectional.topEnd,
      offset: offset,
      largeSize: isLarge ? 24 : null,
      child: child,
    );
    return displayText.isEmpty && effectiveSemanticsLabel != null
        ? Semantics(
            container: true,
            explicitChildNodes: true,
            label: effectiveSemanticsLabel,
            child: fallbackBadge,
          )
        : fallbackBadge;
  }
}

class _AndroidMeasuredBadge extends StatefulWidget {
  const _AndroidMeasuredBadge({
    required this.label,
    required this.isLarge,
    required this.backgroundColor,
    required this.textColor,
    required this.semanticsLabel,
    required this.alignment,
    required this.offset,
    required this.child,
    required this.initialWidth,
    required this.initialHeight,
  });

  final String label;
  final bool isLarge;
  final Color? backgroundColor;
  final Color? textColor;
  final String? semanticsLabel;
  final AlignmentGeometry? alignment;
  final Offset? offset;
  final Widget child;
  final double initialWidth;
  final double initialHeight;

  @override
  State<_AndroidMeasuredBadge> createState() => _AndroidMeasuredBadgeState();
}

class _AndroidMeasuredBadgeState extends State<_AndroidMeasuredBadge> {
  double? _measuredWidth;
  double? _measuredHeight;
  int _measurementKey = 0;

  @override
  void didUpdateWidget(covariant _AndroidMeasuredBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.label != widget.label ||
        oldWidget.isLarge != widget.isLarge ||
        oldWidget.initialWidth != widget.initialWidth ||
        oldWidget.initialHeight != widget.initialHeight) {
      _measuredWidth = null;
      _measuredHeight = null;
      _measurementKey++;
    }
  }

  void _handleNativeEvent(String event, Object? value) {
    if (event != 'measuredSize' || value is! Map) return;
    if (value['key'] != _measurementKey) return;
    final width = (value['width'] as num?)?.toDouble();
    final height = (value['height'] as num?)?.toDouble();
    if (width == null ||
        height == null ||
        !width.isFinite ||
        !height.isFinite ||
        width <= 0 ||
        height <= 0) {
      return;
    }
    if ((_measuredWidth == null || (_measuredWidth! - width).abs() > 0.5) ||
        (_measuredHeight == null || (_measuredHeight! - height).abs() > 0.5)) {
      setState(() {
        _measuredWidth = width;
        _measuredHeight = height;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final badgeWidth = _measuredWidth ?? widget.initialWidth;
    final badgeHeight = _measuredHeight ?? widget.initialHeight;
    final usesContentOffset = badgeWidth > 6;
    final horizontalOffset = badgeWidth - (usesContentOffset ? 12 : 6);
    final nativeOffset = widget.alignment == null
        ? Offset(
            Directionality.of(context) == TextDirection.rtl
                ? -horizontalOffset
                : horizontalOffset,
            (usesContentOffset ? 14 : 6) - badgeHeight,
          )
        : Offset.zero;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        widget.child,
        Positioned.fill(
          child: OverflowBox(
            alignment: widget.alignment ?? AlignmentDirectional.topEnd,
            minWidth: 0,
            maxWidth: double.infinity,
            minHeight: 0,
            maxHeight: double.infinity,
            child: Transform.translate(
              offset: nativeOffset + (widget.offset ?? Offset.zero),
              child: AndroidM3EPlatformView(
                component: 'badge',
                hitTestBehavior: PlatformViewHitTestBehavior.transparent,
                width: badgeWidth,
                height: badgeHeight,
                properties: {
                  'label': widget.label,
                  'isLarge': widget.isLarge,
                  'backgroundColor': widget.backgroundColor?.toARGB32(),
                  'textColor': widget.textColor?.toARGB32(),
                  'semanticsLabel': widget.semanticsLabel,
                  'measurementKey': _measurementKey,
                },
                onEvent: _handleNativeEvent,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// iOS-style badge widget
class _IOSBadge extends StatelessWidget {
  const _IOSBadge({
    required this.displayText,
    required this.backgroundColor,
    required this.textColor,
    required this.isLarge,
    required this.semanticsLabel,
    required this.alignment,
    required this.offset,
    required this.child,
  });

  final String displayText;
  final Color backgroundColor;
  final Color textColor;
  final bool isLarge;
  final String? semanticsLabel;
  final AlignmentGeometry? alignment;
  final Offset? offset;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final badgeSize = isLarge ? 24.0 : 18.0;
    final fontSize = isLarge ? 13.0 : 11.0;
    final minWidth = isLarge ? 24.0 : 18.0;

    // Calculate badge position
    final badgeAlignment = alignment ?? Alignment.topRight;
    final badgeOffset = offset ?? const Offset(-4, 4);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        Positioned(
          top:
              badgeAlignment == Alignment.topRight ||
                  badgeAlignment == Alignment.topLeft
              ? badgeOffset.dy
              : null,
          bottom:
              badgeAlignment == Alignment.bottomRight ||
                  badgeAlignment == Alignment.bottomLeft
              ? -badgeOffset.dy
              : null,
          right:
              badgeAlignment == Alignment.topRight ||
                  badgeAlignment == Alignment.bottomRight
              ? badgeOffset.dx
              : null,
          left:
              badgeAlignment == Alignment.topLeft ||
                  badgeAlignment == Alignment.bottomLeft
              ? -badgeOffset.dx
              : null,
          child: Semantics(
            label: semanticsLabel,
            child: ExcludeSemantics(
              excluding: semanticsLabel != null,
              child: Container(
                constraints: BoxConstraints(
                  minWidth: minWidth,
                  minHeight: badgeSize,
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: displayText.length > 1 ? 6 : 0,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(badgeSize / 2),
                ),
                child: Center(
                  child: Text(
                    displayText,
                    style: TextStyle(
                      color: textColor,
                      fontSize: fontSize,
                      fontWeight: FontWeight.w600,
                      height: 1.0,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
