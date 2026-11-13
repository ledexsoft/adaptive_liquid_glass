import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../platform/platform_info.dart';
import 'android/android_m3e_native_icon.dart';
import 'android/android_m3e_overlay.dart';
import 'native_occurrence_ids.dart';

final _nativeContextActionIds =
    NativeOccurrenceIds<AdaptiveContextMenuAction>();

/// A context menu action item
class AdaptiveContextMenuAction {
  /// Creates a context menu action
  const AdaptiveContextMenuAction({
    required this.title,
    required this.onPressed,
    this.icon,
    this.isDestructive = false,
    this.isDisabled = false,
    this.androidIcon,
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

  /// Serializable Compose icon for Android when [icon] cannot be mapped.
  final AndroidM3EIcon? androidIcon;
}

/// An adaptive context menu that renders platform-specific styles
///
/// On iOS 26+: Uses native UIContextMenu with Liquid Glass effects
/// On iOS <26: Uses CupertinoContextMenu
/// On Android: Uses a native Compose `DropdownMenu` anchored at the long-press
/// position.
class AdaptiveContextMenu extends StatefulWidget {
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
  State<AdaptiveContextMenu> createState() => _AdaptiveContextMenuState();
}

class _AdaptiveContextMenuState extends State<AdaptiveContextMenu> {
  @override
  Widget build(BuildContext context) {
    for (final action in widget.actions) {
      if (action.title.trim().isEmpty) {
        throw FlutterError('AdaptiveContextMenuAction.title must be nonempty.');
      }
    }
    // iOS 26+ - Use CupertinoContextMenu
    // Note: Native iOS 26 UIContextMenu could be implemented with platform view for enhanced visuals
    if (PlatformInfo.isIOS26OrHigher()) {
      return _buildCupertinoContextMenu(context);
    }

    // iOS <26 - Use CupertinoContextMenu
    if (PlatformInfo.isIOS) {
      return _buildCupertinoContextMenu(context);
    }

    // Android - Flutter detects the long press; Compose draws the native menu.
    return _buildAndroidContextMenu(context);
  }

  Widget _buildCupertinoContextMenu(BuildContext context) {
    return CupertinoContextMenu.builder(
      actions: widget.actions.map((action) {
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
        return widget.child;
      },
    );
  }

  Widget _buildAndroidContextMenu(BuildContext context) {
    return GestureDetector(
      onLongPressStart: (details) {
        if (PlatformInfo.usesNativeAndroidViews) {
          _showAndroidMenu(context, details.globalPosition);
        } else {
          _showFlutterMenu(context, details.globalPosition);
        }
      },
      child: widget.child,
    );
  }

  void _showFlutterMenu(BuildContext context, Offset anchor) {
    final screenSize = MediaQuery.sizeOf(context);
    final actionIds = _nativeContextActionIds.forItems(widget.actions);
    showMenu<int>(
      context: context,
      position: RelativeRect.fromLTRB(
        anchor.dx,
        anchor.dy,
        screenSize.width - anchor.dx,
        screenSize.height - anchor.dy,
      ),
      items: [
        for (var index = 0; index < widget.actions.length; index++)
          PopupMenuItem<int>(
            value: actionIds[index],
            enabled: !widget.actions[index].isDisabled,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.actions[index].icon is IconData) ...[
                  Icon(
                    widget.actions[index].icon as IconData,
                    color: widget.actions[index].isDestructive
                        ? Theme.of(context).colorScheme.error
                        : null,
                  ),
                  const SizedBox(width: 12),
                ],
                Text(
                  widget.actions[index].title,
                  style: widget.actions[index].isDestructive
                      ? TextStyle(color: Theme.of(context).colorScheme.error)
                      : null,
                ),
              ],
            ),
          ),
      ],
    ).then((id) {
      if (!mounted || id == null) return;
      final index = _selectedActionIndex({'id': id});
      if (index != null) widget.actions[index].onPressed();
    });
  }

  int? _selectedActionIndex(Object? value) {
    int? index;
    if (value is Map) {
      final id = value['id'];
      if (id is! int) return null;
      index = _nativeContextActionIds.forItems(widget.actions).indexOf(id);
    } else if (value is int) {
      index = value;
    }
    if (index == null || index < 0 || index >= widget.actions.length) {
      return null;
    }
    return widget.actions[index].isDisabled ? null : index;
  }

  Future<void> _showAndroidMenu(BuildContext context, Offset anchor) async {
    final actionIds = _nativeContextActionIds.forItems(widget.actions);
    final result = await showAndroidM3EOverlay(
      context: context,
      component: 'contextMenu',
      rootNavigator: true,
      properties: {
        'anchorX': anchor.dx,
        'anchorY': anchor.dy,
        'actions': [
          for (var index = 0; index < widget.actions.length; index++)
            {
              'id': actionIds[index],
              'title': widget.actions[index].title,
              'icon': _nativeIcon(widget.actions[index]),
              'enabled': !widget.actions[index].isDisabled,
              'destructive': widget.actions[index].isDestructive,
            },
        ],
      },
    );
    if (!mounted) return;
    if (result is AndroidM3EOverlayResult && result.event == 'selected') {
      final index = _selectedActionIndex(result.value);
      if (index != null) widget.actions[index].onPressed();
    }
  }

  String? _nativeIcon(AdaptiveContextMenuAction action) {
    if (action.androidIcon != null) return action.androidIcon!.name;
    if (action.icon is AndroidM3EIcon) {
      return (action.icon as AndroidM3EIcon).name;
    }
    if (action.icon is IconData) {
      return resolveAndroidM3EIcon(
        child: Icon(action.icon as IconData),
        nativeIcon: null,
        parameterName: 'action.androidIcon',
      );
    }
    if (action.icon != null) {
      throw FlutterError(
        'Android context-menu icons must be mapped Material icons or AndroidM3EIcon.',
      );
    }
    return null;
  }
}
