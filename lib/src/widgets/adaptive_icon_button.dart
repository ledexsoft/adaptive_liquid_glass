import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../platform/platform_info.dart';
import 'adaptive_ai_sparkle_icon.dart';
import 'android/android_m3e_native_icon.dart';
import 'android/android_m3e_platform_view.dart';

/// Icon button that uses the native Android Material 3 Expressive control.
class AdaptiveIconButton extends StatelessWidget {
  const AdaptiveIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.tooltip,
    this.semanticLabel,
    this.variant = AdaptiveIconButtonVariant.standard,
    this.size = AdaptiveIconButtonSize.small,
    this.shape = AdaptiveIconButtonShape.round,
    this.width = AdaptiveIconButtonWidth.defaultWidth,
    this.isSelected,
    this.selectedIcon,
    this.badgeValue,
    this.badgeSemanticsLabel,
    this.enableFeedback,
    this.nativeIcon,
    this.nativeSelectedIcon,
    this.aiPowered = false,
    this.backgroundColor,
    this.foregroundColor,
    this.selectedBackgroundColor,
    this.selectedForegroundColor,
  });

  final Widget icon;
  final VoidCallback? onPressed;

  /// Tooltip text. On native Android, defaults to the resolved action label.
  final String? tooltip;

  /// Localized accessible name for the action. Native Android requires this,
  /// [tooltip], or a nonblank [Icon.semanticLabel].
  final String? semanticLabel;
  final AdaptiveIconButtonVariant variant;
  final AdaptiveIconButtonSize size;
  final AdaptiveIconButtonShape shape;
  final AdaptiveIconButtonWidth width;
  final bool? isSelected;
  final Widget? selectedIcon;
  final Object? badgeValue;

  /// Contextual accessibility description for [badgeValue] on Android.
  /// For example, "3 unread alerts" instead of the bare number "3".
  final String? badgeSemanticsLabel;

  /// Controls platform sound or haptic feedback where supported. On native
  /// Android, false silences the Compose click sound but keeps the ripple.
  final bool? enableFeedback;
  final AndroidM3EIcon? nativeIcon;

  /// Android selected-state icon; a Flutter [selectedIcon] is optional.
  final AndroidM3EIcon? nativeSelectedIcon;

  /// Adds the AI sparkle to the action icon. Off by default.
  final bool aiPowered;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? selectedBackgroundColor;
  final Color? selectedForegroundColor;

  @override
  Widget build(BuildContext context) {
    if (PlatformInfo.usesNativeAndroidViews) {
      final hasSelectedIcon =
          selectedIcon != null || nativeSelectedIcon != null;
      final useSelectedIcon = isSelected == true && hasSelectedIcon;
      final effectiveIcon = useSelectedIcon ? selectedIcon ?? icon : icon;
      final effectiveNative = useSelectedIcon ? nativeSelectedIcon : nativeIcon;
      final nativeSemanticLabel =
          <String?>[
            semanticLabel,
            tooltip,
            if (effectiveIcon is Icon) effectiveIcon.semanticLabel,
            if (icon is Icon) (icon as Icon).semanticLabel,
          ].whereType<String>().firstWhere(
            (value) => value.trim().isNotEmpty,
            orElse: () => '',
          );
      if (!canSerializeAndroidM3EIconStyle(icon) ||
          !canSerializeAndroidM3EIconStyle(selectedIcon) ||
          !canResolveAndroidM3EIcon(
            child: effectiveIcon,
            nativeIcon: effectiveNative,
          ) ||
          (hasSelectedIcon &&
              !canResolveAndroidM3EIcon(
                child: selectedIcon,
                nativeIcon: nativeSelectedIcon,
              ))) {
        return IconButton(
          onPressed: onPressed,
          tooltip: tooltip ?? semanticLabel,
          isSelected: isSelected,
          selectedIcon: selectedIcon,
          icon: Semantics(label: semanticLabel, child: effectiveIcon),
        );
      }
      if (nativeSemanticLabel.isEmpty) {
        throw FlutterError(
          'An Android AdaptiveIconButton requires a nonblank semanticLabel, tooltip, or Icon.semanticLabel.',
        );
      }
      final explicitIconSize = effectiveIcon is Icon
          ? effectiveIcon.size
          : null;
      return AndroidM3EPlatformView(
        component: 'iconButton',
        width: math.max(
          math.max(48.0, _containerWidth),
          explicitIconSize ?? 0.0,
        ),
        height: math.max(
          math.max(48.0, _containerHeight),
          explicitIconSize ?? 0.0,
        ),
        properties: {
          'icon': resolveAndroidM3EIcon(
            child: effectiveIcon,
            nativeIcon: effectiveNative,
            parameterName: 'nativeIcon',
          ),
          'iconSizeOverride': effectiveIcon is Icon ? effectiveIcon.size : null,
          'iconColorOverride': effectiveIcon is Icon
              ? effectiveIcon.color?.toARGB32()
              : null,
          'aiPowered': aiPowered,
          'selectedIcon': !hasSelectedIcon
              ? null
              : resolveAndroidM3EIcon(
                  child: selectedIcon,
                  nativeIcon: nativeSelectedIcon,
                  parameterName: 'nativeSelectedIcon',
                ),
          'variant': variant.name,
          'size': size.name,
          'sizeDp': _containerHeight,
          'width': width.name,
          'widthDp': _containerWidth,
          'shape': shape.name,
          'selected': isSelected,
          'badge': badgeValue?.toString(),
          'badgeSemanticsLabel': badgeSemanticsLabel,
          'enabled': onPressed != null,
          'tooltip': tooltip?.trim().isNotEmpty == true
              ? tooltip
              : nativeSemanticLabel,
          'semanticLabel': nativeSemanticLabel,
          'backgroundColor': backgroundColor?.toARGB32(),
          'foregroundColor': foregroundColor?.toARGB32(),
          'selectedBackgroundColor': selectedBackgroundColor?.toARGB32(),
          'selectedForegroundColor': selectedForegroundColor?.toARGB32(),
          'enableFeedback': enableFeedback,
        },
        onEvent: (event, _) {
          if (event == 'pressed' || event == 'selectionChanged') {
            onPressed?.call();
          }
        },
      );
    }

    final resolvedIcon = isSelected == true && selectedIcon != null
        ? selectedIcon!
        : icon;
    final decoratedIcon = aiPowered
        ? AdaptiveAiSparkleIcon(
            icon: resolvedIcon,
            nativeIcon: isSelected == true && selectedIcon != null
                ? nativeSelectedIcon
                : nativeIcon,
            size: 24,
          )
        : resolvedIcon;
    if (PlatformInfo.isIOS) {
      return CupertinoButton(
        padding: const EdgeInsets.all(10),
        onPressed: onPressed,
        child: Semantics(label: semanticLabel, child: decoratedIcon),
      );
    }
    return IconButton(
      onPressed: onPressed,
      tooltip: tooltip ?? semanticLabel,
      isSelected: isSelected,
      selectedIcon: selectedIcon,
      icon: decoratedIcon,
    );
  }

  double get _containerHeight => switch (size) {
    AdaptiveIconButtonSize.extraSmall => 32,
    AdaptiveIconButtonSize.small => 40,
    AdaptiveIconButtonSize.medium => 56,
    AdaptiveIconButtonSize.large => 96,
    AdaptiveIconButtonSize.extraLarge => 136,
  };

  double get _containerWidth => switch ((size, width)) {
    (AdaptiveIconButtonSize.extraSmall, AdaptiveIconButtonWidth.narrow) => 28,
    (AdaptiveIconButtonSize.extraSmall, AdaptiveIconButtonWidth.defaultWidth) =>
      32,
    (AdaptiveIconButtonSize.extraSmall, AdaptiveIconButtonWidth.wide) => 40,
    (AdaptiveIconButtonSize.small, AdaptiveIconButtonWidth.narrow) => 32,
    (AdaptiveIconButtonSize.small, AdaptiveIconButtonWidth.defaultWidth) => 40,
    (AdaptiveIconButtonSize.small, AdaptiveIconButtonWidth.wide) => 52,
    (AdaptiveIconButtonSize.medium, AdaptiveIconButtonWidth.narrow) => 48,
    (AdaptiveIconButtonSize.medium, AdaptiveIconButtonWidth.defaultWidth) => 56,
    (AdaptiveIconButtonSize.medium, AdaptiveIconButtonWidth.wide) => 72,
    (AdaptiveIconButtonSize.large, AdaptiveIconButtonWidth.narrow) => 64,
    (AdaptiveIconButtonSize.large, AdaptiveIconButtonWidth.defaultWidth) => 96,
    (AdaptiveIconButtonSize.large, AdaptiveIconButtonWidth.wide) => 128,
    (AdaptiveIconButtonSize.extraLarge, AdaptiveIconButtonWidth.narrow) => 104,
    (AdaptiveIconButtonSize.extraLarge, AdaptiveIconButtonWidth.defaultWidth) =>
      136,
    (AdaptiveIconButtonSize.extraLarge, AdaptiveIconButtonWidth.wide) => 184,
  };
}

enum AdaptiveIconButtonVariant { standard, filled, tonal, outlined }

enum AdaptiveIconButtonSize { extraSmall, small, medium, large, extraLarge }

enum AdaptiveIconButtonShape { round, square }

enum AdaptiveIconButtonWidth { defaultWidth, narrow, wide }
