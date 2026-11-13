import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../platform/platform_info.dart';
import 'android/android_m3e_native_icon.dart';
import 'android/android_m3e_platform_view.dart';
import 'android/android_m3e_text_options.dart';

/// An adaptive list tile that renders platform-specific styles
///
/// On iOS: Uses CupertinoListTile-like styling
/// On Android: Uses Material ListTile
class AdaptiveListTile extends StatelessWidget {
  /// Creates an adaptive list tile
  const AdaptiveListTile({
    super.key,
    this.leading,
    this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.onLongPress,
    this.enabled = true,
    this.selected = false,
    this.hideBottomDivider = false,
    this.backgroundColor,
    this.separatorColor,
    this.padding,
    this.androidLeadingIcon,
    this.androidTrailingIcon,
    this.androidSegmentIndex,
    this.androidSegmentCount,
  });

  /// A widget to display before the title.
  final Widget? leading;

  /// The primary content of the list tile.
  final Widget? title;

  /// Additional content displayed below the title.
  final Widget? subtitle;

  /// A widget to display after the title.
  final Widget? trailing;

  /// Called when the user taps this list tile.
  final VoidCallback? onTap;

  /// Called when the user long-presses on this list tile.
  final VoidCallback? onLongPress;

  /// Whether this list tile is interactive.
  final bool enabled;

  /// Whether this list tile is selected.
  final bool selected;

  /// Whether to hide the bottom divider (iOS only).
  /// Useful for the last tile in a grouped list to avoid a double border.
  final bool hideBottomDivider;

  /// The background color of the tile.
  final Color? backgroundColor;

  /// The color of the iOS bottom separator.
  ///
  /// If null, uses the platform default separator color. This only affects iOS;
  /// Android uses Material [ListTile], which does not render a bottom separator.
  final Color? separatorColor;

  /// The tile's internal padding.
  final EdgeInsetsGeometry? padding;

  /// Serializable icon used in the native Android Compose list item.
  final AndroidM3EIcon? androidLeadingIcon;

  /// Serializable trailing icon used by the native Android Compose list item.
  final AndroidM3EIcon? androidTrailingIcon;

  /// Zero-based position in a native Android segmented list. Set with
  /// [androidSegmentCount] on every item in the group.
  final int? androidSegmentIndex;

  /// Number of items in the native Android segmented list. The last item has
  /// [androidSegmentIndex] equal to this minus one.
  final int? androidSegmentCount;

  @override
  Widget build(BuildContext context) {
    if (PlatformInfo.isIOS) {
      return _buildCupertinoListTile(context);
    }

    if (PlatformInfo.usesNativeAndroidViews) {
      if (androidSegmentIndex != null || androidSegmentCount != null) {
        final index = androidSegmentIndex;
        final count = androidSegmentCount;
        if (index == null ||
            count == null ||
            count < 1 ||
            index < 0 ||
            index >= count) {
          throw FlutterError(
            'Android segmented list items require both androidSegmentIndex '
            'and androidSegmentCount, with 0 <= index < count.',
          );
        }
        if (!_canRenderAndroidNatively) {
          throw FlutterError(
            'Android segmented list items require plain Text and serializable icons '
            'so Compose can render the native SegmentedListItem.',
          );
        }
      }
      return _canRenderAndroidNatively
          ? _buildAndroidNativeListItem(context)
          : _buildMaterialListTile(context);
    }

    // Other platforms - Use Material ListTile
    return _buildMaterialListTile(context);
  }

  bool get _canRenderAndroidNatively {
    bool isPlainText(Widget? value) =>
        value == null || canRenderAndroidM3EText(value);
    bool isSerializableIcon(Widget? value, AndroidM3EIcon? native) {
      if (!canSerializeAndroidM3EIconStyle(value)) {
        return false;
      }
      return value == null ||
          native != null ||
          canResolveAndroidM3EIcon(child: value, nativeIcon: null);
    }

    return isPlainText(title) &&
        isPlainText(subtitle) &&
        isSerializableIcon(leading, androidLeadingIcon) &&
        isSerializableIcon(trailing, androidTrailingIcon);
  }

  Widget _buildAndroidNativeListItem(BuildContext context) {
    final titleText = title is Text ? title as Text : null;
    final subtitleText = subtitle is Text ? subtitle as Text : null;
    if (title != null && titleText?.data == null) {
      throw FlutterError(
        'Android AdaptiveListTile uses a native Compose ListItem. '
        'Pass a plain Text title.',
      );
    }
    if (subtitle != null && subtitleText?.data == null) {
      throw FlutterError(
        'Android AdaptiveListTile requires subtitle to be a plain Text.',
      );
    }
    String? iconName(Widget? widget, AndroidM3EIcon? native, String parameter) {
      if (native != null) return native.name;
      if (widget == null) return null;
      if (widget is Icon && widget.icon != null) {
        return resolveAndroidM3EIcon(
          child: widget,
          nativeIcon: null,
          parameterName: parameter,
        );
      }
      throw FlutterError(
        'Android AdaptiveListTile requires a serializable $parameter. '
        'Pass AndroidM3EIcon.<value>.',
      );
    }

    final nativePadding = padding?.resolve(Directionality.of(context));
    if (nativePadding != null &&
        [
          nativePadding.left,
          nativePadding.top,
          nativePadding.right,
          nativePadding.bottom,
        ].any((value) => !value.isFinite || value < 0)) {
      throw FlutterError(
        'AdaptiveListTile.padding must be finite and nonnegative on Android.',
      );
    }
    final textScaler = MediaQuery.textScalerOf(context);
    final verticalPadding = nativePadding?.vertical ?? 20.0;
    final paddingExtra = verticalPadding > 20.0 ? verticalPadding - 20.0 : 0.0;
    final scaledTitleExtra = textScaler.scale(16.0) - 16.0;
    final scaledSubtitleExtra = subtitleText == null
        ? 0.0
        : textScaler.scale(14.0) - 14.0;
    // Mirrors ListItemDefaults.SegmentedGap in the pinned Compose version.
    final segmentGap =
        androidSegmentIndex != null &&
            androidSegmentIndex! < androidSegmentCount! - 1
        ? 2.0
        : 0.0;
    return AndroidM3EMeasuredHeightView(
      component: 'listTile',
      initialHeight:
          (subtitleText == null ? 56.0 : 72.0) +
          paddingExtra +
          (scaledTitleExtra > 0 ? scaledTitleExtra : 0.0) +
          (scaledSubtitleExtra > 0 ? scaledSubtitleExtra : 0.0) +
          segmentGap,
      properties: {
        'title': titleText?.data ?? '',
        'titleTextOptions': titleText == null
            ? null
            : androidM3ETextOptions(titleText),
        'titleColor': titleText?.style?.color?.toARGB32(),
        'subtitle': subtitleText?.data,
        'subtitleTextOptions': subtitleText == null
            ? null
            : androidM3ETextOptions(subtitleText),
        'subtitleColor': subtitleText?.style?.color?.toARGB32(),
        'leadingIcon': iconName(
          leading,
          androidLeadingIcon,
          'androidLeadingIcon',
        ),
        'leadingIconSize': leading is Icon ? (leading as Icon).size : null,
        'leadingIconColor': leading is Icon
            ? (leading as Icon).color?.toARGB32()
            : null,
        'leadingIconSemanticLabel': leading is Icon
            ? (leading as Icon).semanticLabel
            : null,
        'trailingIcon': iconName(
          trailing,
          androidTrailingIcon,
          'androidTrailingIcon',
        ),
        'trailingIconSize': trailing is Icon ? (trailing as Icon).size : null,
        'trailingIconColor': trailing is Icon
            ? (trailing as Icon).color?.toARGB32()
            : null,
        'trailingIconSemanticLabel': trailing is Icon
            ? (trailing as Icon).semanticLabel
            : null,
        'enabled': enabled,
        'selected': selected,
        'backgroundColor': backgroundColor?.toARGB32(),
        'padding': nativePadding == null
            ? null
            : [
                nativePadding.left,
                nativePadding.top,
                nativePadding.right,
                nativePadding.bottom,
              ],
        'hasOnTap': onTap != null,
        'hasOnLongPress': onLongPress != null,
        'segmentIndex': androidSegmentIndex,
        'segmentCount': androidSegmentCount,
      },
      onEvent: (event, _) {
        if (!enabled) return;
        if (event == 'tapped') onTap?.call();
        if (event == 'longPressed') onLongPress?.call();
      },
    );
  }

  Widget _buildCupertinoListTile(BuildContext context) {
    final isDark = MediaQuery.platformBrightnessOf(context) == Brightness.dark;

    Widget child = Container(
      padding:
          padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color:
            backgroundColor ??
            (selected
                ? (isDark
                      ? CupertinoColors.systemGrey5.darkColor
                      : CupertinoColors.systemGrey6.color)
                : (isDark
                      ? CupertinoColors.darkBackgroundGray
                      : CupertinoColors.white)),
        border: hideBottomDivider
            ? null
            : Border(
                bottom: BorderSide(
                  color:
                      separatorColor ??
                      (isDark
                          ? CupertinoColors.systemGrey4
                          : CupertinoColors.separator),
                  width: 0.5,
                ),
              ),
      ),
      child: Row(
        children: [
          if (leading != null) ...[leading!, const SizedBox(width: 12)],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (title != null)
                  DefaultTextStyle(
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w400,
                      color: enabled
                          ? (isDark
                                ? CupertinoColors.white
                                : CupertinoColors.black)
                          : (isDark
                                ? CupertinoColors.systemGrey
                                : CupertinoColors.systemGrey2),
                    ),
                    child: title!,
                  ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  DefaultTextStyle(
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark
                          ? CupertinoColors.systemGrey
                          : CupertinoColors.systemGrey2,
                    ),
                    child: subtitle!,
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 12), trailing!],
        ],
      ),
    );

    if (enabled && (onTap != null || onLongPress != null)) {
      return GestureDetector(
        onTap: onTap,
        onLongPress: onLongPress,
        behavior: HitTestBehavior.opaque,
        child: child,
      );
    }

    return child;
  }

  Widget _buildMaterialListTile(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: ListTile(
        leading: leading,
        title: title,
        subtitle: subtitle,
        trailing: trailing,
        onTap: enabled ? onTap : null,
        onLongPress: enabled ? onLongPress : null,
        enabled: enabled,
        selected: selected,
        tileColor: backgroundColor,
        contentPadding:
            padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }
}
