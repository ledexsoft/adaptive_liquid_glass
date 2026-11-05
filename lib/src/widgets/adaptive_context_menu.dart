import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:material_3_expressive/material_3_expressive.dart' as m3e;
import '../platform/platform_info.dart';
import '../theme/adaptive_material_expressive_theme.dart';

/// A context menu action item
class AdaptiveContextMenuAction {
  /// Creates a context menu action
  const AdaptiveContextMenuAction({
    required this.title,
    required this.onPressed,
    this.icon,
    this.isDestructive = false,
    this.isDisabled = false,
  });

  /// The title of the action
  final String title;

  /// Callback when the action is pressed
  final VoidCallback onPressed;

  /// Icon for the action (iOS 26+: SF Symbol string, iOS <26/Android: IconData)
  final dynamic icon;

  /// Whether this is a destructive action (shown in red)
  final bool isDestructive;

  /// Whether this action is disabled
  final bool isDisabled;
}

/// An adaptive context menu that renders platform-specific styles
///
/// On iOS 26+: Uses native UIContextMenu with Liquid Glass effects
/// On iOS <26: Uses CupertinoContextMenu
/// On Android: Uses an M3E anchored menu when the app theme is installed above
/// the root Navigator; otherwise uses a Material popup menu.
class AdaptiveContextMenu extends StatelessWidget {
  /// Creates an adaptive context menu
  const AdaptiveContextMenu({
    super.key,
    required this.child,
    required this.actions,
    this.previewBuilder,
  });

  /// The widget to wrap with context menu
  final Widget child;

  /// List of actions to show in the context menu
  final List<AdaptiveContextMenuAction> actions;

  /// Optional preview builder for iOS (shows preview when long pressing)
  final Widget Function(BuildContext)? previewBuilder;

  @override
  Widget build(BuildContext context) {
    // iOS 26+ - Use CupertinoContextMenu
    // Note: Native iOS 26 UIContextMenu could be implemented with platform view for enhanced visuals
    if (PlatformInfo.isIOS26OrHigher()) {
      return _buildCupertinoContextMenu(context);
    }

    // iOS <26 - Use CupertinoContextMenu
    if (PlatformInfo.isIOS) {
      return _buildCupertinoContextMenu(context);
    }

    // Android - Use the expressive anchored menu.
    return _buildAndroidContextMenu(context);
  }

  Widget _buildCupertinoContextMenu(BuildContext context) {
    return CupertinoContextMenu.builder(
      actions: actions.map((action) {
        return CupertinoContextMenuAction(
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pop();
            Future.microtask(() => action.onPressed());
          },
          isDestructiveAction: action.isDestructive,
          trailingIcon: action.icon is IconData
              ? action.icon as IconData
              : null,
          child: Text(action.title),
        );
      }).toList(),
      builder: (context, animation) {
        return child;
      },
    );
  }

  Widget _buildAndroidContextMenu(BuildContext context) {
    if (!hasAdaptiveMaterialExpressiveNavigatorTheme(
      context,
      rootNavigator: true,
    )) {
      return GestureDetector(
        onLongPressStart: (details) =>
            _showAndroidMenu(context, details.globalPosition),
        child: child,
      );
    }

    return m3e.M3EMenu.entries(
      anchorBuilder: (context, open) =>
          GestureDetector(onLongPress: open, child: child),
      entries: [
        for (final action in actions)
          m3e.M3EMenuEntry(
            label: action.title,
            leading: action.icon is IconData
                ? Icon(action.icon as IconData)
                : null,
            enabled: !action.isDisabled,
            isDestructive: action.isDestructive,
            onPressed: action.onPressed,
          ),
      ],
    );
  }

  void _showAndroidMenu(BuildContext context, Offset anchor) {
    final screenSize = MediaQuery.sizeOf(context);
    showMenu<int>(
      context: context,
      position: RelativeRect.fromLTRB(
        anchor.dx,
        anchor.dy,
        screenSize.width - anchor.dx,
        screenSize.height - anchor.dy,
      ),
      items: [
        for (var index = 0; index < actions.length; index++)
          PopupMenuItem<int>(
            value: index,
            enabled: !actions[index].isDisabled,
            child: Row(
              children: [
                if (actions[index].icon is IconData) ...[
                  Icon(
                    actions[index].icon as IconData,
                    color: actions[index].isDestructive
                        ? Theme.of(context).colorScheme.error
                        : null,
                  ),
                  const SizedBox(width: 12),
                ],
                Text(
                  actions[index].title,
                  style: TextStyle(
                    color: actions[index].isDestructive
                        ? Theme.of(context).colorScheme.error
                        : null,
                  ),
                ),
              ],
            ),
          ),
      ],
    ).then((selectedIndex) {
      if (selectedIndex != null) actions[selectedIndex].onPressed();
    });
  }
}
