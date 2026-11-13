import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../platform/platform_info.dart';
import 'android/android_m3e_native_icon.dart';
import 'android/android_m3e_overlay.dart';
import 'android/android_m3e_text_options.dart';

/// An action item for [showAdaptiveActionSheet].
class AdaptiveActionSheetAction {
  /// Creates an action for an adaptive action sheet.
  const AdaptiveActionSheetAction({
    required this.child,
    required this.onPressed,
    this.isDefaultAction = false,
    this.isDestructiveAction = false,
    this.icon,
    this.androidIcon,
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

  /// Serializable Compose icon for Android when [icon] cannot be mapped.
  final AndroidM3EIcon? androidIcon;
}

/// Shows an adaptive action sheet matching the platform design.
///
/// On iOS & macOS: Displays a [CupertinoActionSheet] with native blur and spring animations.
/// On Android: Displays a native Compose Material 3 bottom sheet when its
/// content can be represented natively. Other content uses a Material sheet.
/// Other platforms use the Material bottom sheet fallback.
///
/// Android sheets close before an action callback runs. Cupertino and other
/// Flutter bottom-sheet actions leave dismissal to the callback.
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
///         if (!PlatformInfo.usesNativeAndroidViews) Navigator.pop(context);
///         // Share the selected item.
///       },
///     ),
///     AdaptiveActionSheetAction(
///       isDestructiveAction: true,
///       child: const Text('Delete'),
///       onPressed: () {
///         if (!PlatformInfo.usesNativeAndroidViews) Navigator.pop(context);
///         // Delete the selected item.
///       },
///     ),
///   ],
///   cancelButton: AdaptiveActionSheetAction(
///     child: const Text('Cancel'),
///     onPressed: () {
///       if (!PlatformInfo.usesNativeAndroidViews) Navigator.pop(context);
///     },
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

  if (PlatformInfo.usesNativeAndroidViews &&
      _canRenderNativeActionSheet(title, message, actions, cancelButton)) {
    final allActions = [...actions, if (cancelButton != null) cancelButton];
    final nativeTitle = _nativeText(title, 'title');
    final nativeMessage = _nativeText(message, 'message');
    final nativeLabels = [
      for (final action in allActions)
        _nativeText(action.child, 'action.child')!,
    ];
    for (var index = 0; index < nativeLabels.length; index++) {
      if (nativeLabels[index].data!.trim().isEmpty) {
        throw FlutterError(
          'Android native action sheet action ${index + 1} requires a nonblank Text label.',
        );
      }
    }
    final result = showAndroidM3EOverlay(
      context: context,
      component: 'actionSheet',
      properties: {
        'title': nativeTitle?.data,
        'titleTextOptions': nativeTitle == null
            ? null
            : androidM3ETextOptions(nativeTitle),
        'titleColor': nativeTitle?.style?.color?.toARGB32(),
        'message': nativeMessage?.data,
        'messageTextOptions': nativeMessage == null
            ? null
            : androidM3ETextOptions(nativeMessage),
        'messageColor': nativeMessage?.style?.color?.toARGB32(),
        'actions': [
          for (var index = 0; index < allActions.length; index++)
            {
              'label': nativeLabels[index].data,
              'labelTextOptions': androidM3ETextOptions(nativeLabels[index]),
              'labelColor': nativeLabels[index].style?.color?.toARGB32(),
              'icon': _nativeIcon(
                allActions[index].icon,
                allActions[index].androidIcon,
              ),
              'iconColor': _nativeIconColor(allActions[index].icon)?.toARGB32(),
              'iconSize': _nativeIconSize(allActions[index].icon),
              'iconSemanticLabel': _nativeIconSemanticLabel(
                allActions[index].icon,
              ),
              'default': allActions[index].isDefaultAction,
              'destructive': allActions[index].isDestructiveAction,
              'cancel': index >= actions.length,
            },
        ],
      },
    );
    return result.then<T?>((value) {
      if (value is AndroidM3EOverlayResult &&
          value.event == 'selected' &&
          value.value is int) {
        final index = value.value! as int;
        if (index >= 0 && index < allActions.length) {
          allActions[index].onPressed();
        }
      }
      return value is T ? value : null;
    });
  }

  // Unsupported Android content and other platforms use a Material sheet.
  final theme = Theme.of(context);
  final closeBeforeAction = PlatformInfo.usesNativeAndroidViews;
  return showModalBottomSheet<T>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (BuildContext sheetContext) {
      void onActionPressed(AdaptiveActionSheetAction action) {
        if (!closeBeforeAction) {
          action.onPressed();
          return;
        }
        final route = ModalRoute.of(sheetContext);
        if (route == null) {
          action.onPressed();
          return;
        }
        route.completed.then((_) => action.onPressed());
        Navigator.of(sheetContext).pop();
      }

      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (title != null || message != null)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 8,
                  ),
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
                  onTap: () => onActionPressed(action),
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
                  onTap: () => onActionPressed(cancelButton),
                ),
              ],
            ],
          ),
        ),
      );
    },
  );
}

Text? _nativeText(Widget? widget, String parameter) {
  if (widget == null) return null;
  if (widget is Text && canRenderAndroidM3EText(widget)) {
    return widget;
  }
  throw FlutterError(
    'Android native action sheets require $parameter to be Text with styling supported by Compose.',
  );
}

bool _canRenderNativeActionSheet(
  Widget? title,
  Widget? message,
  List<AdaptiveActionSheetAction> actions,
  AdaptiveActionSheetAction? cancelButton,
) {
  if (title != null && !canRenderAndroidM3EText(title)) return false;
  if (message != null && !canRenderAndroidM3EText(message)) return false;
  for (final action in [...actions, if (cancelButton != null) cancelButton]) {
    if (!canRenderAndroidM3EText(action.child)) return false;
    if (action.icon != null &&
        !canResolveAndroidM3EIcon(
          child: action.icon,
          nativeIcon: action.androidIcon,
        )) {
      return false;
    }
  }
  return true;
}

String? _nativeIcon(Widget? widget, AndroidM3EIcon? nativeIcon) {
  if (nativeIcon != null) return nativeIcon.name;
  if (widget == null) return null;
  if (widget is! Icon || widget.icon == null) {
    throw FlutterError(
      'Android native action sheet icons must be Icon or AndroidM3EIcon.',
    );
  }
  return resolveAndroidM3EIcon(
    child: widget,
    nativeIcon: null,
    parameterName: 'action.icon',
  );
}

Color? _nativeIconColor(Widget? widget) => widget is Icon ? widget.color : null;

double? _nativeIconSize(Widget? widget) => widget is Icon ? widget.size : null;

String? _nativeIconSemanticLabel(Widget? widget) =>
    widget is Icon ? widget.semanticLabel : null;
