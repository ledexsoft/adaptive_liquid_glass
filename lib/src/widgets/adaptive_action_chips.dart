import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../platform/platform_info.dart';
import 'android/android_m3e_native_icon.dart';
import 'android/android_m3e_platform_view.dart';

/// A contextual action rendered with Compose AssistChip on Android.
class AdaptiveAssistChip extends StatelessWidget {
  const AdaptiveAssistChip({
    super.key,
    required this.label,
    this.onPressed,
    this.enabled = true,
    this.elevated = false,
    this.leadingIcon,
    this.trailingIcon,
    this.nativeLeadingIcon,
    this.nativeTrailingIcon,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool enabled;
  final bool elevated;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final AndroidM3EIcon? nativeLeadingIcon;
  final AndroidM3EIcon? nativeTrailingIcon;

  @override
  Widget build(BuildContext context) {
    if (label.trim().isEmpty) {
      throw FlutterError('AdaptiveAssistChip.label must be nonempty.');
    }
    final leading = leadingIcon == null ? null : Icon(leadingIcon, size: 18);
    final trailing = trailingIcon == null ? null : Icon(trailingIcon, size: 18);
    final canUseNative =
        PlatformInfo.usesNativeAndroidViews &&
        (leading == null ||
            canResolveAndroidM3EIcon(
              child: leading,
              nativeIcon: nativeLeadingIcon,
            )) &&
        (trailing == null ||
            canResolveAndroidM3EIcon(
              child: trailing,
              nativeIcon: nativeTrailingIcon,
            ));
    if (!canUseNative) {
      final action = enabled ? onPressed : null;
      final content = trailing == null
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
                trailing,
              ],
            );
      return elevated
          ? ActionChip.elevated(
              label: content,
              avatar: leading,
              onPressed: action,
            )
          : ActionChip(label: content, avatar: leading, onPressed: action);
    }
    final leadingName = _nativeIconName(
      leading,
      nativeLeadingIcon,
      'nativeLeadingIcon',
    );
    final trailingName = _nativeIconName(
      trailing,
      nativeTrailingIcon,
      'nativeTrailingIcon',
    );
    return _nativeActionChip(
      component: 'assistChip',
      label: label,
      elevated: elevated,
      leadingIconName: leadingName,
      trailingIconName: trailingName,
      enabled: enabled,
      onPressed: onPressed,
    );
  }
}

/// A contextual suggestion rendered with Compose SuggestionChip on Android.
class AdaptiveSuggestionChip extends StatelessWidget {
  const AdaptiveSuggestionChip({
    super.key,
    required this.label,
    this.onPressed,
    this.enabled = true,
    this.elevated = false,
    this.icon,
    this.nativeIcon,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool enabled;
  final bool elevated;
  final IconData? icon;
  final AndroidM3EIcon? nativeIcon;

  @override
  Widget build(BuildContext context) {
    if (label.trim().isEmpty) {
      throw FlutterError('AdaptiveSuggestionChip.label must be nonempty.');
    }
    final flutterIcon = icon == null ? null : Icon(icon, size: 18);
    if (!PlatformInfo.usesNativeAndroidViews ||
        (flutterIcon != null &&
            !canResolveAndroidM3EIcon(
              child: flutterIcon,
              nativeIcon: nativeIcon,
            ))) {
      final action = enabled ? onPressed : null;
      return elevated
          ? ActionChip.elevated(
              label: Text(label),
              avatar: flutterIcon,
              onPressed: action,
            )
          : ActionChip(
              label: Text(label),
              avatar: flutterIcon,
              onPressed: action,
            );
    }
    return _nativeActionChip(
      component: 'suggestionChip',
      label: label,
      elevated: elevated,
      leadingIconName: _nativeIconName(flutterIcon, nativeIcon, 'nativeIcon'),
      enabled: enabled,
      onPressed: onPressed,
    );
  }
}

String? _nativeIconName(Icon? icon, AndroidM3EIcon? nativeIcon, String name) {
  if (icon == null && nativeIcon == null) return null;
  return resolveAndroidM3EIcon(
    child: icon,
    nativeIcon: nativeIcon,
    parameterName: name,
  );
}

Widget _nativeActionChip({
  required String component,
  required String label,
  required bool elevated,
  required String? leadingIconName,
  String? trailingIconName,
  required bool enabled,
  required VoidCallback? onPressed,
}) {
  final interactive = enabled && onPressed != null;
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
            (leadingIconName == null ? 0.0 : 26.0) +
            (trailingIconName == null ? 0.0 : 26.0),
      );
      final initialHeight = math.max(48.0, painter.height + 16.0);
      painter.dispose();
      return AndroidM3EMeasuredHeightView(
        component: component,
        initialWidth: initialWidth,
        initialHeight: initialHeight,
        maxWidth: constraints.maxWidth.isFinite ? constraints.maxWidth : null,
        widthMeasurementKey: (
          label,
          elevated,
          leadingIconName,
          trailingIconName,
          initialWidth,
          initialHeight,
        ),
        properties: {
          'label': label,
          'elevated': elevated,
          'leadingIcon': leadingIconName,
          'trailingIcon': trailingIconName,
          if (constraints.maxWidth.isFinite) 'maxWidth': constraints.maxWidth,
          'enabled': interactive,
          'hasCallback': onPressed != null,
        },
        onEvent: (event, _) {
          if (event == 'pressed' && interactive) onPressed();
        },
      );
    },
  );
}
