import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../platform/platform_info.dart';
import 'android/android_m3e_native_icon.dart';
import 'android/android_m3e_platform_view.dart';
import 'native_occurrence_ids.dart';

final NativeOccurrenceIds<AdaptiveCarouselItem> _nativeCarouselItemIds =
    NativeOccurrenceIds<AdaptiveCarouselItem>();

int? _selectedNativeCarouselItemIndex(Object? value, List<int> itemIds) {
  if (value is Map) {
    final id = value['id'];
    if (id is! int) return null;
    final reported = value['index'];
    if (reported is int &&
        reported >= 0 &&
        reported < itemIds.length &&
        itemIds[reported] == id) {
      return reported;
    }
    final current = itemIds.indexOf(id);
    return current < 0 ? null : current;
  }
  if (value is int && value >= 0 && value < itemIds.length) return value;
  return null;
}

/// Native Material 3 Expressive carousel layout on Android.
enum AdaptiveCarouselType { hero, contained, uncontained, multiAspect }

/// Change details emitted when the carousel settles on an item.
class AdaptiveCarouselChangeDetails {
  const AdaptiveCarouselChangeDetails({
    required this.leadingIndex,
    required this.focalIndex,
    required this.itemCount,
  });

  /// First visible item in the carousel viewport.
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
    this.imageBytes,
    this.mainAxisExtent,
  });

  /// Visible title. If empty, supply supporting text or a localized
  /// [semanticDescription] so the native interactive card has a name.
  final String title;
  final String? supportingText;
  final AndroidM3EIcon? icon;

  /// Optional accessibility description replacing the visible title and
  /// supporting text in the native clickable card. When omitted, Compose
  /// announces that visible text through the card's merged semantics.
  final String? semanticDescription;
  final Color? containerColor;
  final Color? contentColor;

  /// Encoded image bytes shown as the visual content of the native Android card.
  /// Treat this buffer as immutable after passing it to the carousel; supply
  /// a new buffer when the image changes.
  final Uint8List? imageBytes;

  /// Main-axis size in logical pixels for a [AdaptiveCarouselType.multiAspect]
  /// item: width for a horizontal carousel, height for a vertical one.
  /// Every item in that layout must have a finite, positive size.
  final double? mainAxisExtent;
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
    this.itemSpacing,
    this.contentPadding,
    this.childElementBorderRadius,
    this.scrollAnimationDuration,
    this.userScrollEnabled = true,
  });

  final List<Widget> children;
  final List<AdaptiveCarouselItem>? androidItems;
  final double? width;
  final double? height;
  final Axis axis;
  final AdaptiveCarouselType type;

  /// Reserved for a future carousel layout; `true` is currently unsupported.
  final bool isExtended;

  /// Disables snapping for hero and contained carousels on Android.
  ///
  /// Uncontained and multi-aspect carousels use native free scrolling.
  final bool freeScroll;

  /// The native Material 3 hero carousel supports [Alignment.center] only.
  final Alignment heroAlignment;
  final ValueChanged<int>? onTap;
  final ValueChanged<AdaptiveCarouselChangeDetails>? onChange;

  /// Item width for the native Android carousel. The multi-browse variant
  /// treats it as a preferred width; uncontained uses it as an exact width.
  /// Multi-aspect items use [AdaptiveCarouselItem.mainAxisExtent] instead.
  /// Both use the 186 dp width from the official Compose examples by default.
  final double? uncontainedItemExtent;

  /// Spacing between native Android carousel items, in logical pixels.
  /// Dedicated layouts use Compose's carousel token by default; multi-aspect
  /// uses the 8 dp gap in the official Compose sample.
  final double? itemSpacing;

  /// Padding around the native Android carousel, in logical pixels.
  /// Dedicated layouts use Compose's carousel token horizontally by default;
  /// multi-aspect uses 16 dp on all edges, following the official sample.
  final double? contentPadding;

  final double? childElementBorderRadius;

  /// Duration in milliseconds for a tap to animate to its item on Android.
  /// The native spring is used when this is null; zero jumps immediately.
  final int? scrollAnimationDuration;
  final bool userScrollEnabled;

  @override
  Widget build(BuildContext context) {
    if (isExtended) {
      throw FlutterError(
        'AdaptiveCarousel.isExtended is unsupported by the available '
        'Material 3 carousel layouts.',
      );
    }
    if (heroAlignment != Alignment.center) {
      throw FlutterError(
        'AdaptiveCarousel.heroAlignment only supports Alignment.center '
        'with the available Material 3 hero carousel.',
      );
    }
    if (PlatformInfo.usesNativeAndroidViews) {
      final items = androidItems;
      if (items == null) {
        throw FlutterError(
          'AdaptiveCarousel on Android requires androidItems because Flutter '
          'widgets cannot render inside a native Compose carousel.',
        );
      }
      if (axis != Axis.horizontal && type != AdaptiveCarouselType.multiAspect) {
        throw FlutterError(
          'Only the native multi-aspect carousel supports vertical scrolling.',
        );
      }
      if (width != null && (!width!.isFinite || width! < 0)) {
        throw FlutterError('width must be finite and nonnegative.');
      }
      if (height != null && (!height!.isFinite || height! < 0)) {
        throw FlutterError('height must be finite and nonnegative.');
      }
      if (scrollAnimationDuration != null && scrollAnimationDuration! < 0) {
        throw FlutterError('scrollAnimationDuration cannot be negative.');
      }
      if (uncontainedItemExtent != null &&
          (!uncontainedItemExtent!.isFinite || uncontainedItemExtent! <= 0)) {
        throw FlutterError(
          'uncontainedItemExtent must be finite and positive.',
        );
      }
      if (itemSpacing != null && (!itemSpacing!.isFinite || itemSpacing! < 0)) {
        throw FlutterError('itemSpacing must be finite and nonnegative.');
      }
      if (contentPadding != null &&
          (!contentPadding!.isFinite || contentPadding! < 0)) {
        throw FlutterError('contentPadding must be finite and nonnegative.');
      }
      if (childElementBorderRadius != null &&
          (!childElementBorderRadius!.isFinite ||
              childElementBorderRadius! < 0)) {
        throw FlutterError(
          'childElementBorderRadius must be finite and nonnegative.',
        );
      }
      if (type == AdaptiveCarouselType.multiAspect) {
        if (uncontainedItemExtent != null) {
          throw FlutterError(
            'Multi-aspect carousel item sizes belong on each '
            'AdaptiveCarouselItem.mainAxisExtent.',
          );
        }
        if (scrollAnimationDuration != null && scrollAnimationDuration! > 0) {
          throw FlutterError(
            'The native multi-aspect carousel does not support a custom '
            'scrollAnimationDuration.',
          );
        }
        if (items.any(
          (item) =>
              item.mainAxisExtent == null ||
              !item.mainAxisExtent!.isFinite ||
              item.mainAxisExtent! <= 0,
        )) {
          throw FlutterError(
            'Every multi-aspect carousel item requires a finite, positive '
            'mainAxisExtent.',
          );
        }
      }

      for (final (index, item) in items.indexed) {
        if (item.title.trim().isEmpty &&
            (item.supportingText?.trim().isNotEmpty ?? false) == false &&
            (item.semanticDescription?.trim().isNotEmpty ?? false) == false) {
          throw FlutterError(
            'AdaptiveCarousel.androidItems[$index] requires visible text '
            'or semanticDescription on Android.',
          );
        }
      }

      final itemIds = _nativeCarouselItemIds.forItems(items);

      return SizedBox(
        width: width,
        height: height ?? 240,
        child: AndroidM3EPlatformView(
          component: 'carousel',
          width: width,
          height: height ?? 240,
          properties: {
            'type': type.name,
            'axis': axis.name,
            'viewportWidth': width,
            'viewportHeight': height ?? 240,
            'freeScroll': freeScroll,
            'userScrollEnabled': userScrollEnabled,
            'itemWidth': uncontainedItemExtent,
            'itemSpacing': itemSpacing,
            'contentPadding': contentPadding,
            'cornerRadius': childElementBorderRadius,
            'scrollAnimationDuration': scrollAnimationDuration,
            'items': [
              for (var index = 0; index < items.length; index++)
                {
                  'id': itemIds[index],
                  'title': items[index].title,
                  'supportingText': items[index].supportingText,
                  'icon': items[index].icon?.name,
                  'semanticDescription': items[index].semanticDescription,
                  'imageBytes': items[index].imageBytes,
                  'mainAxisExtent': items[index].mainAxisExtent,
                  'containerColor': items[index].containerColor?.toARGB32(),
                  'contentColor': items[index].contentColor?.toARGB32(),
                },
            ],
          },
          onEvent: (event, value) {
            if (event == 'itemPressed') {
              final index = _selectedNativeCarouselItemIndex(value, itemIds);
              if (index != null) onTap?.call(index);
            }
            if (event == 'positionChanged') {
              final focal = value is int
                  ? value
                  : value is Map
                  ? value['focalIndex']
                  : null;
              final leading = value is int
                  ? value
                  : value is Map
                  ? value['leadingIndex']
                  : null;
              if (focal is! int ||
                  leading is! int ||
                  focal < 0 ||
                  focal >= items.length ||
                  leading < 0 ||
                  leading >= items.length) {
                return;
              }
              if (value is Map) {
                if (value.containsKey('leadingId') &&
                    (value['leadingId'] is! int ||
                        itemIds[leading] != value['leadingId'])) {
                  return;
                }
                if (value.containsKey('focalId') &&
                    (value['focalId'] is! int ||
                        itemIds[focal] != value['focalId'])) {
                  return;
                }
              }
              onChange?.call(
                AdaptiveCarouselChangeDetails(
                  leadingIndex: leading,
                  focalIndex: focal,
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
