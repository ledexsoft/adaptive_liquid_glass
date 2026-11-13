import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../platform/platform_info.dart';
import 'android/android_m3e_native_icon.dart';
import 'android/android_m3e_platform_view.dart';
import 'native_occurrence_ids.dart';

final _nativeFabMenuItemIds = NativeOccurrenceIds<AdaptiveFabMenuItem>();

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
    String? toggleMenuLabel,
    String? closeMenuLabel,
    String? expandedStateLabel,
    String? collapsedStateLabel,
    this.useFullScreenOverlay = false,
  }) : // Keep the public parameter names while distinguishing omitted labels.
       // ignore: prefer_initializing_formals
       _toggleMenuLabel = toggleMenuLabel,
       // ignore: prefer_initializing_formals
       _closeMenuLabel = closeMenuLabel,
       // ignore: prefer_initializing_formals
       _expandedStateLabel = expandedStateLabel,
       // ignore: prefer_initializing_formals
       _collapsedStateLabel = collapsedStateLabel;

  final List<AdaptiveFabMenuItem> items;
  final Widget icon;
  final Widget closeIcon;
  final AdaptiveFabColor color;
  final AdaptiveFabSize size;

  /// Menu edge relative to the reading direction: [AdaptiveFabMenuPosition.left]
  /// is start and [AdaptiveFabMenuPosition.right] is end. The physical edge
  /// reverses in RTL so the native menu stays attached to Flutter's FAB.
  final AdaptiveFabMenuPosition position;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final AndroidM3EIcon? nativeIcon;
  final AndroidM3EIcon? nativeCloseIcon;

  /// Accessible name for the FAB when it opens this menu.
  final String? _toggleMenuLabel;
  String get toggleMenuLabel => _toggleMenuLabel ?? 'Toggle menu';

  /// Accessible name for the FAB and its custom action when closing the menu.
  final String? _closeMenuLabel;
  String get closeMenuLabel => _closeMenuLabel ?? 'Close menu';

  /// Localized state descriptions announced by accessibility services.
  final String? _expandedStateLabel;
  final String? _collapsedStateLabel;
  String get expandedStateLabel => _expandedStateLabel ?? 'Expanded';
  String get collapsedStateLabel => _collapsedStateLabel ?? 'Collapsed';

  ({String toggle, String close, String expanded, String collapsed})
  _resolvedLabels(BuildContext context) {
    final localizations = Localizations.of<MaterialLocalizations>(
      context,
      MaterialLocalizations,
    );
    return (
      toggle:
          _toggleMenuLabel ?? localizations?.showMenuTooltip ?? toggleMenuLabel,
      close:
          _closeMenuLabel ?? localizations?.menuDismissLabel ?? closeMenuLabel,
      expanded:
          _expandedStateLabel ??
          localizations?.collapsedHint ??
          expandedStateLabel,
      collapsed:
          _collapsedStateLabel ??
          localizations?.expandedHint ??
          collapsedStateLabel,
    );
  }

  /// Uses the full bounds supplied by the caller for the native Android menu.
  /// Place this mode in a bounded screen overlay such as `Positioned.fill`.
  /// The default builds that overlay automatically while retaining a
  /// correctly sized FAB in `Scaffold.floatingActionButton`.
  final bool useFullScreenOverlay;

  @override
  Widget build(BuildContext context) {
    if (items.length < 2 || items.length > 6) {
      throw ArgumentError.value(
        items.length,
        'items.length',
        'Material 3 Expressive FAB menus require 2 to 6 actions.',
      );
    }
    for (final (index, item) in items.indexed) {
      if (item.label.trim().isEmpty) {
        throw ArgumentError.value(
          item.label,
          'items[$index].label',
          'Material 3 Expressive FAB menu actions require a visible label.',
        );
      }
    }
    if (PlatformInfo.usesNativeAndroidViews) {
      for (final (name, label) in <(String, String?)>[
        ('toggleMenuLabel', _toggleMenuLabel),
        ('closeMenuLabel', _closeMenuLabel),
        ('expandedStateLabel', _expandedStateLabel),
        ('collapsedStateLabel', _collapsedStateLabel),
      ]) {
        if (label != null && label.trim().isEmpty) {
          throw ArgumentError.value(
            label,
            name,
            'Native FAB menu accessibility labels cannot be blank.',
          );
        }
      }
      if (!useFullScreenOverlay) {
        return _AndroidFabMenuOverlay(menu: this);
      }
      final labels = _resolvedLabels(context);
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
      final itemIds = _nativeFabMenuItemIds.forItems(items);
      final serializedItems = [
        for (var index = 0; index < items.length; index++)
          {
            'id': itemIds[index],
            'label': items[index].label,
            'icon': resolveAndroidM3EIcon(
              child: items[index].icon,
              nativeIcon: items[index].nativeIcon,
              parameterName: 'AdaptiveFabMenuItem.nativeIcon',
            ),
            'iconSize': items[index].icon is Icon
                ? (items[index].icon as Icon).size
                : null,
            'iconColor': items[index].icon is Icon
                ? (items[index].icon as Icon).color?.toARGB32()
                : null,
          },
      ];
      Widget nativeMenu({
        required double? width,
        required double? height,
        required PlatformViewHitTestBehavior hitTestBehavior,
      }) => AndroidM3EPlatformView(
        component: 'fabMenu',
        width: width,
        height: height,
        hitTestBehavior: hitTestBehavior,
        properties: {
          'icon': iconName,
          'closeIcon': closeIconName,
          'iconSize': icon is Icon ? (icon as Icon).size : null,
          'iconColor': icon is Icon ? (icon as Icon).color?.toARGB32() : null,
          'closeIconSize': closeIcon is Icon ? (closeIcon as Icon).size : null,
          'closeIconColor': closeIcon is Icon
              ? (closeIcon as Icon).color?.toARGB32()
              : null,
          'color': color.name,
          'size': size.name,
          'position': position.name,
          'backgroundColor': backgroundColor?.toARGB32(),
          'foregroundColor': foregroundColor?.toARGB32(),
          'toggleMenuLabel': labels.toggle,
          'closeMenuLabel': labels.close,
          'expandedStateLabel': labels.expanded,
          'collapsedStateLabel': labels.collapsed,
          'items': serializedItems,
        },
        onEvent: (event, value) {
          if (event != 'itemPressed') return;
          if (value is Map<Object?, Object?>) {
            final id = value['id'];
            if (id is! int) return;
            final index = itemIds.indexOf(id);
            if (index >= 0) items[index].onPressed?.call();
          } else if (value is int && value >= 0 && value < items.length) {
            // Accept events from an older native view during a hot restart.
            items[value].onPressed?.call();
          }
        },
      );

      return LayoutBuilder(
        builder: (context, constraints) {
          if (!constraints.hasBoundedWidth || !constraints.hasBoundedHeight) {
            throw FlutterError(
              'AdaptiveFabMenu.useFullScreenOverlay needs bounded screen-sized constraints.',
            );
          }
          return nativeMenu(
            width: constraints.maxWidth,
            height: constraints.maxHeight,
            hitTestBehavior: PlatformViewHitTestBehavior.translucent,
          );
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

class _AndroidFabMenuOverlay extends StatefulWidget {
  const _AndroidFabMenuOverlay({required this.menu});

  final AdaptiveFabMenu menu;

  @override
  State<_AndroidFabMenuOverlay> createState() => _AndroidFabMenuOverlayState();
}

class _AndroidFabMenuOverlayState extends State<_AndroidFabMenuOverlay> {
  final OverlayPortalController _controller = OverlayPortalController();
  final LayerLink _link = LayerLink();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _controller.show();
    });
  }

  @override
  Widget build(BuildContext context) {
    final menu = widget.menu;
    final labels = menu._resolvedLabels(context);
    final diameter = switch (menu.size) {
      // The native toggle grows from 40 dp to a 56 dp close button.
      AdaptiveFabSize.small => 56.0,
      AdaptiveFabSize.medium => 56.0,
      AdaptiveFabSize.large => 96.0,
    };
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final alignLeft = (menu.position == AdaptiveFabMenuPosition.left) != rtl;
    final corner = alignLeft ? Alignment.bottomLeft : Alignment.bottomRight;
    return OverlayPortal(
      controller: _controller,
      overlayChildBuilder: (overlayContext) {
        final viewport = MediaQuery.sizeOf(overlayContext);
        return CompositedTransformFollower(
          link: _link,
          showWhenUnlinked: false,
          targetAnchor: corner,
          followerAnchor: corner,
          child: SizedBox(
            width: viewport.width,
            height: viewport.height,
            child: AdaptiveFabMenu(
              items: menu.items,
              icon: menu.icon,
              closeIcon: menu.closeIcon,
              color: menu.color,
              size: menu.size,
              position: menu.position,
              backgroundColor: menu.backgroundColor,
              foregroundColor: menu.foregroundColor,
              nativeIcon: menu.nativeIcon,
              nativeCloseIcon: menu.nativeCloseIcon,
              toggleMenuLabel: labels.toggle,
              closeMenuLabel: labels.close,
              expandedStateLabel: labels.expanded,
              collapsedStateLabel: labels.collapsed,
              useFullScreenOverlay: true,
            ),
          ),
        );
      },
      child: CompositedTransformTarget(
        link: _link,
        child: SizedBox(width: diameter, height: diameter),
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

  /// Visible, nonblank label for the menu action.
  final String label;
  final Widget icon;
  final AndroidM3EIcon? nativeIcon;
  final VoidCallback? onPressed;
}
