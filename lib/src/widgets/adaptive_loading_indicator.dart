import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../platform/platform_info.dart';
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
  });

  final AdaptiveLoadingIndicatorVariant variant;
  final Color? color;
  final Color? containerColor;
  final double size;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    if (PlatformInfo.usesNativeAndroidViews) {
      return AndroidM3EPlatformView(
        component: 'loadingIndicator',
        width: size,
        height: size,
        properties: {
          'size': size,
          'variant': variant.name,
          'color': color?.toARGB32(),
          'containerColor': containerColor?.toARGB32(),
          'semanticLabel': semanticLabel,
        },
        onEvent: (_, __) {},
      );
    }
    if (PlatformInfo.isIOS) {
      return Semantics(
        label: semanticLabel,
        child: CupertinoActivityIndicator(radius: size / 4),
      );
    }
    return Semantics(
      label: semanticLabel,
      child: SizedBox(
        width: size,
        height: size,
        child: CircularProgressIndicator(color: color),
      ),
    );
  }
}
