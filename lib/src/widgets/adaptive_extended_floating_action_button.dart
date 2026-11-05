import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../platform/platform_info.dart';
import 'android/android_m3e_native_icon.dart';
import 'android/android_m3e_platform_view.dart';

/// Extended FAB that uses M3 Expressive size and press motion on Android.
class AdaptiveExtendedFloatingActionButton extends StatelessWidget {
  const AdaptiveExtendedFloatingActionButton({
    super.key,
    required this.label,
    required this.icon,
    this.onPressed,
    this.extended = true,
    this.color = AdaptiveFabColor.primary,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
    this.tooltip,
    this.heroTag,
    this.nativeIcon,
  });

  final String label;
  final Widget icon;
  final VoidCallback? onPressed;
  final bool extended;
  final AdaptiveFabColor color;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? elevation;
  final String? tooltip;
  final Object? heroTag;
  final AndroidM3EIcon? nativeIcon;

  @override
  Widget build(BuildContext context) {
    if (PlatformInfo.isAndroid) {
      final iconName = resolveAndroidM3EIcon(
        child: icon,
        nativeIcon: nativeIcon,
        parameterName: 'nativeIcon',
      );
      final textPainter = TextPainter(
        text: TextSpan(
          text: label,
          style: Theme.of(context).textTheme.labelLarge,
        ),
        textDirection: Directionality.of(context),
        maxLines: 1,
      )..layout();
      final width = extended ? textPainter.width + 88 : 56.0;
      return AndroidM3EPlatformView(
        component: 'extendedFab',
        width: width,
        height: 56,
        properties: {
          'icon': iconName,
          'label': label,
          'extended': extended,
          'color': color.name,
          'backgroundColor': backgroundColor?.toARGB32(),
          'foregroundColor': foregroundColor?.toARGB32(),
          'elevation': elevation,
          'tooltip': tooltip,
          'enabled': onPressed != null,
        },
        onEvent: (event, _) {
          if (event == 'pressed') onPressed?.call();
        },
      );
    }
    if (PlatformInfo.isIOS) {
      return CupertinoButton.filled(
        onPressed: onPressed,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            icon,
            if (extended) ...[const SizedBox(width: 8), Text(label)],
          ],
        ),
      );
    }
    return FloatingActionButton.extended(
      onPressed: onPressed,
      icon: icon,
      label: Text(label),
      tooltip: tooltip,
      elevation: elevation,
      heroTag: heroTag,
      isExtended: extended,
    );
  }
}
