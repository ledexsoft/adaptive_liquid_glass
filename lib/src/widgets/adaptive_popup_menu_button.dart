import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../platform/platform_info.dart';
import 'android/android_m3e_native_icon.dart';
import 'android/android_m3e_overlay.dart';
import 'android/android_m3e_platform_view.dart';
import 'ios26/ios26_popup_menu_button.dart';

export 'ios26/ios26_popup_menu_button.dart'
    show
        AdaptivePopupMenuItem,
        AdaptivePopupMenuDivider,
        AdaptivePopupMenuEntry,
        PopupButtonStyle;

/// An adaptive popup menu button that renders platform-specific styles
class AdaptivePopupMenuButton<T> {
  AdaptivePopupMenuButton._();

  /// Creates a text-labeled popup menu button
  static Widget text<T>({
    Key? key,
    required String label,
    required List<AdaptivePopupMenuEntry> items,
    required void Function(int index, AdaptivePopupMenuItem<T> entry)
    onSelected,
    Color? tint,
    double height = 32.0,
    bool shrinkWrap = false,
    PopupButtonStyle buttonStyle = PopupButtonStyle.plain,
  }) {
    // iOS 26+ - Use native iOS 26 popup menu button
    if (PlatformInfo.isIOS26OrHigher()) {
      return IOS26PopupMenuButton<T>(
        buttonLabel: label,
        items: items,
        onSelected: onSelected,
        tint: tint,
        height: height,
        shrinkWrap: shrinkWrap,
        buttonStyle: buttonStyle,
      );
    }

    // Android uses a native Compose anchor and DropdownMenu.
    if (PlatformInfo.isAndroid) {
      return AndroidM3EPlatformView(
        key: key,
        component: 'popupMenuButton',
        height: height,
        properties: {
          'anchorType': 'text',
          'label': label,
          'style': _nativeMenuButtonStyle(buttonStyle),
          'tint': tint?.toARGB32(),
          'items': _nativeMenuItems<T>(items),
        },
        onEvent: (event, value) {
          if (event == 'selected' &&
              value is int &&
              value >= 0 &&
              value < items.length) {
            final entry = items[value];
            if (entry is AdaptivePopupMenuItem<T>) onSelected(value, entry);
          }
        },
      );
    }

    // iOS <26 (iOS 18 and below) - Use CupertinoButton with action sheet (iOS fallback)
    return Builder(
      builder: (context) => SizedBox(
        height: height,
        child: CupertinoButton(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          onPressed: () => _showMenu<T>(context, label, items, onSelected),
          child: Text(label),
        ),
      ),
    );
  }

  /// Creates a popup menu button with a custom child widget
  static Widget widget<T>({
    Key? key,
    required List<AdaptivePopupMenuEntry> items,
    required void Function(int index, AdaptivePopupMenuItem<T> entry)
    onSelected,
    Color? tint,
    PopupButtonStyle buttonStyle = PopupButtonStyle.plain,
    bool triggerOnLongPress = false,
    VoidCallback? onTap,
    required Widget child,
  }) {
    assert(
      onTap == null || triggerOnLongPress,
      'onTap is only used with triggerOnLongPress: true (tap fires onTap, '
      'long-press opens the menu).',
    );
    // iOS 26+ - Use gesture detector with native menu
    if (PlatformInfo.isIOS26OrHigher()) {
      return IOS26PopupMenuButton<T>.widget(
        items: items,
        onSelected: onSelected,
        tint: tint,
        buttonStyle: buttonStyle,
        triggerOnLongPress: triggerOnLongPress,
        onTap: onTap,
        child: child,
      );
    }

    // Keep the arbitrary Flutter child as an anchor and render the menu in Compose.
    if (PlatformInfo.isAndroid) {
      return _AndroidNativePopupMenuAnchor<T>(
        key: key,
        items: items,
        onSelected: onSelected,
        triggerOnLongPress: triggerOnLongPress,
        onTap: onTap,
        child: child,
      );
    }

    // iOS <26 (iOS 18 and below) - Use GestureDetector with action sheet
    return Builder(
      builder: (context) => GestureDetector(
        onTap: triggerOnLongPress
            ? onTap
            : () => _showMenu<T>(context, null, items, onSelected),
        onLongPress: triggerOnLongPress
            ? () => _showMenu<T>(context, null, items, onSelected)
            : null,
        child: child,
      ),
    );
  }

  /// Creates a round, icon-only popup menu button
  ///
  /// [icon] can be either:
  /// - String (SF Symbol) for iOS 26+
  /// - IconData for iOS <26 and Android
  static Widget icon<T>({
    Key? key,
    required dynamic icon,
    required List<AdaptivePopupMenuEntry> items,
    required void Function(int index, AdaptivePopupMenuItem<T> entry)
    onSelected,
    Color? tint,
    double size = 44.0,
    PopupButtonStyle buttonStyle = PopupButtonStyle.glass,
  }) {
    // iOS 26+ - Use native iOS 26 popup menu button (expects String - SF Symbol)
    if (PlatformInfo.isIOS26OrHigher()) {
      return IOS26PopupMenuButton<T>.icon(
        buttonIcon: icon is String ? icon : 'ellipsis.circle',
        items: items,
        onSelected: onSelected,
        tint: tint,
        size: size,
        buttonStyle: buttonStyle,
      );
    }

    // Android uses a native Compose icon button and DropdownMenu.
    if (PlatformInfo.isAndroid) {
      return AndroidM3EPlatformView(
        key: key,
        component: 'popupMenuButton',
        width: size,
        height: size,
        properties: {
          'anchorType': 'icon',
          'icon': _nativeIconName(icon, parameterName: 'icon'),
          'style': _nativeMenuButtonStyle(buttonStyle),
          'tint': tint?.toARGB32(),
          'items': _nativeMenuItems<T>(items),
        },
        onEvent: (event, value) {
          if (event == 'selected' &&
              value is int &&
              value >= 0 &&
              value < items.length) {
            final entry = items[value];
            if (entry is AdaptivePopupMenuItem<T>) onSelected(value, entry);
          }
        },
      );
    }

    // iOS <26 (iOS 18 and below) - Use icon button with action sheet (iOS fallback)
    return Builder(
      builder: (context) => SizedBox(
        width: size,
        height: size,
        child: CupertinoButton(
          padding: const EdgeInsets.all(4),
          onPressed: () => _showMenu<T>(context, null, items, onSelected),
          child: Icon(icon is IconData ? icon : CupertinoIcons.ellipsis),
        ),
      ),
    );
  }

  static List<Map<String, Object?>> _nativeMenuItems<T>(
    List<AdaptivePopupMenuEntry> items,
  ) => [
    for (final entry in items)
      if (entry is AdaptivePopupMenuItem<T>)
        {
          'label': entry.label,
          'subtitle': entry.subtitle,
          'icon': entry.icon == null
              ? null
              : _nativeIconName(entry.icon, parameterName: 'item.icon'),
          'imageBytes': entry.imageBytes,
          'enabled': entry.enabled,
          'destructive': entry.isDestructive,
        }
      else
        {'divider': true},
  ];

  static String _nativeMenuButtonStyle(PopupButtonStyle style) =>
      switch (style) {
        PopupButtonStyle.filled || PopupButtonStyle.prominentGlass => 'filled',
        PopupButtonStyle.tinted ||
        PopupButtonStyle.gray ||
        PopupButtonStyle.glass => 'tonal',
        PopupButtonStyle.bordered ||
        PopupButtonStyle.borderedProminent => 'outlined',
        PopupButtonStyle.plain => 'text',
      };

  static String _nativeIconName(Object? icon, {required String parameterName}) {
    if (icon is AndroidM3EIcon) return icon.name;
    if (icon is IconData) {
      return resolveAndroidM3EIcon(
        child: Icon(icon),
        nativeIcon: null,
        parameterName: parameterName,
      );
    }
    throw FlutterError(
      'Android native popup menus require a serializable icon. '
      'Use AndroidM3EIcon for $parameterName.',
    );
  }

  static Widget _buildActionSheetContent<T>(AdaptivePopupMenuItem<T> item) {
    final hasImage = item.imageBytes != null;
    final hasSubtitle = item.subtitle != null && item.subtitle!.isNotEmpty;

    if (!hasImage && !hasSubtitle) return Text(item.label);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (hasImage) ...[
          ClipOval(
            child: Image.memory(
              item.imageBytes!,
              width: 32,
              height: 32,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 10),
        ],
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: hasImage
              ? CrossAxisAlignment.start
              : CrossAxisAlignment.center,
          children: [
            Text(item.label),
            if (hasSubtitle)
              Text(
                item.subtitle!,
                style: const TextStyle(
                  fontSize: 13,
                  color: CupertinoColors.secondaryLabel,
                ),
              ),
          ],
        ),
      ],
    );
  }

  static Future<void> _showMenu<T>(
    BuildContext context,
    String? title,
    List<AdaptivePopupMenuEntry> items,
    void Function(int index, AdaptivePopupMenuItem<T> entry) onSelected,
  ) async {
    final selected = await showCupertinoModalPopup<int>(
      context: context,
      builder: (ctx) {
        return CupertinoActionSheet(
          title: title != null ? Text(title) : null,
          actions: [
            for (var i = 0; i < items.length; i++)
              if (items[i] is AdaptivePopupMenuItem<T>)
                CupertinoActionSheetAction(
                  onPressed: () => Navigator.of(ctx).pop(i),
                  isDestructiveAction:
                      (items[i] as AdaptivePopupMenuItem<T>).isDestructive,
                  child: _buildActionSheetContent<T>(
                    items[i] as AdaptivePopupMenuItem<T>,
                  ),
                )
              else
                const SizedBox(height: 8),
          ],
          cancelButton: CupertinoActionSheetAction(
            onPressed: () => Navigator.of(ctx).pop(),
            isDefaultAction: true,
            child: Text(
              PlatformInfo.isIOS
                  ? CupertinoLocalizations.of(ctx).cancelButtonLabel
                  : MaterialLocalizations.of(ctx).cancelButtonLabel,
            ),
          ),
        );
      },
    );

    if (selected != null) {
      final selectedEntry = items[selected];
      if (selectedEntry is AdaptivePopupMenuItem<T>) {
        onSelected(selected, selectedEntry);
      }
    }
  }
}

class _AndroidNativePopupMenuAnchor<T> extends StatefulWidget {
  const _AndroidNativePopupMenuAnchor({
    super.key,
    required this.items,
    required this.onSelected,
    required this.triggerOnLongPress,
    required this.onTap,
    required this.child,
  });

  final List<AdaptivePopupMenuEntry> items;
  final void Function(int, AdaptivePopupMenuItem<T>) onSelected;
  final bool triggerOnLongPress;
  final VoidCallback? onTap;
  final Widget child;

  @override
  State<_AndroidNativePopupMenuAnchor<T>> createState() =>
      _AndroidNativePopupMenuAnchorState<T>();
}

class _AndroidNativePopupMenuAnchorState<T>
    extends State<_AndroidNativePopupMenuAnchor<T>> {
  final _anchorKey = GlobalKey();

  void _show() {
    final box = _anchorKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;
    final origin = box.localToGlobal(Offset.zero);
    showAndroidM3EOverlay(
      context: context,
      component: 'anchoredPopupMenu',
      rootNavigator: true,
      properties: {
        'anchorX': origin.dx,
        'anchorY': origin.dy + box.size.height,
        'items': AdaptivePopupMenuButton._nativeMenuItems<T>(widget.items),
      },
      onEvent: (event, value) {
        if (event == 'selected' &&
            value is int &&
            value >= 0 &&
            value < widget.items.length) {
          final item = widget.items[value];
          if (item is AdaptivePopupMenuItem<T>) widget.onSelected(value, item);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
    key: _anchorKey,
    behavior: HitTestBehavior.opaque,
    onTap: widget.triggerOnLongPress ? widget.onTap : _show,
    onLongPress: widget.triggerOnLongPress ? _show : null,
    child: widget.child,
  );
}
