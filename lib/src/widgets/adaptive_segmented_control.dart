import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../platform/platform_info.dart';
import 'ios26/ios26_segmented_control.dart';
import 'android/android_m3e_platform_view.dart';
import 'android/android_m3e_native_icon.dart';

/// An adaptive segmented control that renders platform-specific styles
///
/// On iOS 26+: Uses native iOS 26 UISegmentedControl with Liquid Glass
/// On iOS <26 (iOS 18 and below): Uses CupertinoSlidingSegmentedControl
/// On Android: Uses Material SegmentedButton
class AdaptiveSegmentedControl extends StatelessWidget {
  /// Creates an adaptive segmented control
  const AdaptiveSegmentedControl({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onValueChanged,
    this.enabled = true,
    this.color,
    this.height = 36.0,
    this.shrinkWrap = false,
    this.sfSymbols,
    this.semanticLabels,
    this.iconSize,
    this.iconColor,
    this.textColor,
    this.selectedTextColor,
  });

  /// Segment labels to display, in order
  final List<String> labels;

  /// The index of the selected segment
  final int selectedIndex;

  /// Called when the user selects a segment
  final ValueChanged<int> onValueChanged;

  /// Whether the control is interactive
  final bool enabled;

  /// Tint color for the selected segment
  final Color? color;

  /// Height of the control
  final double height;

  /// Whether the control should shrink to fit content
  final bool shrinkWrap;

  /// Optional SF Symbol names or IconData
  final List<dynamic>? sfSymbols;

  /// Localized names for Android segments without visible text, including
  /// icon-only and numeric fallback segments.
  final List<String>? semanticLabels;

  /// Icon size
  final double? iconSize;

  /// Icon color
  final Color? iconColor;

  /// Optional text color for unselected segments.
  final Color? textColor;

  /// Optional text color for the selected segment.
  final Color? selectedTextColor;

  @override
  Widget build(BuildContext context) {
    // iOS 26+ - Use native iOS 26 segmented control
    if (PlatformInfo.isIOS26OrHigher()) {
      return IOS26SegmentedControl(
        labels: labels,
        selectedIndex: selectedIndex,
        onValueChanged: onValueChanged,
        enabled: enabled,
        color: color,
        height: height,
        shrinkWrap: shrinkWrap,
        icons: sfSymbols,
        iconSize: iconSize,
        iconColor: iconColor,
        textColor: textColor,
        selectedTextColor: selectedTextColor,
      );
    }

    // iOS <26 (iOS 18 and below) - Use CupertinoSlidingSegmentedControl
    if (PlatformInfo.isIOS) {
      return _buildCupertinoSegmentedControl(context);
    }

    // Android - Use Material SegmentedButton
    if (PlatformInfo.usesNativeAndroidViews) {
      final nativeIcons = sfSymbols?.map((symbol) {
        if (symbol is AndroidM3EIcon) return symbol.name;
        if (symbol is IconData) {
          return resolveAndroidM3EIcon(
            child: Icon(symbol),
            nativeIcon: null,
            parameterName: 'sfSymbols',
          );
        }
        if (symbol is String) {
          for (final icon in AndroidM3EIcon.values) {
            if (icon.name == symbol) return icon.name;
          }
        }
        throw FlutterError(
          'Android segmented-control icons must use a mapped Material '
          'IconData or AndroidM3EIcon value.',
        );
      }).toList();
      final iconCount = nativeIcons?.length ?? 0;
      final itemCount = labels.length > iconCount ? labels.length : iconCount;
      if (itemCount == 0) return const SizedBox.shrink();
      final effectiveSelectedIndex = selectedIndex.clamp(0, itemCount - 1);
      for (var index = 0; index < itemCount; index++) {
        final visibleLabel = index < labels.length ? labels[index].trim() : '';
        if (visibleLabel.isNotEmpty) continue;
        final name = index < (semanticLabels?.length ?? 0)
            ? semanticLabels![index].trim()
            : '';
        if (name.isEmpty) {
          throw FlutterError(
            'AdaptiveSegmentedControl segment $index requires a localized '
            'semanticLabels entry on Android when it has no visible text.',
          );
        }
      }
      var contentHeight = 18.0;
      for (var index = 0; index < itemCount; index++) {
        final text = index < labels.length && labels[index].trim().isNotEmpty
            ? labels[index]
            : index >= iconCount
            ? '${index + 1}'
            : '';
        if (text.isEmpty) continue;
        final painter = TextPainter(
          text: TextSpan(
            text: text,
            style: Theme.of(context).textTheme.labelLarge,
          ),
          textDirection: Directionality.of(context),
          textScaler: MediaQuery.textScalerOf(context),
          maxLines: 1,
        )..layout();
        contentHeight = math.max(contentHeight, painter.height);
        painter.dispose();
      }
      if (iconCount > 0 && iconSize != null) {
        contentHeight = math.max(contentHeight, iconSize!);
      }
      final nativeHeight = math.max(40.0, height);
      final initialHostHeight = math.max(nativeHeight, contentHeight + 16);
      final properties = <String, Object?>{
        'labels': labels,
        'icons': nativeIcons,
        'semanticLabels': semanticLabels,
        'selectedIndex': effectiveSelectedIndex,
        'enabled': enabled,
        'height': nativeHeight,
        'selectedColor': color?.toARGB32(),
        'iconSize': iconSize,
        'iconColor': iconColor?.toARGB32(),
        'textColor': textColor?.toARGB32(),
        'selectedTextColor': selectedTextColor?.toARGB32(),
      };
      void handleEvent(String event, Object? value) {
        if (event == 'selected' &&
            enabled &&
            value is int &&
            value >= 0 &&
            value < itemCount &&
            value != effectiveSelectedIndex) {
          onValueChanged(value);
        }
      }

      if (!shrinkWrap) {
        return AndroidM3EMeasuredHeightView(
          component: 'segmentedButton',
          initialHeight: initialHostHeight,
          properties: properties,
          onEvent: handleEvent,
        );
      }
      final widthMeasurementKey = Object.hashAll(<Object?>[
        ...labels,
        if (nativeIcons != null) ...nativeIcons,
        itemCount,
        iconSize,
        Theme.of(context).textTheme.labelLarge,
        MediaQuery.textScalerOf(context),
        Directionality.of(context),
      ]);
      return LayoutBuilder(
        builder: (context, constraints) {
          final bounded = constraints.maxWidth.isFinite;
          return Align(
            heightFactor: 1,
            child: AndroidM3EMeasuredHeightView(
              component: 'segmentedButton',
              initialHeight: initialHostHeight,
              // A finite first width lets AndroidView mount even in a
              // horizontal scroller. Compose reports its intrinsic width.
              initialWidth: bounded ? constraints.maxWidth : itemCount * 96.0,
              maxWidth: bounded ? constraints.maxWidth : null,
              widthMeasurementKey: widthMeasurementKey,
              properties: {
                ...properties,
                'shrinkWrap': true,
                'allowIntrinsicWidth': !bounded,
              },
              onEvent: handleEvent,
            ),
          );
        },
      );
    }

    // Desktop/web fallback
    return _buildMaterialSegmentedButton(context);
  }

  Widget _buildCupertinoSegmentedControl(BuildContext context) {
    final theme = CupertinoTheme.of(context);
    final effectiveTextColor =
        textColor ??
        theme.textTheme.textStyle.color ??
        (Theme.of(context).brightness == Brightness.dark
            ? CupertinoColors.white
            : CupertinoColors.black);
    final effectiveSelectedTextColor =
        selectedTextColor ??
        (color != null ? CupertinoColors.white : effectiveTextColor);

    // Build children map from labels or icons
    final Map<int, Widget> children = {};

    // Check if using icons
    final useIcons = sfSymbols != null && sfSymbols!.isNotEmpty;
    final itemCount = useIcons ? sfSymbols!.length : labels.length;

    for (int i = 0; i < itemCount; i++) {
      if (useIcons) {
        // Icon mode
        final dynamic icon = sfSymbols![i];
        children[i] = Padding(
          padding: const EdgeInsets.all(8),
          child: icon is IconData
              ? Icon(icon, size: iconSize ?? 20, color: iconColor)
              : Text(icon.toString()),
        );
      } else {
        // Text mode
        children[i] = Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Text(
            labels[i],
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: selectedIndex == i
                  ? effectiveSelectedTextColor
                  : effectiveTextColor,
            ),
          ),
        );
      }
    }

    Widget control = color != null
        ? CupertinoSlidingSegmentedControl<int>(
            children: children,
            groupValue: selectedIndex,
            thumbColor: color!,
            onValueChanged: (int? value) {
              if (enabled && value != null) {
                onValueChanged(value);
              }
            },
          )
        : CupertinoSlidingSegmentedControl<int>(
            children: children,
            groupValue: selectedIndex,
            onValueChanged: (int? value) {
              if (enabled && value != null) {
                onValueChanged(value);
              }
            },
          );

    control = ConstrainedBox(
      constraints: BoxConstraints(minHeight: height),
      child: control,
    );

    if (shrinkWrap) {
      control = Center(child: IntrinsicWidth(child: control));
    }

    return control;
  }

  Widget _buildMaterialSegmentedButton(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveTextColor = textColor ?? theme.colorScheme.onSurface;
    final effectiveSelectedTextColor =
        selectedTextColor ??
        (color != null ? Colors.white : effectiveTextColor);
    final segments = <ButtonSegment<int>>[];

    // Check if using icons
    final useIcons = sfSymbols != null && sfSymbols!.isNotEmpty;
    final itemCount = useIcons ? sfSymbols!.length : labels.length;

    for (int i = 0; i < itemCount; i++) {
      if (useIcons) {
        // Icon mode
        final dynamic icon = sfSymbols![i];
        segments.add(
          ButtonSegment<int>(
            value: i,
            icon: icon is IconData
                ? Icon(icon, size: iconSize ?? 20, color: iconColor)
                : Icon(Icons.circle, size: iconSize ?? 20, color: iconColor),
          ),
        );
      } else {
        // Text mode
        segments.add(
          ButtonSegment<int>(
            value: i,
            label: Text(
              labels[i],
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: selectedIndex == i
                    ? effectiveSelectedTextColor
                    : effectiveTextColor,
              ),
            ),
          ),
        );
      }
    }

    final buttonStyle = SegmentedButton.styleFrom(
      minimumSize: Size.fromHeight(height),
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      selectedBackgroundColor: color,
      selectedForegroundColor: selectedTextColor,
      foregroundColor: textColor,
    );

    Widget control = SegmentedButton<int>(
      segments: segments,
      selected: {selectedIndex},
      onSelectionChanged: enabled
          ? (Set<int> newSelection) {
              if (newSelection.isNotEmpty) {
                onValueChanged(newSelection.first);
              }
            }
          : null,
      style: buttonStyle,
    );

    if (shrinkWrap) {
      control = Center(child: IntrinsicWidth(child: control));
    }

    return control;
  }
}
