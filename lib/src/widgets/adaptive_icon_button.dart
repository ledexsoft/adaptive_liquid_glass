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
  final String? tooltip;
  final String? semanticLabel;
  final AdaptiveIconButtonVariant variant;
  final AdaptiveIconButtonSize size;
  final AdaptiveIconButtonShape shape;
  final AdaptiveIconButtonWidth width;
  final bool? isSelected;
  final Widget? selectedIcon;
  final Object? badgeValue;
  final bool? enableFeedback;
  final AndroidM3EIcon? nativeIcon;
  final AndroidM3EIcon? nativeSelectedIcon;

  /// Adds the AI sparkle to the action icon. Off by default.
  final bool aiPowered;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? selectedBackgroundColor;
  final Color? selectedForegroundColor;

  @override
  Widget build(BuildContext context) {
    if (PlatformInfo.isAndroid) {
      return AndroidM3EPlatformView(
        component: 'iconButton',
        width: _buttonWidth,
        height: _buttonSize,
        properties: {
          'icon': resolveAndroidM3EIcon(
            child: icon,
            nativeIcon: nativeIcon,
            parameterName: 'nativeIcon',
          ),
          'aiPowered': aiPowered,
          'selectedIcon': selectedIcon == null
              ? null
              : resolveAndroidM3EIcon(
                  child: selectedIcon,
                  nativeIcon: nativeSelectedIcon,
                  parameterName: 'nativeSelectedIcon',
                ),
          'variant': variant.name,
          'size': size.name,
          'sizeDp': _buttonSize,
          'widthDp': _buttonWidth,
          'shape': shape.name,
          'selected': isSelected,
          'badge': badgeValue?.toString(),
          'enabled': onPressed != null,
          'tooltip': tooltip,
          'semanticLabel': semanticLabel,
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

  double get _buttonSize => switch (size) {
    AdaptiveIconButtonSize.extraSmall => 40,
    AdaptiveIconButtonSize.small => 48,
    AdaptiveIconButtonSize.medium => 56,
    AdaptiveIconButtonSize.large => 64,
    AdaptiveIconButtonSize.extraLarge => 72,
  };

  double get _buttonWidth => switch (width) {
    AdaptiveIconButtonWidth.narrow => _buttonSize * 0.8,
    AdaptiveIconButtonWidth.defaultWidth => _buttonSize,
    AdaptiveIconButtonWidth.wide => _buttonSize * 1.25,
  };
}

enum AdaptiveIconButtonVariant { standard, filled, tonal, outlined }

enum AdaptiveIconButtonSize { extraSmall, small, medium, large, extraLarge }

enum AdaptiveIconButtonShape { round, square }

enum AdaptiveIconButtonWidth { defaultWidth, narrow, wide }
