import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../platform/platform_info.dart';
import 'android/android_m3e_native_icon.dart';
import 'android/android_m3e_platform_view.dart';

/// Action menu paired with the native Android Material 3 Expressive FAB menu.
class AdaptiveFabMenu extends StatelessWidget {
  const AdaptiveFabMenu({
    super.key,
    required this.items,
    this.icon = const Icon(Icons.add),
    this.closeIcon = const Icon(Icons.close),
    this.color = AdaptiveFabColor.primary,
    this.size = AdaptiveFabSize.medium,
    this.position = AdaptiveFabMenuPosition.right,
    this.backgroundColor,
    this.foregroundColor,
    this.nativeIcon,
    this.nativeCloseIcon,
    this.toggleMenuLabel = 'Toggle menu',
    this.expandedStateLabel = 'Expanded',
    this.collapsedStateLabel = 'Collapsed',
  });

  final List<AdaptiveFabMenuItem> items;
  final Widget icon;
  final Widget closeIcon;
  final AdaptiveFabColor color;
  final AdaptiveFabSize size;
  final AdaptiveFabMenuPosition position;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final AndroidM3EIcon? nativeIcon;
  final AndroidM3EIcon? nativeCloseIcon;

  /// Accessible name for the FAB that opens and closes this menu.
  final String toggleMenuLabel;

  /// Localized state descriptions announced by accessibility services.
  final String expandedStateLabel;
  final String collapsedStateLabel;

  @override
  Widget build(BuildContext context) {
    if (items.length < 2 || items.length > 6) {
      throw ArgumentError.value(
        items.length,
        'items.length',
        'Material 3 Expressive FAB menus require 2 to 6 actions.',
      );
    }
    if (PlatformInfo.usesNativeAndroidViews) {
      final iconName = resolveAndroidM3EIcon(
        child: icon,
        nativeIcon: nativeIcon,
        parameterName: 'nativeIcon',
      );
      final closeIconName = resolveAndroidM3EIcon(
        child: closeIcon,
        nativeIcon: nativeCloseIcon,
        parameterName: 'nativeCloseIcon',
      );
      final serializedItems = [
        for (final item in items)
          {
            'label': item.label,
            'icon': resolveAndroidM3EIcon(
              child: item.icon,
              nativeIcon: item.nativeIcon,
              parameterName: 'AdaptiveFabMenuItem.nativeIcon',
            ),
          },
      ];
      final diameter = switch (size) {
        AdaptiveFabSize.small => 40.0,
        AdaptiveFabSize.medium => 56.0,
        AdaptiveFabSize.large => 96.0,
      };
      return AndroidM3EPlatformView(
        component: 'fabMenu',
        width: diameter,
        height: diameter,
        properties: {
          'icon': iconName,
          'closeIcon': closeIconName,
          'color': color.name,
          'size': size.name,
          'position': position.name,
          'backgroundColor': backgroundColor?.toARGB32(),
          'foregroundColor': foregroundColor?.toARGB32(),
          'toggleMenuLabel': toggleMenuLabel,
          'expandedStateLabel': expandedStateLabel,
          'collapsedStateLabel': collapsedStateLabel,
          'items': serializedItems,
        },
        onEvent: (event, value) {
          if (event == 'itemPressed' &&
              value is int &&
              value >= 0 &&
              value < items.length) {
            items[value].onPressed?.call();
          }
        },
      );
    }
    if (PlatformInfo.isIOS) {
      return CupertinoButton.filled(
        padding: const EdgeInsets.all(14),
        onPressed: () => _showActions(context),
        child: icon,
      );
    }
    return FloatingActionButton(
      onPressed: () => _showActions(context),
      child: icon,
    );
  }

  Future<void> _showActions(BuildContext context) async {
    if (PlatformInfo.isIOS) {
      await showCupertinoModalPopup<void>(
        context: context,
        builder: (context) => CupertinoActionSheet(
          actions: [
            for (final item in items)
              CupertinoActionSheetAction(
                onPressed: () {
                  Navigator.of(context).pop();
                  item.onPressed?.call();
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    item.icon,
                    const SizedBox(width: 8),
                    Text(item.label),
                  ],
                ),
              ),
          ],
          cancelButton: CupertinoActionSheetAction(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ),
      );
      return;
    }
    await showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final item in items)
              ListTile(
                leading: item.icon,
                title: Text(item.label),
                onTap: () {
                  Navigator.of(context).pop();
                  item.onPressed?.call();
                },
              ),
          ],
        ),
      ),
    );
  }
}

/// One serializable action in an [AdaptiveFabMenu].
class AdaptiveFabMenuItem {
  const AdaptiveFabMenuItem({
    required this.label,
    required this.icon,
    this.nativeIcon,
    this.onPressed,
  });

  final String label;
  final Widget icon;
  final AndroidM3EIcon? nativeIcon;
  final VoidCallback? onPressed;
}
