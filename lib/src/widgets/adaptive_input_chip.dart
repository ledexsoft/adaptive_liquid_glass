import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../platform/platform_info.dart';
import 'android/android_m3e_native_icon.dart';
import 'android/android_m3e_platform_view.dart';

/// A selected input value rendered with the real Compose InputChip on Android.
class AdaptiveInputChip extends StatelessWidget {
  const AdaptiveInputChip({
    super.key,
    required this.label,
    required this.selected,
    this.onSelected,
    this.onDismiss,
    this.dismissLabel,
    this.enabled = true,
    this.leadingIcon,
    this.nativeLeadingIcon,
    this.avatarIcon,
    this.nativeAvatarIcon,
    this.avatarImageBytes,
    this.avatarSemanticLabel,
  });

  /// Visible, localized text representing the input value.
  final String label;
  final bool selected;
  final ValueChanged<bool>? onSelected;

  /// Removes this input value when the chip is pressed. Use instead of [onSelected].
  final VoidCallback? onDismiss;

  /// Localized action name for dismissal. Defaults to the app's delete tooltip.
  final String? dismissLabel;

  final bool enabled;

  /// An optional leading icon. An avatar takes precedence when supplied.
  final IconData? leadingIcon;
  final AndroidM3EIcon? nativeLeadingIcon;

  /// Optional icon in the official input-chip avatar slot.
  /// [avatarImageBytes] takes precedence when both are supplied.
  final IconData? avatarIcon;

  /// Explicit Compose avatar icon when [avatarIcon] cannot map to Android.
  final AndroidM3EIcon? nativeAvatarIcon;

  /// PNG, JPEG, or WebP bytes for the chip avatar.
  final Uint8List? avatarImageBytes;

  /// Optional spoken description when the avatar conveys more than [label].
  final String? avatarSemanticLabel;

  @override
  Widget build(BuildContext context) {
    if (label.trim().isEmpty) {
      throw FlutterError('AdaptiveInputChip.label must be nonempty.');
    }
    if (onSelected != null && onDismiss != null) {
      throw FlutterError(
        'AdaptiveInputChip accepts either onSelected or onDismiss.',
      );
    }
    if (dismissLabel != null && dismissLabel!.trim().isEmpty) {
      throw FlutterError('AdaptiveInputChip.dismissLabel must be nonempty.');
    }
    final interactive = enabled && (onSelected != null || onDismiss != null);
    final effectiveDismissLabel = onDismiss == null
        ? null
        : dismissLabel ?? MaterialLocalizations.of(context).deleteButtonTooltip;
    final flutterIcon = leadingIcon == null
        ? null
        : Icon(leadingIcon, size: 18);
    final flutterAvatarIcon = avatarIcon == null
        ? null
        : Icon(avatarIcon, size: 24, semanticLabel: avatarSemanticLabel);
    final avatar = avatarImageBytes == null
        ? flutterAvatarIcon ?? flutterIcon
        : ClipOval(
            child: Image.memory(
              avatarImageBytes!,
              width: 24,
              height: 24,
              fit: BoxFit.cover,
              semanticLabel: avatarSemanticLabel,
            ),
          );
    Widget fallback() => InputChip(
      label: Text(label),
      selected: selected,
      showCheckmark: false,
      isEnabled: enabled,
      onSelected: onSelected,
      onPressed: onDismiss,
      onDeleted: onDismiss,
      deleteButtonTooltipMessage: effectiveDismissLabel,
      avatar: avatar,
    );

    if (!PlatformInfo.usesNativeAndroidViews ||
        (avatarImageBytes == null &&
            flutterAvatarIcon != null &&
            !canResolveAndroidM3EIcon(
              child: flutterAvatarIcon,
              nativeIcon: nativeAvatarIcon,
            )) ||
        (avatarImageBytes == null &&
            flutterAvatarIcon == null &&
            nativeAvatarIcon == null &&
            flutterIcon != null &&
            !canResolveAndroidM3EIcon(
              child: flutterIcon,
              nativeIcon: nativeLeadingIcon,
            ))) {
      return fallback();
    }

    final avatarIconName =
        avatarImageBytes != null ||
            (flutterAvatarIcon == null && nativeAvatarIcon == null)
        ? null
        : resolveAndroidM3EIcon(
            child: flutterAvatarIcon,
            nativeIcon: nativeAvatarIcon,
            parameterName: 'nativeAvatarIcon',
          );
    final iconName =
        avatarImageBytes != null ||
            avatarIconName != null ||
            (flutterIcon == null && nativeLeadingIcon == null)
        ? null
        : resolveAndroidM3EIcon(
            child: flutterIcon,
            nativeIcon: nativeLeadingIcon,
            parameterName: 'nativeLeadingIcon',
          );
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
              (avatarImageBytes != null ||
                      avatarIconName != null ||
                      iconName != null
                  ? 30.0
                  : 0.0) +
              (onDismiss != null ? 26.0 : 0.0),
        );
        final initialHeight = math.max(48.0, painter.height + 16.0);
        painter.dispose();
        return AndroidM3EMeasuredHeightView(
          component: 'inputChip',
          initialWidth: initialWidth,
          initialHeight: initialHeight,
          maxWidth: constraints.maxWidth.isFinite ? constraints.maxWidth : null,
          widthMeasurementKey: (
            label,
            selected,
            iconName,
            avatarIconName,
            avatarImageBytes,
            onDismiss != null,
            initialWidth,
            initialHeight,
          ),
          properties: {
            'label': label,
            'selected': selected,
            'leadingIcon': iconName,
            'avatarIcon': avatarIconName,
            'avatarImageBytes': avatarImageBytes,
            'avatarSemanticLabel': avatarSemanticLabel,
            'dismissible': onDismiss != null,
            'dismissLabel': effectiveDismissLabel,
            if (constraints.maxWidth.isFinite) 'maxWidth': constraints.maxWidth,
            'enabled': interactive,
            'hasCallback': onSelected != null || onDismiss != null,
          },
          onEvent: (event, value) {
            if (event == 'dismissed' && interactive && onDismiss != null) {
              onDismiss!();
              return;
            }
            if (event == 'selectedChanged' &&
                value is bool &&
                value != selected &&
                onDismiss == null &&
                interactive) {
              onSelected?.call(value);
            }
          },
        );
      },
    );
  }
}
