import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:material_3_expressive/material_3_expressive.dart' as m3e;
import '../platform/platform_info.dart';
import '../theme/adaptive_material_expressive_theme.dart';
import 'ios26/ios26_alert_dialog.dart';

export 'ios26/ios26_alert_dialog.dart' show AlertAction, AlertActionStyle;

/// Configuration for text input in alert dialog
class AdaptiveAlertDialogInput {
  /// Creates a text input configuration for alert dialog
  const AdaptiveAlertDialogInput({
    required this.placeholder,
    this.initialValue,
    this.keyboardType,
    this.obscureText = false,
    this.maxLength,
  });

  /// Placeholder text for the text field
  final String placeholder;

  /// Initial value for the text field
  final String? initialValue;

  /// Keyboard type for the text field
  final TextInputType? keyboardType;

  /// Whether to obscure the text (for passwords)
  final bool obscureText;

  /// Maximum length of the text input
  final int? maxLength;
}

/// An adaptive alert dialog that renders platform-specific styles
///
/// On iOS 26+: Uses native iOS 26 UIAlertController with Liquid Glass
/// On iOS <26 (iOS 18 and below): Uses CupertinoAlertDialog
/// On Android: Uses an M3E dialog when the app theme is installed above the
/// Navigator; otherwise uses a Flutter Material dialog.
class AdaptiveAlertDialog {
  AdaptiveAlertDialog._();

  /// Shows a standard adaptive alert dialog
  ///
  /// The [icon] parameter accepts:
  /// - iOS 26+: String (SF Symbol name, e.g., "checkmark.circle.fill")
  /// - iOS <26: IconData (e.g., CupertinoIcons.checkmark_alt_circle_fill)
  /// - Android: IconData (e.g., Icons.check_circle)
  ///
  /// Returns a Future that resolves to void when the dialog is dismissed
  static Future<void> show({
    required BuildContext context,
    required String title,
    String? message,
    required List<AlertAction> actions,
    dynamic icon,
    double? iconSize,
    Color? iconColor,
    String? oneTimeCode,
  }) {
    // iOS 26+ - Use native iOS 26 alert dialog
    if (PlatformInfo.isIOS26OrHigher()) {
      // Convert icon to String if needed for iOS 26 (expects SF Symbol)
      String? iconString;
      if (icon != null) {
        if (icon is String) {
          iconString = icon;
        }
        // If IconData is provided on iOS 26+, ignore it (iOS 26 uses SF Symbols)
      }

      return showCupertinoDialog<void>(
        context: context,
        barrierColor: CupertinoColors.transparent,
        builder: (context) => IOS26AlertDialog(
          title: title,
          message: message,
          actions: actions,
          icon: iconString,
          iconSize: iconSize,
          iconColor: iconColor,
          oneTimeCode: oneTimeCode,
          input: null, // No input for standard dialog
        ),
      );
    }

    // iOS 18 and below - Use CupertinoAlertDialog
    if (PlatformInfo.isIOS) {
      return showCupertinoDialog<void>(
        context: context,
        builder: (context) {
          Widget? contentWidget;
          final hasLegacyIcon =
              icon != null && icon is IconData && iconSize != null;
          final hasOtpCode = oneTimeCode != null;
          final hasContentBelowMessage = hasOtpCode;
          final hasScrollableLegacyContent =
              hasLegacyIcon || hasOtpCode || message != null;

          // Build custom content if icon or OTP is present
          if (hasScrollableLegacyContent) {
            contentWidget = ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: hasContentBelowMessage ? 60 : 0,
                maxHeight: 300,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (hasLegacyIcon) ...[
                      Icon(
                        icon,
                        size: iconSize,
                        color: iconColor ?? CupertinoColors.systemBlue,
                      ),
                      const SizedBox(height: 8),
                    ],
                    if (message != null) ...[
                      Text(
                        message,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 13),
                      ),
                      if (hasContentBelowMessage) const SizedBox(height: 12),
                    ],
                    if (hasOtpCode) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          // 09/09: resolver el color dinámico — crudo pintaba
                          // el valor claro (≈blanco) también en modo oscuro.
                          color: CupertinoDynamicColor.resolve(
                            CupertinoColors.systemGrey6,
                            context,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          oneTimeCode,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Courier',
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ],
                ),
              ),
            );
          }

          return CupertinoAlertDialog(
            title: Text(title),
            content: contentWidget != null
                ? Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: contentWidget,
                  )
                : null,
            actions: actions.map((action) {
              return CupertinoDialogAction(
                onPressed: () {
                  Navigator.of(context).pop();
                  action.onPressed();
                },
                isDefaultAction: action.style == AlertActionStyle.primary,
                isDestructiveAction:
                    action.style == AlertActionStyle.destructive,
                child: Text(action.title),
              );
            }).toList(),
          );
        },
      );
    }

    if (PlatformInfo.isAndroid &&
        oneTimeCode == null &&
        hasAdaptiveMaterialExpressiveNavigatorTheme(context)) {
      return m3e.M3EDialog.show<void>(
        context,
        dialog: m3e.M3EDialog(
          title: title,
          icon: icon is IconData
              ? Icon(icon, size: iconSize, color: iconColor)
              : null,
          content: message == null ? null : Text(message),
          actions: [
            for (final action in actions)
              m3e.M3EButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  action.onPressed();
                },
                enabled:
                    action.enabled && action.style != AlertActionStyle.disabled,
                style: action.style == AlertActionStyle.primary
                    ? m3e.M3EButtonStyle.filled
                    : m3e.M3EButtonStyle.text,
                decoration: _m3eActionForeground(action.style, context),
                child: Text(action.title),
              ),
          ],
        ),
      ).then((_) {});
    }

    // Android - Use Material Design AlertDialog
    return _showMaterialDialog(
      context: context,
      title: title,
      message: message,
      actions: actions,
      icon: icon,
      iconSize: iconSize,
      iconColor: iconColor,
      oneTimeCode: oneTimeCode,
      input: null,
    );
  }

  /// Shows an adaptive alert dialog with text input
  ///
  /// The [input] parameter configures the text input field.
  /// Returns a Future containing the entered text or null if cancelled
  static Future<String?> inputShow({
    required BuildContext context,
    required String title,
    String? message,
    required List<AlertAction> actions,
    required AdaptiveAlertDialogInput input,
    dynamic icon,
    double? iconSize,
    Color? iconColor,
  }) {
    // iOS 26+ - Use native iOS 26 alert dialog with input
    if (PlatformInfo.isIOS26OrHigher()) {
      // Convert icon to String if needed for iOS 26 (expects SF Symbol)
      String? iconString;
      if (icon != null) {
        if (icon is String) {
          iconString = icon;
        }
      }

      return showCupertinoDialog<String?>(
        context: context,
        builder: (context) => IOS26AlertDialog(
          title: title,
          message: message,
          actions: actions,
          icon: iconString,
          iconSize: iconSize,
          iconColor: iconColor,
          oneTimeCode: null,
          input: input,
        ),
      );
    }

    // iOS 18 and below - Use CupertinoAlertDialog with text field
    if (PlatformInfo.isIOS) {
      final textController = TextEditingController(text: input.initialValue);

      return showCupertinoDialog<String?>(
        context: context,
        builder: (context) {
          Widget? contentWidget;

          // Build custom content with text field
          contentWidget = ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 100, maxHeight: 300),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (icon != null && icon is IconData && iconSize != null) ...[
                    Icon(
                      icon,
                      size: iconSize,
                      color: iconColor ?? CupertinoColors.systemBlue,
                    ),
                    const SizedBox(height: 8),
                  ],
                  if (message != null) ...[
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 13),
                    ),
                    const SizedBox(height: 12),
                  ],
                  CupertinoTextField(
                    controller: textController,
                    placeholder: input.placeholder,
                    keyboardType: input.keyboardType,
                    obscureText: input.obscureText,
                    maxLength: input.maxLength,
                    autofocus: true,
                    padding: const EdgeInsets.all(12),
                  ),
                ],
              ),
            ),
          );

          return CupertinoAlertDialog(
            title: Text(title),
            content: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: contentWidget,
            ),
            actions: actions.map((action) {
              return CupertinoDialogAction(
                onPressed: () {
                  if (action.style == AlertActionStyle.cancel) {
                    // Cancel button returns null
                    Navigator.of(context).pop<String?>(null);
                  } else {
                    // Other buttons return the entered text
                    final text = textController.text.trim();
                    Navigator.of(
                      context,
                    ).pop<String?>(text.isNotEmpty ? text : null);
                  }
                  action.onPressed();
                },
                isDefaultAction: action.style == AlertActionStyle.primary,
                isDestructiveAction:
                    action.style == AlertActionStyle.destructive,
                child: Text(action.title),
              );
            }).toList(),
          );
        },
      );
    }

    if (PlatformInfo.isAndroid &&
        input.maxLength == null &&
        hasAdaptiveMaterialExpressiveNavigatorTheme(context)) {
      return m3e.M3EDialog.show<String>(
        context,
        dialog: _M3EInputAlertDialog(
          title: title,
          message: message,
          actions: actions,
          input: input,
          icon: icon,
          iconSize: iconSize,
          iconColor: iconColor,
        ),
      );
    }

    // Android - Use Material Design AlertDialog with TextField
    return _showMaterialDialog<String?>(
      context: context,
      title: title,
      message: message,
      actions: actions,
      icon: icon,
      iconSize: iconSize,
      iconColor: iconColor,
      oneTimeCode: null,
      input: input,
    );
  }

  /// Internal helper method for showing Material dialogs
  static Future<T?> _showMaterialDialog<T>({
    required BuildContext context,
    required String title,
    String? message,
    required List<AlertAction> actions,
    dynamic icon,
    double? iconSize,
    Color? iconColor,
    String? oneTimeCode,
    AdaptiveAlertDialogInput? input,
  }) {
    final textController = TextEditingController(text: input?.initialValue);

    return showDialog<T>(
      context: context,
      builder: (context) {
        // Build custom content if icon, OTP, or textfield is present
        Widget? contentWidget;
        final hasMaterialIcon =
            icon != null && icon is IconData && iconSize != null;
        final hasOtpCode = oneTimeCode != null;
        final hasInput = input != null;
        final hasContentBelowMessage = hasOtpCode || hasInput;
        if (icon != null ||
            oneTimeCode != null ||
            message != null ||
            input != null) {
          contentWidget = Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (hasMaterialIcon) ...[
                Icon(icon, size: iconSize, color: iconColor ?? Colors.blue),
                const SizedBox(height: 12),
              ],
              if (message != null) ...[
                Text(message, textAlign: TextAlign.center),
                if (hasContentBelowMessage) const SizedBox(height: 16),
              ],
              if (hasOtpCode) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    oneTimeCode,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                      letterSpacing: 4,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              if (input != null) ...[
                TextField(
                  controller: textController,
                  decoration: InputDecoration(
                    hintText: input.placeholder,
                    border: const OutlineInputBorder(),
                  ),
                  keyboardType: input.keyboardType,
                  obscureText: input.obscureText,
                  maxLength: input.maxLength,
                  autofocus: true,
                ),
              ],
            ],
          );
        }

        // Separate actions by type
        final normalActions = actions
            .where((a) => a.style != AlertActionStyle.cancel)
            .toList();
        final cancelAction = actions.firstWhere(
          (a) => a.style == AlertActionStyle.cancel,
          orElse: () => AlertAction(
            title: MaterialLocalizations.of(context).cancelButtonLabel,
            onPressed: () {},
            style: AlertActionStyle.cancel,
          ),
        );

        return AlertDialog(
          title: Text(title),
          content: contentWidget,
          // Material convention: dismissive action on the left, confirming
          // action on the right — so the cancel button comes first.
          actions: [
            if (actions.any((a) => a.style == AlertActionStyle.cancel))
              TextButton(
                onPressed: () {
                  // Cancel button always returns null for input dialogs
                  if (input != null) {
                    Navigator.of(context).pop<String?>(null);
                  } else {
                    Navigator.of(context).pop();
                  }
                  cancelAction.onPressed();
                },
                child: Text(cancelAction.title),
              ),
            ...normalActions.map((action) {
              Color? buttonColor;
              switch (action.style) {
                case AlertActionStyle.destructive:
                  buttonColor = Colors.red;
                  break;
                case AlertActionStyle.primary:
                  buttonColor = Theme.of(context).colorScheme.primary;
                  break;
                case AlertActionStyle.success:
                  buttonColor = Colors.green;
                  break;
                case AlertActionStyle.warning:
                  buttonColor = Colors.orange;
                  break;
                case AlertActionStyle.info:
                  buttonColor = Colors.blue;
                  break;
                default:
                  buttonColor = null;
              }

              return TextButton(
                onPressed: action.enabled
                    ? () {
                        if (input != null) {
                          // Input dialog - return the text
                          final text = textController.text.trim();
                          Navigator.of(
                            context,
                          ).pop<String?>(text.isNotEmpty ? text : null);
                        } else {
                          // Normal dialog - just close
                          Navigator.of(context).pop();
                        }
                        action.onPressed();
                      }
                    : null,
                style: buttonColor != null
                    ? TextButton.styleFrom(foregroundColor: buttonColor)
                    : null,
                child: Text(action.title),
              );
            }),
          ],
        );
      },
    );
  }
}

class _M3EInputAlertDialog extends StatefulWidget {
  const _M3EInputAlertDialog({
    required this.title,
    required this.message,
    required this.actions,
    required this.input,
    required this.icon,
    required this.iconSize,
    required this.iconColor,
  });

  final String title;
  final String? message;
  final List<AlertAction> actions;
  final AdaptiveAlertDialogInput input;
  final dynamic icon;
  final double? iconSize;
  final Color? iconColor;

  @override
  State<_M3EInputAlertDialog> createState() => _M3EInputAlertDialogState();
}

class _M3EInputAlertDialogState extends State<_M3EInputAlertDialog> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.input.initialValue,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return m3e.M3EDialog(
      title: widget.title,
      icon: widget.icon is IconData
          ? Icon(
              widget.icon as IconData,
              size: widget.iconSize,
              color: widget.iconColor,
            )
          : null,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.message != null) ...[
            Text(widget.message!),
            const SizedBox(height: 16),
          ],
          m3e.M3ETextField(
            controller: _controller,
            label: widget.input.placeholder,
            keyboardType: widget.input.keyboardType,
            obscureText: widget.input.obscureText,
            maxLines: 1,
          ),
        ],
      ),
      actions: [
        for (final action in widget.actions)
          m3e.M3EButton(
            onPressed: () {
              final value = action.style == AlertActionStyle.cancel
                  ? null
                  : _controller.text.trim();
              Navigator.of(
                context,
              ).pop<String>(value == null || value.isEmpty ? null : value);
              action.onPressed();
            },
            enabled:
                action.enabled && action.style != AlertActionStyle.disabled,
            style: action.style == AlertActionStyle.primary
                ? m3e.M3EButtonStyle.filled
                : m3e.M3EButtonStyle.text,
            decoration: _m3eActionForeground(action.style, context),
            child: Text(action.title),
          ),
      ],
    );
  }
}

m3e.M3EButtonDecoration? _m3eActionForeground(
  AlertActionStyle style,
  BuildContext context,
) {
  final theme = m3e.M3ETheme.of(context);
  final color = switch (style) {
    AlertActionStyle.destructive => theme.colorScheme.error,
    AlertActionStyle.success => Colors.green,
    AlertActionStyle.warning => Colors.orange,
    AlertActionStyle.info => Colors.blue,
    _ => null,
  };
  return color == null
      ? null
      : m3e.M3EButtonDecoration.styleFrom(foregroundColor: color);
}
