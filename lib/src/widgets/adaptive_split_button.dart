import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../platform/platform_info.dart';
import 'android/android_m3e_native_icon.dart';
import 'android/android_m3e_platform_view.dart';

enum AdaptiveSplitButtonStyle { filled, tonal, outlined, elevated }

/// Recommended native Material 3 Expressive split-button sizes.
enum AdaptiveSplitButtonSize {
  extraSmall(32, 48),
  small(40, 48),
  medium(56, 56),
  large(96, 96),
  extraLarge(136, 136);

  const AdaptiveSplitButtonSize(
    this.containerHeight,
    this.minimumTouchTargetHeight,
  );

  /// Visual container height in logical pixels on Android.
  final double containerHeight;

  /// Minimum host height needed to retain the native 48 dp touch target.
  final double minimumTouchTargetHeight;
}

/// Serializable action option for an adaptive split button.
class AdaptiveSplitButtonItem<T> {
  const AdaptiveSplitButtonItem({
    required this.value,
    required this.label,
    this.nativeIcon,
    this.enabled = true,
  });

  final T value;
  final String label;
  final AndroidM3EIcon? nativeIcon;
  final bool enabled;
}

/// Split action button backed by the native Compose split button on Android.
class AdaptiveSplitButton<T> extends StatelessWidget {
  const AdaptiveSplitButton({
    super.key,
    required this.items,
    required this.label,
    required this.onPressed,
    this.leadingIcon,
    this.nativeLeadingIcon,
    this.onSelected,
    this.selectedValue,
    this.enabled = true,
    this.size = AdaptiveSplitButtonSize.small,
    this.style = AdaptiveSplitButtonStyle.filled,
    this.menuButtonSemanticLabel,
  });

  final List<AdaptiveSplitButtonItem<T>> items;
  final String label;
  final VoidCallback? onPressed;
  final IconData? leadingIcon;
  final AndroidM3EIcon? nativeLeadingIcon;
  final ValueChanged<T>? onSelected;
  final T? selectedValue;
  final bool enabled;
  final AdaptiveSplitButtonSize size;
  final AdaptiveSplitButtonStyle style;

  /// Accessible name for the trailing menu button, localized by the caller.
  /// The native toggle semantics announce whether the menu is expanded.
  final String? menuButtonSemanticLabel;

  @override
  Widget build(BuildContext context) {
    if (PlatformInfo.isAndroid) {
      final leadingIconName = leadingIcon == null && nativeLeadingIcon == null
          ? null
          : resolveAndroidM3EIcon(
              child: leadingIcon == null ? null : Icon(leadingIcon),
              nativeIcon: nativeLeadingIcon,
              parameterName: 'nativeLeadingIcon',
            );
      return AndroidM3EPlatformView(
        component: 'splitButton',
        height: size.minimumTouchTargetHeight,
        properties: {
          'label': label,
          'menuButtonSemanticLabel': menuButtonSemanticLabel,
          'leadingIcon': leadingIconName,
          'enabled': enabled && (onPressed != null || onSelected != null),
          'primaryEnabled': enabled && onPressed != null,
          'style': style.name,
          'size': size.name,
          'selectedIndex': items.indexWhere(
            (item) => item.value == selectedValue,
          ),
          'items': [
            for (final item in items)
              {
                'label': item.label,
                'icon': item.nativeIcon?.name,
                'enabled': item.enabled,
              },
          ],
        },
        onEvent: (event, value) {
          if (event == 'primaryPressed') onPressed?.call();
          if (event == 'selected' &&
              value is int &&
              value >= 0 &&
              value < items.length) {
            onSelected?.call(items[value].value);
          }
        },
      );
    }

    final primaryButton = PlatformInfo.isIOS
        ? CupertinoButton.filled(
            onPressed: enabled ? onPressed : null,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (leadingIcon != null) ...[
                  Icon(leadingIcon!),
                  const SizedBox(width: 8),
                ],
                Text(label),
              ],
            ),
          )
        : leadingIcon == null
        ? FilledButton.tonal(
            onPressed: enabled ? onPressed : null,
            child: Text(label),
          )
        : FilledButton.tonalIcon(
            onPressed: enabled ? onPressed : null,
            icon: Icon(leadingIcon!),
            label: Text(label),
          );
    if (PlatformInfo.isIOS) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          primaryButton,
          CupertinoButton(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            onPressed: enabled ? () => _showIOSMenu(context) : null,
            child: const Icon(CupertinoIcons.chevron_down),
          ),
        ],
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        primaryButton,
        PopupMenuButton<int>(
          enabled: enabled,
          initialValue: items.indexWhere((item) => item.value == selectedValue),
          tooltip: 'More options',
          onSelected: (index) => onSelected?.call(items[index].value),
          itemBuilder: (context) => [
            for (var index = 0; index < items.length; index++)
              PopupMenuItem<int>(
                value: index,
                enabled: items[index].enabled,
                child: Text(items[index].label),
              ),
          ],
          icon: const Icon(Icons.arrow_drop_down),
        ),
      ],
    );
  }

  Future<void> _showIOSMenu(BuildContext context) async {
    await showCupertinoModalPopup<void>(
      context: context,
      builder: (context) => CupertinoActionSheet(
        actions: [
          for (final item in items)
            CupertinoActionSheetAction(
              isDefaultAction: item.value == selectedValue,
              onPressed: item.enabled
                  ? () {
                      Navigator.of(context).pop();
                      onSelected?.call(item.value);
                    }
                  : () {},
              child: Text(item.label),
            ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ),
    );
  }
}
