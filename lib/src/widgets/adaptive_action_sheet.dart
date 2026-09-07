import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../platform/platform_info.dart';

/// An action item for [showAdaptiveActionSheet].
class AdaptiveActionSheetAction {
  /// Creates an action for an adaptive action sheet.
  const AdaptiveActionSheetAction({
    required this.child,
    required this.onPressed,
    this.isDefaultAction = false,
    this.isDestructiveAction = false,
    this.icon,
  });

  /// The widget to display as the action's label (usually a [Text]).
  final Widget child;

  /// The callback to invoke when this action is tapped.
  final VoidCallback onPressed;

  /// Whether this action is the default (emphasized) action.
  final bool isDefaultAction;

  /// Whether this action performs a destructive operation (e.g. Delete).
  final bool isDestructiveAction;

  /// Optional leading icon displayed on Android / Material sheets.
  final Widget? icon;
}

/// Shows an adaptive action sheet matching the platform design.
///
/// On iOS & macOS: Displays a [CupertinoActionSheet] with native blur and spring animations.
/// On Android & other platforms: Displays a Material 3 bottom sheet with drag handle and options.
///
/// Example:
/// ```dart
/// showAdaptiveActionSheet<void>(
///   context: context,
///   title: const Text('Options'),
///   message: const Text('Select an option to proceed'),
///   actions: [
///     AdaptiveActionSheetAction(
///       child: const Text('Share'),
///       onPressed: () {
///         Navigator.pop(context);
///       },
///     ),
///     AdaptiveActionSheetAction(
///       isDestructiveAction: true,
///       child: const Text('Delete'),
///       onPressed: () {
///         Navigator.pop(context);
///       },
///     ),
///   ],
///   cancelButton: AdaptiveActionSheetAction(
///     child: const Text('Cancel'),
///     onPressed: () => Navigator.pop(context),
///   ),
/// );
/// ```
Future<T?> showAdaptiveActionSheet<T>({
  required BuildContext context,
  Widget? title,
  Widget? message,
  required List<AdaptiveActionSheetAction> actions,
  AdaptiveActionSheetAction? cancelButton,
}) {
  if (PlatformInfo.isIOS || PlatformInfo.isMacOS) {
    return showCupertinoModalPopup<T>(
      context: context,
      builder: (BuildContext sheetContext) {
        return CupertinoActionSheet(
          title: title,
          message: message,
          actions: actions.map((action) {
            return CupertinoActionSheetAction(
              onPressed: action.onPressed,
              isDefaultAction: action.isDefaultAction,
              isDestructiveAction: action.isDestructiveAction,
              child: action.child,
            );
          }).toList(),
          cancelButton: cancelButton != null
              ? CupertinoActionSheetAction(
                  onPressed: cancelButton.onPressed,
                  isDefaultAction: cancelButton.isDefaultAction,
                  isDestructiveAction: cancelButton.isDestructiveAction,
                  child: cancelButton.child,
                )
              : null,
        );
      },
    );
  }

  // Android & Material bottom sheet
  final theme = Theme.of(context);
  return showModalBottomSheet<T>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (BuildContext sheetContext) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (title != null || message != null)
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (title != null)
                        DefaultTextStyle(
                          style: theme.textTheme.titleMedium!.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          child: title,
                        ),
                      if (message != null) ...[
                        const SizedBox(height: 4),
                        DefaultTextStyle(
                          style: theme.textTheme.bodyMedium!.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          child: message,
                        ),
                      ],
                    ],
                  ),
                ),
              if (title != null || message != null) const Divider(),
              for (final action in actions)
                ListTile(
                  leading: action.icon,
                  title: DefaultTextStyle(
                    style: theme.textTheme.bodyLarge!.copyWith(
                      color: action.isDestructiveAction
                          ? theme.colorScheme.error
                          : (action.isDefaultAction
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurface),
                      fontWeight: action.isDefaultAction
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                    child: action.child,
                  ),
                  onTap: action.onPressed,
                ),
              if (cancelButton != null) ...[
                const Divider(),
                ListTile(
                  leading: cancelButton.icon,
                  title: Center(
                    child: DefaultTextStyle(
                      style: theme.textTheme.bodyLarge!.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                      child: cancelButton.child,
                    ),
                  ),
                  onTap: cancelButton.onPressed,
                ),
              ],
            ],
          ),
        ),
      );
    },
  );
}
