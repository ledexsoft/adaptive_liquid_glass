import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../platform/platform_info.dart';
import 'android/android_m3e_native_icon.dart';
import 'android/android_m3e_platform_view.dart';

/// A selectable filter chip using Material 3 Expressive Compose on Android.
class AdaptiveFilterChip extends StatelessWidget {
  const AdaptiveFilterChip({
    super.key,
    required this.label,
    required this.selected,
    this.onSelected,
    this.enabled = true,
    this.elevated = false,
    this.showCheckmark = true,
    this.leadingIcon,
    this.nativeLeadingIcon,
    this.trailingIcon,
    this.nativeTrailingIcon,
  });

  /// Visible, localized chip label.
  final String label;

  /// Controlled selection state.
  final bool selected;
  final ValueChanged<bool>? onSelected;
  final bool enabled;

  /// Uses the official elevated filter-chip variant on Android.
  final bool elevated;
  final bool showCheckmark;

  /// Flutter icon for other platforms and for supported native Android icons.
  final IconData? leadingIcon;

  /// Native Android icon when [leadingIcon] cannot identify the desired icon.
  final AndroidM3EIcon? nativeLeadingIcon;

  /// Optional icon in the native FilterChip trailing slot.
  final IconData? trailingIcon;
  final AndroidM3EIcon? nativeTrailingIcon;

  @override
  Widget build(BuildContext context) {
    if (label.trim().isEmpty) {
      throw FlutterError('AdaptiveFilterChip.label must be nonempty.');
    }
    final interactive = enabled && onSelected != null;
    final flutterIcon = leadingIcon == null
        ? null
        : Icon(leadingIcon, size: 18);
    final flutterTrailingIcon = trailingIcon == null
        ? null
        : Icon(trailingIcon, size: 18);
    Widget fallback() {
      final avatar = flutterIcon;
      final content = flutterTrailingIcon == null
          ? Text(label, maxLines: 1, overflow: TextOverflow.ellipsis)
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                flutterTrailingIcon,
              ],
            );
      if (elevated) {
        return FilterChip.elevated(
          label: content,
          selected: selected,
          onSelected: interactive ? onSelected : null,
          showCheckmark: showCheckmark,
          avatar: avatar,
        );
      }
      return FilterChip(
        label: content,
        selected: selected,
        onSelected: interactive ? onSelected : null,
        showCheckmark: showCheckmark,
        avatar: avatar,
      );
    }

    if (!PlatformInfo.usesNativeAndroidViews ||
        (flutterIcon != null &&
            !canResolveAndroidM3EIcon(
              child: flutterIcon,
              nativeIcon: nativeLeadingIcon,
            )) ||
        (flutterTrailingIcon != null &&
            !canResolveAndroidM3EIcon(
              child: flutterTrailingIcon,
              nativeIcon: nativeTrailingIcon,
            ))) {
      return fallback();
    }

    final iconName = flutterIcon == null && nativeLeadingIcon == null
        ? null
        : resolveAndroidM3EIcon(
            child: flutterIcon,
            nativeIcon: nativeLeadingIcon,
            parameterName: 'nativeLeadingIcon',
          );
    final trailingIconName =
        flutterTrailingIcon == null && nativeTrailingIcon == null
        ? null
        : resolveAndroidM3EIcon(
            child: flutterTrailingIcon,
            nativeIcon: nativeTrailingIcon,
            parameterName: 'nativeTrailingIcon',
          );
    final hasLeading = iconName != null || (selected && showCheckmark);
    return LayoutBuilder(
      builder: (context, constraints) {
        final painter = TextPainter(
          text: TextSpan(
            text: label,
            style: Theme.of(context).textTheme.labelLarge,
          ),
          maxLines: 1,
          textDirection: Directionality.of(context),
          textScaler: MediaQuery.textScalerOf(context),
        )..layout();
        final initialWidth = math.max(
          48.0,
          painter.width +
              28.0 +
              (hasLeading ? 26.0 : 0.0) +
              (trailingIconName == null ? 0.0 : 26.0),
        );
        final initialHeight = math.max(48.0, painter.height + 16.0);
        painter.dispose();
        return AndroidM3EMeasuredHeightView(
          component: 'filterChip',
          initialWidth: initialWidth,
          initialHeight: initialHeight,
          maxWidth: constraints.maxWidth.isFinite ? constraints.maxWidth : null,
          widthMeasurementKey: (
            label,
            selected,
            elevated,
            showCheckmark,
            iconName,
            trailingIconName,
            initialWidth,
            initialHeight,
          ),
          properties: {
            'label': label,
            'selected': selected,
            'elevated': elevated,
            'showCheckmark': showCheckmark,
            'leadingIcon': iconName,
            'trailingIcon': trailingIconName,
            if (constraints.maxWidth.isFinite) 'maxWidth': constraints.maxWidth,
            'enabled': interactive,
            'hasCallback': onSelected != null,
          },
          onEvent: (event, value) {
            if (event == 'selectedChanged' &&
                value is bool &&
                value != selected &&
                interactive) {
              onSelected?.call(value);
            }
          },
        );
      },
    );
  }
}
