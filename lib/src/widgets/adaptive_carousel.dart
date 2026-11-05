import 'package:flutter/material.dart';

import '../platform/platform_info.dart';
import 'android/android_m3e_native_icon.dart';
import 'android/android_m3e_platform_view.dart';

/// Native Material 3 Expressive carousel layout on Android.
enum AdaptiveCarouselType { hero, contained, uncontained }

/// Change details emitted when the carousel settles on an item.
class AdaptiveCarouselChangeDetails {
  const AdaptiveCarouselChangeDetails({
    required this.leadingIndex,
    required this.focalIndex,
    required this.itemCount,
  });

  final int leadingIndex;
  final int focalIndex;
  final int itemCount;
}

/// Serializable item data for the native Android Compose carousel.
///
/// Flutter widgets cannot be embedded inside a Compose carousel. Supply these
/// data items on Android; [AdaptiveCarousel.children] remains the content API
/// for other platforms.
class AdaptiveCarouselItem {
  const AdaptiveCarouselItem({
    required this.title,
    this.supportingText,
    this.icon,
    this.semanticDescription,
    this.containerColor,
    this.contentColor,
  });

  final String title;
  final String? supportingText;
  final AndroidM3EIcon? icon;
  final String? semanticDescription;
  final Color? containerColor;
  final Color? contentColor;
}

/// Adaptive carousel backed by official Material 3 Expressive Compose APIs
/// on Android and a Flutter page view elsewhere.
class AdaptiveCarousel extends StatelessWidget {
  const AdaptiveCarousel({
    super.key,
    required this.children,
    this.androidItems,
    this.width,
    this.height,
    this.axis = Axis.horizontal,
    this.type = AdaptiveCarouselType.hero,
    this.isExtended = false,
    this.freeScroll = false,
    this.heroAlignment = Alignment.center,
    this.onTap,
    this.onChange,
    this.uncontainedItemExtent,
    this.childElementBorderRadius,
    this.scrollAnimationDuration,
  });

  final List<Widget> children;
  final List<AdaptiveCarouselItem>? androidItems;
  final double? width;
  final double? height;
  final Axis axis;
  final AdaptiveCarouselType type;
  final bool isExtended;
  final bool freeScroll;
  final Alignment heroAlignment;
  final ValueChanged<int>? onTap;
  final ValueChanged<AdaptiveCarouselChangeDetails>? onChange;
  final double? uncontainedItemExtent;
  final double? childElementBorderRadius;
  final int? scrollAnimationDuration;

  @override
  Widget build(BuildContext context) {
    if (PlatformInfo.isAndroid) {
      final items = androidItems;
      if (items == null) {
        throw FlutterError(
          'AdaptiveCarousel on Android requires androidItems because Flutter '
          'widgets cannot render inside a native Compose carousel.',
        );
      }
      if (axis != Axis.horizontal) {
        throw FlutterError(
          'The native Material 3 carousel supports horizontal scrolling only.',
        );
      }

      return SizedBox(
        width: width,
        height: height ?? 240,
        child: AndroidM3EPlatformView(
          component: 'carousel',
          width: width,
          height: height ?? 240,
          properties: {
            'type': type.name,
            'freeScroll': freeScroll,
            'itemWidth': uncontainedItemExtent ?? 300,
            'itemSpacing': 8,
            'cornerRadius': childElementBorderRadius ?? 28,
            'heroAlignment': heroAlignment == Alignment.center
                ? 'center'
                : heroAlignment == Alignment.centerLeft
                ? 'leading'
                : heroAlignment == Alignment.centerRight
                ? 'trailing'
                : 'center',
            'items': [
              for (final item in items)
                {
                  'title': item.title,
                  'supportingText': item.supportingText,
                  'icon': item.icon?.name,
                  'semanticDescription': item.semanticDescription,
                  'containerColor': item.containerColor?.toARGB32(),
                  'contentColor': item.contentColor?.toARGB32(),
                },
            ],
          },
          onEvent: (event, value) {
            if (event == 'itemPressed' && value is int) onTap?.call(value);
            if (event == 'positionChanged' && value is int) {
              onChange?.call(
                AdaptiveCarouselChangeDetails(
                  leadingIndex: value,
                  focalIndex: value,
                  itemCount: items.length,
                ),
              );
            }
          },
        ),
      );
    }

    return SizedBox(
      width: width,
      height: height,
      child: PageView(
        scrollDirection: axis,
        onPageChanged: (index) => onChange?.call(
          AdaptiveCarouselChangeDetails(
            leadingIndex: index,
            focalIndex: index,
            itemCount: children.length,
          ),
        ),
        children: [
          for (var index = 0; index < children.length; index++)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onTap == null ? null : () => onTap!(index),
              child: children[index],
            ),
        ],
      ),
    );
  }
}
