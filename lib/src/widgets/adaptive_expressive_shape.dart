import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../platform/platform_info.dart';
import 'android/android_m3e_platform_view.dart';

/// The complete set of expressive shapes provided by Material 3 on Android.
///
/// The Android implementation uses `MaterialShapes` from Compose Material 3
/// directly. Other platforms render a rounded-rectangle fallback so this
/// optional decorative widget remains safe to include in shared layouts.
enum AdaptiveExpressiveShape {
  arch,
  arrow,
  boom,
  bun,
  burst,
  circle,
  clamShell,
  clover4Leaf,
  clover8Leaf,
  cookie12Sided,
  cookie4Sided,
  cookie6Sided,
  cookie7Sided,
  cookie9Sided,
  diamond,
  fan,
  flower,
  gem,
  ghostish,
  heart,
  oval,
  pentagon,
  pill,
  pixelCircle,
  pixelTriangle,
  puffy,
  puffyDiamond,
  semiCircle,
  slanted,
  softBoom,
  softBurst,
  square,
  sunny,
  triangle,
  verySunny,
}

/// Draws an expressive Material shape and optionally morphs between two shapes.
///
/// On Android, shapes are drawn with the native Compose Material 3
/// `MaterialShapes` catalog. Set [morphTo] and animate [morphProgress] from
/// `0` (the [shape]) to `1` (the [morphTo]) to drive a native `Morph`.
///
/// This widget draws a colored shape behind [child]; it does not clip the
/// child's contents. The native shape catalog is opt-in and does not change
/// the shapes of other package widgets.
class AdaptiveExpressiveShapeView extends StatelessWidget {
  const AdaptiveExpressiveShapeView({
    super.key,
    required this.shape,
    required this.width,
    required this.height,
    this.morphTo,
    this.morphProgress = 0,
    this.color,
    this.child,
    this.semanticLabel,
  }) : assert(morphProgress >= 0 && morphProgress <= 1);

  final AdaptiveExpressiveShape shape;
  final AdaptiveExpressiveShape? morphTo;
  final double morphProgress;
  final double width;
  final double height;
  final Color? color;
  final Widget? child;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final shapeView = PlatformInfo.isAndroid
        ? AndroidM3EPlatformView(
            component: 'expressiveShape',
            width: width,
            height: height,
            hitTestBehavior: PlatformViewHitTestBehavior.transparent,
            properties: {
              'shape': shape.name,
              'morphTo': morphTo?.name,
              'morphProgress': morphProgress,
              'color': color?.toARGB32(),
            },
            onEvent: (_, _) {},
          )
        : DecoratedBox(
            decoration: BoxDecoration(
              color: color ?? Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(
                (height < width ? height : width) * 0.22,
              ),
            ),
          );

    return Semantics(
      label: semanticLabel,
      image: semanticLabel != null,
      child: ExcludeSemantics(
        child: SizedBox(
          width: width,
          height: height,
          child: Stack(fit: StackFit.expand, children: [shapeView, ?child]),
        ),
      ),
    );
  }
}
