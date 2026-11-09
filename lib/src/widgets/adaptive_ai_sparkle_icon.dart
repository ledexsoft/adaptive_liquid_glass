import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../platform/platform_info.dart';
import 'android/android_m3e_native_icon.dart';
import 'android/android_m3e_platform_view.dart';

/// Decorates an icon with an optional AI sparkle marker.
///
/// On Android the icon and marker are rendered by Jetpack Compose. Other
/// platforms use Flutter. Keep [semanticLabel] specific to the action (for
/// example, "Summarize with AI"); the sparkle alone does not describe what AI
/// will do. When a parent control already supplies that label, it can be null.
class AdaptiveAiSparkleIcon extends StatelessWidget {
  const AdaptiveAiSparkleIcon({
    super.key,
    required this.icon,
    this.nativeIcon,
    this.size = 24,
    this.color,
    this.sparkleColor,
    this.semanticLabel,
  });

  /// The icon shown beneath the sparkle on Flutter-rendered platforms.
  final Widget icon;

  /// Serializable Material icon used by the native Android implementation.
  ///
  /// Common Flutter Material icons are mapped automatically.
  final AndroidM3EIcon? nativeIcon;

  final double size;
  final Color? color;
  final Color? sparkleColor;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    if (PlatformInfo.usesNativeAndroidViews) {
      final iconName = resolveAndroidM3EIcon(
        child: icon,
        nativeIcon: nativeIcon,
        parameterName: 'nativeIcon',
      );
      return Semantics(
        label: semanticLabel,
        image: semanticLabel != null,
        child: AndroidM3EPlatformView(
          component: 'aiSparkleIcon',
          width: size,
          height: size,
          hitTestBehavior: PlatformViewHitTestBehavior.transparent,
          properties: {
            'icon': iconName,
            'size': size,
            'color': color?.toARGB32(),
            'sparkleColor': sparkleColor?.toARGB32(),
            'semanticLabel': semanticLabel,
          },
          onEvent: (_, _) {},
        ),
      );
    }

    return Semantics(
      label: semanticLabel,
      image: semanticLabel != null,
      child: ExcludeSemantics(
        child: SizedBox.square(
          dimension: size,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              IconTheme.merge(
                data: IconThemeData(color: color, size: size),
                child: icon,
              ),
              Positioned(
                top: 0,
                right: 0,
                child: CustomPaint(
                  size: Size.square(size * 0.46),
                  painter: _AiSparklePainter(
                    sparkleColor ?? Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AiSparklePainter extends CustomPainter {
  const _AiSparklePainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;
    final path = Path()
      ..moveTo(width * 0.5, 0)
      ..cubicTo(
        width * 0.58,
        height * 0.39,
        width * 0.61,
        height * 0.42,
        width,
        height * 0.5,
      )
      ..cubicTo(
        width * 0.61,
        height * 0.58,
        width * 0.58,
        height * 0.61,
        width * 0.5,
        height,
      )
      ..cubicTo(
        width * 0.42,
        height * 0.61,
        width * 0.39,
        height * 0.58,
        0,
        height * 0.5,
      )
      ..cubicTo(
        width * 0.39,
        height * 0.42,
        width * 0.42,
        height * 0.39,
        width * 0.5,
        0,
      )
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_AiSparklePainter oldDelegate) =>
      color != oldDelegate.color;
}
