import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../platform/platform_info.dart';
import 'android/android_m3e_native_icon.dart';
import 'android/android_m3e_platform_view.dart';

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

  @override
  Widget build(BuildContext context) {
    if (PlatformInfo.isIOS) {
      return _buildCupertinoListTile(context);
    }

    if (PlatformInfo.usesNativeAndroidViews) {
      return _canRenderAndroidNatively
          ? _buildAndroidNativeListItem(context)
          : _buildMaterialListTile(context);
    }

    // Other platforms - Use Material ListTile
    return _buildMaterialListTile(context);
  }

  bool get _canRenderAndroidNatively {
    bool isPlainText(Widget? value) =>
        value == null ||
        (value is Text && value.data != null && value.style == null);
    bool isSerializableIcon(Widget? value, AndroidM3EIcon? native) =>
        value == null ||
        native != null ||
        canResolveAndroidM3EIcon(child: value, nativeIcon: null);

    return isPlainText(title) &&
        isPlainText(subtitle) &&
        isSerializableIcon(leading, androidLeadingIcon) &&
        isSerializableIcon(trailing, androidTrailingIcon);
  }

  Widget _buildAndroidNativeListItem(BuildContext context) {
    final titleText = title is Text ? title as Text : null;
    final subtitleText = subtitle is Text ? subtitle as Text : null;
    if (title != null &&
        (titleText?.data == null || titleText!.style != null)) {
      throw FlutterError(
        'Android AdaptiveListTile uses a native Compose ListItem. '
        'Pass a plain Text title.',
      );
    }
    if (subtitle != null &&
        (subtitleText?.data == null || subtitleText!.style != null)) {
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
    return AndroidM3EPlatformView(
      component: 'listTile',
      height: subtitleText == null ? 72 : 88,
      properties: {
        'title': titleText?.data ?? '',
        'subtitle': subtitleText?.data,
        'leadingIcon': iconName(
          leading,
          androidLeadingIcon,
          'androidLeadingIcon',
        ),
        'trailingIcon': iconName(
          trailing,
          androidTrailingIcon,
          'androidTrailingIcon',
        ),
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
      },
      onEvent: (event, _) {
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
