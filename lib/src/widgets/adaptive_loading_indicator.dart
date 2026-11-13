import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../platform/platform_info.dart';
import 'adaptive_expressive_shape.dart';
import 'adaptive_progress_value.dart';
import 'android/android_m3e_platform_view.dart';

enum AdaptiveLoadingIndicatorVariant { defaultStyle, contained }

/// Shape-morphing M3 Expressive loading indicator on Android.
class AdaptiveLoadingIndicator extends StatelessWidget {
  const AdaptiveLoadingIndicator({
    super.key,
    this.variant = AdaptiveLoadingIndicatorVariant.defaultStyle,
    this.color,
    this.containerColor,
    this.size = 48,
    this.semanticLabel,
    this.progress,
    this.polygons,
  });

  final AdaptiveLoadingIndicatorVariant variant;
  final Color? color;
  final Color? containerColor;

  /// Square container size. Defaults to Compose's 48 dp container and must be
  /// finite and greater than zero.
  final double size;
  final String? semanticLabel;

  /// Progress from 0 to 1. Null keeps the native shape-morphing loop.
  final double? progress;

  /// Optional sequence of at least two native Material 3 shapes for the
  /// Android morph. Null uses Compose's official determinate or indeterminate
  /// sequence. Other platforms keep their platform progress indicator.
  final List<AdaptiveExpressiveShape>? polygons;

  @override
  Widget build(BuildContext context) {
    if (!size.isFinite || size <= 0) {
      throw ArgumentError.value(size, 'size', 'must be finite and positive');
    }
    final normalizedProgress = normalizeAdaptiveProgress(progress);
    final nativePolygons = polygons;
    if (nativePolygons != null && nativePolygons.length < 2) {
      throw ArgumentError.value(
        nativePolygons,
        'polygons',
        'requires two or more shapes',
      );
    }
    if (PlatformInfo.usesNativeAndroidViews) {
      return AndroidM3EPlatformView(
        component: 'loadingIndicator',
        width: size,
        height: size,
        hitTestBehavior: PlatformViewHitTestBehavior.transparent,
        properties: {
          'size': size,
          'variant': variant.name,
          'color': color?.toARGB32(),
          'containerColor': containerColor?.toARGB32(),
          'semanticLabel': semanticLabel,
          'progress': normalizedProgress,
          'polygons': nativePolygons?.map((shape) => shape.name).toList(),
        },
        onEvent: (_, __) {},
      );
    }
    if (PlatformInfo.isIOS) {
      return Semantics(
        label: semanticLabel,
        value: normalizedProgress == null
            ? null
            : '${(normalizedProgress * 100).round()}%',
        child: normalizedProgress == null
            ? CupertinoActivityIndicator(radius: size / 4)
            : CupertinoActivityIndicator.partiallyRevealed(
                radius: size / 4,
                progress: normalizedProgress,
              ),
      );
    }
    return Semantics(
      label: semanticLabel,
      value: normalizedProgress == null
          ? null
          : '${(normalizedProgress * 100).round()}%',
      child: SizedBox(
        width: size,
        height: size,
        child: CircularProgressIndicator(
          value: normalizedProgress,
          color: color,
        ),
      ),
    );
  }
}
